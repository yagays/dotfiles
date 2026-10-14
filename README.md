# dotfiles

Managed by [chezmoi](https://www.chezmoi.io/).

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
