const { initializeTestEnvironment, assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');
const fs = require('fs');

let testEnv;

describe('Security Rules - Owner Auth (T-05)', () => {
  before(async () => {
    const hostPort = process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8080';
    const [host, portStr] = hostPort.split(':');
    testEnv = await initializeTestEnvironment({
      projectId: 'al-asad-traders-test',
      firestore: {
        host: host || '127.0.0.1',
        port: parseInt(portStr || '8080', 10),
        rules: fs.readFileSync('../firestore.rules', 'utf8'),
      },
    });
  });

  after(async () => {
    if (testEnv) {
      await testEnv.cleanup();
    }
  });

  beforeEach(async () => {
    if (testEnv) {
      await testEnv.clearFirestore();
    }
  });

  it('denies unauthenticated read by default', async () => {
    const unauthDb = testEnv.unauthenticatedContext().firestore();
    await assertFails(unauthDb.collection('bills').get());
  });

  it('denies non-owner authenticated user read and write', async () => {
    const nonOwnerDb = testEnv.authenticatedContext('other-uid').firestore();
    await assertFails(nonOwnerDb.collection('bills').get());
    await assertFails(nonOwnerDb.collection('bills').add({ status: 'draft' }));
  });

  it('allows owner authenticated user read and write', async () => {
    const ownerDb = testEnv.authenticatedContext('po2rFc75KISIx5DuyyiQhznl3nM2').firestore();
    await assertSucceeds(ownerDb.collection('bills').get());
    await assertSucceeds(ownerDb.collection('bills').doc('bill-1').set({ status: 'draft' }));
  });

  it('allows owner to read and write deviceRegistry and devices (T-06)', async () => {
    const ownerDb = testEnv.authenticatedContext('po2rFc75KISIx5DuyyiQhznl3nM2').firestore();
    await assertSucceeds(ownerDb.collection('deviceRegistry').doc('main').set({ nextIndex: 0 }));
    await assertSucceeds(ownerDb.collection('devices').doc('A').set({ lastNumber: 0 }));
  });

  it('denies non-owner to write deviceRegistry and devices (T-06)', async () => {
    const nonOwnerDb = testEnv.authenticatedContext('other-uid').firestore();
    await assertFails(nonOwnerDb.collection('deviceRegistry').doc('main').set({ nextIndex: 0 }));
    await assertFails(nonOwnerDb.collection('devices').doc('A').set({ lastNumber: 0 }));
  });

  it('allows owner to read and write profile main document (T-09)', async () => {
    const ownerDb = testEnv.authenticatedContext('po2rFc75KISIx5DuyyiQhznl3nM2').firestore();
    await assertSucceeds(ownerDb.collection('profile').doc('main').set({ businessName: 'Test' }));
    await assertSucceeds(ownerDb.collection('profile').doc('main').get());
  });

  it('denies non-owner to read and write profile main document (T-09)', async () => {
    const nonOwnerDb = testEnv.authenticatedContext('other-uid').firestore();
    await assertFails(nonOwnerDb.collection('profile').doc('main').set({ businessName: 'Test' }));
    await assertFails(nonOwnerDb.collection('profile').doc('main').get());
  });

  it('allows owner to write valid buyer document and denies invalid/delete (T-10)', async () => {
    const ownerDb = testEnv.authenticatedContext('po2rFc75KISIx5DuyyiQhznl3nM2').firestore();
    const validBuyer = {
      name: 'John Buyer',
      contactNumber: '03001234567',
      address: 'Main Market',
      notes: null,
      archivedAt: null,
      createdAt: new Date(),
    };
    await assertSucceeds(ownerDb.collection('buyers').doc('b1').set(validBuyer));
    await assertFails(ownerDb.collection('buyers').doc('b1').set({ name: 'Invalid' }));
    await assertFails(ownerDb.collection('buyers').doc('b1').delete());
  });

  it('allows owner to write valid supplier document and denies invalid/delete (T-10)', async () => {
    const ownerDb = testEnv.authenticatedContext('po2rFc75KISIx5DuyyiQhznl3nM2').firestore();
    const validSupplier = {
      name: 'ABC Supplier',
      contactNumber: '03007654321',
      address: null,
      notes: 'Reliable',
      archivedAt: null,
      createdAt: new Date(),
    };
    await assertSucceeds(ownerDb.collection('suppliers').doc('s1').set(validSupplier));
    await assertFails(ownerDb.collection('suppliers').doc('s1').set({ name: 'Invalid' }));
    await assertFails(ownerDb.collection('suppliers').doc('s1').delete());
  });

  it('denies non-owner to read or write buyers and suppliers (T-10)', async () => {
    const nonOwnerDb = testEnv.authenticatedContext('other-uid').firestore();
    await assertFails(nonOwnerDb.collection('buyers').get());
    await assertFails(nonOwnerDb.collection('suppliers').get());
  });

  it('allows owner to write valid bank account and enforces single owner constraint (T-11)', async () => {
    const ownerDb = testEnv.authenticatedContext('po2rFc75KISIx5DuyyiQhznl3nM2').firestore();
    const validAccount = {
      profileId: 'main',
      buyerId: null,
      supplierId: null,
      name: 'Meezan Bank',
      accountNumber: 'PK36MEZN00012345678901',
      notes: 'Main account',
      archivedAt: null,
      createdAt: new Date(),
    };
    await assertSucceeds(ownerDb.collection('bankAccounts').doc('ba1').set(validAccount));

    // Valid buyer bank account
    const buyerAccount = {
      profileId: null,
      buyerId: 'b1',
      supplierId: null,
      name: 'HBL',
      accountNumber: '12345678',
      notes: null,
      archivedAt: null,
      createdAt: new Date(),
    };
    await assertSucceeds(ownerDb.collection('bankAccounts').doc('ba2').set(buyerAccount));

    // Valid supplier bank account
    const supplierAccount = {
      profileId: null,
      buyerId: null,
      supplierId: 's1',
      name: 'UBL',
      accountNumber: '87654321',
      notes: null,
      archivedAt: null,
      createdAt: new Date(),
    };
    await assertSucceeds(ownerDb.collection('bankAccounts').doc('ba3').set(supplierAccount));

    // Invalid: no owner
    const noOwnerAccount = {
      profileId: null,
      buyerId: null,
      supplierId: null,
      name: 'No Owner Bank',
      accountNumber: '1111',
      notes: null,
      archivedAt: null,
      createdAt: new Date(),
    };
    await assertFails(ownerDb.collection('bankAccounts').doc('ba4').set(noOwnerAccount));

    // Invalid: multiple owners
    const multiOwnerAccount = {
      profileId: 'main',
      buyerId: 'b1',
      supplierId: null,
      name: 'Multi Owner Bank',
      accountNumber: '2222',
      notes: null,
      archivedAt: null,
      createdAt: new Date(),
    };
    await assertFails(ownerDb.collection('bankAccounts').doc('ba5').set(multiOwnerAccount));

    // Invalid: delete is prohibited
    await assertFails(ownerDb.collection('bankAccounts').doc('ba1').delete());
  });

  it('denies non-owner to read or write bankAccounts (T-11)', async () => {
    const nonOwnerDb = testEnv.authenticatedContext('other-uid').firestore();
    await assertFails(nonOwnerDb.collection('bankAccounts').get());
    await assertFails(
      nonOwnerDb.collection('bankAccounts').doc('ba1').set({
        profileId: 'main',
        buyerId: null,
        supplierId: null,
        name: 'Meezan Bank',
        accountNumber: 'PK36MEZN00012345678901',
        notes: null,
        archivedAt: null,
        createdAt: new Date(),
      }),
    );
  });

  it('allows owner to write valid product document and denies invalid/delete (T-12)', async () => {
    const ownerDb = testEnv.authenticatedContext('po2rFc75KISIx5DuyyiQhznl3nM2').firestore();
    const validProduct = {
      name: 'Sugar 1kg',
      sku: '1234567890123',
      defaultSupplierRate: 140,
      defaultBuyerRate: 150,
      defaultRetailPrice: 160,
      notes: 'Good quality',
      archivedAt: null,
      createdAt: new Date(),
    };
    await assertSucceeds(ownerDb.collection('products').doc('p1').set(validProduct));
    // Invalid: negative price
    const invalidProduct = {
      ...validProduct,
      defaultSupplierRate: -10,
    };
    await assertFails(ownerDb.collection('products').doc('p2').set(invalidProduct));
    await assertFails(ownerDb.collection('products').doc('p1').delete());
  });

  it('denies non-owner to read or write products (T-12)', async () => {
    const nonOwnerDb = testEnv.authenticatedContext('other-uid').firestore();
    await assertFails(nonOwnerDb.collection('products').get());
    await assertFails(
      nonOwnerDb.collection('products').doc('p1').set({
        name: 'Sugar 1kg',
        sku: null,
        defaultSupplierRate: 140,
        defaultBuyerRate: 150,
        defaultRetailPrice: 160,
        notes: null,
        archivedAt: null,
        createdAt: new Date(),
      }),
    );
  });
});
