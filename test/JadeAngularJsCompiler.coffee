describe "JadeAngularJsCompiler", ->

  describe "Public surface", ->

    it "Should exists", ->
      Plugin.should.exist
      Plugin.name.should.equal "JadeAngularJsCompiler"


    describe "Constructor's parameters", ->
      _public = "_public"

      it "Defaults", ->
        plugin = new Plugin({})

        defaults =
          public: _public
          pretty: false
          doctype: "5"
          modulesFolder: "templates"
          compileTrigger: "#{_public}/js/dontUseMe"
          singleFile: false
          singleFileName: "#{_public}/js/templates.js"

        for k, v of defaults
          plugin[k].should.equal v

        Object.keys(plugin.locals).should.have.length 0

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

