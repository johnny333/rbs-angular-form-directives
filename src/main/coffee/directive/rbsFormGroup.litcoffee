# `rbsFormGroup`

Dyrektywa grupy elementów formularza - odpowiednik `form-group` w `Bootstrap`.
Dyrektywa zarządza klasami CSS nałożonymi na element zależnie od stanu formularza w którym się znajduje oraz kontrolek
`ngModel`, które zawiera. Chodzi o to by naśladować zachowanie "tradycyjnego" formularza - gdzie błędy walidacji
pojawiają się dopiero po akcji użytkownika na kontrolce.

Grupa może być w następujących stanach:
* `error` - gdy jednocześnie:
  - wystąpi któryś z warunków:
    * którykolwiek z formularzy nadrzędnych grupy jest `$submitted`
    * którakolwiek z kontrolek w grupie jest `$touched`
    * którakolwiek z kontrolek w grupie jest `$dirty`
  - którakolwiek z kontrolek w grupie jest `$invalid`
* `warning` - TODO: myślałem żeby wykorzystać parametr `allowInvalid` z `ngModelOptions` - i ustawiać stan `warning` gdy
  spełnione są warunki stanu `error` ale wszytkie kontrolki w grupie mają ustawione `allowInvalid` := `true`
* `success` - TODO: gdy jednocześnie:
  - wystąpi któryś z warunków:
    * którykolwiek z formularzy nadrzędnych grupy jest `$submitted`
    * którakolwiek z kontrolek w grupie jest `$touched`
    * którakolwiek z kontrolek w grupie jest `$dirty`
  - wszystkie kontrolki w grupie są `$valid`

Atrybuty:
* `rbs-form-group-error` - klasa lub klasy CSS nakładana w przypadku gdy grupa jest w stanie `error`
* `rbs-form-group-warning` - klasa lub klasy CSS nakładana w przypadku gdy grupa jest w stanie `warning`
* `rbs-form-group-success` - klasa lub klasy CSS nakładana w przypadku gdy grupa jest w stanie `success`


    VALID_STATES = ['error', 'warning', 'success']
    DEFAULT_ERROR_CLASS = 'has-error'
    DEFAULT_WARNING_CLASS = 'has-warning'
    DEFAULT_SUCCESS_CLASS = 'has-success'

    class FormGroupCtrl

      constructor: (@attrs, @element, @log, @scope) ->
        @successClass = [DEFAULT_SUCCESS_CLASS]
        @warningClass = [DEFAULT_WARNING_CLASS]
        @errorClass = [DEFAULT_ERROR_CLASS]
        @controls = []
        @stateChangeListeners = []
        @dirty = false

Ustalamy stan grupy raz na `$digest`:

        @scope.$watch =>
          if @dirty
            @$setState()
          @dirty = false
          @dirty

Ustawia nazwę grupy:

      $$setName: (name) ->
        @name = name

Ustawia jakie klasy CSS będą ustawiane dla elementu w stanie `state`. Parametr `klass` może być `string` lub
`array`[`string`]:

      $$setClass: (state, klass) ->
        if angular.isString(klass) and not S(klass).isEmpty()
          @["#{state}Class"] = [klass]
        else if angular.isArray(klass) and klass.length
          @["#{state}Class"] = []
          for element in klass when angular.isString(element) and not S(element).isEmpty()
            @["#{state}Class"].push element

Dodaje do elementu wszystkie klasy przypisane do stanu `state`:
TODO: wsparcie dla `$animate`

      $$addClass: (state) ->
        for klass in @["#{state}Class"] or []
          @attrs.$addClass klass

Usuwa z elementu wszystkie klasy przypisane do stanu `state`:
TODO: wsparcie dla `$animate`

      $$removeClass: (state) ->
        for klass in @["#{state}Class"] or []
          @attrs.$removeClass klass

Dodaje kontrolkę do grupy. Zwraca funkcję usuwającą kontrolkę:

      $addControl: (ngModel) ->

        ctrl = this

        listener = ->
          ctrl.dirty = true

        visitForm = (form) =>
          if form.$$parentForm?
            if form.$$parentForm.$addStateChangeListener?
              unless form.$$parentForm in @controls
                @controls.push form.$$parentForm
                removeListener = form.$$parentForm.$addStateChangeListener(listener)
                @scope.$on '$destroy', removeListener
                visitForm form.$$parentForm

        unless ngModel in @controls
          @controls.push ngModel
          removeListener = ngModel.$addStateChangeListener listener
          @scope.$on '$destroy', removeListener
          visitForm ngModel
          => @$removeControl ngModel
        else angular.noop

      $removeControl: (ngModel) ->
        _.pull @controls, ngModel
        undefined

Metoda określa warunki na wystąpienie stanu `error`:

      $$hasError: ->
        someFormsSubmitted = _.chain(@controls).filter('$isForm').some('$submitted').value()
        someModelsTouched = _.chain(@controls).reject('$isForm').some('$touched').value()
        someModelsDirty = _.chain(@controls).reject('$isForm').some('$dirty').value()
        someModelsInvalid = _.chain(@controls).reject('$isForm').some('$invalid').value()
        (someFormsSubmitted or someModelsTouched or someModelsDirty) and someModelsInvalid

Metoda określa warunki na wystąpienie stanu `warning` (TODO:):

      $$hasWarning: -> false

Metoda określa warunki na wystąpienie stanu `success` (TODO:):

      $$hasSuccess: -> false

      $$hasState: (state) ->
        @["$$has#{S(state).capitalize().s}"]()

      $addStateChangeListener: (listener) ->
        if (angular.isFunction listener) and not (listener in @stateChangeListeners)
          @stateChangeListeners.push listener
          => @$removeStateChangeListener listener
        else angular.noop

      $removeStateChangeListener: (listener) ->
        _.pull @stateChangeListeners, listener
        undefined

      $setState: ->
        states = []
        for state in VALID_STATES
          if @$$hasState state
            @$$addClass state
            states.push state
          else
            @$$removeClass state
        for listener in @stateChangeListeners
          listener states

    (angular.module '<%= package.name %>').directive 'rbsFormGroup', [
      '$log'
      '$parse'
      ($log, $parse) ->

        getter = (attrs, name) ->
          key = attrs[name]
          fn = $parse key
          fn.key = key
          fn

        require: 'rbsFormGroup'
        controller: [
          '$attrs'
          '$element'
          '$log'
          '$scope'
          ($attrs, $element, $log, $scope) -> new FormGroupCtrl($attrs, $element, $log, $scope)
        ]
        link: (scope, element, attrs, ctrl) ->

          rbsFormGroupError = getter attrs, 'rbsFormGroupError'
          rbsFormGroupWarning = getter attrs, 'rbsFormGroupWarning'
          rbsFormGroupSuccess = getter attrs, 'rbsFormGroupSuccess'

          ctrl.$$setClass 'error', rbsFormGroupError scope
          ctrl.$$setClass 'warning', rbsFormGroupWarning scope
          ctrl.$$setClass 'success', rbsFormGroupSuccess scope

          attrs.$observe 'rbsFormGroup', (name) ->
            ctrl.$$setName name
    ]
