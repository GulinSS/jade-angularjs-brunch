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
        modulesFolder: "templates"
        compileTrigger: compileTrigger
        singleFile: false
        singleFileName: "#{_public}/js/angular_templates.js"

      for k, v of defaults
        plugin[k].should.equal v

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

          plugin.writeModules(
            "myModule": [
              content: "Hello!"
              virtualPath: "hello.tmp"
              modulePath: tempFileName
            ,
              content: "Hello!2"
              virtualPath: "hello2.tmp"
              modulePath: tempFileName
            ]
            "myModule2": [
              content: "Hello!2-1"
              virtualPath: "hello3.tmp"
              modulePath: tempFileName+1
            ]
          )

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
                                      }]);""")

            contentSecond = fs.readFileSync tempFileName+1, encoding: "utf8"
            contentSecond.should.equal("""
                                       angular.module('myModule2', [])
                                       .run(['$templateCache', function($templateCache) {
                                         return $templateCache.put('hello3.tmp', [
                                       'Hello!2-1',''].join("\\n"));
                                       }]);
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

      describe "preparePair", ->
        it "Change file extension from jade to html and add result public folder as first", ->
          path = ['folder', 'file', 'jade']

          plugin.preparePair
            path: path

          path.should.be.deep.equal ['_public', 'folder', 'file', 'html']



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