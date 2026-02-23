---
name: codex-review
description: Get a thorough code review from OpenAI Codex as a senior reviewer
disable-model-invocation: true
allowed-tools: Bash(codex *)
---

## Context

- Current branch: !`git branch --show-current`
- Base branch: !`git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null`
- Changes summary: !`git diff --stat $(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null)..HEAD 2>/dev/null`
- Uncommitted changes: !`git diff --stat HEAD`

## Your task

Send the code changes to Codex CLI for a thorough senior-level code review using its built-in `review` subcommand.

If there are branch changes (commits beyond main/master), run:

```
codex review --base "$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null)"
```

If there are no branch changes, fall back to reviewing uncommitted changes:

```
codex review --uncommitted
```

After Codex responds, present the review results to the user. Add your own perspective where you agree or disagree with Codex's assessment. Highlight any points where you and Codex see things differently.
