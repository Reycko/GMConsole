/// @description Open console and execute commands
if keyboard_check_pressed(vk_f5)
	if (con.open) { keyboard_string = con.previous_keyboard_string; con_close(); } 
	else { con.previous_keyboard_string = keyboard_string; con_open(); keyboard_string = ""; }

if (con.open)
{
	if (keyboard_check_pressed(vk_tab))
	{
		keyboard_string += "    ";
	}
	if (keyboard_check_pressed(vk_enter) && string_replace_all(keyboard_string, " ", "") != "")
	{
		while (string_char_at(keyboard_string, 1) == " ")
		{
			keyboard_string = string_copy(keyboard_string, 2, string_length(keyboard_string));
		}
		con_call_command(string_split(keyboard_string, " "));
		keyboard_string = ""
	}
	// Feather disable once GM2016
	_cmdargs = undefined;
}