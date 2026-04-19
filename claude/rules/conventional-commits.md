When writing git commit messages, always follow the Conventional Commits specification:
- Format: <type>[optional scope]: <description>
- Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
- Example: feat(auth): add OAuth2 login support
- Breaking changes: append `!` after the type or add `BREAKING CHANGE:` in the footer
- Keep the subject line under 72 characters
- Use imperative mood in the description ("add" not "added")
