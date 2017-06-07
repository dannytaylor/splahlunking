-- Powerup.lua

-- Breath.lua

Powerup = class('Powerup')

puMaxTime = 12
dolphinspeed = 10
walrusbreath = 2

pooftime = 0.4

function Powerup:initialize(x,y,type,num)
	self.x,self.y = (x-1)*tileSize,(y-1)*tileSize
	self.active = true
	self.type = type or 'dolphin'
	world:add('powerup'..x..'x'..y..'x'..num, self.x,self.y, tileSize,tileSize)
	local cx,cy = self.x+4,self.y+4
	self.sprite = sodapop.newAnimatedSprite(cx, cy)
	self.sprite:addAnimation('dolphin1', {
		image        = breathsheet,
		frameWidth   = 16,
		frameHeight  = 16,
		frames       = {
		  {1, 2, 6, 2, .2},
		},
	})
	self.sprite:addAnimation('dolphin2', {
		image        = breathsheet,
		frameWidth   = 16,
		frameHeight  = 16,
		frames       = {
		  {7, 2, 12, 2, .1},
		},
		stopAtEnd = true,
	})
	self.sprite:addAnimation('walrus1', {
		image        = breathsheet,
		frameWidth   = 16,
		frameHeight  = 16,
		frames       = {
		  {1, 3, 6, 3, .1},
		},
	})
	self.sprite:addAnimation('walrus2', {
		image        = breathsheet,
		frameWidth   = 16,
		frameHeight  = 16,
		frames       = {
		  {7, 3, 12, 3, .1},
		},
		stopAtEnd = true,
	})
	self.sprite:addAnimation('squid1', {
		image        = breathsheet,
		frameWidth   = 16,
		frameHeight  = 16,
		frames       = {
		  {1, 4, 6, 4, .1},
		},
	})
	self.sprite:addAnimation('squid2', {
		image        = breathsheet,
		frameWidth   = 16,
		frameHeight  = 16,
		frames       = {
		  {7, 4, 12, 4, .1},
		},
		stopAtEnd = true,
	})

	if self.type == 'dolphin' then self.sprite:switch('dolphin1')
	elseif self.type == 'walrus' then self.sprite:switch('walrus1')
	elseif self.type == 'squid' then self.sprite:switch('squid1')
	end
end

function Powerup:draw()
	
	-- if self.active then 
	-- 	if self.type == 'dolphin' then love.graphics.setColor(255,0,255)
	-- 	elseif self.type == 'walrus' then love.graphics.setColor(255,255,0)
	-- 	end
	-- 	love.graphics.rectangle('fill', self.x, self.y, tileSize*2, tileSize*2)
	-- end
	self.sprite:draw()
end

function Powerup:update(dt)
	self.sprite:update(dt)
end
