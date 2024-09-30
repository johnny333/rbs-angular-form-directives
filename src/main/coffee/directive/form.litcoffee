# `ngForm`

Dekorator dyrektywy `ngForm`.

Roszerzam kontroler `NgFormController`:

    extendController = (OriginalFormCtrl) ->

      stateChangeListeners = []
      childControlListeners = []
      OVERRIDEN = ['dirty', 'pristine', 'untouched', 'submitted', 'validity']

      FormCtrl = (element, attrs, $scope, $animate, $interpolate) ->

        OriginalFormCtrl.call this, element, attrs, $scope, $animate, $interpolate

        form = this

        super_$addControl = this.$addControl
        super_$renameControl = this.$renameControl
        super_$removeControl = this.$removeControl

Dodaje flagę `$isForm` do kontrolera - aby łatwo można było go odróżnić od kontrolek.

        @$isForm = true

Metoda `$(add|remove|rename)Control` rozszerzona jest o notyfikację `childControlListeners`.

        @$addControl = (control) ->
          super_$addControl.call form, control
          for listener in childControlListeners
            listener.call form, control

        @$removeControl = (control) ->
          super_$removeControl.call form, control
          for listener in childControlListeners
            listener.call form, undefined, control

        @$renameControl = (control) ->
          super_$renameControl.call form, control
          for listener in childControlListeners
            listener.call form, control, control

Wszystkie metody kontrolera zmieniające stan `$set(Dirty|Pristine|Untouched|Submitted|Validity)` rozszerzamy o
notyfikację `stateChangeLiteners`.

        for field in OVERRIDEN
          methodName = "$set#{S(field).capitalize().s}"
          ((methodName) ->
            supr = form[methodName]
            form[methodName] = (args...) ->
              supr.call form, args...
              for listener in stateChangeListeners
                listener.call form
          )(methodName)

Metoda `$addStateChangeListener` dodaje listener zmiany stanu kontrolki - umożliwia otrzymywanie notyfikacji o wszelkich
zmianach stanu kontrolki i jej kontrolek (formularzy) nadrzędnych. Zwracana jest funkcja usuwająca `listener`.

        @$addStateChangeListener = (listener) ->
          if (angular.isFunction listener) and not (listener in stateChangeListeners)
            stateChangeListeners.push listener
            -> form.$removeStateChangeListener listener
          else angular.noop

        @$removeStateChangeListener = (listener) ->
          _.pull stateChangeListeners, listener
          undefined

Metoda `$addChildControlListener` dodaje listener dodania kontrolek podrzędnych. Zwracana jest funkcja usuwająca
`listener`.

        @$addChildControlListener = (listener) ->
          if (angular.isFunction listener) and not (listener in childControlListeners)
            childControlListeners.push listener
            -> form.$removeChildControlListener listener
          else angular.noop

        @$removeChildControlListener = (listener) ->
          _.pull childControlListeners, listener
          undefined

        undefined

      FormCtrl.$inject = OriginalFormCtrl.$inject

      FormCtrl

Dekoracja dyrektywy `form` i `ngForm`:

    decorateNgForm = ($delegate) ->
      directive = $delegate[0]
      directive.controller = extendController directive.controller
      $delegate

    (angular.module '<%= package.name %>').config [
      '$provide'
      ($provide) ->
        $provide.decorator 'ngFormDirective', [
          '$delegate'
          decorateNgForm
        ]
    ]

    (angular.module '<%= package.name %>').config [
      '$provide'
      ($provide) ->
        $provide.decorator 'formDirective', [
          '$delegate'
          decorateNgForm
        ]
    ]
