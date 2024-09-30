# `ngModel`

Dekorator dyrektywy `ngModel`.

Rozszerzam funkcję `preLink` - dodaję `ngModel` jako kontrolkę do nadrzędnej dyrektywy `rbsFormGroup` (jeżeli istnieje).

    extendPreLink = (originalPreLink) ->

      (scope, element, attr, [ngModel, form, ngModelOptions, rbsFormGroup]) ->

        result = originalPreLink scope, element, attr, [ngModel, form, ngModelOptions, rbsFormGroup]

        if rbsFormGroup?
          removeControl = rbsFormGroup.$addControl ngModel
          scope.$on '$destroy', removeControl

        result

Rozszerzam funkcję `compile` - jedynie po to, by rozszerzyć zwróconą funkcję `preLink`.

    extendCompile = (originalCompile) ->

      (args...) ->

        result = originalCompile args...

        result.pre = extendPreLink result.pre
        result

Roszerzam kontroler `NgModelController`:

    extendController = (OriginalModelCtrl) ->

oryginalny kontroler jest w formie tablicowej - przechwytuję funkcje kontrolera i rozszerzam ją.

      inject = []

      for field in OriginalModelCtrl
        if angular.isString field
          inject.push field
        else if angular.isFunction field
          OriginalModelCtrl = field

      OVERRIDEN = ['dirty', 'pristine', 'untouched', 'touched', 'validity']

      stateChangeListeners = []

      ModelCtrl = ($scope, $exceptionHandler, $attrs, $element, $parse, $animate, $timeout, $rootScope, $q,
        $interpolate) ->

        OriginalModelCtrl.call this, $scope, $exceptionHandler, $attrs, $element, $parse, $animate, $timeout,
         $rootScope, $q, $interpolate

        model = this

Wszystkie metody kontrolera zmieniające stan `$set(Dirty|Pristine|Untouched|Touched|Validity)` rozszerzamy o notyfikację
`stateChangeLiteners`.

        for field in OVERRIDEN
          methodName = "$set#{S(field).capitalize().s}"
          ((methodName) ->
            supr = model[methodName]
            model[methodName] = (args...) ->
              supr.call model, args...
              for listener in stateChangeListeners
                listener.call model
          )(methodName)

Metoda `$addStateChangeListener` dodaje listener zmiany stanu kontrolki - umożliwia otrzymywanie notyfikacji o wszelkich
zmianach stanu kontrolki i jej kontrolek (formularzy) nadrzędnych. Zwracana jest funkcja usuwająca `listener`.

        @$addStateChangeListener = (listener) ->
          if (angular.isFunction listener) and not (listener in stateChangeListeners)
            stateChangeListeners.push listener
            -> model.$removeStateChangeListener listener
          else angular.noop

        @$removeStateChangeListener = (listener) ->
          _.pull stateChangeListeners, listener
          undefined

        undefined

      ModelCtrl.$inject = inject

      ModelCtrl

Dekoracja dyrektywy

    decorateNgModel = ($delegate) ->
      directive = $delegate[0]
      directive.controller = extendController directive.controller
      directive.compile = extendCompile directive.compile
      directive.require.push '?^rbsFormGroup'
      $delegate

    (angular.module '<%= package.name %>').config [
      '$provide'
      ($provide) ->
        $provide.decorator 'ngModelDirective', [
          '$delegate'
          decorateNgModel
        ]
    ]
