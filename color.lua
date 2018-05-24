-- Color table
-- TODO: add colorblind mode drawing functions to each color

COLOR = {
	{r = 1, g = 0, b = 0},
	{r = 0, g = 0, b = 1},
	{r = 0, g = 1, b = 0},
	{r = 1, g = 0, b = 1},
	{r = 0, g = 1, b = 1},
	{r = 1, g = 1, b = 0},
	{r = 1, g = 0.5, b = 0},
	{r = 0, g = 0.75, b = 1},
	{r = 0.5, g = 0, b = 1},
	{r = 1, g = 0, b = 0.5},
	{r = 1, g = 1, b = 1},
	{r = 0.5, g = 0.5, b = 0.5}
}

function compare_color(t, other)
	return (t.r == other.r and t.g == other.g and t.b == other.b)
end