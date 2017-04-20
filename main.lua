-- tables for colours used by /r/place
rgb_red = {}
rgb_green = {}
rgb_blue = {}

function comma_value(n) -- credit http://richard.warburton.it
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function set_rgb(k, r, g, b)
	rgb_red[k] = r
	rgb_green[k] = g
	rgb_blue[k] = b
end

set_rgb(0, 0xff, 0xff, 0xff)
set_rgb(1, 0xe4, 0xe4, 0xe4)
set_rgb(2, 0x88, 0x88, 0x88)
set_rgb(3, 0x22, 0x22, 0x22)
set_rgb(4, 0xff, 0xa7, 0xd1)
set_rgb(5, 0xe5, 0x00, 0x00)
set_rgb(6, 0xe5, 0x95, 0x00)
set_rgb(7, 0xa0, 0x6a, 0x42)
set_rgb(8, 0xe5, 0xd9, 0x00)
set_rgb(9, 0x94, 0xe0, 0x44)
set_rgb(10, 0x02, 0xbe, 0x01)
set_rgb(11, 0x00, 0xe5, 0xf0)
set_rgb(12, 0x00, 0x83, 0xc7)
set_rgb(13, 0x00, 0x00, 0xea)
set_rgb(14, 0xe0, 0x4a, 0xff)
set_rgb(15, 0x82, 0x00, 0x80)

function love.load()
	-- create a canvas
	canvas = love.graphics.newCanvas(1000, 1000)
	--create a font
	font = love.graphics.newFont(24)
	love.graphics.setFont(font)
	-- hide the cursor
	love.mouse.setVisible(false)
	-- open csv file. this should not have the original header, and be
	-- sorted by increasing timestamp
	-- cat tile_placements.csv | sort --field-separator=',' --key=1 > sorted.csv
	fh = io.open("sorted.csv", "r")
	-- initialise here for scope reasons
	hud_line_1 = ""
	hud_line_2 = ""
	updates = 1000
	lines_read = 0
	lines_update = 0
end

function love.update(dt)
	hud_line_1 = "status: "..(fh and "working" or "done").." | progress: "..math.floor(100*lines_read/16559898).."%"
	hud_line_2 = "pixels per second: "..comma_value(math.floor(updates/dt))
	if fh then
		for i = 0,updates do
			-- read next line
			local line = fh:read()
			-- handling the end of the file
			if (line == nil) or (line == "ts,user,x_coordinate,y_coordinate,color") then
				fh:close()
				print("eof reached")
				return
			end
			-- split the line into variables
			local ts,user,x,y,c = line:match("(.+),(.+),(.+),(.+),(.+)")
			-- conver strings to ints
			x = tonumber(x)
			y = tonumber(y)
			c = tonumber(c)

			--print(x, y, c)
			-- should never fire but who knows
			if x > 999 or y > 999 then break end
			-- draw the pixel to the canvas
			putPixel(x, y, c)
			lines_read = lines_read + 1
		end
	end
end

function love.draw()
	-- important setup each frame
	love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode("alpha", "premultiplied")
	-- draw the canvas to the screen
	love.graphics.draw(canvas)
	-- check if mouse is on screen
	x, y = love.mouse.getPosition()
	if (x > 0) and (x < 999) and (y > 0) and (y < 999) then
		-- setup for HUD
		love.graphics.setBlendMode("alpha")
		-- draw HUD
		-- line 1
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.print(hud_line_1, love.mouse.getX()+1, love.mouse.getY()+1)
		love.graphics.print(hud_line_1, love.mouse.getX()-1, love.mouse.getY()-1)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.print(hud_line_1, love.mouse.getX(), love.mouse.getY())
		-- line 2
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.print(hud_line_2, love.mouse.getX()+1, love.mouse.getY()+32+1)
		love.graphics.print(hud_line_2, love.mouse.getX()-1, love.mouse.getY()+32-1)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.print(hud_line_2, love.mouse.getX(), love.mouse.getY()+32)
	end
end

function love.quit()
	fh:close()
end

-- takes x,y coordinates and /r/place colour value and adds them to the canvas
function putPixel(x, y, c)
	love.graphics.setCanvas(canvas)
    love.graphics.setBlendMode("alpha")
	love.graphics.setColor(rgb_red[c], rgb_green[c], rgb_blue[c], 255)
	love.graphics.points(x, y)
	love.graphics.setCanvas()
end

