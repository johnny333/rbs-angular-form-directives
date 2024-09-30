(function() {
  angular.module('rbs-angular-form-directives', []);

}).call(this);

(function() {
  var DEFAULT_ERROR_CLASS, DEFAULT_SUCCESS_CLASS, DEFAULT_WARNING_CLASS, FormGroupCtrl, VALID_STATES,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  VALID_STATES = ['error', 'warning', 'success'];

  DEFAULT_ERROR_CLASS = 'has-error';

  DEFAULT_WARNING_CLASS = 'has-warning';

  DEFAULT_SUCCESS_CLASS = 'has-success';

  FormGroupCtrl = (function() {
    function FormGroupCtrl(attrs1, element1, log, scope1) {
      this.attrs = attrs1;
      this.element = element1;
      this.log = log;
      this.scope = scope1;
      this.successClass = [DEFAULT_SUCCESS_CLASS];
      this.warningClass = [DEFAULT_WARNING_CLASS];
      this.errorClass = [DEFAULT_ERROR_CLASS];
      this.controls = [];
      this.stateChangeListeners = [];
      this.dirty = false;
      this.scope.$watch((function(_this) {
        return function() {
          if (_this.dirty) {
            _this.$setState();
          }
          _this.dirty = false;
          return _this.dirty;
        };
      })(this));
    }

    FormGroupCtrl.prototype.$$setName = function(name) {
      return this.name = name;
    };

    FormGroupCtrl.prototype.$$setClass = function(state, klass) {
      var element, i, len, results;
      if (angular.isString(klass) && !S(klass).isEmpty()) {
        return this[state + "Class"] = [klass];
      } else if (angular.isArray(klass) && klass.length) {
        this[state + "Class"] = [];
        results = [];
        for (i = 0, len = klass.length; i < len; i++) {
          element = klass[i];
          if (angular.isString(element) && !S(element).isEmpty()) {
            results.push(this[state + "Class"].push(element));
          }
        }
        return results;
      }
    };

    FormGroupCtrl.prototype.$$addClass = function(state) {
      var i, klass, len, ref, results;
      ref = this[state + "Class"] || [];
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        klass = ref[i];
        results.push(this.attrs.$addClass(klass));
      }
      return results;
    };

    FormGroupCtrl.prototype.$$removeClass = function(state) {
      var i, klass, len, ref, results;
      ref = this[state + "Class"] || [];
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        klass = ref[i];
        results.push(this.attrs.$removeClass(klass));
      }
      return results;
    };

    FormGroupCtrl.prototype.$addControl = function(ngModel) {
      var ctrl, listener, removeListener, visitForm;
      ctrl = this;
      listener = function() {
        return ctrl.dirty = true;
      };
      visitForm = (function(_this) {
        return function(form) {
          var ref, removeListener;
          if (form.$$parentForm != null) {
            if (form.$$parentForm.$addStateChangeListener != null) {
              if (ref = form.$$parentForm, indexOf.call(_this.controls, ref) < 0) {
                _this.controls.push(form.$$parentForm);
                removeListener = form.$$parentForm.$addStateChangeListener(listener);
                _this.scope.$on('$destroy', removeListener);
                return visitForm(form.$$parentForm);
              }
            }
          }
        };
      })(this);
      if (indexOf.call(this.controls, ngModel) < 0) {
        this.controls.push(ngModel);
        removeListener = ngModel.$addStateChangeListener(listener);
        this.scope.$on('$destroy', removeListener);
        visitForm(ngModel);
        return (function(_this) {
          return function() {
            return _this.$removeControl(ngModel);
          };
        })(this);
      } else {
        return angular.noop;
      }
    };

    FormGroupCtrl.prototype.$removeControl = function(ngModel) {
      _.pull(this.controls, ngModel);
      return void 0;
    };

    FormGroupCtrl.prototype.$$hasError = function() {
      var someFormsSubmitted, someModelsDirty, someModelsInvalid, someModelsTouched;
      someFormsSubmitted = _.chain(this.controls).filter('$isForm').some('$submitted').value();
      someModelsTouched = _.chain(this.controls).reject('$isForm').some('$touched').value();
      someModelsDirty = _.chain(this.controls).reject('$isForm').some('$dirty').value();
      someModelsInvalid = _.chain(this.controls).reject('$isForm').some('$invalid').value();
      return (someFormsSubmitted || someModelsTouched || someModelsDirty) && someModelsInvalid;
    };

    FormGroupCtrl.prototype.$$hasWarning = function() {
      return false;
    };

    FormGroupCtrl.prototype.$$hasSuccess = function() {
      return false;
    };

    FormGroupCtrl.prototype.$$hasState = function(state) {
      return this["$$has" + (S(state).capitalize().s)]();
    };

    FormGroupCtrl.prototype.$addStateChangeListener = function(listener) {
      if ((angular.isFunction(listener)) && !(indexOf.call(this.stateChangeListeners, listener) >= 0)) {
        this.stateChangeListeners.push(listener);
        return (function(_this) {
          return function() {
            return _this.$removeStateChangeListener(listener);
          };
        })(this);
      } else {
        return angular.noop;
      }
    };

    FormGroupCtrl.prototype.$removeStateChangeListener = function(listener) {
      _.pull(this.stateChangeListeners, listener);
      return void 0;
    };

    FormGroupCtrl.prototype.$setState = function() {
      var i, j, len, len1, listener, ref, results, state, states;
      states = [];
      for (i = 0, len = VALID_STATES.length; i < len; i++) {
        state = VALID_STATES[i];
        if (this.$$hasState(state)) {
          this.$$addClass(state);
          states.push(state);
        } else {
          this.$$removeClass(state);
        }
      }
      ref = this.stateChangeListeners;
      results = [];
      for (j = 0, len1 = ref.length; j < len1; j++) {
        listener = ref[j];
        results.push(listener(states));
      }
      return results;
    };

    return FormGroupCtrl;

  })();

  (angular.module('rbs-angular-form-directives')).directive('rbsFormGroup', [
    '$log', '$parse', function($log, $parse) {
      var getter;
      getter = function(attrs, name) {
        var fn, key;
        key = attrs[name];
        fn = $parse(key);
        fn.key = key;
        return fn;
      };
      return {
        require: 'rbsFormGroup',
        controller: [
          '$attrs', '$element', '$log', '$scope', function($attrs, $element, $log, $scope) {
            return new FormGroupCtrl($attrs, $element, $log, $scope);
          }
        ],
        link: function(scope, element, attrs, ctrl) {
          var rbsFormGroupError, rbsFormGroupSuccess, rbsFormGroupWarning;
          rbsFormGroupError = getter(attrs, 'rbsFormGroupError');
          rbsFormGroupWarning = getter(attrs, 'rbsFormGroupWarning');
          rbsFormGroupSuccess = getter(attrs, 'rbsFormGroupSuccess');
          ctrl.$$setClass('error', rbsFormGroupError(scope));
          ctrl.$$setClass('warning', rbsFormGroupWarning(scope));
          ctrl.$$setClass('success', rbsFormGroupSuccess(scope));
          return attrs.$observe('rbsFormGroup', function(name) {
            return ctrl.$$setName(name);
          });
        }
      };
    }
  ]);

}).call(this);

