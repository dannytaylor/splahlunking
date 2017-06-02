-- Breath.lua

Breath = class('Breath')

breathPlus = 15

function Breath:initialize(x,y,num)
	self.x,self.y = (x-1)*tileSize,(y-1)*tileSize
	self.active = true
	world:add('breath'..x..'x'..y..'x'..num, self.x,self.y, tileSize*2,tileSize*2)
	local cx,cy = self.x+4,self.y+4
	self.bubble = sodapop.newAnimatedSprite(cx, cy)
	self.bubble:addAnimation('default', {
		image        = sparklesheet,
		frameWidth   = 16,
		frameHeight  = 16,
		frames       = {
		  {1, 1, 4, 1, .4},
		},
	})
end

function Breath:draw()
	local ts = treasureSheet1
	if mapsel == 3 then ts = treasureSheet3 end

	if self.active then 
		love.graphics.setColor(255,0,255)
		love.graphics.rectangle('fill', self.x, self.y, tileSize*2, tileSize*2)
		-- self.bubble:draw()
	end
	love.graphics.setColor(255,255,255)
end

function Breath:update(dt)
	if self.active then
		self.bubble:update(dt)
	end
end
