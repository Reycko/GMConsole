/// @description Initialize `con` struct, Define functions
if instance_number(obj_console) > 1
{
	instance_destroy(self); // Self destruct if a console already exists
}

con = {}; // This is our console's struct!
/*
	If you modify/add internal variables, then
	make sure to define your vars in the con 
	struct.
	
	Only use object variables like temporary vars
	that can be used in code for multiple events,
	or in between a *_foreach() function.
	
	The reason is for us to be able to define vars
	like `x` or `visible` without using the built-
	in variables for objects. -Reycko
*/

// Settings at region: Console variables -> Console settings
#region Console variables
#region Others
con.open = false;
con.version = "0.2.4"
con.build = {
	release: GM_build_type == "exe", // false = test run
	compiled: code_is_compiled(),
};
con.output = ds_list_create();

con.game_guisize = [display_get_gui_width(), display_get_gui_height()];
con.guisize = [1280, 720];
con.deactivation = []; // this is used for opening and closing console
con.screenshot = -1;
#endregion
#region Console UI customization
con.ui = {
	text: {
		colors: {
			// Would name "def" default but that's reserved
			def: c_white, // Default color for stuff like top bar or cmdbar
		},
		opacity: 0.75,
		output: {
			colors: {
				log: c_white,
				warn: c_yellow,
				error: c_red,
				debug: c_gray,
			},
			opacity: 1,
		},
	},
	
	background: {
		color: c_black,
		opacity: 0.75,
	},
	
	separator: {
		width: 2,
		col: c_white,
		opacity: 0.5,
	},
	
	cmdbar: {
		input_bar: {
			show: true,
			width: 3,
			opacity: 1,
		},
		opacity_empty: 0.5,
		opacity: 1,
	},
};
#endregion
#region Strings n stuff
con.strings = {
	game: "Game",
	game_version: "1.0",
	top: {
		console: "Console",
		on: "on",
		gm: "GameMaker",
		builddate: "Build date",
	},
	build: {
		test: "TEST",
		release: "RELEASE/VM",
		compiled: "COMPILED/YYC",
		build: "BUILD",
	},
	output: {
		log: "log",
		warn: "warn",
		error: "error",
		err: "error",
		debug: "debug",
	},
	cmdbar: {
		returned: "Command returned",
		couldnt_exec: "Couldn't execute command:",
		invalid: "Invalid command,",
		invalid_cmds: "you can see a list of commands with `cmds`",
		line: "line",
		types: {
			string: "string",
			number: "number",
			int32: "int32",
			int64: "int64",
			bool: "boolean",
			struct: "struct",
			array: "array",
			undefined: "nothing",
		},
		no_print: "Command did not print anything"
	},
};
#endregion
#region Console "enums"
con.enums = {};
con.enums.logtype =
{
	log: 0,
	warn: 1,
	error: 2,
	err: 2, // Same as "error"
	debug: 3, // Will only print in test runs
	none: 4,
}
#endregion
#region Console settings
con.settings = {
	show_debug_logs: !con.build.release, // Show logs with the debug type
	can_open: !con.build.release, // If false, console cannot be opened.
};
#endregion
#endregion
#region Console functions
#region Opening/closing console
function con_open()
{
	if (con.open || !con.settings.can_open) { return; }
	display_set_gui_size(con.guisize[0], con.guisize[1]);
	var _deactivation_index = [];
	var _console = id;
	with (all)
	{
		if (id != _console)
		{
			array_push(_deactivation_index, self);
			instance_deactivate_object(self);
		}
	}
	con.open = true;
	if (!sprite_exists(con.screenshot))
	{
		con.screenshot = sprite_create_from_surface(application_surface, 0, 0, view_wport[view_current], view_hport[view_current], false, false, 0, 0);
	}
	con.deactivation = _deactivation_index;
}

