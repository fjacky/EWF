// Generated by CoffeeScript 1.6.1
var Mini, WSF_AUTOCOMPLETE_CONTROL, WSF_BUTTON_CONTROL, WSF_CHECKBOX_CONTROL, WSF_CHECKBOX_LIST_CONTROL, WSF_CONTROL, WSF_FORM_ELEMENT_CONTROL, WSF_GRID_CONTROL, WSF_HTML_CONTROL, WSF_INPUT_CONTROL, WSF_MAX_VALIDATOR, WSF_MIN_VALIDATOR, WSF_PAGE_CONTROL, WSF_PAGINATION_CONTROL, WSF_PROGRESS_CONTROL, WSF_REGEXP_VALIDATOR, WSF_REPEATER_CONTROL, WSF_TEXTAREA_CONTROL, WSF_VALIDATOR, build_control, cache, controls, template, tmpl,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

cache = {};

template = tmpl = function(str, data) {
  var fn;
  fn = (!/\W/.test(str) ? cache[str] = cache[str] || tmpl(str) : new Function("obj", "var p=[],print=function(){p.push.apply(p,arguments);};" + "with(obj){p.push('" + str.replace(/[\r\t\n]/g, " ").split("{{").join("\t").replace(/((^|}})[^\t]*)'/g, "$1\r").replace(/\t=(.*?)}}/g, "',$1,'").split("\t").join("');").split("}}").join("p.push('").split("\r").join("\\'") + "');}return p.join('');"));
  if (data) {
    return fn(data);
  } else {
    return fn;
  }
};

Mini = {
  compile: function(t) {
    return {
      render: template(t)
    };
  }
};

build_control = function(control_name, state, control) {
  var $el, type, typeclass;
  $el = control.$el.find('[data-name=' + control_name + ']');
  type = $el.data('type');
  typeclass = null;
  try {
    typeclass = eval(type);
  } catch (e) {
    typeclass = WSF_CONTROL;
  }
  if ((type != null) && (typeclass != null)) {
    return new typeclass(control, $el, control_name, state);
  }
  return null;
};

WSF_VALIDATOR = (function() {

  function WSF_VALIDATOR(parent_control, settings) {
    this.parent_control = parent_control;
    this.settings = settings;
    this.error = this.settings.error;
    return;
  }

  WSF_VALIDATOR.prototype.validate = function() {
    return true;
  };

  return WSF_VALIDATOR;

})();

WSF_REGEXP_VALIDATOR = (function(_super) {

  __extends(WSF_REGEXP_VALIDATOR, _super);

  function WSF_REGEXP_VALIDATOR() {
    WSF_REGEXP_VALIDATOR.__super__.constructor.apply(this, arguments);
    this.pattern = new RegExp(this.settings.expression, 'g');
  }

  WSF_REGEXP_VALIDATOR.prototype.validate = function() {
    var res, val;
    val = this.parent_control.value();
    res = val.match(this.pattern);
    return res !== null;
  };

  return WSF_REGEXP_VALIDATOR;

})(WSF_VALIDATOR);

WSF_MIN_VALIDATOR = (function(_super) {

  __extends(WSF_MIN_VALIDATOR, _super);

  function WSF_MIN_VALIDATOR() {
    return WSF_MIN_VALIDATOR.__super__.constructor.apply(this, arguments);
  }

  WSF_MIN_VALIDATOR.prototype.validate = function() {
    var val;
    val = this.parent_control.value();
    return val.length >= this.settings.min;
  };

  return WSF_MIN_VALIDATOR;

})(WSF_VALIDATOR);

WSF_MAX_VALIDATOR = (function(_super) {

  __extends(WSF_MAX_VALIDATOR, _super);

  function WSF_MAX_VALIDATOR() {
    return WSF_MAX_VALIDATOR.__super__.constructor.apply(this, arguments);
  }

  WSF_MAX_VALIDATOR.prototype.validate = function() {
    var val;
    val = this.parent_control.value();
    return val.length <= this.settings.max;
  };

  return WSF_MAX_VALIDATOR;

})(WSF_VALIDATOR);

