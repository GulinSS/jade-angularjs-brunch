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

    beforeEach ->
      plugin = new Plugin({})

    it "Constructor's parameters defaults", ->
      _public = "_public"

      defaults =
        public: _public
        pretty: false
        doctype: "5"
        modulesFolder: "templates"
        compileTrigger: "#{_public}/js/dontUseMe"
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

    describe "Post-compile hook", ->