(function() {
  var FormErrorsCtrl,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  FormErrorsCtrl = (function() {
    function FormErrorsCtrl(attrs1, element1, log, scope1) {
      this.attrs = attrs1;
      this.element = element1;
      this.log = log;
      this.scope = scope1;
    }

    FormErrorsCtrl.prototype.$setVisible = function(visible) {
      if (visible) {
        return this.attrs.$removeClass('ng-hide');
      } else {
        return this.attrs.$addClass('ng-hide');
      }
    };

    return FormErrorsCtrl;

  })();

  (angular.module('rbs-angular-form-directives')).directive('rbsFormErrors', [
    '$log', '$parse', function($log, $parse) {
      return {
        require: ['rbsFormErrors', '?^rbsFormGroup'],
        controller: [
          '$attrs', '$element', '$log', '$scope', function($attrs, $element, $log, $scope) {
            return new FormErrorsCtrl($attrs, $element, $log, $scope);
          }
        ],
        link: function(scope, element, attrs, arg) {
          var ctrl, rbsFormGroup, removeListener;
          ctrl = arg[0], rbsFormGroup = arg[1];
          if (rbsFormGroup != null) {
            removeListener = rbsFormGroup.$addStateChangeListener(function(states) {
              return ctrl.$setVisible((indexOf.call(states, 'error') >= 0));
            });
            return scope.$on('$destroy', removeListener);
          }
        }
      };
    }
  ]);

}).call(this);

