# Skrypt uruchomieniowy aplikacji z przykładami

    angular.element(document).ready ->
      angular.bootstrap document, ['<%= package.name %>-samples', 'ngMessages']