WSF_CONTROL = (function() {

  function WSF_CONTROL(parent_control, $el, control_name, fullstate) {
    this.parent_control = parent_control;
    this.$el = $el;
    this.control_name = control_name;
    this.fullstate = fullstate;
    this.state = this.fullstate.state;
    this.load_subcontrols();
    return;
  }

  WSF_CONTROL.prototype.load_subcontrols = function() {
    var control_name, state;
    if (this.fullstate.controls != null) {
      return this.controls = (function() {
        var _ref, _results;
        _ref = this.fullstate.controls;
        _results = [];
        for (control_name in _ref) {
          state = _ref[control_name];
          _results.push(build_control(control_name, state, this));
        }
        return _results;
      }).call(this);
    } else {
      return this.controls = [];
    }
  };

  WSF_CONTROL.prototype.attach_events = function() {
    var control, _i, _len, _ref;
    console.log("Attached " + this.control_name);
    _ref = this.controls;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      control = _ref[_i];
      if (control != null) {
        control.attach_events();
      }
    }
  };

  WSF_CONTROL.prototype.update = function(state) {};

  WSF_CONTROL.prototype.get_state = function() {
    return this.state;
  };

  WSF_CONTROL.prototype.get_control_states = function() {
    var control, result, _i, _len, _ref;
    result = {};
    _ref = this.controls;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      control = _ref[_i];
      if (control != null) {
        result[control.control_name] = control.get_full_state();
      }
    }
    return result;
  };

  WSF_CONTROL.prototype.get_full_state = function() {
    return {
      "state": this.get_state(),
      "controls": this.get_control_states()
    };
  };

  WSF_CONTROL.prototype.process_update = function(new_states) {
    var control, _i, _len, _ref, _results;
    if (new_states[this.control_name] != null) {
      this.update(new_states[this.control_name]);
    }
    _ref = this.controls;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      control = _ref[_i];
      if (control != null) {
        _results.push(control.process_update(new_states));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  WSF_CONTROL.prototype.get_context_state = function() {
    if (this.parent_control != null) {
      return this.parent_control.get_context_state();
    }
    return this.get_full_state();
  };

  WSF_CONTROL.prototype.trigger_callback = function(control_name, event, event_parameter) {
    var self;
    if (this.parent_control != null) {
      return this.parent_control.trigger_callback(control_name, event, event_parameter);
    }
    self = this;
    return $.ajax({
      type: 'POST',
      url: '?' + $.param({
        control_name: control_name,
        event: event
      }),
      data: JSON.stringify(this.get_full_state()),
      processData: false,
      contentType: 'application/json',
      cache: false
    }).done(function(new_states) {
      return self.process_update(new_states);
    });
  };

  WSF_CONTROL.prototype.on = function(name, callback, context) {
    if (this._events == null) {
      this._events = {};
    }
    if (this._events[name] == null) {
      this._events[name] = [];
    }
    this._events[name].push({
      callback: callback,
      context: context
    });
    return this;
  };

  WSF_CONTROL.prototype.trigger = function(name) {
    var ev, _i, _len, _ref, _ref1;
    if (((_ref = this._events) != null ? _ref[name] : void 0) == null) {
      return this;
    }
    _ref1 = this._events[name];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      ev = _ref1[_i];
      ev.callback.call(ev.context);
    }
    return this;
  };

  return WSF_CONTROL;

})();

WSF_PAGE_CONTROL = (function(_super) {

  __extends(WSF_PAGE_CONTROL, _super);

  function WSF_PAGE_CONTROL(fullstate) {
    this.fullstate = fullstate;
    this.state = this.fullstate.state;
    this.parent_control = null;
    this.$el = $('[data-name=' + this.state.id + ']');
    this.control_name = this.state.id;
    this.load_subcontrols();
  }

  return WSF_PAGE_CONTROL;

})(WSF_CONTROL);

controls = {};

