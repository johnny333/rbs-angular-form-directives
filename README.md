# rbs-angular-form-directives

Biblioteka dyrektyw **Angular.js** wspomagających obsługę formularzy.

Celem było uporządkowanie pokazywania/ukrywania informacji walidacyjnych tak aby przypominało to zachowanie
"klasycznych" formularzy.

## Instalacja

    npm install
    bower install

## Instalacja w projekcie

    bower install git@gitlab.bssolutions.pl:biblioteki/rbs-angular-form-directives.git#v0.0.2 string lodash --save

## Demo

Po wywołaniu domyślnego tasku `gulp`. Otwierana jest sesja deweloperska, która może służyć jako demo funkcjonalności.
Pamiętaj aby cały kod związany z prezentacją, a nie samym modułem pozostał w katalogu `src/main/samples` w module
`rbs-angular-form-directives-samples`.

    gulp

## API

### `ngForm`

Dyrektywa `ngForm` jest [rozszerzona](https://docs.angularjs.org/api/auto/service/$provide#decorator) o dodatkowe metody.

Zobacz dodane [API](src/main/coffee/directive/form.litcoffee)

### `ngModel`

Dyrektywa `ngModel` jest [rozszerzona](https://docs.angularjs.org/api/auto/service/$provide#decorator) o dodatkowe metody.

Zobacz dodane [API](src/main/coffee/directive/model.litcoffee)

### `rbsFormGroup`

Dyrektywa do obsługi grupy pól formularzy (w Bootstrap: `.form-group`)

Zobacz dostępne [API](src/main/coffee/directive/rbsFormGroup.litcoffee) oraz [testy E2E](src/test/e2e/coffee/rbsFormGroup_specs.coffee)

### `rbsFormErrors`

Dyrektywa do obsługi kontenera błędów grupy pól formularzy

Zobacz dostępne [API](src/main/coffee/directive/rbsFormErrors.litcoffee) oraz [testy E2E](src/test/e2e/coffee/rbsFormErrors_specs.coffee)
