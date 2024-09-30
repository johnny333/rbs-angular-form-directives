(function() {
  angular.module('rbs-angular-form-directives-samples', ['rbs-angular-form-directives']);

}).call(this);

(function() {
  (angular.module('rbs-angular-form-directives-samples')).controller('SimpleFormCtrl', [
    '$log', '$scope', function($log, $scope) {
      $log.info('Start SimpleFormCtrl');
      this.user = {};
      return void 0;
    }
  ]);

}).call(this);

(function() {
  (angular.module('rbs-angular-form-directives-samples')).controller('NestedFormCtrl', [
    '$log', '$scope', function($log, $scope) {
      $log.info('Start NestedFormCtrl');
      this.company = {
        employees: [
          {
            id: 1
          }, {
            id: 2
          }, {
            id: 3
          }
        ]
      };
      return void 0;
    }
  ]);

}).call(this);

//# sourceMappingURL=rbs-angular-form-directives-samples.js.map
