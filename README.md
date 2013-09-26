jade-angularjs-brunch [![Build Status](https://travis-ci.org/GulinSS/jade-angularjs-brunch.png?branch=master)](https://travis-ci.org/GulinSS/jade-angularjs-brunch)
=====================

DEPRECATED! Need update!
========================

Automatic compiler Jade templates to AngularJS modules for Brunch.IO

## Sample of settings:

### Add to dependencies section in package.json of your project:

`` "jade-angularjs-brunch" : ">= 0.0.1 < 1.5" `` 

### Add to paths section in config.coffee:

```coffee
jadeCompileTrigger: '.compile-jade'  # Defaults to 'js/dontUseMe'.
```

### Add to templates section in config.coffee:

```coffee
joinTo: 
  '.compile-jade': /^app/  # Hack for auto-compiling Jade templates.
```

### Add to plugin section in config.coffee:

```coffee
plugins:
  jade:
    pretty: yes  # Adds pretty-indentation whitespaces to output (false by default).
    doctype: "xml"  # Specify doctype ("5" by default).
  jade_angular:
    modules_folder: 'templates'
    locals: {}
```

* modules_folder: folder with your template
* locals: context for jade compiler

### Now you can get angular.js modules:

_public/js/login.template.js:

```js
angular.module('login.templates', [])
.run(['$templateCache', function($templateCache) {
  return $templateCache.put('/login/modal.page.html', [
'This is content of your jade-file',''].join("\n"));
}])
```

# Single-File Mode

If you want a single file instead of a file per module, you can use the `single_file` option in `jade_angular`.

```coffee
plugins:
  jade_angular:
    single_file: true
    # if you want to change the file name (defaults to js/templates.js and is in your public directory)
    single_file_name: 'js/angular_templates.js'
```
