# dotfiles

Managed by [chezmoi](https://www.chezmoi.io/).

## Herdr agent summaries

Claude Code and Codex `UserPromptSubmit` hooks generate a Japanese task title
in the background and report it to Herdr's Agent sidebar. The title wraps into
two 20-column rows via `$summary_line1` and `$summary_line2`; `$summary` retains
the complete title for other consumers. An unused second row disappears.
The shared script is `~/.config/herdr/hooks/summary.py` and needs only Python's
standard library. This is a title for the latest request, updated per prompt;
it does not track individual tool calls or infer live progress. Tab names stay
unchanged. Outside Herdr and in subagents, the hook does nothing.

Both agents use `codex exec` with `gpt-6-luna` and the existing Codex login
for summarization. No additional API key or Claude login is required.
Each submitted prompt makes one additional LLM call against the Codex account
and its usage limits. Override the model with `HERDR_SUMMARY_MODEL` in the
environment where you start the agent.
Only the latest three human requests (up to 2,000 characters total) are used.
Tools, customizations, persistent sessions, and recursive hooks are disabled
for title generation. Failures leave the summary empty and do not block work.

New requests and session boundaries clear the old summary. Out-of-order
completions are ignored via Herdr metadata sequences; reported titles also
expire after 24 hours as a fallback.
Hook diagnostics are appended to `~/.cache/herdr/summary.log`; they contain
event names, pane IDs, and outcomes, without request text or credentials.
If a resumed CLI passes a stale pane ID, the hook identifies its own pane from
process ancestry or a unique matching session argument, never from UI focus.

Apply the integration with:

```sh
chezmoi apply ~/.config/herdr ~/.codex/hooks.json ~/.claude/settings.json
```

Restart the agent sessions afterward. Codex requires reviewing and trusting
the new hook definitions through `/hooks` before it runs them. Existing Herdr
session hooks and other local settings are preserved. Claude settings are now
modified in place; `.chezmoitemplates/claude-settings.json.tmpl` supplies initial
defaults only when no local settings exist.

Run the offline checks with:

```sh
python3 -B -m unittest discover -s tests -v
```

Inspired by [sh1ma/herdr-auto-title](https://github.com/sh1ma/herdr-auto-title).

## Installation

```sh
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply yagays
```

## Usage

### Apply dotfiles

```sh
chezmoi apply
```

### Edit a dotfile

```sh
chezmoi edit ~/.zshrc
```

### Update from remote repository

```sh
chezmoi update
```

### Add a new dotfile

```sh
chezmoi add ~/.config/xxx
```

### List managed files

```sh
chezmoi managed
```

## Codex Playwright settings

`dot_codex/modify_private_config.toml` uses a [chezmoi modify template](https://www.chezmoi.io/user-guide/manage-different-types-of-file/#manage-part-but-not-all-of-a-file) to set `mcp_servers.playwright.default_tools_approval_mode = "approve"` while preserving other local Codex settings. If Playwright MCP is not configured yet, it also adds `npx @playwright/mcp@latest` as the server command.

Apply only this setting with:

```sh
chezmoi apply ~/.codex/config.toml
```

When all managed settings already match, the local file is preserved byte-for-byte. When an update is needed, TOML serialization may normalize formatting and remove comments.


## Codex automatic approvals

The same modify template also sets `approval_policy = "on-request"` and
`approvals_reviewer = "auto_review"` globally. Eligible approval requests go to
Codex's automatic reviewer, with the existing sandbox and network boundaries
preserved. `approval_policy = "never"` is not used: that setting suppresses
prompts without granting blocked operations permission to run.

`.chezmoitemplates/codex-auto-review.md` owns the additional policy rendered into
`auto_review.extra_policy`. It records standing authorization for task-scoped
reads, monitoring, local validation and development, and bounded API trials.
It supplements the built-in review policy; it does not replace `auto_review.policy`.
`dot_codex/AGENTS.md` also tells the working agent not to ask conversationally
for the same permission again. Unrelated local settings and existing command
rules remain intact, including the Playwright configuration above.

Apply both managed settings with:

```sh
chezmoi apply ~/.codex/config.toml ~/.codex/AGENTS.md
```

Start a new Codex session after applying. Existing sessions, CLI overrides,
project configuration, and managed organization policies may override the global
default. In the desktop app, check that the chat's permissions mode is
**Approve for me**. Automatic review can still deny an action; Computer Use app
permissions and interactive authentication can still require human input.

The configuration was checked with Codex CLI 0.162.1. See the official
[Auto-review documentation](https://learn.chatgpt.com/docs/sandboxing/auto-review)
and [configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference).
