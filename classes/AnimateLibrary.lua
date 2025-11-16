local AnimateLibrary = {}

function AnimateLibrary.animate_color_lerp(o,cb,duration,from_color,to_color)
	duration = duration or 1
	
	from_color = from_color or o:color()
	to_color = to_color or o:color()
	
	local t,dt = 0,0
	while t < duration do 
		o:set_color(from_color + (to_color-from_color) * math.bezier({0,0,1,1}, t/duration))
		dt = coroutine.yield()
		t = t + dt
	end
	o:set_color(to_color)
	if cb then
		cb(o)
	end
end
function AnimateLibrary.animate_alpha_lerp(o,cb,duration,from_alpha,to_alpha)
	duration = duration or 1
	
	from_alpha = from_alpha or o:alpha()
	to_alpha = to_alpha or o:alpha()
	
	local t,dt = 0,0
	while t < duration do 
		o:set_alpha(from_alpha + (to_alpha-from_alpha) * math.bezier({0,0,1,1}, t/duration))
		dt = coroutine.yield()
		t = t + dt
	end
	o:set_alpha(to_alpha)
	if cb then
		cb(o)
	end
end

-- pulses forever, until stopped
function AnimateLibrary.animate_color_oscillate(o,speed,color_1,color_2)
	local d_color = color_2 - color_1
	local t = 0
	speed = speed * 180 -- speed becomes seconds/period
	while true do 
		local s = math.sin(speed*t)
		o:set_color(color_1 + d_color*s*s)
		t = t + coroutine.yield()
	end
end

return AnimateLibrary