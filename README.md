# STATIONEERS

Stationeers IC10 scripts and logic reference files.

## IC10 Logic Database

The `logic-db/` folder contains a Codex-oriented Stationeers IC10 logic database generated from Stationeers wiki/reference material verified on 2026-05-06.

Files:

- `stationeers_ic10_codex_db.json` - full IC10 logic database.
- `stationeers_ic10_codex_chunks.jsonl` - smaller retrieval chunks for prompts and script generation.
- `manifest.codex.json` - database metadata and file counts.
- `build_stationeers_logic_db.ps1` - script used to rebuild the database.

## Markup Language

The `markup-language/` folder contains editor support files for working with Stationeers IC10 scripts.

The `markup-language/Notepad++/` folder contains a Notepad++ user-defined language file named `userDefineLang.xml`. It adds IC10 syntax highlighting for `.ic10` files in Notepad++.

The `markup-language/TextMate/` folder contains `ic10.tmLanguage.json`, a TextMate grammar adapted from the Notepad++ language file and the IC10 logic database.

GitHub syntax highlighting for `.ic10` files is limited by GitHub Linguist. This repo maps IC10 scripts to GitHub's closest built-in `Assembly` highlighter through `.gitattributes`, but exact IC10 highlighting would require IC10 support to be added upstream to GitHub Linguist.

See `markup-language/Notepad++/README.md` for the Windows install path and setup notes.
