	
	# coffee -bo lib/ -cw src/
	
	Function.prototype.method = (name, func) ->
		if not @prototype[name]
			@prototype[name] = func
			@
	
	String.method 'trim', ->
		return this.replace /^\s+|\s+$/g, ''
	
	app =
		
		changeUrl: false
		changeTitle: false
		retarded: $.browser.msie is true and parseInt($.browser.version) <= 9
		loop: [2000, 1500, 1000, 1000, 750, 750, 500, 300, 300, 300, 300, 200, 150, 130, 120, 110, 100]
		hashids: undefined
		additionalLinks: {
			javascript: []
			ruby: [{
				title: 'Ruby Gem'
				class: 'rubygem'
				url: 'http://rubygems.org/gems/hashids'
			}]
			python: [{
				title: 'PyPI Package'
				class: 'pypi'
				url: 'https://pypi.python.org/pypi/hashids/'
			}]
			java: []
			php: [{
				title: 'Composer Package'
				class: 'packagist'
				url: 'https://packagist.org/packages/hashids/hashids'
			}, {
				title: 'Laravel Bundle'
				class: 'laravel'
				url: 'http://bundles.laravel.com/bundle/hashids'
			}, {
				title: 'CodeIgniter Spark'
				class: 'code-igniter'
				url: 'http://getsparks.org/packages/sk-hashids/versions/HEAD/show'
			}, {
				title: 'Kohana Module'
				class: 'kohana'
				url: 'http://kohana-modules.com/modules/pocesar/hashids-kohana'
			}, {
				title: 'WordPress Plugin'
				class: 'wordpress'
				url: 'http://wordpress.org/support/plugin/wp-hashed-ids'
			}]
			coffeescript: []
			go: [{
				title: 'GoDoc'
				class: 'godoc'
				url: 'http://godoc.org/github.com/speps/go-hashids'
			}]
			'node-js': [{
				title: 'Node Package'
				class: 'npm'
				url: 'https://npmjs.org/package/hashids'
			}, {
				title: 'Meteor Package'
				class: 'meteor'
				url: 'https://github.com/crapthings/meteor-hashids'
			}]
			'objective-c': []
			net: [{
				title: 'NuGet Package'
				class: 'nuget'
				url: 'http://nuget.org/packages/Hashids.net/'
			}]
		}
		
		checkPath: ->
			lang = window.location.pathname.replace(/\//g, '')
			@changeTitle = true if lang
			@select lang || 'javascript'
		
		select: (lang) ->
			
			that = $('#' + lang)
			
			if that.hasClass 'selected'
				return
			
			that.addClass('selected').siblings().removeClass 'selected'
			
			$input = $ "#template-lang-#{lang}-input"
			$output = $ "#template-lang-#{lang}-output"
			
			template = $('#template-playground').html()
			data =
				lang: lang
				title: that.text()
				github: that.attr 'github'
				input: $input.text().trim()
				output: $output.text().trim()
				run: not $output.length
				links: app.additionalLinks[lang]
				linksExist: !!app.additionalLinks[lang].length
			
			$('#playground').html Mustache.render template, data
			
			examples = (num) ->
				example = $('#template-example-'+num+'-lang-'+lang).html().trim()
				$('#template-example-'+num).html(example)
			
			examples number for number in [1..9]
			
			prettyPrint() if not @retarded
			$('title').text data.title if @changeTitle
			History.pushState {}, data.title, "/#{lang}/" if @changeUrl
			
			@changeUrl = true
			
		logo: (original = true) ->
			
			$logo = $ "#wrap-inner h1 a"
			
			if original
				$logo.text "hashids"
			else
				hash = @hashids.encrypt Math.floor Math.random() * 1000
				$logo.text hash
			
		loopLogo: (index = 0) ->
			
			if @loop[index]
				@logo false
				setTimeout `function() { app.loopLogo(++index) }`, @loop[index]
			else
				@logo true
				setTimeout "app.loopLogo()", 40000
			
	$ ->
		
		app.hashids = new Hashids "this is my salt", 7
		History = window.History
		
		window.console2 = log: ->
			output = $('#output')
			output.text ""
			for argument in arguments
				if output.text().length
					output.append ', '
				output.append argument
		
		$('#documentation button').click (e) ->
			
			$(@).parent().remove()
			$('#documentation .hidden').removeClass 'hidden'
			$('#documentation').removeClass 'section'
		
		$('.clickable').click (e) ->
			
			e.preventDefault()
			
			that = $ @
			lang = that.attr 'id'
			
			if app.retarded
				window.location = "/#{lang}/"
				return
			
			app.select lang
			
		$('#run').live 'click', ->
			try
				code = $(@).prev().text().replace /console\.log/gi, 'console2.log'
				if $('.clickable.selected').attr('id') == 'coffeescript'
					code = CoffeeScript.compile code
				eval code
			catch e
				$('#output').text '<error> ' + e
		
		app.checkPath()
		
		History.Adapter.bind window, 'statechange', ->
			app.checkPath()
		
		setTimeout "app.loopLogo()", 20000
		