function con_close()
{
	if (!con.open || !con.settings.can_open) { return; }
	display_set_gui_size(con.game_guisize[0], con.game_guisize[1]);
	for (var i = 0; i < array_length(con.deactivation); i++)
	{
		instance_activate_object(con.deactivation[i]);
	}
	if (sprite_exists(con.screenshot))
	{
		sprite_delete(con.screenshot);
	}
	con.open = false;
}
#endregion
#region Log to console
// Inverting the arguments in this weirdly causes isues
// Feather disable once GM1056
/// @param	{Struct.con.enums.logtype}	_type
/// @param	{Any}						_text
function con_log(_type = con.enums.logtype.log, _text)
{
	_text = string(_text); // Stringification
	// If you've dealt with the trim bug, then uncomment the second line and delete the first.
	//ds_list_add(con.output, [_type, date_current_datetime(), string_replace(_text, "\n", " ")]);
	ds_list_add(con.output, [_type, date_current_datetime(), _text, true]);
}
#endregion
#region Constructors

/// @param	{String}				_arg			The name of the argument.
/// @param	{String}				_type			The argument's type. The console will use typeof.
/// @param	{String}				_description	The description for your argument. Used by `cmds` to give a description.
/// @param	{Bool}					_optional		Whether this is an optional argument.
/// @param	{Array<Any>}			_values			Accepted values, leave blank to allow anything (of the specified type).
function ConCommandArg(_arg, _type, _description, _optional = false, _values = []) constructor
{
	arg = _arg;
	type = _type;
	description = _description;
	optional = _optional;
	values = _values;
}
/// @param	{String}						_name			Command name.
/// @param	{String}						_description	Command description.
/// @param	{Array<Struct.ConCommandArg>}	_arguments		Arguments for the command.
/// @param	{Array<String>}					_aliases		Command aliases.
function ConCommandMeta(_name, _description, _arguments = [], _aliases = []) constructor
{
	name = _name;
	description = _description;
	arguments = _arguments;
	aliases = _aliases;
}
#endregion
#region Command-related functions
/// @function												con_add_command(name, description, function, aliases)
/// @description											Add a console command.
///															If success, returns true, else returns the exception struct.
/// @param			{Struct.ConCommandMeta}	_meta			The name of the command to add.
/// @param			{Function}				_func			The function to execute. Add an argument as a 
///															parameter to get command arguments.
/// @return			{Undefined}
function con_add_command(_meta, _func)
{
	con.commands.metas[$ _meta[$ "name"]] = _meta;
	con.commands.funcs[$ _meta[$ "name"]] = _func;
}
#endregion
#region Others
/// @param		{String}	_val		Input value.
/// @param		{String}	_to			Tries to convert _val to this.
/// @returns	{Any}
function con_convert_value(_val, _to)
{
	switch (_to)
	{
		case "string": return string(_val);
		case "real": case "number": return real(_val);
		case "int64": return int64(_val);
	}
	/*con_log(con.enums.logtype.err, $"con_convert_value(): Invalid or unsupported type `{_to}`.");
	return undefined;*/
	throw($"con_convert_value(): Invalid or unsupported type `{_to}`.");
	return undefined;
}

/// @param		{Array<String>}	_args		Contents of the command's `args` array.
/// @param		{Real}			_index		Index of the args array to get the value from.
/// @returns	{Any}						argument, converted based on it's meta.
function con_get_arg(_args, _index)
{
	// TODO: Implement this in a way that `args` directly gives these! (Step code?)
	// TODO: Convert all the text here to con.strings
	var _arg_meta = con.commands.metas[$ _args[0]].arguments[_index - 1];
	if (_index == 0) { return _arg_meta.name; }
	var _fail = [false, ""];
	if (_index >= array_length(_args)) { _fail = [true, $"Argument {_index}: expected {_arg_meta.type}"]; }
	if (is_undefined(_args[_index])) { _fail = [true, $"Argument {_index}: expected {_arg_meta.type}"]; }
	
	var _arg = con_convert_value(_args[_index], _arg_meta.type);
	if (typeof(_arg) != _arg_meta.type) { _fail = [true, $"Argument {_index}: expected {_arg_meta.type}, got {typeof(_arg)}"]; }
	
	if (array_length(_arg_meta.values) >= 1)
	{
		if (!array_contains(_arg_meta.values, _arg)) { _fail = [true, $"Argument {_index}: expected `{string_join_ext("`|`", _arg_meta.values)}`, got {_arg}"]; }
	}
	
	if (_fail[0]) { throw(_fail[1]); }
	return _arg;
}

