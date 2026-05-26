# Babel Extension Update Note

Context: the SCUBA project uses the `wmorellato.babel` VS Code extension.

Current findings:
- Installed locally: `wmorellato.babel` version `1.12.0`
- Marketplace latest: `2.0.0`
- VS Code version on this machine: `1.121.0`
- This does not appear to be blocked by the VS Code engine version.
- No newer local Babel extension folder or staged update artifact was found.

Important risk:
- Babel `2.0.0` is a major upgrade.
- The changelog indicates a migration from the older `babel.json` model to a `.babel/babel.db` SQLite model.
- Treat this as a migration, not a routine extension patch.

Recommended update path:
1. Close all VS Code windows that have the SCUBA project open.
2. Back up the SCUBA workspace, especially any `babel.json` or `.babel/` data.
3. Uninstall `wmorellato.babel` from VS Code.
4. Delete `C:\Users\jackd\.vscode\extensions\wmorellato.babel-1.12.0` if it remains after uninstall.
5. Reinstall `wmorellato.babel` from the marketplace.
6. Reopen SCUBA and allow Babel to run its v1 to v2 migration if prompted.

Extra notes:
- The issue does not look like the wrong extension anymore; it is the SCUBA Babel extension.
- The update gap looks more like a local extension install/update state problem than a marketplace or engine compatibility problem.