WSF_BUTTON_CONTROL = (function(_super) {

  __extends(WSF_BUTTON_CONTROL, _super);

  function WSF_BUTTON_CONTROL() {
    return WSF_BUTTON_CONTROL.__super__.constructor.apply(this, arguments);
  }

  WSF_BUTTON_CONTROL.prototype.attach_events = function() {
    var self;
    WSF_BUTTON_CONTROL.__super__.attach_events.apply(this, arguments);
    self = this;
    return this.$el.click(function(e) {
      e.preventDefault();
      return self.click();
    });
  };

  WSF_BUTTON_CONTROL.prototype.click = function() {
    if (this.state['callback_click']) {
      return this.trigger_callback(this.control_name, 'click');
    }
  };

  WSF_BUTTON_CONTROL.prototype.update = function(state) {
    if (state.text != null) {
      this.state['text'] = state.text;
      return this.$el.text(state.text);
    }
  };

  return WSF_BUTTON_CONTROL;

})(WSF_CONTROL);

WSF_INPUT_CONTROL = (function(_super) {

  __extends(WSF_INPUT_CONTROL, _super);

  function WSF_INPUT_CONTROL() {
    return WSF_INPUT_CONTROL.__super__.constructor.apply(this, arguments);
  }

  WSF_INPUT_CONTROL.prototype.attach_events = function() {
    var self;
    WSF_INPUT_CONTROL.__super__.attach_events.apply(this, arguments);
    self = this;
    return this.$el.change(function() {
      return self.change();
    });
  };

  WSF_INPUT_CONTROL.prototype.change = function() {
    this.state['text'] = this.$el.val();
    if (this.state['callback_change']) {
      this.trigger_callback(this.control_name, 'change');
    }
    return this.trigger('change');
  };

  WSF_INPUT_CONTROL.prototype.value = function() {
    return this.$el.val();
  };

  WSF_INPUT_CONTROL.prototype.update = function(state) {
    if (state.text != null) {
      this.state['text'] = state.text;
      return this.$el.val(state.text);
    }
  };

  return WSF_INPUT_CONTROL;

})(WSF_CONTROL);

WSF_TEXTAREA_CONTROL = (function(_super) {

  __extends(WSF_TEXTAREA_CONTROL, _super);

  function WSF_TEXTAREA_CONTROL() {
    return WSF_TEXTAREA_CONTROL.__super__.constructor.apply(this, arguments);
  }

  return WSF_TEXTAREA_CONTROL;

})(WSF_INPUT_CONTROL);

WSF_AUTOCOMPLETE_CONTROL = (function(_super) {

  __extends(WSF_AUTOCOMPLETE_CONTROL, _super);

  function WSF_AUTOCOMPLETE_CONTROL() {
    return WSF_AUTOCOMPLETE_CONTROL.__super__.constructor.apply(this, arguments);
  }

  WSF_AUTOCOMPLETE_CONTROL.prototype.attach_events = function() {
    var self;
    WSF_AUTOCOMPLETE_CONTROL.__super__.attach_events.apply(this, arguments);
    self = this;
    this.$el.typeahead({
      name: this.control_name,
      template: this.state['template'],
      engine: Mini,
      remote: {
        url: "",
        replace: function(url, uriEncodedQuery) {
          self.state['text'] = self.$el.val();
          return '?' + $.param({
            control_name: self.control_name,
            event: 'autocomplete',
            states: JSON.stringify(self.get_context_state())
          });
        },
        filter: function(parsedResponse) {
          return parsedResponse[self.control_name]['suggestions'];
        },
        fn: function() {
          return self.trigger_callback(self.control_name, 'autocomplete');
        }
      }
    });
    this.$el.on('typeahead:closed', function() {
      return self.change();
    });
    return this.$el.on('typeahead:blured', function() {
      return self.change();
    });
  };

  return WSF_AUTOCOMPLETE_CONTROL;

})(WSF_INPUT_CONTROL);

WSF_CHECKBOX_CONTROL = (function(_super) {

  __extends(WSF_CHECKBOX_CONTROL, _super);

  function WSF_CHECKBOX_CONTROL() {
    return WSF_CHECKBOX_CONTROL.__super__.constructor.apply(this, arguments);
  }

  WSF_CHECKBOX_CONTROL.prototype.attach_events = function() {
    var self;
    WSF_CHECKBOX_CONTROL.__super__.attach_events.apply(this, arguments);
    self = this;
    this.checked_value = this.state['checked_value'];
    return this.$el.change(function() {
      return self.change();
    });
  };

  WSF_CHECKBOX_CONTROL.prototype.change = function() {
    this.state['checked'] = this.$el.is(':checked');
    if (this.state['callback_change']) {
      this.trigger_callback(this.control_name, 'change');
    }
    return this.trigger('change');
  };

  WSF_CHECKBOX_CONTROL.prototype.value = function() {
    return this.$el.is(':checked');
  };

  WSF_CHECKBOX_CONTROL.prototype.update = function(state) {
    if (state.text != null) {
      this.state['checked'] = state.checked;
      return this.$el.prop('checked', state.checked);
    }
  };

  return WSF_CHECKBOX_CONTROL;

})(WSF_CONTROL);