(function() {
  var decorateNgModel, extendCompile, extendController, extendPreLink,
    slice = [].slice,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  extendPreLink = function(originalPreLink) {
    return function(scope, element, attr, arg) {
      var form, ngModel, ngModelOptions, rbsFormGroup, removeControl, result;
      ngModel = arg[0], form = arg[1], ngModelOptions = arg[2], rbsFormGroup = arg[3];
      result = originalPreLink(scope, element, attr, [ngModel, form, ngModelOptions, rbsFormGroup]);
      if (rbsFormGroup != null) {
        removeControl = rbsFormGroup.$addControl(ngModel);
        scope.$on('$destroy', removeControl);
      }
      return result;
    };
  };

  extendCompile = function(originalCompile) {
    return function() {
      var args, result;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      result = originalCompile.apply(null, args);
      result.pre = extendPreLink(result.pre);
      return result;
    };
  };

  extendController = function(OriginalModelCtrl) {
    var ModelCtrl, OVERRIDEN, field, i, inject, len, stateChangeListeners;
    inject = [];
    for (i = 0, len = OriginalModelCtrl.length; i < len; i++) {
      field = OriginalModelCtrl[i];
      if (angular.isString(field)) {
        inject.push(field);
      } else if (angular.isFunction(field)) {
        OriginalModelCtrl = field;
      }
    }
    OVERRIDEN = ['dirty', 'pristine', 'untouched', 'touched', 'validity'];
    stateChangeListeners = [];
    ModelCtrl = function($scope, $exceptionHandler, $attrs, $element, $parse, $animate, $timeout, $rootScope, $q, $interpolate) {
      var fn, j, len1, methodName, model;
      OriginalModelCtrl.call(this, $scope, $exceptionHandler, $attrs, $element, $parse, $animate, $timeout, $rootScope, $q, $interpolate);
      model = this;
      fn = function(methodName) {
        var supr;
        supr = model[methodName];
        return model[methodName] = function() {
          var args, k, len2, listener, results;
          args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
          supr.call.apply(supr, [model].concat(slice.call(args)));
          results = [];
          for (k = 0, len2 = stateChangeListeners.length; k < len2; k++) {
            listener = stateChangeListeners[k];
            results.push(listener.call(model));
          }
          return results;
        };
      };
      for (j = 0, len1 = OVERRIDEN.length; j < len1; j++) {
        field = OVERRIDEN[j];
        methodName = "$set" + (S(field).capitalize().s);
        fn(methodName);
      }
      this.$addStateChangeListener = function(listener) {
        if ((angular.isFunction(listener)) && !(indexOf.call(stateChangeListeners, listener) >= 0)) {
          stateChangeListeners.push(listener);
          return function() {
            return model.$removeStateChangeListener(listener);
          };
        } else {
          return angular.noop;
        }
      };
      this.$removeStateChangeListener = function(listener) {
        _.pull(stateChangeListeners, listener);
        return void 0;
      };
      return void 0;
    };
    ModelCtrl.$inject = inject;
    return ModelCtrl;
  };

  decorateNgModel = function($delegate) {
    var directive;
    directive = $delegate[0];
    directive.controller = extendController(directive.controller);
    directive.compile = extendCompile(directive.compile);
    directive.require.push('?^rbsFormGroup');
    return $delegate;
  };

  (angular.module('rbs-angular-form-directives')).config([
    '$provide', function($provide) {
      return $provide.decorator('ngModelDirective', ['$delegate', decorateNgModel]);
    }
  ]);

}).call(this);

