-- Drawing functions

shaders = {
	standard = love.graphics.getShader(),
	colorize = love.graphics.newShader[[
vec4 effect(vec4 vcolor, Image texture, vec2 texcoord, vec2 pixcoord)
{
    vec4 texcolor = Texel(texture, texcoord);
	
	number r = (vcolor.r == 0)? texcolor.r: vcolor.r * texcolor.r;
	number g = (vcolor.g == 0)? texcolor.g: vcolor.g * texcolor.g;
	number b = (vcolor.b == 0)? texcolor.b: vcolor.b * texcolor.b;
	number a = texcolor.a;

    return vec4(r,g,b,a);
}
]],
	add = love.graphics.newShader[[
vec4 effect(vec4 vcolor, Image texture, vec2 texcoord, vec2 pixcoord)
{
    vec4 texcolor = Texel(texture, texcoord);

    return vec4(vcolor.rgb + texcolor.rgb, texcolor.a);
}
]],
	combine = love.graphics.newShader[[
vec4 effect(vec4 vcolor, Image texture, vec2 texcoord, vec2 pixcoord)
{
    vec4 texcolor = Texel(texture, texcoord);

    return vec4(vcolor.rgb + texcolor.rgb - 0.5, texcolor.a);
}
]],
	multiply = love.graphics.newShader[[
vec4 effect(vec4 vcolor, Image texture, vec2 texcoord, vec2 pixcoord)
{
    vec4 texcolor = Texel(texture, texcoord);

    return vec4(vcolor.rgb * texcolor.rgb, texcolor.a);
}
]],
	average = love.graphics.newShader[[
vec4 effect(vec4 vcolor, Image texture, vec2 texcoord, vec2 pixcoord)
{
    vec4 texcolor = Texel(texture, texcoord);

    return vec4((vcolor.rgb + texcolor.rgb) * 0.5, texcolor.a);
}
]]
}

function drawDecoratedBox(x, y, w, h, border)
	love.graphics.setBlendMode("replace")
	love.graphics.rectangle("line", x, y, w, border)
	love.graphics.rectangle("line", x, y, border, h)
	love.graphics.rectangle("line", x+w-border, y, border, h)
	love.graphics.rectangle("line", x, y+h-border, w, border)
	love.graphics.setBlendMode("alpha")
end

function drawBox(x, y, w, h, border)
	local border = border or 0
	love.graphics.setBlendMode("replace")
	love.graphics.rectangle("line", x, y, w, h)
	if border > 0 then
		love.graphics.rectangle("line", x+border, y+border, w-2*border, h-2*border)
	end
	love.graphics.setBlendMode("alpha")
end