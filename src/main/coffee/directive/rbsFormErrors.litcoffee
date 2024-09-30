# `rbsFormErrors`

Dyrektywa:
1. pokazuje element gdy nadrzędny `rbsFormGroup` zawiera stan `error`
1. ukrywa element gdy nadrzędny `rbsFormGroup` nie zawiera stanu `error`


    class FormErrorsCtrl

      constructor: (@attrs, @element, @log, @scope) ->

Ustawia widoczność elementu:
TODO: wsparcie dla `$animate`

      $setVisible: (visible) ->
        if visible
          @attrs.$removeClass 'ng-hide'
        else
          @attrs.$addClass 'ng-hide'

    (angular.module '<%= package.name %>').directive 'rbsFormErrors', [
      '$log'
      '$parse'
      ($log, $parse) ->
        require: ['rbsFormErrors', '?^rbsFormGroup']
        controller: [
          '$attrs'
          '$element'
          '$log'
          '$scope'
          ($attrs, $element, $log, $scope) -> new FormErrorsCtrl($attrs, $element, $log, $scope)
        ]
        link: (scope, element, attrs, [ctrl, rbsFormGroup]) ->
          if rbsFormGroup?
            removeListener = rbsFormGroup.$addStateChangeListener (states) ->
              ctrl.$setVisible ('error' in states)
            scope.$on '$destroy', removeListener
    ]
