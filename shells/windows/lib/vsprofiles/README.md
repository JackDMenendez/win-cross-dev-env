# VS Code isolation profiles

Each `vscode-*.cmd` launcher runs VS Code as an **isolated instance** with its own
`--user-data-dir` (settings/state) and `--extensions-dir` (extension set), so a
window launched for one toolchain never inherits another's ambient PATH, and a
C++/Java/Haskell extension set never bleeds into an unrelated flavor.

## How a launcher selects its profile

Every launcher sets one variable before launching:

```bat
set "WCDE_VSCODE_PROFILE=ps"
```

Then [`tools\vscode-isolation.cmd`](../../tools/vscode-isolation.cmd) turns that label into:

| Dir | Location | Notes |
|-----|----------|-------|
| `--user-data-dir` | `<repo>\.vsisolation\<profile>\data` when a target repo is given; else `%USERPROFILE%\.vsisolation\<profile>\data` | small, per-repo, customizable; gitignored in-repo |
| `--extensions-dir` | `%USERPROFILE%\.vsisolation\<profile>\ext` (always) | installed once per profile, shared across every repo |

The helper appends `.vsisolation/` to a target repo's `.gitignore` automatically.

## Profile -> launcher map (defaults)

| Profile | Launchers | Manifest |
|---------|-----------|----------|
| `ps`      | vscode-ps, vscode-cmd            | `ps.txt` (seed from your full set) |
| `web`     | vscode-quarto                   | `web.txt` |
| `ucrt64`  | vscode-ucrt64                   | `ucrt64.txt` |
| `mingw64` | vscode-mingw64                  | `mingw64.txt` |
| `haskell` | vscode-haskell, vscode-ghcup    | `haskell.txt` |
| `agda`    | vscode-agda                     | `agda.txt` |
| `sage`    | vscode-sagemath                 | `sage.txt` |
| `tex`     | vscode-miktex                   | `tex.txt` |
| `python`  | vscode-python                   | `python.txt` |
| `exp-tex` | vscode-exp-tex                  | `exp-tex.txt` (python + LaTeX) |
| `drawio`  | vscode-drawio                   | `drawio.txt` (draw.io diagrams; inherits the lean toolset) |
| `write`   | vscode-write                    | `write.txt` (creative writing; Pandoc/Vale/Calibre, no interpreter) |
| `lean`    | vscode-lean                     | `lean.txt` (Lean 4 / Mathlib; LaTeX + graphviz) |

Every launcher must have a row here **and** a matching `<profile>.txt`. Nothing
enforces the pairing: `install_list` skips a missing manifest with a warning and
carries on, so an unpaired launcher provisions `common.txt` only and silently
loses its whole toolset on a fresh machine. `lean` was unpaired from `3066352`
until 2026-09-04 and is the reason this paragraph exists — re-check the pairing
whenever a `vscode-*.cmd` is added.

## Known state: the two draw.io builds

There are two draw.io engines on this machine and they are a major version apart:
the desktop app at `C:\Program Files\draw.io` (**31.3.1**) and the one bundled
inside `hediet.vscode-drawio` (**30.2.7**). `hediet.vscode-drawio.offline`
defaults to `true`, so the extension always uses its own bundled build and never
the desktop one. `extensions.autoUpdate` is `false` in `user-settings.json`
(deliberate), which freezes that skew rather than letting it drift.

This is known state, not a bug to fix. In particular, do **NOT** set
`hediet.vscode-drawio.offline` to `false` to "align" them: that routes diagram
content through `https://embed.diagrams.net/`, which is a network-egress and
privacy change, not a rendering fix.

The skew only shows up as differing colours when a `.drawio` file **omits**
colours, because each build then supplies its own defaults. The durable fix is
explicit `fillColor` / `strokeColor` / `fontColor` in the files, not an editor
setting. For committed figures the source of truth is the headless CLI —
`draw.io.exe --export --format png --scale 2 --crop` renders correctly in a few
seconds, MathJax included — not whichever editor happens to be open.

Version numbers above were measured against the **shared** extensions directory
(`%USERPROFILE%\.vscode\extensions`). The isolated profiles carry their own copy
(`hediet.vscode-drawio-1.9.0`), so re-measure per profile before treating these
exact numbers as applying to a launcher-started window.

## How the dedicated Claude Code learns its toolset

Each launcher exports `WCDE_VSCODE_PROFILE` into the environment `Code.exe`
inherits, so it reaches the extension host and every shell the Claude Code
extension spawns. A plain env var (unlike PATH) is not rewritten by shell login
profiles, so it is the reliable signal. A Claude session identifies its sandbox
with `echo %WCDE_VSCODE_PROFILE%` (cmd) or `$env:WCDE_VSCODE_PROFILE`
(PowerShell), then maps it via the profile table above.

Because the launcher's ambient PATH is also inherited, the profile's tools
resolve by bare name (e.g. `quarto` in `web`) - so a Claude session in a
launcher-spawned VS Code should call tools by name, not by hardcoded full paths.

## Extension manifests

`<profile>.txt` lists the profile's extra extension ids (one per line, `#`
comments allowed). On the **first** launch of a profile the helper installs
`common.txt` + `<profile>.txt` into that profile's ext dir, then writes a
`.wcde-provisioned` marker so later launches are instant.

- **`common.txt`** goes into every profile: Vim, GitLens, Claude Code, EditorConfig.
  (VS Code cannot live-share a partial extensions dir, so shared = re-installed.)
  - The Vim extension (`vscodevim.vim`) runs with **Neovim ex-command integration
    enabled** (`vim.enableNeovim` + `vim.neovimPath: "nvim"` in
    [`user-settings.json`](user-settings.json)). That needs a real `nvim` on PATH,
    so every `vscode-*.cmd` launcher adds `nvim` to its `requires` list, which runs
    [`cmd\env\nvim-env.cmd`](../../cmd/env/nvim-env.cmd) to prepend the canonical
    native Neovim (`C:\tools\neovim`). Classic Vim has a parallel
    [`vim-env.cmd`](../../cmd/env/vim-env.cmd) for shells that want `vim`/`gvim`.
- **Claude Code** rides in `common.txt`, so it is present in every profile; its
  state lives in `%USERPROFILE%\.claude` and is shared regardless of profile.

### Seeding the heavy `ps` profile

`ps.txt` is meant to carry your whole working set. Bootstrap it from your current
default VS Code install:

```bat
tools\seed-profile.cmd ps
```

## Re-provisioning

Delete `%USERPROFILE%\.vsisolation\<profile>\ext\.wcde-provisioned` (or the whole
`ext` dir) and relaunch to reinstall from the manifests.
