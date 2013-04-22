jade-angularjs-brunch
=====================

Automatic compiler Jade templates to AngularJS modules for Brunch.IO

## Sample of settings:

### Add to dependencies section in package.json of your project:

`` "jade-angularjs-brunch" : ">= 0.0.1 < 1.5" `` 

### Add to paths section in config.coffee:

    jadeCompileTrigger: '.compile-jade'  # Defaults to 'js/dontUseMe'.

### Add to templates section in config.coffee:

    joinTo: 
      '.compile-jade': /^app/  # Hack for auto-compiling Jade templates.

### Add to plugin section in config.coffee:

    plugins:
      jade:
        pretty: yes  # Adds pretty-indentation whitespaces to output (false by default).
      jade_angular:
        modules_folder: 'templates'
        locals: {}

* modules_folder: folder with your template
* locals: context for jade compiler

### Now you can get angular.js modules:

_public/js/login.template.js:

    angular.module('login.templates', [])
    .run(['$templateCache', function($templateCache) {
      return $templateCache.put('/login/modal.page.html', [
    'This is content of your jade-file',''].join("\n"));
    }])


