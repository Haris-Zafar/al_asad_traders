# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]
- Product tagging and tag filtering for product list and product details (T-14).
- Product barcode scanning & lookup via `productSkus` collection and MobileScanner integration (T-13).
- Products management (add, edit, list, search, archive) with default prices and Firestore security rules (T-12).
- Bank accounts management for business profile, buyers, and suppliers with single-owner validation and Firestore security rules (T-11).
- Buyer and supplier management screens, form sheets, repositories, and Firestore security rules (T-10).
- Business profile management screen (`/more/business`) and repository for updating business name, address, and contact numbers.
- Logout warning dialog when unsynced data exists and persistence cache clearance on logout.
- Sync state tracking provider and real-time sync status UI chip.
- First-time device setup flow with atomic letter claim transaction (`deviceRegistry/main`), spreadsheet index-to-letter calculation, and initial full server sync.
- Email and password login screen with persistent authentication and owner security rules.
- App navigation shell with four bottom navigation tabs (Bills, Demands, Buyers, More) and backstack handling.
- Core shared UI widgets, dialogs, sheets, and test environment harness.
- Design system theme, typography, color tokens, strings, error handling, and formatters.
- Initial project setup with Flutter dependencies, CI workflow, and Firestore security rules testing infrastructure.
