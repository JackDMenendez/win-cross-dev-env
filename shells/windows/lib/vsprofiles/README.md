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
