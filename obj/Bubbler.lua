-- Bubbler.lua

Bubbler = class('Bubbler')

function Bubbler:initialize(max, life)
	self.max = max or 4
	self.life = life or 3
	self.tickRate = 5

	self.bubbles = {}

	for i=1,self.max do
		self.bubbles[i] = {x = 1, y = 1, t = self.life/i, tick = 0}
	end
end

function Bubbler:draw()
	if mapsel ~= 3 then
		love.graphics.setColor(178, 220, 239)
		for i=1,#self.bubbles do 
			if self.bubbles[i].y > waterLevel*tileSize then
				if self.bubbles[i].t < self.life*0.7 then
					love.graphics.setPointSize(windowScale*2)
					love.graphics.points({self.bubbles[i].x, self.bubbles[i].y})
				elseif self.bubbles[i].t < self.life*0.94 then
					love.graphics.rectangle('line',self.bubbles[i].x-1, self.bubbles[i].y-1,2,2)
				else
					love.graphics.setPointSize(windowScale)
					love.graphics.points({
						self.bubbles[i].x, self.bubbles[i].y-1,
						self.bubbles[i].x+1, self.bubbles[i].y,
						self.bubbles[i].x, self.bubbles[i].y+1,
						self.bubbles[i].x-1, self.bubbles[i].y
					})
				end
			end
		end
	end
	love.graphics.setColor(255, 255, 255)
end

function Bubbler:update(dt,x,y)
	for i=1,#self.bubbles do 
		local testTick = math.floor(self.bubbles[i].tick*self.tickRate)
		-- self.bubbles[i].y = self.bubbles[i].y - dt*self.rise
		self.bubbles[i].t = self.bubbles[i].t + dt
		self.bubbles[i].tick = self.bubbles[i].tick + dt
		if testTick ~= math.floor(self.bubbles[i].tick*self.tickRate) then
			self.bubbles[i].y = self.bubbles[i].y - 4
			self.bubbles[i].x = self.bubbles[i].x - lume.weightedchoice(({ [-2] = 20, [0] = 60, [2] = 20 }))
		end
		if self.bubbles[i].t > self.life then
			self.bubbles[i].x = x
			self.bubbles[i].y = y
			self.bubbles[i].t = love.math.random(0,0.6)
		end
	end
end