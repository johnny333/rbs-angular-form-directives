// An example configuration file.
exports.config = {
  directConnect: true,

  // Capabilities to be passed to the webdriver instance.
  capabilities: {browserName: 'chrome'},
  
  // Framework to use. Jasmine is recommended.
  framework: 'jasmine',

  // Spec patterns are relative to the current working directly when
  // protractor is called.
  specs: [
  "target/test/e2e/js/forms.js",
  "target/test/e2e/js/rbsFormErrors_specs.js",
  "target/test/e2e/js/rbsFormGroup_specs.js"
  ],

  // A base URL for your application under test. Calls to protractor.get()
  // with relative paths will be resolved against this URL (via url.resolve)
  baseUrl: 'http://localhost:3000',

  // Options to be passed to Jasmine.
  jasmineNodeOpts: {
    defaultTimeoutInterval: 30000
  },

  onPrepare: function() {
    var jasmineReporters = require('jasmine-reporters');

    // returning the promise makes protractor wait for the reporter config before executing tests
    return browser.getProcessedConfig().then(function(config) {
        // you could use other properties here if you want, such as platform and version
        var browserName = config.capabilities.browserName;

        var junitReporter = new jasmineReporters.JUnitXmlReporter({
            consolidateAll: true,
            savePath: 'target/reports',
            filePrefix: 'E2E-' + browserName
        });
        jasmine.getEnv().addReporter(junitReporter);
    });
  }
};