(function() {
  var decorateNgForm, extendController,
    slice = [].slice,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  extendController = function(OriginalFormCtrl) {
    var FormCtrl, OVERRIDEN, childControlListeners, stateChangeListeners;
    stateChangeListeners = [];
    childControlListeners = [];
    OVERRIDEN = ['dirty', 'pristine', 'untouched', 'submitted', 'validity'];
    FormCtrl = function(element, attrs, $scope, $animate, $interpolate) {
      var field, fn, form, i, len, methodName, super_$addControl, super_$removeControl, super_$renameControl;
      OriginalFormCtrl.call(this, element, attrs, $scope, $animate, $interpolate);
      form = this;
      super_$addControl = this.$addControl;
      super_$renameControl = this.$renameControl;
      super_$removeControl = this.$removeControl;
      this.$isForm = true;
      this.$addControl = function(control) {
        var i, len, listener, results;
        super_$addControl.call(form, control);
        results = [];
        for (i = 0, len = childControlListeners.length; i < len; i++) {
          listener = childControlListeners[i];
          results.push(listener.call(form, control));
        }
        return results;
      };
      this.$removeControl = function(control) {
        var i, len, listener, results;
        super_$removeControl.call(form, control);
        results = [];
        for (i = 0, len = childControlListeners.length; i < len; i++) {
          listener = childControlListeners[i];
          results.push(listener.call(form, void 0, control));
        }
        return results;
      };
      this.$renameControl = function(control) {
        var i, len, listener, results;
        super_$renameControl.call(form, control);
        results = [];
        for (i = 0, len = childControlListeners.length; i < len; i++) {
          listener = childControlListeners[i];
          results.push(listener.call(form, control, control));
        }
        return results;
      };
      fn = function(methodName) {
        var supr;
        supr = form[methodName];
        return form[methodName] = function() {
          var args, j, len1, listener, results;
          args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
          supr.call.apply(supr, [form].concat(slice.call(args)));
          results = [];
          for (j = 0, len1 = stateChangeListeners.length; j < len1; j++) {
            listener = stateChangeListeners[j];
            results.push(listener.call(form));
          }
          return results;
        };
      };
      for (i = 0, len = OVERRIDEN.length; i < len; i++) {
        field = OVERRIDEN[i];
        methodName = "$set" + (S(field).capitalize().s);
        fn(methodName);
      }
      this.$addStateChangeListener = function(listener) {
        if ((angular.isFunction(listener)) && !(indexOf.call(stateChangeListeners, listener) >= 0)) {
          stateChangeListeners.push(listener);
          return function() {
            return form.$removeStateChangeListener(listener);
          };
        } else {
          return angular.noop;
        }
      };
      this.$removeStateChangeListener = function(listener) {
        _.pull(stateChangeListeners, listener);
        return void 0;
      };
      this.$addChildControlListener = function(listener) {
        if ((angular.isFunction(listener)) && !(indexOf.call(childControlListeners, listener) >= 0)) {
          childControlListeners.push(listener);
          return function() {
            return form.$removeChildControlListener(listener);
          };
        } else {
          return angular.noop;
        }
      };
      this.$removeChildControlListener = function(listener) {
        _.pull(childControlListeners, listener);
        return void 0;
      };
      return void 0;
    };
    FormCtrl.$inject = OriginalFormCtrl.$inject;
    return FormCtrl;
  };

  decorateNgForm = function($delegate) {
    var directive;
    directive = $delegate[0];
    directive.controller = extendController(directive.controller);
    return $delegate;
  };

  (angular.module('rbs-angular-form-directives')).config([
    '$provide', function($provide) {
      return $provide.decorator('ngFormDirective', ['$delegate', decorateNgForm]);
    }
  ]);

  (angular.module('rbs-angular-form-directives')).config([
    '$provide', function($provide) {
      return $provide.decorator('formDirective', ['$delegate', decorateNgForm]);
    }
  ]);

}).call(this);

//# sourceMappingURL=rbs-angular-form-directives.js.map
