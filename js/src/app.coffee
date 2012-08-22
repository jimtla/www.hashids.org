	
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
				project: that.attr('href').split('/')[4]
				input: $input.text().trim()
				output: $output.text().trim()
				run: not $output.length
			
			$('#playground').html Mustache.render template, data
			
			prettyPrint() if not @retarded
			$('title').text data.title if @changeTitle
			History.pushState {}, data.title, "/#{lang}/" if @changeUrl
			
			@changeUrl = true
			
	$ ->
		
		#alert app.templates['javascript']
		History = window.History
		
		if typeof console isnt "undefined"
			window.console = log: ->
				output = $('#output')
				output.text ""
				for argument in arguments
					if output.text().length
						output.append ', '
					output.append argument
		
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
				code = $(@).prev().text()
				if $('.clickable.selected').attr('id') == 'coffeescript'
					code = CoffeeScript.compile code
				eval code
			catch e
				$('#output').text '<error> ' + e
		
		app.checkPath()
		
		History.Adapter.bind window, 'statechange', ->
			app.checkPath()
		