/// @returns	{Struct}
function con_get_aliases()
{
	var _ret = {};
	var _metas = con.commands.metas;
	for (var i = 0; i < struct_names_count(_metas); i++)
	{
		var key = struct_get_names(_metas)[i];
		var value = struct_get(_metas, key);
		_ret[$ key] = value[$ "aliases"];
	}
	return _ret;
}

/// @param		{String}		_alias
/// @returns	{String | Bool}
function con_translate_alias(_alias)
{
	if (variable_instance_exists(self, con.commands.funcs[$ _alias]) || !is_undefined(con.commands.funcs[$ _alias])) { return _alias; } // Is already the actual name
	_ret = _alias;
	struct_foreach(con_get_aliases(), function(_key, _value)
	{
		for (var i = 0; i < array_length(_value); i++)
		{
			var _check = _value[i];
			if (string_lower(_ret) == string_lower(_check))
			{
				_ret = _key;
			}
		}
	});
	
	var __ret = _ret;
	_ret = undefined;
	return (__ret == _alias ? false : __ret);
}

/// @param		{String}	_str	The input string.
///	@returns	{Bool}				Whether or not said string is a valid number.
function string_is_number(_str)
{
	return string_digits(_str) != "";
}

/// @param		{String}		_str	Input string.
/// @returns	{Real | Bool}			If number, the converted number, else false.
function string_to_number(_str)
{
	if !string_is_number(_str) { return false; }
	var _negative = string_char_at(_str, 1) == "-";
	return _negative ? -real(string_digits(_str)) : real(string_digits(_str)); //TODO: Make this use math instead of an ternary (optimization)
}
#endregion
#endregion
#region CONSOLE COMMANDS
con.commands = {
	funcs: {},
	metas: {},
};

con_add_command(new ConCommandMeta
(
	"help", // ConCommandMeta: name
	"Lists all commands. Call on a command to see it's description.", // ConCommandMeta: description
	[
		new ConCommandArg("command", "string", "Specific command to get information about.", true), // ConCommandMeta: arguments (Array of `ConCommandArg`s). This is arg 1
		//new ConCommandArg("example_optional_arg", "bool", true)
	], 
	["cmds", "commands"] // ConCommandMeta: aliases
), 

function(_args) // Function
{
	if (array_length(_args) < 2) // No arguments provided (_args[0] is the command name)
	{
		var _ret = "";
		for (var i = 0; i < struct_names_count(con.commands.funcs); i++)
		{
			_ret += $"{struct_get_names(con.commands.funcs)[i]}, ";
		}
		_ret = string_copy(_ret, 1, string_length(_ret) - 2);
		return _ret;
	}
	else
	{
		var _ret = "";
		var _cmd = con_translate_alias(con_get_arg(_args, 1));
		if (_cmd == false) { con_log(con.enums.logtype.err, $"Invalid command/alias was specified: `{con_get_arg(_args, 1)}`"); return; } // Using `!_cmd` would throw an error
		var _meta = con.commands.metas[$ _cmd];
		var _cmdargs = _meta.arguments;
		var _cmdargs_fmt = ""; // Formatted args
		for (var i = 0; i < array_length(_meta.arguments); i++)
		{
			// Feather disable once GM1100
			_cmdargs_fmt += $"\t{_cmdargs[i].arg}<{_cmdargs[i].type}>{_cmdargs[i].optional ? " (optional) " : ""}{array_length(_cmdargs[i].values) >= 1 ? $" (takes the following values, separated by |: `{string_join_ext("|", _cmdargs[i].values)}`)" : ""}: {_cmdargs[i].description}\n";
		}
		// Feather disable once GM1100
		_ret = $"\n{_meta.name}: {_meta.description}\n{_meta.arguments != [] ? $"Arguments: \n{_cmdargs_fmt}" : "Command takes no arguments"}\n{_meta.aliases != [] ? $"Aliases: `{string_join_ext("`|`", _meta.aliases)}`" : "Command has no aliases"}";
		return _ret;
	}
});

