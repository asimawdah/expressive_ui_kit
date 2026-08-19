# Agent notes

This repo is the Flutter package `material3_expressive`. Public widgets use the **`ME` prefix** (not `M3E`).

When writing or refactoring UI, **load and follow** `.cursor/skills/material3-expressive/SKILL.md`. It tells you which `ME*` widget to pick for a job, what not to use, and where the source/demos live.

Quick constraints:

- Wrap apps with `METheme` (`METhemeData.expressive` or `.standard`).
- `MEAppBar` is a sliver — not `Scaffold.appBar`.
- Prefer `MEMenu` over `PopupMenuButton`.
- Do not use deprecated `ExpressiveButton`.
- Confirm constructors in `lib/src/` before generating code.
