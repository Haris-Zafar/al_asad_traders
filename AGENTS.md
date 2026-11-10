# AGENTS.md

Flutter Android app for one wholesale owner: demands, buying lists, bills, buyer accounts. Cloud Firestore, works offline. You are one AI agent doing one task in one chat. Read this file fully, then follow it.

## Start of every chat
1. `PROGRESS.md`: what is done, what is blocked.
2. Your task in `TASKS.md`. The owner gives you its id (T-07). Read only that task, not the whole file.
3. The files in the task's `read:` line, and nothing else. For `wholesale_project.md`, read only the sections and stories the task names.
4. Check the task's `depends:` are listed as done in `PROGRESS.md`. If not, stop and tell the owner.
5. Say the plan in 5 lines or fewer, then start.

## Docs
| File | Owns |
|---|---|
| `wholesale_project.md` | Business rules and stories S1-S35 |
| `wholesale_erd_v9.mermaid`, `wholesale_relationships.md` | Fields and links |
| `STORY_DEPENDENCIES.md` | Which story needs which, build order |
| `docs/TECH_STACK.md` | Packages, permissions, how to add one |
| `docs/ARCHITECTURE.md` | Layers, folders, state, errors, code style |
| `docs/DATABASE.md` | Collections, batches, security rules, sync |
| `docs/UI_PLAN.md` | Plain words, screens, bill editor, states |
| `docs/DESIGN_SYSTEM.md` | Colors, text, sizes, shared widgets, theme |
| `docs/TESTING.md` | Test rules, must-have tests, manual check |
| `docs/GIT_WORKFLOW.md` | Branches, commits, PRs, CI, releases |
| `docs/DECISIONS.md` | Why big choices were made |
| `TASKS.md`, `PROGRESS.md` | The backlog and its status |

## Hard rules
- Do only your task's goal. Touch only the files in `touch:`. Need more? Say why and ask.
- Never hardcode colors, sizes or strings. Use the theme, `AppSizes`, `AppSpacing`, `strings.dart`.
- Keep the layers: UI never imports Firebase or repositories; rules are pure Dart; only repositories touch Firebase.
- Never `await` a Firestore write on the UI path. Multi-document changes are one batch.
- Money and quantities are `int`. No decimals.
- Do not add a package without asking. Do not add features, screens or abstractions the stories do not need.
- Do not weaken a security rule, skip a test or delete a failing test to get green. Fix the cause.
- If a doc contradicts the task or looks wrong, stop and ask. Do not edit docs outside your task. Do not rewrite business rules.
- UI text is plain English as in `docs/UI_PLAN.md`.
- Every public class and function gets a `///` comment with its rule and story.
- No secrets, keystores or `.env` in commits.
- Git: task branch only, never `main`, never force-push, never merge. Details in `docs/GIT_WORKFLOW.md`.
- Unsure? Ask one short question. Do not guess.

## Commands
```
flutter pub get
dart format .
flutter analyze
flutter test                        # everything
flutter test test/features/bills    # one feature
flutter run
tool/check_hardcoded.sh
cd rules_test && npm ci && firebase emulators:exec --only firestore "npm test"
```
`firebase deploy` is for the owner only.

## Definition of done
- `dart format .`, `flutter analyze` and `flutter test` are clean.
- The task's `done-when` is met and its `tests:` are written (see `docs/TESTING.md`).
- `tool/check_hardcoded.sh` passes. UI tasks were checked at 360x640 with text scale 1.0 and 1.8.
- The last commit updates `PROGRESS.md` and `CHANGELOG.md` (`Unreleased`, one line, user-visible words).
- Branch pushed. PR text written (task id, stories, what changed, how tested). You stop there.

## PROGRESS.md format
Keep it under 40 lines, one line per task.
```
# Progress
Updated: 2026-11-07
## Done
- T-01 Project setup (merged 2026-11-08, PR #1)
## Now
- T-02 Theme and shared widgets: in progress, feature/T-02-theme, next: StatusChip
## Blocked
- T-09: waiting for the owner on the currency label
## Notes for the next chat
- Facts the next task must know. 5 lines at most. Delete when no longer true.
```

## Saving tokens
- Read only what the task lists. Use grep or a line range, not whole files.
- Do not read a file again in the same chat. Do not paste whole files back.
- Edit in place with small changes. Do not rewrite a file to change a few lines.
- Cut command output: `| tail -20`. On a failing test, show the test name and the first error only.
- Do not explore the repo. The `touch:` list says where to work.
- Short answers. No restating the task, no praise, no long summaries: 5 lines at most.
- One task per chat. If the chat gets long or the task grows, stop, update `PROGRESS.md`, and start a new chat.
