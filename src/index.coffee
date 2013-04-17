jade = require 'jade'
sysPath = require 'path'
mkdirp  = require 'mkdirp'
fs = require 'fs'

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
    @public = config.paths.public
    @pretty = !!config.plugins?.jade?.pretty
    @locals = config.plugins?.jade_angular?.locals
    @modulesFolder = config.plugins?.jade_angular?.modules_folder

  compile: (data, path, callback) ->
    try
      content = jade.compile data, 
        compileDebug: no,
        client: no,
        filename: path,
        pretty: @pretty
    catch err
      error = err
    finally
      callback error, ""

  preparePair: (pair) ->
    pair.path.push(pair.path.pop()[...-@extension.length] + 'html')
    pair.path.splice 0, 1, @public

  writeStatic: (pair) ->
    @preparePair pair
    writer = fileWriter sysPath.join.apply(this, pair.path)
    writer null, pair.result

  setupModule: (pair) ->
    @preparePair pair
    pair.path.splice 1, 1, 'js'

    modulePath = pair.path.slice 2, pair.path.lastIndexOf(@modulesFolder)+1

    if modulePath.length is 0
      modulePath.push @modulesFolder

    moduleName = modulePath.join '.'
    jsFileName = moduleName + '.js'
    
    for vpath in pair.path.slice 2, pair.path.length - 1
      modulePath.push vpath
      
    modulePath.push pair.path[pair.path.length-1]
    copyfolder = pair.path.slice 0, 2
    copyfolder.push jsFileName

    virtualPathGen = ->
        return '/' + modulePath.join('/')

    result =
      moduleName: moduleName
      modulePath: sysPath.join.apply this, copyfolder
      virtualPath: virtualPathGen()
      content: pair.result

  parseStringToJSArray: (str) ->
    stringArray = '['
    str.split('\n').map (e, i) ->
      stringArray += "\n'" + e.replace(/'/g, "\\'") + "',"
    stringArray += "''" + '].join("\\n")'

  writeModules: (modules) ->
    for own moduleName, templates of modules
      content = """
                angular.module('#{moduleName}', [])
                """
      templates.map (e, i) =>
        inlineContent = @parseStringToJSArray(e.content)
        content +=  """
                    \n.run(['$templateCache', function($templateCache) {
                      return $templateCache.put('#{e.virtualPath}', #{inlineContent});
                    }])
                    """

      content += ";"

      writer = fileWriter templates[0].modulePath
      writer null, content

  #TODO: сделать async
  prepareResult: (compiled) ->
    
    publicPath = @public;
    
    pathes = (result.sourceFiles for result in compiled when result.path is sysPath.normalize(publicPath + '/js/dontUseMe'))[0]

    return [] if pathes is undefined

    pathes.map (e, i) => 
        data = fs.readFileSync e.path, 'utf8'
        content = jade.compile data,
          compileDebug: no,
          client: no,
          filename: e.path,
          pretty: @pretty

        result =
          path: e.path.split sysPath.sep
          result: content @locals

  onCompile: (compiled) ->
    preResult = @prepareResult compiled

    @writeStatic pair for pair in preResult \
      when pair.path.indexOf(@modulesFolder) is -1 and \
        pair.path.indexOf('assets') is -1

    modulesRows = (@setupModule pair for pair in preResult \
      when pair.path.indexOf(@modulesFolder) > -1 and \
        pair.path.indexOf('assets') is -1)

    modules = {}
    modulesRows.map (element, index) ->
      if Object.keys(modules).indexOf(element.moduleName) is -1
        modules[element.moduleName] = []
      modules[element.moduleName].push(element)

    @writeModules modules