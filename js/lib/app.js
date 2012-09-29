// Generated by CoffeeScript 1.3.3
var app;

Function.prototype.method = function(name, func) {
  if (!this.prototype[name]) {
    this.prototype[name] = func;
    return this;
  }
};

String.method('trim', function() {
  return this.replace(/^\s+|\s+$/g, '');
});

app = {
  changeUrl: false,
  changeTitle: false,
  retarded: $.browser.msie === true && parseInt($.browser.version) <= 9,
  loop: [2300, 2000, 1500, 1000, 1000, 750, 750, 500, 300, 300, 300, 300, 300, 300, 300],
  hashids: void 0,
  checkPath: function() {
    var lang;
    lang = window.location.pathname.replace(/\//g, '');
    if (lang) {
      this.changeTitle = true;
    }
    return this.select(lang || 'javascript');
  },
  select: function(lang) {
    var $input, $output, data, template, that;
    that = $('#' + lang);
    if (that.hasClass('selected')) {
      return;
    }
    that.addClass('selected').siblings().removeClass('selected');
    $input = $("#template-lang-" + lang + "-input");
    $output = $("#template-lang-" + lang + "-output");
    template = $('#template-playground').html();
    data = {
      title: that.text(),
      github: that.attr('href'),
      input: $input.text().trim(),
      output: $output.text().trim(),
      run: !$output.length
    };
    $('#playground').html(Mustache.render(template, data));
    if (!this.retarded) {
      prettyPrint();
    }
    if (this.changeTitle) {
      $('title').text(data.title);
    }
    if (this.changeUrl) {
      History.pushState({}, data.title, "/" + lang + "/");
    }
    return this.changeUrl = true;
  },
  logo: function(original) {
    var $logo, hash;
    if (original == null) {
      original = true;
    }
    $logo = $("#wrap-inner h1 a");
    if (original) {
      return $logo.text("hashids");
    } else {
      hash = this.hashids.encrypt(Math.floor(Math.random() * 1000));
      return $logo.text(hash);
    }
  },
  loopLogo: function(index) {
    if (index == null) {
      index = 0;
    }
    if (this.loop[index]) {
      this.logo(false);
      return setTimeout(function() { app.loopLogo(++index) }, this.loop[index]);
    } else {
      this.logo(true);
      return setTimeout("app.loopLogo()", 40000);
    }
  }
};

$(function() {
  var History;
  app.hashids = new hashids("this is my salt", 7);
  History = window.History;
  if (typeof console !== "undefined") {
    window.console = {
      log: function() {
        var argument, output, _i, _len, _results;
        output = $('#output');
        output.text("");
        _results = [];
        for (_i = 0, _len = arguments.length; _i < _len; _i++) {
          argument = arguments[_i];
          if (output.text().length) {
            output.append(', ');
          }
          _results.push(output.append(argument));
        }
        return _results;
      }
    };
  }
  $('.clickable').click(function(e) {
    var lang, that;
    e.preventDefault();
    that = $(this);
    lang = that.attr('id');
    if (app.retarded) {
      window.location = "/" + lang + "/";
      return;
    }
    return app.select(lang);
  });
  $('#run').live('click', function() {
    var code;
    try {
      code = $(this).prev().text();
      if ($('.clickable.selected').attr('id') === 'coffeescript') {
        code = CoffeeScript.compile(code);
      }
      return eval(code);
    } catch (e) {
      return $('#output').text('<error> ' + e);
    }
  });
  app.checkPath();
  History.Adapter.bind(window, 'statechange', function() {
    return app.checkPath();
  });
  return setTimeout("app.loopLogo()", 20000);
});
