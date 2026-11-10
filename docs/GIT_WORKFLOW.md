# Git Workflow

Backlog is `../TASKS.md` (ids T-01...). Test commands: `TESTING.md`. Design rule check: `DESIGN_SYSTEM.md`. Agent entry point: `../AGENTS.md`.

## Branches
- `main` is protected: pull request only, CI must pass, no force push, no direct commits.
- One branch per task, from an up-to-date `main`: `feature/T-07-bill-editor`. Other prefixes: `fix/`, `docs/`, `chore/`.
- Short-lived: one task, one branch. Delete after merge.

## Commits
Conventional Commits: `type(scope): subject (T-07)`.
- Types: `feat`, `fix`, `test`, `refactor`, `docs`, `chore`, `ci`, `build`, `perf`. Scope = feature folder or area (`bills`, `ledger`, `rules`, `theme`).
- Subject: imperative, at most 72 characters, no full stop. Add a body only to explain why. Breaking change: `!` after the scope.
- Example: `feat(bills): autosave draft bill items (T-07)`.
- Small commits, one logical change each. Every commit passes `flutter analyze` and `flutter test`. Tests go in the same commit as the code they cover, or the one before.
- Tidy your own unpushed commits with `git rebase -i` before the PR. After pushing a task branch, only `--force-with-lease` on that branch.

## Pull requests
- Title: `T-07: Bill editor`. Opened as soon as the branch is ready; template fields: task id and stories, what changed (5 lines at most), how it was tested, docs updated, checklist.
- Checklist: analyze and tests pass; tests added; `PROGRESS.md` and `CHANGELOG.md` updated; no package added without approval; no secrets in the diff.
- Review your own diff first. Merge with a merge commit only (squash and rebase merges are switched off). The branch is deleted on merge. Then `git switch main && git pull`.

## CI (`.github/workflows/ci.yml`)
- Runs on pull requests and pushes to `main`. Both jobs are required checks. No secrets are used.
- Job `app`: checkout, Flutter stable with cache, `flutter pub get`, `flutter analyze`, `flutter test`, `tool/check_hardcoded.sh`.
- Job `rules`: Node with cache, then the rules-test commands from `TESTING.md`.
- `tool/check_hardcoded.sh` fails if `lib/` outside `lib/core/theme/` and `lib/core/strings.dart` contains `Color(0x`, `Colors.`, `fontSize:`, `EdgeInsets` with a number, or `Text('`.
- Actions are pinned to a major version. Timeout 15 minutes per job.

## Releases
- Milestone tags at the end of each phase of `TASKS.md`: annotated, `v0.2.0` style. `v0.x` until the owner uses the app daily; `v1.0.0` when the owner accepts it.
- Steps: `CHANGELOG.md` turns `Unreleased` into the version (Keep a Changelog format) in a `docs(release)` commit; set `version: 0.2.0+2` in `pubspec.yaml`; CI green on `main`; `git tag -a v0.2.0 -m "Phase 2: billing"`; `git push --tags`.
- Build: `flutter build apk --release --obfuscate --split-debug-info=build/symbols`, signed with the release keystore. Attach the APK to a GitHub Release. Keep `build/symbols` for stack traces; do not commit it.
- Deploy `firestore.rules` (`firebase deploy --only firestore:rules`) before shipping an APK that needs them.
- The keystore, `key.properties` and its passwords are never committed. Keep an offline copy: without it an installed app cannot be updated.

## Repo setup (once, by the owner)
1. Create the GitHub repo. Public is fine for a portfolio: no secrets are committed (`TECH_STACK.md`). No customer or business data in the repo.
2. First commit on `main`: `chore: initial Flutter project`, with `.gitignore` (Flutter defaults plus `key.properties`, `*.jks`, `.env`, `build/`, `rules_test/node_modules/`), `README.md` (what it is, setup, run, test), the `docs/` folder, `AGENTS.md`, `CHANGELOG.md`.
3. Add CI (task T-01). After its first run, switch on branch protection for `main`: require a pull request, require both checks, block force pushes.
4. Settings: allow merge commits only, delete head branches automatically.
5. Set `user.name` and `user.email` locally. No issues or project board: `TASKS.md` is the backlog.

## Rules for the AI agent
- Work only on the task's branch. Start with `git switch main && git pull && git switch -c feature/T-xx-name`. Never commit or push to `main`.
- Before each commit run `git status` and `git diff --staged`. Check there are no keystores, `.env`, keys or build output.
- Run `flutter analyze` before every commit and `flutter test` before pushing.
- Commit in small steps using the format above. The last commit of a task updates `PROGRESS.md` and `CHANGELOG.md`.
- Never run `push --force`, `reset --hard`, `clean -fd`, or delete branches or tags. Never rebase onto `main` or change history that is pushed, unless the owner asks.
- Never merge a pull request. Prepare the PR text from the template and stop.
- Touch only the files in the task's `touch` list. If more is needed, say why and ask.
- Ask before: adding a package, editing the workflow or GitHub settings, resolving a merge conflict, or starting work outside the task.
- If the task grows, stop and propose a new task instead of widening this one.
