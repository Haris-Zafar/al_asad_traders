const { initializeTestEnvironment, assertFails } = require('@firebase/rules-unit-testing');
const fs = require('fs');

let testEnv;

describe('Security Rules', () => {
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
});
