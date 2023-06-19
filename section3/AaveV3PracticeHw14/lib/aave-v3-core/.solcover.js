const accounts = require(`./test-wallets.js`).accounts;
const cp = require('child_process');

module.exports = {
  configureYulOptimizer: true,
  skipFiles: ['./mocks', './interfaces', './dependencies'],
  mocha: {
    enableTimeouts: false,
  },
  providerOptions: {
    accounts,
  },
  onCompileComplete: function () {
    console.log('onCompileComplete hook');
    cp.execSync('. ./setup-test-env.sh', {stdio: 'inherit'});
  },
};
