function c_rainbow(divider) // https://www.reddit.com/r/gamemaker/comments/70t9eg/comment/hnjs73h
{
	return make_color_hsv((current_time / divider) % 255,255,255);
} 