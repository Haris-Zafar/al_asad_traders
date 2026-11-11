/// Plain English strings used across the entire application.
/// Rule: docs/DESIGN_SYSTEM.md > Shared widgets & strings. Story: none.
abstract final class AppStrings {
  // Currency and Numbers

  /// Application-wide currency label.
  static const String currency = 'Rs';

  // Statuses (UI_PLAN.md > Plain words)

  /// Draft status chip label.
  static const String draft = 'Draft';

  /// Finished status chip label.
  static const String finished = 'Finished';

  /// Paid status chip label.
  static const String paid = 'Paid';

  /// On account status chip label.
  static const String onAccount = 'On account';

  // Sync state (UI_PLAN.md > Plain words)

  /// Synced state label.
  static const String synced = 'Synced';

  /// Not synced yet state label.
  static const String notSyncedYet = 'Not synced yet';

  // Domain terms (UI_PLAN.md > Plain words)

  /// Plain term for purchase list summary.
  static const String buyingList = 'Buying list';

  /// Plain term for summary or demand item.
  static const String item = 'item';

  /// Plain term for customer order.
  static const String demand = 'Demand';

  /// Plain term for issuing a bill.
  static const String finishBill = 'Finish bill';

  /// Plain term for invoice number.
  static const String billNumber = 'Bill number';

  /// Plain term for moving an invoice to the ledger.
  static const String putOnAccount = 'Put on account';

  /// Plain term for customer ledger.
  static const String account = 'Account';

  /// Plain term for ledger entry.
  static const String entry = 'entry';

  /// Positive ledger balance prompt.
  static const String owesYou = 'Owes you';

  /// Negative ledger balance prompt.
  static const String youOwe = 'You owe';

  /// Plain term for opening balance.
  static const String startingBalance = 'Starting balance';

  /// Plain term for archiving an item or entity.
  static const String hide = 'Hide';

  /// Plain term for SKU / barcode.
  static const String barcode = 'Barcode';

  /// Plain term for buyer-specific rate.
  static const String priceForThisBuyer = 'Price for this buyer';

  /// Plain term for supplier rate.
  static const String buyingPrice = 'Buying price';

  /// Plain term for retail price.
  static const String shopPrice = 'Shop price';

  /// Plain term for default product price.
  static const String usualPrice = 'Usual price';

  /// Plain term for effective rate date.
  static const String fromDate = 'From date';

  // Screen actions and common buttons

  /// New bill button label.
  static const String newBill = 'New bill';

  /// Add buyer button label.
  static const String addBuyer = 'Add buyer';

  /// Total sum label.
  static const String total = 'Total';

  /// Remove item button label.
  static const String remove = 'Remove';

  /// Autosave pending indicator.
  static const String saving = 'Saving...';

  /// Autosave completed indicator.
  static const String saved = 'Saved';

  /// General confirmation dialog confirmation button.
  static const String ok = 'OK';

  /// General cancel action.
  static const String cancel = 'Cancel';

  /// Waiting action button.
  static const String wait = 'Wait';

  /// Action retry button.
  static const String tryAgain = 'Try again';

  /// Bill finalization confirmation action.
  static const String yesFinish = 'Yes, finish';

  /// Negative or postpone choice in confirmation dialogs.
  static const String notYet = 'Not yet';

  /// User login action.
  static const String logIn = 'Log in';

  /// Email field label.
  static const String email = 'Email';

  /// Password field label.
  static const String password = 'Password';

  /// User logout action.
  static const String logOut = 'Log out';

  /// Force logout action when unsynced data is pending.
  static const String logOutAnyway = 'Log out anyway';

  // Error messages (UI_PLAN.md > Loading, empty and error states)

  /// Failed list loading error message.
  static const String errorCouldNotLoad = 'Could not load this';

  /// Missing network connection prompt.
  static const String errorInternetNeeded = 'Internet is needed for this';

  /// Session expired or permission denied prompt.
  static const String errorPleaseLogInAgain = 'Please log in again';

  /// Stale or deleted item reference error.
  static const String errorItemNoLongerAvailable =
      'This is no longer available';

  /// Fallback generic user error message.
  static const String errorGeneric = 'Something went wrong. Please try again.';

  /// Input validation error prompt.
  static const String errorValidation = 'Please check the entered details.';

  /// Invalid email or password error prompt.
  static const String errorInvalidCredentials = 'Invalid email or password';

  /// Resource not found error message.
  static const String errorNotFound = 'The requested item was not found.';

  /// Concurrent edit or conflict error message.
  static const String errorConflict = 'This item has changed. Please refresh.';

  // Navigation tabs

  /// Bills bottom navigation tab label.
  static const String billsTab = 'Bills';

  /// Demands bottom navigation tab label.
  static const String demandsTab = 'Demands';

  /// Buyers bottom navigation tab label.
  static const String buyersTab = 'Buyers';

  /// More bottom navigation tab label.
  static const String moreTab = 'More';

  // Accessibility labels

  /// Back navigation affordance.
  static const String back = 'Back';

  /// Decrease quantity stepper button.
  static const String decrease = 'Decrease';

  /// Increase quantity stepper button.
  static const String increase = 'Increase';

  // Setup screen (S33)

  /// Device setup title.
  static const String setupTitle = 'Device setup';

  /// Device setup progress message.
  static const String setupMessage =
      'Setting up your device and downloading business data. Please wait...';

