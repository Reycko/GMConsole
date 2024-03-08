# GMConsole for GameMaker
Note: this is my first tool, expect a bug or two.
Add your commands in obj_console's alarm 1.
Change game name and version in Create code -> Console variables -> Strings
You can change strings and customize UI in Create code -> Console variables.

If you have a custom exception handler, make it a function called "_exception_unhandled_handler". The console will pick up on it and add the built-in command `crash`.

Tutorial for stuff like adding commands is in the wiki.

## Known issues 
Opening the console on non-16:9 games will make the game be in 16:9 until reboot 
