(angular.module '<%= package.name %>-samples').controller 'NestedFormCtrl', [
  '$log'
  '$scope'
  ($log, $scope) ->
    $log.info 'Start NestedFormCtrl'

    @company =
      employees: [
        { id: 1 }
        { id: 2 }
        { id: 3 }
      ]

    undefined
]
