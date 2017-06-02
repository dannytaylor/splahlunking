-- mapoverlay.lua

-- from startMatch()
function mapoverlay_init()
	local framerate = 0.2
	if mapsel == 1 then framerate = 0.4 end
	moAni  = sodapop.newAnimatedSprite(64*tileSize,12*tileSize)
		moAni:addAnimation('default', {
			image       = moAni_sheets[mapsel],
			frameWidth  = 64,
			frameHeight = 64,
			frames      = {
				{1, 1, 4, 1, framerate},
			},
		})

end


function mapoverlay_update(dt)
	--update animations
	if mapsel == 3 then moAni:update(dt) end
end

function mapoverlay_draw()

	-- animations here
	if mapsel == 3 then moAni:draw() end
end