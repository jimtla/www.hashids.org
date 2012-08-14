	
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
		
		$('.clickable').live 'click', (e) ->
			
			that = $ @
			e.preventDefault()
			
			that.siblings().removeClass 'selected'
			that.addClass 'selected'
			
			template = $('.template-' + that.attr 'rel').html()
			data =
				title: that.text()
				github: that.attr 'href'
				project: that.attr('href').split('/')[4]
			
			$('#playground').html Mustache.render template, data
			prettyPrint()
			
			$('title').text data.title if app.changeTitle
			History.pushState({}, data.title, "/" + that.attr('rel') + "/") if History.enabled and app.changeUrl
			
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
			$('.clickable').first().click()
		