import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch


SCRIPT = Path(__file__).resolve().parents[1] / "dot_config/herdr/hooks/summary.py"
spec = importlib.util.spec_from_file_location("summary", SCRIPT)
summary = importlib.util.module_from_spec(spec)
spec.loader.exec_module(summary)


class SummaryTests(unittest.TestCase):
    def invoke(self, payload, backend="codex", environment=None):
        env = {
            "HERDR_ENV": "1", "HERDR_PANE_ID": "w1:p2",
            "HERDR_SOCKET_PATH": "/tmp/herdr-test.sock",
        }
        if environment is not None:
            env = environment
        with patch.dict(os.environ, env, clear=True), patch.object(sys, "argv", [str(SCRIPT), backend]), patch.object(sys, "stdin", io.StringIO(json.dumps(payload))), patch.object(summary, "log_event"), patch.object(summary, "resolve_pane_id", return_value=env.get("HERDR_PANE_ID")):
            return summary.main()

    def test_prompt_reports_a_title_to_its_own_pane(self):
        with patch.object(summary, "report") as report, patch.object(summary, "generate_title", return_value="認証エラーの調査") as generate:
            self.assertEqual(self.invoke({"hook_event_name": "UserPromptSubmit", "prompt": "認証エラーを調べて"}), 0)
        self.assertEqual(generate.call_count, 1)
        clear, update = report.call_args_list
        self.assertEqual(clear.args[0], "w1:p2")
        self.assertEqual(update.args, ("w1:p2", clear.args[1] + 1, "認証エラーの調査"))

    def test_no_work_outside_herdr_or_for_subagents(self):
        with patch.object(summary, "report") as report, patch.object(summary, "generate_title") as generate:
            self.invoke({"hook_event_name": "UserPromptSubmit", "prompt": "test"}, environment={})
            self.invoke({"hook_event_name": "UserPromptSubmit", "prompt": "test", "agent_id": "child"})
        report.assert_not_called()
        generate.assert_not_called()

    def test_session_lifecycle_clears_without_llm_calls(self):
        with patch.object(summary, "report") as report, patch.object(summary, "generate_title") as generate:
            self.invoke({"hook_event_name": "SessionStart", "source": "startup"})
            self.invoke({"hook_event_name": "SessionEnd"})
            self.invoke({"hook_event_name": "SessionStart", "source": "compact"})
        self.assertEqual(report.call_count, 2)
        generate.assert_not_called()

    def test_failures_do_not_block_the_agent(self):
        for error in (FileNotFoundError(), subprocess.TimeoutExpired("codex", 45), subprocess.CalledProcessError(1, "codex")):
            with self.subTest(error=type(error).__name__), patch.object(summary, "report"), patch.object(summary, "generate_title", side_effect=error), patch.object(sys, "stderr", io.StringIO()):
                self.assertEqual(self.invoke({"hook_event_name": "UserPromptSubmit", "prompt": "test"}), 0)

    def test_unavailable_server_skips_the_llm(self):
        with patch.object(summary, "report", side_effect=FileNotFoundError()), patch.object(summary, "generate_title") as generate, patch.object(sys, "stderr", io.StringIO()):
            self.assertEqual(self.invoke({"hook_event_name": "UserPromptSubmit", "prompt": "test"}), 0)
        generate.assert_not_called()

    def test_ignores_invalid_or_irrelevant_payloads(self):
        with patch.object(summary, "report") as report:
            for payload in ([], None, {"hook_event_name": "Stop"}, {"hook_event_name": "UserPromptSubmit", "prompt": " "}):
                self.invoke(payload)
        report.assert_not_called()

    def test_history_excludes_tools_system_messages_and_subagents(self):
        cases = {
            "codex": [
                {"type": "event_msg", "payload": {"type": "user_message", "message": "認証の調査"}},
                {"type": "response_item", "payload": {"role": "user", "content": "system context"}},
                {"type": "event_msg", "payload": {"type": "agent_message", "message": "tool context"}},
            ],
            "claude": [
                {"type": "user", "message": {"content": [{"type": "text", "text": "認証の調査"}]}},
                {"type": "user", "isSidechain": True, "message": {"content": "subagent task"}},
                {"type": "user", "message": {"content": [{"type": "tool_result", "content": "tool context"}]}},
                {"type": "user", "isMeta": True, "message": {"content": "system context"}},
            ],
        }
        for backend, entries in cases.items():
            with self.subTest(backend=backend), tempfile.TemporaryDirectory() as directory:
                transcript = Path(directory) / "session.jsonl"
                transcript.write_text("invalid\n" + "\n".join(json.dumps(entry) for entry in entries))
                payload = {"transcript_path": str(transcript), "prompt": "それで進めて"}
                self.assertEqual(summary.request_history(payload, backend), ["認証の調査", "それで進めて"])

    def test_large_requests_are_bounded_and_missing_history_is_optional(self):
        requests = summary.request_history({"transcript_path": "/nonexistent", "prompt": "あ" * 5000}, "codex")
        self.assertLessEqual(sum(map(len, requests)), summary.MAX_INPUT)

    def test_title_has_no_controls_and_fits_a_japanese_sidebar(self):
        self.assertEqual(summary.normalize_title('\n「認証エラーの調査」\x00\n説明'), "認証エラーの調査")
        self.assertEqual(summary.normalize_title("あ" * 30), "あ" * 19)
        self.assertEqual(summary.normalize_title("\n\x00"), "")

    def test_summary_wraps_into_two_lines_without_losing_text(self):
        for title in ("日本語要約hookの動作確認", "あ" * 20, "短い要約", "a" + "あ" * 19):
            first, second = summary.split_title(title)
            self.assertEqual(first + second, title)
            for line in (first, second):
                self.assertLessEqual(sum(2 if summary.unicodedata.east_asian_width(c) in "WF" else 1 for c in line), summary.LINE_WIDTH)

    def test_stale_pane_id_resolves_from_calling_process_not_focus(self):
        missing = subprocess.CalledProcessError(1, "herdr", stderr='{"error":{"code":"pane_not_found"}}')
        replies = [
            missing,
            {"agents": [{"agent": "codex", "pane_id": "w2:p1"}, {"agent": "codex", "pane_id": "w2:p2"}]},
            {"process_info": {"foreground_processes": [{"pid": 200, "argv": ["codex"]}]}},
            {"process_info": {"foreground_processes": [{"pid": 999, "argv": ["codex"]}]}},
        ]
        with patch.dict(os.environ, {"HERDR_PANE_ID": "old:p1"}), patch.object(os, "getpid", return_value=300), patch.object(summary, "herdr_json", side_effect=replies), patch.object(subprocess, "run", return_value=subprocess.CompletedProcess("ps", 0, stdout="300 200\n200 1\n1 0\n999 1\n")), patch.object(summary, "log_event"):
            self.assertEqual(summary.resolve_pane_id({}, "codex"), "w2:p1")

    def test_stale_pane_id_never_falls_back_to_an_unrelated_agent(self):
        missing = subprocess.CalledProcessError(1, "herdr", stderr='{"error":{"code":"pane_not_found"}}')
        replies = [missing, {"agents": [{"agent": "codex", "pane_id": "w2:p1"}]}, {"process_info": {"foreground_processes": [{"pid": 999, "argv": ["codex"]}]}}]
        with patch.dict(os.environ, {"HERDR_PANE_ID": "old:p1"}), patch.object(os, "getpid", return_value=300), patch.object(summary, "herdr_json", side_effect=replies), patch.object(subprocess, "run", return_value=subprocess.CompletedProcess("ps", 0, stdout="300 1\n1 0\n999 1\n")):
            with self.assertRaises(ValueError):
                summary.resolve_pane_id({}, "codex")

    def test_generators_keep_auth_but_disable_recursive_hooks_and_tools(self):
        for backend in ("codex", "claude"):
            def run(command, **kwargs):
                self.assertNotIn("HERDR_ENV", kwargs["env"])
                self.assertNotIn("CLAUDECODE", kwargs["env"])
                self.assertEqual(kwargs["env"]["CODEX_HOME"], "/tmp/existing-codex-home")
                self.assertLessEqual(kwargs["timeout"], 45)
                self.assertEqual(command[:2], ["codex", "exec"])
                self.assertIn("--ignore-user-config", command)
                self.assertIn("hooks", command)
                self.assertIn("shell_tool", command)
                Path(command[command.index("--output-last-message") + 1]).write_text("認証の調査")
                return subprocess.CompletedProcess(command, 0, stdout="認証の調査")

            with self.subTest(backend=backend), patch.dict(os.environ, {"HERDR_ENV": "1", "CLAUDECODE": "1", "CODEX_HOME": "/tmp/existing-codex-home"}), patch.object(subprocess, "run", side_effect=run):
                self.assertEqual(summary.generate_title({"prompt": "認証を調べて"}, backend), "認証の調査")


if __name__ == "__main__":
    unittest.main()
