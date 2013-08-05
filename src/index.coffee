jade = require 'jade'
sysPath = require 'path'
mkdirp  = require 'mkdirp'
fs = require 'fs'
_ = require 'lodash'

fileWriter = (newFilePath) -> (err, content) ->
  throw err if err?
  return if not content?
  dirname = sysPath.dirname newFilePath
  mkdirp dirname, '0775', (err) ->
    throw err if err?
    fs.writeFile newFilePath, content, (err) -> throw err if err?

module.exports = class JadeAngularJsCompiler
  brunchPlugin: yes
  type: 'template'
  extension: 'jade'

  constructor: (config) ->
    @public = config.paths?.public or "_public"
    @pretty = !!config.plugins?.jade?.pretty
    @doctype = config.plugins?.jade?.doctype or "5"
    @locals = config.plugins?.jade_angular?.locals or {}
    @modulesFolder = config.plugins?.jade_angular?.modules_folder or "templates"
    @compileTrigger = sysPath.normalize @public + sysPath.sep + (config.paths?.jadeCompileTrigger or 'js/dontUseMe')
    @singleFile = !!config?.plugins?.jade_angular?.single_file
    @singleFileName = sysPath.join @public, (config?.plugins?.jade_angular?.single_file_name or "js/angular_templates.js")

  # Do nothing, just check possibility of Jade compilation
  compile: (data, path, callback) ->
    try
      content = jade.compile data, 
        compileDebug: no,
        client: no,
        filename: path,
        doctype: @doctype
        pretty: @pretty

      content @locals
    catch err

      error = err
    finally
      callback error, ""

  preparePairStatic: (pair) ->
    pair.path.push(pair.path.pop()[...-@extension.length] + 'html')
    pair.path.splice 0, 0, @public

  writeStatic: (pair) ->
    @preparePairStatic pair
    writer = fileWriter sysPath.join.apply(this, pair.path)
    writer null, pair.result

  attachModuleNameToTemplate: (pair) ->
    pair.module = pair.path[0..-3].join '.'

  generateModuleFileName: (module) ->
    module.filename = "#{@public}/js/#{module.name}.js"

  writeModules: (modules) ->

    buildModule = (module) ->
      moduleHeader = (name) ->
        """
        angular.module('#{name}', [])
        """

      templateRecord = (result, path) ->
        parseStringToJSArray = (str) ->
          stringArray = '['
          str.split('\n').map (e, i) ->
            stringArray += "\n'" + e.replace(/'/g, "\\'") + "',"
          stringArray += "''" + '].join("\\n")'

        """
        \n.run(['$templateCache', function($templateCache) {
          return $templateCache.put('#{path}', #{parseStringToJSArray(result)});
        }])
        """

      addEndOfModule = -> ";\n"

      content = moduleHeader module.name

      _.each module.templates, (template) ->
        content += templateRecord template.result, template.path

      content += addEndOfModule()

    content = ""

    _.each modules, (module) ->
      moduleContent = buildModule module

      if @singleFile
        content += "\n#{moduleContent}"
      else
        writer = fileWriter module.filename
        writer null, moduleContent

    if @singleFile
      writer = fileWriter @singleFileName
      writer null, content

  prepareResult: (compiled) ->
    pathes = (result.sourceFiles for result in compiled when result.path is @compileTrigger)[0]

    return [] if pathes is undefined

    pathes.map (e, i) => 
        data = fs.readFileSync e.path, 'utf8'
        content = jade.compile data,
          compileDebug: no,
          client: no,
          filename: e.path,
          doctype: @doctype
          pretty: @pretty

        result =
          path: e.path.split sysPath.sep
          result: content @locals

  onCompile: (compiled) ->
    preResult = @prepareResult compiled

    assets = _.filter preResult, (v) -> v.path.indexOf('assets') is -1

    @writeStatic assets

    @writeModules _.chain(preResult)
      .difference(assets)
      .each(@attachModuleNameToTemplate)
      .groupBy((v) -> v.module)
      .map((v, k) -> name: k, templates: v)
      .each(@generateModuleFileName)
      .value()