con_add_command(new ConCommandMeta
(
	"quit",
	"Exits the game.",
	[],
	["exit", "stop"],
), 
function(_args)
{
	game_end();
});

// OLD COMMANDS - TODO: REMAKE THESE
/*
con_add_command("quit", "Exits the game.", function(_args) 
{
	game_end(); 
}, ["exit", "stop"]);
con_add_command("restart", "Restarts the game.", function(_args) 
{ 
	game_restart(); 
}, ["reboot"]);
con_add_command("time", "Shows date_current_datetime() and it's string result.", function(_args)
{
	return $"{date_current_datetime()}|{date_datetime_string(date_current_datetime())}";
});

con_add_command("aliases", "Lists all aliases.", function(_args)
{
	var _return = "";
	_ret = "";
	struct_foreach(con.commands.aliases, function(_key, _value)
	{
		_ret += $"{_key} -> {_value}; ";
	});
	_return = string_copy(_ret, 1, string_length(_ret) - 2);
	_ret = undefined;
	return _return;
}, ["alias"]);

con_add_command("clear", "Clears console.", function(_args)
{
	ds_list_clear(con.output);
	return ds_list_empty(con.output);
}, ["cls"]);

con_add_command("speed", "Get or adjust game speed.", function(_args)
{
	var _type = con_get_arg_safe(_args, 1);
	if (is_undefined(_type)) { return; }
	if (string_pos(_type, "set|get") == 0) { con_log(con.enums.logtype.err, "Invalid argument 1"); return; }
	var _mode = con_get_arg_safe(_args, 2);
	if (is_undefined(_mode)) { return; }
	if (string_pos(_mode, "fps|us") == 0) { con_log(con.enums.logtype.err, "Invalid argument 2"); return; }
	_mode = _mode == "fps" ? gamespeed_fps : gamespeed_microseconds;
	var _to = undefined; // Ironically defining as undefined
	if (_type == "set")
	{
		_to = con_get_arg_safe(_args, 3);
		if (is_undefined(_to)) { return; }
		_to = string_to_number(_to);
		if (_to == false) { con_log(con.enums.logtype.err, "Invalid argument 3"); return; }
	}
	
	switch (_type)
	{
		case "set":
			game_set_speed(_to, _mode);
			return game_get_speed(_mode) == _to;
		break;
		case "get":
			return game_get_speed(_mode);
		break;
	}
});

if (!is_undefined(live_enabled) && live_enabled)
{
	con_add_command("eval", "Run a command live using GMLive.", function(_args)
	{
		var _args2 = [];
		array_copy(_args2, 0, _args, 1, array_length(_args) - 1);
		var _call = "";
		for (var i = 0; i < array_length(_args2); i++)
		{
			_call += $"{_args2[i]} ";
		}
		_call = string_copy(_call, 1, string_length(_call) - 1); // Remove trailing space
		if (live_execute_string(_call)) { return live_result; } else { con_log(con.enums.logtype.err, $"Command failed to execute: {string(live_result)}"); }
	});
}*/

/*
// TEMPLATE COMMAND
con_add_command("mycommand", "Example command!", function(_args)
{
	show_message("I'm such a silly function!");
	con_log(con.enums.logtype.log, string(_args)); // Prints out all arguments including command
}, ["alias1", "alias2"], // You can now call "mycommand" using "alias1" or "alias2"
function(_e) // Optional argument, error handler.
{
	show_message("This is a custom error handler!");
	show_message($"Exception: {string(_e)}");
});
*/
#endregion