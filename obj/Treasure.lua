-- Treasure.lua

Treasure = class('Treasure')

function Treasure:initialize(x,y,v,size)
	self.x,self.y = (x-1)*tileSize,(y-1)*tileSize
	self.value = v or 1
	self.active = true
	self.size = size or 1
	if self.size > 1 then
		self.bubbler = Bubbler(3,12)
	end
	world:add('treasure'..x..'x'..y..'x'..self.size, self.x,self.y, tileSize*self.size,tileSize*self.size)
	if self.size == 2 then
		self.sprite = lume.randomchoice({1,2})
	end
	local cx,cy = self.x+4,self.y+4
	if self.size == 2 then
		cx,cy = self.x+8,self.y+8
	elseif self.size == 3 then
		cx,cy = self.x+16,self.y+16
	end
	self.sparkle = sodapop.newAnimatedSprite(cx, cy)
	self.sparkle:addAnimation('default', {
		image        = sparklesheet,
		frameWidth   = 16,
		frameHeight  = 16,
		frames       = {
		  {1, 1, 4, 1, .4},
		},
	})
end

function Treasure:draw()

	if self.active then 
		-- love.graphics.setColor(self.value*25, self.value*10, self.value*25)
		-- love.graphics.rectangle('fill', self.x, self.y, tileSize*self.size, tileSize*self.size)

		if self.size == 1 then
			if self.value < 2 then love.graphics.draw(treasureSheet,trq.t1,self.x, self.y)
			elseif self.value < 3 then love.graphics.draw(treasureSheet,trq.t2,self.x, self.y)
			elseif self.value < 5 then love.graphics.draw(treasureSheet,trq.t3,self.x, self.y)
			elseif self.value < 7 then love.graphics.draw(treasureSheet,trq.t4,self.x, self.y)
			else love.graphics.draw(treasureSheet,trq.t5,self.x, self.y)
			end
		elseif self.size == 2 then
			if self.sprite == 1 then love.graphics.draw(treasureSheet,trq.tl1,self.x, self.y)
			else love.graphics.draw(treasureSheet,trq.tl2,self.x, self.y)
			end
			self.bubbler:draw()
		else
			love.graphics.draw(treasureSheet,trq.txl1,self.x, self.y-16)
			self.bubbler:draw()
		end
		self.sparkle:draw()
	end

end

function Treasure:update(dt)
	if self.active and self.size > 1 then
		self.bubbler:update(dt,self.x,self.y)
	end
	if self.active then
		self.sparkle:update(dt)
	end
end
