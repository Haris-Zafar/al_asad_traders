const { initializeTestEnvironment, assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');
const fs = require('fs');

let testEnv;

describe('Security Rules - Owner Auth (T-05)', () => {
  before(async () => {
    testEnv = await initializeTestEnvironment({
      projectId: 'al-asad-traders-test',
      firestore: {
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
    const ownerDb = testEnv.authenticatedContext('OWNER_UID').firestore();
    await assertSucceeds(ownerDb.collection('bills').get());
    await assertSucceeds(ownerDb.collection('bills').doc('bill-1').set({ status: 'draft' }));
  });
});
