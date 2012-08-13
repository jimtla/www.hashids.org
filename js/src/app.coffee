	
	# coffee -o lib/ -cw src/
	
	app =
		
		changeUrl: false
		changeTitle: true
		checkPath: ->
			token = window.location.pathname.replace(/\//g, '')
			el = $('.available a[rel="'+token+'"]')
			el.click() if el
		
	$ ->
		
		History = window.History
		
		if typeof console isnt "undefined"
			window.console = log: ->
				output = $('#output')
				output.text ""
				for argument in arguments
					if output.text().length
						output.append ', '
					output.append argument
		
		$('.available a').live 'click', (e) ->
			e.preventDefault()
			
			that = $ @
			$('.available a').removeClass 'selected'
			that.addClass 'selected'
			
			template = $('.template-' + that.attr 'rel').html()
			data =
				title: that.text()
				github: that.attr 'href'
			
			$('#playground').html Mustache.render template, data
			prettyPrint()
			
			$('title').text data.title if app.changeTitle
			History.pushState({}, data.title, "/" + that.attr('rel') + "/") if app.changeUrl
			
			app.changeUrl = true
			
		$('#run').live 'click', ->
			try
				code = $(@).prev().text()
				if $('.available a.selected').attr('rel') == 'coffeescript'
					code = CoffeeScript.compile code
				eval code
			catch e
				$('#output').text '<error> ' + e
		
		app.checkPath()
		History.Adapter.bind window, 'statechange', ->
			app.checkPath()
		
		if not window.location.pathname.replace(/\//g, '')
			app.changeTitle = false
			$('.available a').first().click()
		