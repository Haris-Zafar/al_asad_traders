# Design System

One light, high-contrast theme. Screens and flows: `UI_PLAN.md`. Folders: `ARCHITECTURE.md`. Widget and size tests: `TESTING.md`.

**Rule: never hardcode colors, sizes or strings.** Colors come from the theme, sizes and spacing from `AppSizes` and `AppSpacing`, text from `strings.dart`. Hardcoded values are allowed only inside `core/theme/` and `core/strings.dart`. A CI check enforces it (`GIT_WORKFLOW.md`).

## Colors
Ratios are WCAG contrast. Body text must be at least 7:1, other text 4.5:1, borders and icons 3:1.

| Token | Hex | Used for | On | Ratio |
|---|---|---|---|---|
| background | #FFFFFF | Screens | onSurface #1A1A1A | 17.4 |
| surface | #F4F6F9 | Cards, sheets | onSurface | 16.1 |
| onSurface | #1A1A1A | Text | - | - |
| onSurfaceMuted | #4A4A4A | Captions, hints | background | 8.9 |
| border | #6B7280 | Field and card borders | background | 4.8 |
| primary | #1F4E8C | Buttons, app bar, links | white text | 8.3 |
| accent | #B45309 | Highlight, Put on account button | white text | 5.0 |
| error | #B3261E | Error text, danger button | background | 6.5 |
| errorContainer | #FBE4E2 | Error panel, text #8C1D18 | - | 7.5 |
| success | #14532D | Paid, Synced | background | 9.1 |

Status chips (text and icon, never color alone):

| Chip | Background | Text | Ratio |
|---|---|---|---|
| Draft | #E5E7EB | #1A1A1A | 14.1 |
| Finished | #DCE6F4 | #1F4E8C | 6.6 |
| Paid | #D8EFE0 | #14532D | 7.5 |
| On account | #FDE9D0 | #7C3A06 | 7.2 |

Accent is for fills with white text or large text. Do not use it for small text on grey.

## Text styles
System font (Roboto). Sizes are sp at scale 1.0. Line height 1.4. Nothing below 16.

| Style | Size | Weight | Used for |
|---|---|---|---|
| amount | 28 | bold | Totals, balance |
| title | 24 | bold | Screen titles |
| section | 20 | bold | Section headers |
| body | 18 | regular | Default text |
| bodyStrong | 18 | bold | Item and person names, buttons |
| caption | 16 | regular | Hints, dates, secondary lines |

Text size setting: Normal 1.0, Large 1.2, Extra large 1.4, multiplied by the phone's font scale and clamped to 2.0.

## Spacing and sizes
| Token | dp | Used for |
|---|---|---|
| space.xs / s / m / l / xl | 4 / 8 / 16 / 24 / 32 | Gaps. Screen padding is m, row gap s |
| touchTarget | 56 | Minimum height and width of anything tappable |
| buttonHeight | 56 | Buttons, fields, bottom bar items |
| iconSize | 28 | Icons, always beside a text label |
| radius | 12 | Cards, buttons, fields, sheets |
| borderWidth | 1.5 | Cards and fields |
| focusWidth | 3 | Focus outline, primary color |
| maxContentWidth | 600 | Content is centered above this |

Cards are flat: border, no shadow.

## Shared widgets (`core/widgets/`)
| Widget | Purpose |
|---|---|
| AppScaffold | Safe area, padding, scrolling body, optional sticky footer |
| AppButton | Primary, secondary, danger; full width; optional icon; 56 high |
| AppTextField, AppNumberField | Label above, error under; number pad, whole numbers, thousands separators |
| SearchField | Search box for pickers and lists |
| AppListRow | Title, subtitle, trailing, 56+ high, wraps text |
| SectionHeader | Section title with optional action |
| MoneyText | Formatted amount, never truncated |
| QuantityStepper | Minus, quantity, plus; tap quantity to type |
| StatusChip | Draft, Finished, Paid, On account |
| SyncChip | Synced / Not synced yet, with icon |
| PickerSheet | Searchable bottom sheet to choose a buyer, product or supplier |
| AppSheet | Bottom sheet frame |
| confirmDialog, messageDialog | Standard dialogs with plain button text |
| EmptyState, ErrorPanel, LoadingView | The three non-data states (`UI_PLAN.md`) |
| ActionRow | Buttons side by side, stacked when narrow or scale > 1.3 |

A feature adds its own widget under `features/<x>/ui/` only when no shared one fits. Use one in two features: move it here.

## Theme files (`core/theme/`)
- `app_colors.dart`: the palette above as constants. The only place with hex values.
- `app_sizes.dart`: `AppSizes` and `AppSpacing` constants from the table.
- `app_text.dart`: builds the `TextTheme` for a given scale; names above are `TextTheme` slots plus `amount`.
- `app_theme.dart`: `buildTheme(textFactor)` returns `ThemeData`:
  - `useMaterial3`, explicit `ColorScheme(...)` from `AppColors` (no `fromSeed`), light only.
  - Button, input, app bar, navigation bar, card, chip, dialog, bottom sheet, snack bar and divider themes using the tokens: buttons `minimumSize` 56, fields with label always above and `borderWidth`, navigation bar labels always shown at caption size.
  - `materialTapTargetSize: padded`, `visualDensity: standard`.
- `status_colors.dart`: a `ThemeExtension` with chip, success and accent-container colors that `ColorScheme` lacks.
- `text_scale.dart`: the Normal / Large / Extra large choice, saved in SharedPreferences, applied once at the app root through `MediaQuery`.

## Responsive and accessibility rules
- Design for 360x640 portrait. Test at that size with text scale 1.0 and 1.8.
- One column. No horizontal scrolling. No fixed heights. Screens scroll vertically; the footer bar stays visible above the keyboard.
- Text wraps. Names may use up to 3 lines. Amounts are never cut: if they do not fit beside a name, move them below it.
- Two buttons in a row use `ActionRow`.
- Every tappable thing is at least 56x56 dp with 8 dp between neighbors, even if it looks smaller.
- Meaning never relies on color alone: chips, errors and sync state have words and an icon.
- Icon-only controls (back, minus, plus) have a text label from `strings.dart` for screen readers.
- Light theme only. No animations beyond the default page transition.
- Status bar icons dark, content inside `SafeArea`.
