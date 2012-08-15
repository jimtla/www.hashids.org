	
	# coffee -o lib/ -cw src/
	
	app =
		
		changeUrl: false
		changeTitle: true
		
		checkPath: ->
			@select window.location.pathname.replace(/\//g, '') || 'javascript'
		
		select: (lang) ->
			
			that = $('#' + lang)
			that.addClass('selected').siblings().removeClass 'selected'
			
			template = $('.template-' + lang).html()
			data =
				title: that.text()
				project: that.attr('href').split('/')[4]
			
			$('#playground').html Mustache.render template, data
			prettyPrint()
			
			$('title').text data.title if @changeTitle
			History.pushState {}, data.title, "/#{lang}/" if @changeUrl
			
			@changeUrl = true
			
	$ ->
		
		History = window.History
		History.ok = $.browser.msie isnt true or parseInt($.browser.version) > 9
		
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
			
			if not History.ok
				url = lang
				window.location = "/#{url}/"
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
		