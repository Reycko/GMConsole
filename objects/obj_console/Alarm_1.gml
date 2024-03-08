/// @description Put your commands here!
// VVVVVVVVVVVVVVVVVVVVVV These bug out if you make your ConCommandMeta or ConCommandArg on multiple lines.
// Feather disable GM1019
// Feather disable GM1020


// Template commands:
/*
con_add_command(new ConCommandMeta
(
	"my_command_with_meta_that_spans_over_multiple_lines", // If you put any spaces in the name, they will be replaced with underscores.
	"This is my command! It's meta uses multiple lines!", // Description
	[
		// It is good practice to make all optional arguments at the end of your command.
		new ConCommandArg("my_argument", "string", "This is my cool argument!"), // Command arguments. arg and description are not used by the console itself as of now. See built-in command `help` for an example on how to query them.
		new ConCommandArg("my_optional_number", "number", "This is my cool optional number!", true); // Optional argument, value is used for metadata only (this is part of why missing args have to be manually handled)
	], 
	["my_command_alias"], // Command can now be called with "my_command_alias". 
),
function(_args, _arg_count) // _args[0] is the command name, _args[1] is the first argument, etc..
{
	// MAKE SURE TO HANDLE MISSING ARGUMENTS YOURSELF! While con_call_command() will change your command's type accordingly, it will NOT account for missing arguments!
	// If your command asks for another command as an argument, you can use con_translate_alias().
	if (_arg_count < 1) { con_log(con.enums.logtype.error, "Argument 1 is missing!"); return "%h"; } // Not enough required args were given
	if (!con_arg_valid(_args, 1)) { return "%h"; } // %h means hiding the "Command returned" text afer a command
	
	var _ret = _args[1]; // Since we know that the argument is valid, we can use it in our code.
	

	//If you didn't already know, you can make strings like below to get the equivalent of Python f-strings 
	//or JavaScript template literals (However JS template literals use ${} as format instead of {})
	if (_arg_count >= 2 && con_arg_valid(_args, 1)) { _ret = $"\nThe sum of the optional number and 7 is {string(_args[2] + 7)}"; }
	
	return _ret;
});

// Single line command.
//										V Name						V Description									  V We are not defining any arguments, so we can use a function without any
con_add_command(new ConCommandMeta("my_single_line_command", "This is a command that uses a singular line."), function() { return "Hello!"; } );
*/