-- Breath.lua

Breath = class('Breath')

breathPlus = 20

function Breath:initialize(x,y,num)
	self.x,self.y = (x-1)*tileSize,(y-1)*tileSize
	self.active = true
	world:add('breath'..x..'x'..y..'x'..num, self.x,self.y, tileSize*2,tileSize*2)
	local cx,cy = self.x+4,self.y+4
	self.sprite = sodapop.newAnimatedSprite(cx, cy)
	self.sprite:addAnimation('default', {
		image        = breathsheet,
		frameWidth   = 16,
		frameHeight  = 16,
		frames       = {
		  {1, 1, 6, 1, .2},
		},
	})
	self.sprite:addAnimation('pop', {
		image        = breathsheet,
		frameWidth   = 16,
		frameHeight  = 16,
		frames       = {
		  {7, 1, 12, 1, .1},
		},
		stopAtEnd = true,
	})
	self.sprite:switch('default')
	self.switch = false
end

function Breath:draw()
	local ts = treasureSheet1
	if mapsel == 3 then ts = treasureSheet3 end

	-- if self.active then 
		-- love.graphics.setColor(255,0,255)
		-- love.graphics.rectangle('fill', self.x, self.y, tileSize*2, tileSize*2)
	if not players[fid].tank then self.sprite:draw() end
end

function Breath:update(dt)
	if not self.switch and not self.active then 
		self.switch = true
		self.sprite:switch 'pop'
	end
	self.sprite:update(dt)
end
