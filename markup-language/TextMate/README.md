# IC10 TextMate Grammar

This folder contains `ic10.tmLanguage.json`, a TextMate grammar for Stationeers IC10 scripts.

It was adapted from `markup-language/Notepad++/userDefineLang.xml` and refreshed with the repo's IC10 logic database so current instructions like `lbn`, `ld`, `sbn`, and batch modes are included.

## GitHub Note

GitHub uses Linguist for syntax highlighting. A repository can use `.gitattributes` to map files to a language that GitHub already supports, but GitHub does not load custom TextMate grammars directly from a normal repository.

Because IC10 is not currently a built-in GitHub Linguist language, this repo maps `.ic10` files to GitHub's closest built-in `Assembly` highlighter. For exact IC10 highlighting on GitHub.com, IC10 would need to be added upstream to GitHub Linguist with a grammar like `ic10.tmLanguage.json`.

## What This File Is For

- TextMate-compatible editors and tools.
- Future VS Code syntax extension work.
- A starting point for a GitHub Linguist contribution.

