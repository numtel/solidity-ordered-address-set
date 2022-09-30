const assert = require('assert');

exports.basicFunctions = async function({
  web3, accounts, deployContract, loadContract, throws, BURN_ACCOUNT
}) {
  const test = await deployContract(accounts[0], 'TestOrderedAddressSet');

  await test.sendFrom(accounts[0]).insert(accounts[0], 0);
  await test.sendFrom(accounts[0]).insert(accounts[1], 1);
  assert.strictEqual(Number(await test.methods.count().call()), 2);
  assert.strictEqual(await test.methods.keyAtIndex(0).call(), accounts[0]);
  assert.strictEqual(await test.methods.keyAtIndex(1).call(), accounts[1]);

  // Insert in middle
  await test.sendFrom(accounts[0]).insert(accounts[2], 1);
  assert.strictEqual(Number(await test.methods.count().call()), 3);
  assert.strictEqual(await test.methods.keyAtIndex(0).call(), accounts[0]);
  assert.strictEqual(await test.methods.keyAtIndex(1).call(), accounts[2]);
  assert.strictEqual(await test.methods.keyAtIndex(2).call(), accounts[1]);

  // Insert at start
  await test.sendFrom(accounts[0]).insert(accounts[3], 0);
  assert.strictEqual(Number(await test.methods.count().call()), 4);
  assert.strictEqual(await test.methods.keyAtIndex(0).call(), accounts[3]);
  assert.strictEqual(await test.methods.keyAtIndex(1).call(), accounts[0]);
  assert.strictEqual(await test.methods.keyAtIndex(2).call(), accounts[2]);
  assert.strictEqual(await test.methods.keyAtIndex(3).call(), accounts[1]);

  // Insert at end
  await test.sendFrom(accounts[0]).insert(accounts[4], 4);
  assert.strictEqual(Number(await test.methods.count().call()), 5);
  assert.strictEqual(await test.methods.keyAtIndex(0).call(), accounts[3]);
  assert.strictEqual(await test.methods.keyAtIndex(1).call(), accounts[0]);
  assert.strictEqual(await test.methods.keyAtIndex(2).call(), accounts[2]);
  assert.strictEqual(await test.methods.keyAtIndex(3).call(), accounts[1]);
  assert.strictEqual(await test.methods.keyAtIndex(4).call(), accounts[4]);

  // Remove from start
  await test.sendFrom(accounts[0]).remove(0);
  assert.strictEqual(Number(await test.methods.count().call()), 4);
  assert.strictEqual(await test.methods.keyAtIndex(0).call(), accounts[0]);
  assert.strictEqual(await test.methods.keyAtIndex(1).call(), accounts[2]);
  assert.strictEqual(await test.methods.keyAtIndex(2).call(), accounts[1]);
  assert.strictEqual(await test.methods.keyAtIndex(3).call(), accounts[4]);

  // Remove from middle
  await test.sendFrom(accounts[0]).remove(2);
  assert.strictEqual(Number(await test.methods.count().call()), 3);
  assert.strictEqual(await test.methods.keyAtIndex(0).call(), accounts[0]);
  assert.strictEqual(await test.methods.keyAtIndex(1).call(), accounts[2]);
  assert.strictEqual(await test.methods.keyAtIndex(2).call(), accounts[4]);

  // Remove from end
  await test.sendFrom(accounts[0]).remove(2);
  assert.strictEqual(Number(await test.methods.count().call()), 2);
  assert.strictEqual(await test.methods.keyAtIndex(0).call(), accounts[0]);
  assert.strictEqual(await test.methods.keyAtIndex(1).call(), accounts[2]);

  // Remove remaining
  await test.sendFrom(accounts[0]).remove(0);
  await test.sendFrom(accounts[0]).remove(0);
  assert.strictEqual(Number(await test.methods.count().call()), 0);

  // Add to empty to be sure
  await test.sendFrom(accounts[0]).insert(accounts[0], 0);
  await test.sendFrom(accounts[0]).insert(accounts[1], 1);
  assert.strictEqual(Number(await test.methods.count().call()), 2);
  assert.strictEqual(await test.methods.keyAtIndex(0).call(), accounts[0]);
  assert.strictEqual(await test.methods.keyAtIndex(1).call(), accounts[1]);
};
