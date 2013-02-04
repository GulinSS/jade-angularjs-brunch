jade-angularjs-brunch
=====================

Automatic compiler Jade templates to AngularJS modules for Brunch.IO

Sample of settings:

* Add to dependencies section in package.json of your project:

"jade-angularjs-brunch" : ">= 0.0.1 < 1.5"

* Add to templates section in config.coffee:

      joinTo: 
        'js/dontUseMe' : /^app/ #slutty hack for Jade-auto-compiling

* Now you can get angular.js modules:

_public/js/login.template.js:

angular.module('login.templates', [])
.run(['$templateCache', function($templateCache) {
  return $templateCache.put('/login/modal.selectYear.html', [
'This is content of your jade-file',''].join("\n"));
}])


