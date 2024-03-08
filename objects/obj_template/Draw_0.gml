var _col = [255, 255, 255];
for (var i = 0; i < view_hport[0]; i++)
{
	for (var j = 0; j < view_wport[0]; j++)
	{
		draw_set_color(make_color_rgb(_col[0] % 256, _col[1] % 256, _col[2] % 256));
		draw_point(j, i);
		_col[j % 3] += 1;
	}
}