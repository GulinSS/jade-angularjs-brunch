jade-angularjs-brunch [![Build Status](https://travis-ci.org/GulinSS/jade-angularjs-brunch.png?branch=master)](https://travis-ci.org/GulinSS/jade-angularjs-brunch)
=====================

Compiler Jade templates to AngularJS modules for Brunch.IO with automatic section detection based on location of index.jade's.

## Step by step using guide

For example you have a directory structure of your project such as:

```
app/
    index.jade
    application.coffee
    welcome/
          page.jade
          page.less
          controllers.coffee
          directives.coffee
          otherStuff.coffee
    access/
          index.jade
          application.coffee
          register/
                    page.jade
                    page.less
                    controllers.coffee
                    directives.coffee
                    otherStuff.coffee
          login/
                    ...
    admin/
          index.jade
          application.coffee
          users/
                    ...
          records/
                    ...
    landing/
          index.jade
          ...
                    
```

The key note of example above is location of index.jade's. Them will be compile as usual jade files into index.html's. Your public folder will have such structure:

```
_public/
        index.html
        access/
                index.html
        admin/
                index.html
        landing/
                index.html
        
```

And as addition it will group "partials" (files like page.jade in example) of this section into javascript files:

```
_public/
        js/
            app.templates.js        # it will contains compiled content of 
                                    # app/welcome/page.jade and any jades in subdirectories
                                    
            app.access.templates.js # it will contains compiled content of
                                    # app/access/register/page.jade and 
                                    # app/access/login/page.jade
                                    # and any jades in subdirectories
                                    
            app.admin.templates.js  # ...
            ...
```

Any file in example above will contains declaration of Angular.js module with same name:

```
app.templates.js        -> app.templates
app.access.templates.js -> app.access.templates
...
```

Modules must be registered in application.coffee's files such as:

```
App = angular.module('app', [
  ...
  
  'app.templates'
])
```

After action above you can use your template in your code like this:

```
  $routeProvider
    .when('/welcome', {templateUrl: 'app/welcome/page.jade'})
```

or in directive's templateUrl.

This magic helps you split your large application on small SPA sections for improving performance and control complexity. 

## Sample of settings (DEPRECATED)

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
