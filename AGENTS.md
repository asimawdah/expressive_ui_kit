# Agent notes

This repo is the Flutter package `material3_expressive`. Public widgets use the **`ME` prefix** (not `M3E`).

When writing or refactoring UI, **load and follow**
`.cursor/skills/material3-expressive/SKILL.md`. That skill is the picker:

1. Map the job to an `ME*` widget (`SKILL.md`).
2. If the job is not in the table, look up `.cursor/skills/material3-expressive/catalog.md`.
3. Copy a verified constructor from `.cursor/skills/material3-expressive/constructors.md`
   or read `lib/src/` — do not invent parameters.

Quick constraints:

- Wrap apps with `METheme` (`METhemeData.expressive` or `.standard`).
- `MEAppBar` is a sliver — not `Scaffold.appBar`.
- Prefer `MEMenu` over `PopupMenuButton`.
- Do not use deprecated `ExpressiveButton`.
- Confirm constructors in `lib/src/` before generating code.