  /// Device setup connecting status.
  static const String setupConnecting = 'Connecting and syncing...';

  /// Continue button label.
  static const String continueLabel = 'Continue';

  // Business profile (S11)

  /// My business menu item and screen title.
  static const String businessProfileTitle = 'My business';

  /// Business name field label.
  static const String businessNameLabel = 'Business name';

  /// Business address field label.
  static const String businessAddressLabel = 'Address';

  /// Contact number 1 field label.
  static const String contactNumber1Label = 'Contact number 1';

  /// Contact number 2 field label.
  static const String contactNumber2Label = 'Contact number 2';

  /// Save button label.
  static const String save = 'Save';

  /// Business profile saved success message.
  static const String businessProfileSaved =
      'Business profile saved successfully';

  // Buyers & Suppliers (S9)

  /// Suppliers menu item and screen title.
  static const String suppliersTitle = 'Suppliers';

  /// Add supplier button label.
  static const String addSupplier = 'Add supplier';

  /// Edit buyer title.
  static const String editBuyer = 'Edit buyer';

  /// Edit supplier title.
  static const String editSupplier = 'Edit supplier';

  /// Buyer details screen title.
  static const String buyerDetails = 'Buyer details';

  /// Supplier details screen title.
  static const String supplierDetails = 'Supplier details';

  /// Name field label.
  static const String nameLabel = 'Name';

  /// Contact number field label.
  static const String contactNumberLabel = 'Contact number';

  /// Address field label.
  static const String addressLabel = 'Address';

  /// Notes field label.
  static const String notesLabel = 'Notes';

  /// Unhide action button label.
  static const String unhide = 'Unhide';

  /// Archived/hidden status label.
  static const String archived = 'Hidden';

  /// Show hidden items toggle label.
  static const String showHidden = 'Show hidden';

  /// Archive buyer dialog title.
  static const String archiveBuyerTitle = 'Hide buyer';

  /// Archive supplier dialog title.
  static const String archiveSupplierTitle = 'Hide supplier';

  /// Archive buyer warning dialog message.
  static const String archiveBuyerWarning =
      'This buyer has active balance, bills, or demands. Are you sure you want to hide this buyer?';

  /// Archive supplier warning dialog message.
  static const String archiveSupplierWarning =
      'This supplier has open buying lists. Are you sure you want to hide this supplier?';

  /// Confirm hide action label.
  static const String confirmHide = 'Yes, hide';

  /// Empty state message for buyers list.
  static const String noBuyersFound = 'No buyers found';

  /// Empty state message for suppliers list.
  static const String noSuppliersFound = 'No suppliers found';

  // Products (S1, S4)

  /// Products screen title.
  static const String productsTitle = 'Products';

  /// Add product button label.
  static const String addProduct = 'Add product';

  /// Edit product title.
  static const String editProduct = 'Edit product';

  /// Product details screen title.
  static const String productDetails = 'Product details';

  /// Search field hint for products.
  static const String searchProducts = 'Search products';

  /// Empty state message for products list.
  static const String noProductsFound = 'No products found';

  /// Product saved success message.
  static const String productSaved = 'Product saved successfully';

  /// Product hidden confirmation message.
  static const String productArchived = 'Product hidden';

  /// Product unhidden confirmation message.
  static const String productUnarchived = 'Product unhidden';

  /// Archive product dialog title.
  static const String archiveProductTitle = 'Hide product';

  /// Archive product warning message.
  static const String archiveProductWarning =
      'Are you sure you want to hide this product?';

  /// Default buying price field label.
  static const String defaultBuyingPrice = 'Default buying price';

  /// Default selling price field label.
  static const String defaultSellingPrice = 'Default selling price';

  /// Shop price field label.
  static const String shopPriceLabel = 'Shop price';

  /// Search field hint for buyers.
  static const String searchBuyers = 'Search buyers';

  /// Search field hint for suppliers.
  static const String searchSuppliers = 'Search suppliers';

  /// Buyer saved confirmation message.
  static const String buyerSaved = 'Buyer saved successfully';

  /// Supplier saved confirmation message.
  static const String supplierSaved = 'Supplier saved successfully';

  /// Buyer hidden confirmation message.
  static const String buyerArchived = 'Buyer hidden';

  /// Supplier hidden confirmation message.
  static const String supplierArchived = 'Supplier hidden';

  /// Buyer unhidden confirmation message.
  static const String buyerUnarchived = 'Buyer unhidden';

  /// Supplier unhidden confirmation message.
  static const String supplierUnarchived = 'Supplier unhidden';

  /// Account balance label.
  static const String accountBalance = 'Account balance';

  /// Bank accounts section label.
  static const String bankAccounts = 'Bank accounts';

  /// Bank name label.
  static const String bankNameLabel = 'Bank name / Title';

  /// Account number label.
  static const String accountNumberLabel = 'Account number / IBAN';

  /// Add bank account button label.
  static const String addBankAccount = 'Add bank account';

  /// Edit bank account button label.
  static const String editBankAccount = 'Edit bank account';

  /// No bank accounts message.
  static const String noBankAccounts = 'No bank accounts added';

  /// Bank account saved confirmation message.
  static const String bankAccountSaved = 'Bank account saved';

  /// Archive bank account title.
  static const String archiveBankAccountTitle = 'Hide Bank Account';

  /// Archive bank account warning message.
  static const String archiveBankAccountWarning =
      'Are you sure you want to hide this bank account?';
}
