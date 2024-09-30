(angular.module '<%= package.name %>-samples').controller 'SimpleFormCtrl', [
  '$log'
  '$scope'
  ($log, $scope) ->
    $log.info 'Start SimpleFormCtrl'

    @user = {}
    
    undefined
]
