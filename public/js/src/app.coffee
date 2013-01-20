	
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
				title: that.text()
				github: that.attr 'github'
				input: $input.text().trim()
				output: $output.text().trim()
				run: not $output.length
			
			$('#playground').html Mustache.render template, data
			
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
		
		$('#read-more button').click (e) ->
			
			$('#initial').remove()
			$('#documentation > *').css 'display', 'block'
		
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
		