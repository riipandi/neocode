# Agent Instructions

## Code

- Comments are short and rare. Write one only for what the code cannot say (a why, a contract, a trap), in plain words, with no filler. Never restate the code, and never mention a decision, plan, issue, audit, session, or another file in a code comment.

## Git

- Stage explicit paths. Check `git status`. Never `git add -A` or `git add .`.
- Message: `{feat,fix,docs,refactor,chore}[(scope)]: <concise message>`. Do not push.
- Do not commit unless this turn asked for it. When the work is finished, recommend the one-line message and list the paths.
- Never run `git reset --hard`, `git checkout .`, `git clean -fd`, `git stash`, `git commit --no-verify`, or `git push --force`.