WSF_FORM_ELEMENT_CONTROL = (function(_super) {

  __extends(WSF_FORM_ELEMENT_CONTROL, _super);

  function WSF_FORM_ELEMENT_CONTROL() {
    return WSF_FORM_ELEMENT_CONTROL.__super__.constructor.apply(this, arguments);
  }

  WSF_FORM_ELEMENT_CONTROL.prototype.attach_events = function() {
    var self, validator, validatorclass, _i, _len, _ref;
    WSF_FORM_ELEMENT_CONTROL.__super__.attach_events.apply(this, arguments);
    self = this;
    this.value_control = this.controls[0];
    if (this.value_control != null) {
      this.value_control.on('change', this.change, this);
    }
    this.serverside_validator = false;
    this.validators = [];
    _ref = this.state['validators'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      validator = _ref[_i];
      try {
        validatorclass = eval(validator.name);
        this.validators.push(new validatorclass(this, validator));
      } catch (e) {
        this.serverside_validator = true;
      }
    }
  };

  WSF_FORM_ELEMENT_CONTROL.prototype.change = function() {
    var validator, _i, _len, _ref;
    _ref = this.validators;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      validator = _ref[_i];
      if (!validator.validate()) {
        this.showerror(validator.error);
        return;
      }
    }
    this.showerror("");
    if (this.serverside_validator) {
      this.trigger_callback(this.control_name, 'validate');
    }
  };

  WSF_FORM_ELEMENT_CONTROL.prototype.showerror = function(message) {
    var errordiv;
    this.$el.removeClass("has-error");
    this.$el.find(".validation").remove();
    if (message.length > 0) {
      this.$el.addClass("has-error");
      errordiv = $("<div />").addClass('help-block').addClass('validation').text(message);
      return this.$el.find(".col-lg-10").append(errordiv);
    }
  };

  WSF_FORM_ELEMENT_CONTROL.prototype.update = function(state) {
    if (state.error != null) {
      return this.showerror(state.error);
    }
  };

  WSF_FORM_ELEMENT_CONTROL.prototype.value = function() {
    return this.value_control.value();
  };

  return WSF_FORM_ELEMENT_CONTROL;

})(WSF_CONTROL);

WSF_HTML_CONTROL = (function(_super) {

  __extends(WSF_HTML_CONTROL, _super);

  function WSF_HTML_CONTROL() {
    return WSF_HTML_CONTROL.__super__.constructor.apply(this, arguments);
  }

  WSF_HTML_CONTROL.prototype.value = function() {
    return this.$el.html();
  };

  WSF_HTML_CONTROL.prototype.update = function(state) {
    if (state.html != null) {
      this.state['html'] = state.html;
      return this.$el.html(state.html);
    }
  };

  return WSF_HTML_CONTROL;

})(WSF_CONTROL);

WSF_CHECKBOX_LIST_CONTROL = (function(_super) {

  __extends(WSF_CHECKBOX_LIST_CONTROL, _super);

  function WSF_CHECKBOX_LIST_CONTROL() {
    return WSF_CHECKBOX_LIST_CONTROL.__super__.constructor.apply(this, arguments);
  }

  WSF_CHECKBOX_LIST_CONTROL.prototype.attach_events = function() {
    var control, _i, _len, _ref;
    WSF_CHECKBOX_LIST_CONTROL.__super__.attach_events.apply(this, arguments);
    _ref = this.controls;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      control = _ref[_i];
      control.on('change', this.change, this);
    }
  };

  WSF_CHECKBOX_LIST_CONTROL.prototype.change = function() {
    return this.trigger("change");
  };

  WSF_CHECKBOX_LIST_CONTROL.prototype.value = function() {
    var result, subc, _i, _len, _ref;
    result = [];
    _ref = this.controls;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      subc = _ref[_i];
      if (subc.value()) {
        result.push(subc.checked_value);
      }
    }
    return result;
  };

  return WSF_CHECKBOX_LIST_CONTROL;

})(WSF_CONTROL);

