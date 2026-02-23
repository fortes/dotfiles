---
name: gemini-review
description: Get a thorough code review from Gemini as a senior reviewer
disable-model-invocation: true
allowed-tools: Bash(gemini *)
---

## Context

- Current branch: !`git branch --show-current`
- Base branch: !`git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null`
- Changes summary: !`git diff --stat $(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null)..HEAD 2>/dev/null`
- Uncommitted changes: !`git diff --stat HEAD`

## Your task

Send the code changes to Gemini CLI for a thorough senior-level code review.

If there are branch changes (commits beyond main/master), run:

```
git diff $(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null)..HEAD 2>/dev/null | gemini -p "You are a senior staff engineer performing a thorough code review. Review the following diff carefully and provide:

1. **Critical Issues**: Bugs, security vulnerabilities, data loss risks, race conditions
2. **Logic Errors**: Incorrect assumptions, edge cases, off-by-one errors, null/undefined handling
3. **Design Concerns**: Architectural problems, tight coupling, violations of SOLID principles, missing abstractions
4. **Performance**: N+1 queries, unnecessary allocations, missing indexes, algorithmic complexity issues
5. **Maintainability**: Unclear naming, missing error handling, code that will confuse future developers
6. **What's Good**: Acknowledge well-written code and smart decisions

Be specific — reference line numbers and code snippets. Prioritize issues by severity. Skip nitpicks about style/formatting. If the diff is clean, say so — don't invent problems."
```

If there are no branch changes, fall back to reviewing uncommitted changes:

```
git diff HEAD | gemini -p "You are a senior staff engineer performing a thorough code review. Review the following diff carefully and provide:

1. **Critical Issues**: Bugs, security vulnerabilities, data loss risks, race conditions
2. **Logic Errors**: Incorrect assumptions, edge cases, off-by-one errors, null/undefined handling
3. **Design Concerns**: Architectural problems, tight coupling, violations of SOLID principles, missing abstractions
4. **Performance**: N+1 queries, unnecessary allocations, missing indexes, algorithmic complexity issues
5. **Maintainability**: Unclear naming, missing error handling, code that will confuse future developers
6. **What's Good**: Acknowledge well-written code and smart decisions

Be specific — reference line numbers and code snippets. Prioritize issues by severity. Skip nitpicks about style/formatting. If the diff is clean, say so — don't invent problems."
```

After Gemini responds, present the review results to the user. Add your own perspective where you agree or disagree with Gemini's assessment. Highlight any points where you and Gemini see things differently.
