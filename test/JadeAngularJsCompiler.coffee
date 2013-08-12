describe "JadeAngularJsCompiler", ->
  describe "Public surface", ->
    it "Should exists", ->
      Plugin.should.exist
      Plugin.name.should.equal "JadeAngularJsCompiler"

    it "Accept contract of Brunch plugin", ->
      Plugin.prototype.should.contain.keys [
        "compile"
        "onCompile"
        "brunchPlugin"
        "type"
        "extension"
      ]

  describe "In action", ->
    plugin = null
    _public = "_public"
    compileTrigger = "#{_public}/js/dontUseMe"
    fileHtmlContent = "<!DOCTYPE html>"

    beforeEach ->
      plugin = new Plugin({})

    it "Constructor's parameters defaults", ->
      _public = "_public"

      defaults =
        public: _public
        pretty: false
        doctype: "5"
        staticMask: /index.jade/
        compileTrigger: compileTrigger
        singleFile: false
        singleFileName: "#{_public}/js/angular_templates.js"

      for k, v of defaults
        plugin[k].should.deep.equal v

      Object.keys(plugin.locals).should.have.length 0

    describe "Standart compile hook", ->
      it "Pass errors of Jade's content compilation", ->
        plugin.compile "mixin asd", "index.jade", (error, content) ->
          error.should.instanceOf TypeError
          content.should.equal ""

      it "Returns empty string to callack everytime", ->
        plugin.compile "!!!", "index.jade", (error, content) ->
          expect(error).to.equal undefined
          content.should.equal ""

    describe "Parts of main function", ->
      describe "prepareResult", ->
        it "Must return empty array if input don't have compileTrigger's path", ->
          result = plugin.prepareResult([
            sourceFiles: []
            path: ""
          ])

          result.should.have.length 0

        it "Must return pairs with path and result on correct compileTrigger", ->
          result = plugin.prepareResult([
            sourceFiles: [
              path: "test/folder/partial1.jade"
            ,
              path: "test/folder/partial2.jade"
            ]
            path: compileTrigger
          ])

          result.should.be.an('array')

          for v, i in ['partial1.jade', 'partial2.jade']
            r = result[i]
            r.should.contain.keys(['path', 'result'])
            r.path.should.be.an('array')
            r.path.should.be.deep.equal(['test', 'folder', v])
            r.result.should.be.an('string')
            r.result.should.be.equal fileHtmlContent

      describe "writeModules", ->
        it "Must write templates into root module", (done) ->
          tempFileName = "temp.tmp"

          plugin.writeModules([
            name: "myModule"
            filename: tempFileName
            templates: [
              path: "hello.tmp"
              result: "Hello!"
            ,
              path: "hello2.tmp"
              result: "Hello!2"
            ]
          ,
            name: "myModule2"
            filename: tempFileName+1
            templates: [
              path: "hello3.tmp"
              result: "Hello!2-1"
            ]
          ])

          setTimeout ->

            contentFirst = fs.readFileSync tempFileName, encoding: "utf8"
            contentFirst.should.equal("""
                                      angular.module('myModule', [])
                                      .run(['$templateCache', function($templateCache) {
                                        return $templateCache.put('hello.tmp', [
                                      'Hello!',''].join("\\n"));
                                      }])
                                      .run(['$templateCache', function($templateCache) {
                                        return $templateCache.put('hello2.tmp', [
                                      'Hello!2',''].join("\\n"));
                                      }]);\n
                                      """)

            contentSecond = fs.readFileSync tempFileName+1, encoding: "utf8"
            contentSecond.should.equal("""
                                       angular.module('myModule2', [])
                                       .run(['$templateCache', function($templateCache) {
                                         return $templateCache.put('hello3.tmp', [
                                       'Hello!2-1',''].join("\\n"));
                                       }]);\n
                                       """)

            fs.unlinkSync tempFileName
            fs.unlinkSync tempFileName+1
            done()
          , 250

        xit "TODO: test for singleFile", ->
          true.should.be.equal true

        xit "TODO: parse string to JSArray", ->
          true.should.be.equal true

      describe "writeStatic", ->
        xit "TODO: write content to file", ->

      describe "preparePairStatic", ->
        it "Change file extension from jade to html, add result public folder as first and remove second folder like \'app\'. Used only by writeStatic.", ->
          path = ['folder', 'file', 'jade']

          plugin.preparePairStatic
            path: path

          path.should.be.deep.equal ['_public', 'file', 'html']

      describe "parsePairsIntoAssetsTree", ->
        it "Translate paths of pairs into assets tree", ->
          pairs = [
            path: ["app", "folder", "file.name"]
          ,
            path: ["app", "folder", "file2.name"]
          ,
            path: ["app", "folder", "folder", "file.name"]
          ,
            path: ["app", "folder2", "file.name"]
          ]

          result = plugin.parsePairsIntoAssetsTree pairs

          result.should.deep.equal [
            name: "app"
            children: [
              name: "folder"
              children: [
                name: "folder"
                children: []
              ]
            ,
              name: "folder2"
              children: []
            ]
          ]

      describe "attachModuleNameToTemplate", ->
        assetsTree = [
          name: "app"
          children: [
            name: "folder"
            children: []
          ]
        ]

        it "Pair in a folder with static page should be placed in one module", ->
          pair =
            path: ['app', 'file.jade']
            content: "<!DOCTYPE html>"

          plugin.attachModuleNameToTemplate pair, assetsTree

          pair.should.contain.keys ['module']
          pair.module.should.equal "app.templates"

        it "Pair should be placed in child module in a case when a folder with index.jade has child folder with own index.jade", ->
          pair =
            path: ['app', 'folder', 'file.jade']
            content: "<!DOCTYPE html>"

          plugin.attachModuleNameToTemplate pair, assetsTree

          pair.should.contain.keys ['module']
          pair.module.should.equal "app.folder.templates"

        it "Pair in deeper path of the last folder with index.jade should be placed in last parent", ->
          pair =
            path: ['app', 'folder', 'folder', 'file.jade']
            content: "<!DOCTYPE html>"

          plugin.attachModuleNameToTemplate pair, assetsTree

          pair.should.contain.keys ['module']
          pair.module.should.equal "app.folder.templates"

        it "If application don't have any static assets all jade files will be stored in top module", ->
          pair =
            path: ['app', 'folder', 'file.jade']
            content: "<!DOCTYPE html>"

          plugin.attachModuleNameToTemplate pair, []

          pair.should.contain.keys ['module']
          pair.module.should.equal "app.templates"

      describe "generateModuleFileName", ->
        it "Generate module file name for writting", ->
          module =
            name: "filename"

          plugin.generateModuleFileName module

          module.should.contain.keys ['filename']
          module.filename.should.equal "#{plugin.public}/js/filename.js"

    describe "Post-compile hook", ->
      data = [
        sourceFiles: [
          path: "test/folder/index.jade"
        ,
          path: "test/folder/partial1.jade"
        ,
          path: "test/folder/partial2.jade"
        ,
          path: "test/folder/folder/index.jade"
        ,
          path: "test/folder/folder/partial1.jade"
        ,
          path: "test/folder/folder/partial2.jade"
        ]
        path: compileTrigger
      ]

      beforeEach ->
        sinon.stub(plugin, "writeModules")
        sinon.stub(plugin, "writeStatic")

      afterEach ->
        plugin.writeModules.restore()
        plugin.writeStatic.restore()

      it "Anyway on test data it should call write methods for modules and assets", ->
        plugin.onCompile data
        plugin.writeStatic.should.have.been.calledOnce
        plugin.writeModules.should.have.been.calledOnce

      it "For static jade files (valid for staticMask) it should write them \'as is\'", ->
        expect = [
          path: [ 'test', 'folder', 'index.jade' ]
          result: '<!DOCTYPE html>'
        ,
          path: [ 'test', 'folder', 'folder', 'index.jade' ]
          result: '<!DOCTYPE html>'
        ]

        plugin.onCompile data

        plugin.writeStatic.args[0].should.length 1
        plugin.writeStatic.args[0][0].should.deep.equal expect

      it "For modules it should filtered and grouped them correct", ->
        expect = [
            name: 'test.folder.templates'
            templates: [
              path: 'test/folder/partial1.jade'
              result: '<!DOCTYPE html>'
              module: 'test.folder.templates'
            ,
              path: 'test/folder/partial2.jade'
              result: '<!DOCTYPE html>'
              module: 'test.folder.templates'
            ]
            filename: '_public/js/test.folder.templates.js'
        ,
            name: 'test.folder.folder.templates',
            templates: [
              path: 'test/folder/folder/partial1.jade'
              result: '<!DOCTYPE html>'
              module: 'test.folder.folder.templates'
            ,
              path: 'test/folder/folder/partial2.jade'
              result: '<!DOCTYPE html>'
              module: 'test.folder.folder.templates'
            ],
            filename: '_public/js/test.folder.folder.templates.js'
        ]

        plugin.onCompile data

        plugin.writeModules.args[0].should.length 1
        plugin.writeModules.args[0][0].should.deep.equal expect