WSF_PROGRESS_CONTROL = (function(_super) {

  __extends(WSF_PROGRESS_CONTROL, _super);

  function WSF_PROGRESS_CONTROL() {
    return WSF_PROGRESS_CONTROL.__super__.constructor.apply(this, arguments);
  }

  WSF_PROGRESS_CONTROL.prototype.attach_events = function() {
    var runfetch, self;
    WSF_PROGRESS_CONTROL.__super__.attach_events.apply(this, arguments);
    self = this;
    runfetch = function() {
      return self.fetch();
    };
    return setInterval(runfetch, 5000);
  };

  WSF_PROGRESS_CONTROL.prototype.fetch = function() {
    return this.trigger_callback(this.control_name, 'progress_fetch');
  };

  WSF_PROGRESS_CONTROL.prototype.update = function(state) {
    if (state.progress != null) {
      this.state['progress'] = state.progress;
      return this.$el.children('.progress-bar').attr('aria-valuenow', state.progress).width(state.progress + '%');
    }
  };

  return WSF_PROGRESS_CONTROL;

})(WSF_CONTROL);

WSF_PAGINATION_CONTROL = (function(_super) {

  __extends(WSF_PAGINATION_CONTROL, _super);

  function WSF_PAGINATION_CONTROL() {
    return WSF_PAGINATION_CONTROL.__super__.constructor.apply(this, arguments);
  }

  WSF_PAGINATION_CONTROL.prototype.attach_events = function() {
    var self;
    self = this;
    return this.$el.on('click', 'a', function(e) {
      e.preventDefault();
      return self.click(e);
    });
  };

  WSF_PAGINATION_CONTROL.prototype.click = function(e) {
    var nr;
    nr = $(e.target).data('nr');
    if (nr === "next") {
      return this.trigger_callback(this.control_name, "next");
    } else if (nr === "prev") {
      return this.trigger_callback(this.control_name, "prev");
    } else {
      return this.trigger_callback(this.control_name, "goto", nr);
    }
  };

  WSF_PAGINATION_CONTROL.prototype.update = function(state) {
    if (state._html != null) {
      return this.$el.html($(state._html).html());
    }
  };

  return WSF_PAGINATION_CONTROL;

})(WSF_CONTROL);

WSF_GRID_CONTROL = (function(_super) {

  __extends(WSF_GRID_CONTROL, _super);

  function WSF_GRID_CONTROL() {
    return WSF_GRID_CONTROL.__super__.constructor.apply(this, arguments);
  }

  WSF_GRID_CONTROL.prototype.attach_events = function() {
    var self;
    WSF_GRID_CONTROL.__super__.attach_events.apply(this, arguments);
    return self = this;
  };

  WSF_GRID_CONTROL.prototype.update = function(state) {
    if (state.datasource != null) {
      this.state['datasource'] = state.datasource;
    }
    if (state._body != null) {
      return this.$el.find('tbody').html(state._body);
    }
  };

  return WSF_GRID_CONTROL;

})(WSF_CONTROL);

WSF_REPEATER_CONTROL = (function(_super) {

  __extends(WSF_REPEATER_CONTROL, _super);

  function WSF_REPEATER_CONTROL() {
    return WSF_REPEATER_CONTROL.__super__.constructor.apply(this, arguments);
  }

  WSF_REPEATER_CONTROL.prototype.attach_events = function() {
    var self;
    WSF_REPEATER_CONTROL.__super__.attach_events.apply(this, arguments);
    return self = this;
  };

  WSF_REPEATER_CONTROL.prototype.update = function(state) {
    if (state.datasource != null) {
      this.state['datasource'] = state.datasource;
    }
    if (state._body != null) {
      this.$el.find('.repeater_content').html(state._body);
      return console.log(state._body);
    }
  };

  return WSF_REPEATER_CONTROL;

})(WSF_CONTROL);
