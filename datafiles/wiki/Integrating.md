# Integrating GMConsole to your game
This will go over how to use GMConsole's logging, and how to add commands.  
<center><span style="color:yellow;"><img src="./img/emoji/information.png" alt="[Information]" width=20px/> This page is made for developers only.</span></center>

---
#### Table of contents:
- [Logging](#logging)  
- [Adding your own commands](#adding-your-own-commands)  

---
## <a name="logging">Logging</a>
Logging with GMConsole is very easy.  
GMConsole has a function called `con_log()`. You can use it in your code using the console enum "logtype". Here is how you could implement a function that adds the player's X to the console as a debug log:

```gml
// Step event
// [...]
// You can log like this:
con_log(obj_gmconsole.con.enum.logtype.debug, x);
// Or also like this, if you have set up the `gmc` macro (see gmconsole_init):
con_log(gmc.con.enum.logtype.debug, x);
```
Your object's X position now prints to the console every frame.

---
## <a name="adding-your-own-commands">Adding your own commands</a>
Adding your own commands is easy as well.  
To add commands, you need to use the `con_add_command()` function. (Note: You can use this function anywhere, but you cannot add a command twice.)  

If you want to make sure that your commands will properly get added, the function `con_user_console_commands()` once all built-in commands have been added to the console.  
Here are 2 template commands as an example, with comments.

```
function con_user_console_commands()
{
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
	// We are not defining any arguments, so we can use a function without any
	con_add_command(new ConCommandMeta("my_single_line_command", "This is a command that uses a singular line."), function() { return "Hello!"; } );
}
```

<span style="color:yellow;"><img src="./img/emoji/information.png" alt="[Information]" width=20px/>con_add_command() returns true if your command was successfully added, and false if it wasn't.\*  
\* This does **not** mean that your command will work, but that the console will recognize it.
</span>  