-- Player.lua

Player = class('Player')



function Player:initialize(x,y,id,skin)
	self.x = x 
	self.y = y
	self.id = id or 1
	self.bumpName = 'player'..self.id
	world:add(self.bumpName, self.x,self.y,tileSize,tileSize)


	self.right = true 	-- == not left
	self.up = true 		-- == not down
	self.move = false

	-- movement
	self.speedx, self.speedy = 8, 48 --dry speed
	self.swimspeed = 32
	self.weight = 1

	self.currentTreasure = nil
	self.activeTreasure = nil

	-- sprite info
	self.gamestate = 'dry'
	self.palette = skin
	self.currentAnim = 'idle_dry'
	self.nextAnim = self.currentAnim
	self.sprite = 'idle_dry'
	self.bubbler = Bubbler()

	-- for UI
	self.score = 0
	self.breath = 100
	self.breathRate = 2.5
	self.tWater = 0

	self.alive = true
	self.tank = true
	self.win = false
	self.surface = false


	self:spriteInit()
end

function Player:draw()
	-- love.graphics.setColor(255, 0, 255)
	-- love.graphics.rectangle('fill', self.x, self.y, tileSize, tileSize)
	-- love.graphics.setColor(255, 255, 255)
	if self.y > (waterLevel + 1)*tileSize and self.alive then self.bubbler:draw()	end
	if tankBubbler then tankBubbler:draw() end
	self.sprite:draw()
end

function Player:update(dt)

	if pid == self.id then
		if not self.win then
			if gametime > gametimeMax then
				self.win = true
			elseif self.tWater > breakTime and self.y < (waterLevel-1)*tileSize then
				self.win = true
				self.surface = true
			end
			if self.alive and not self.win then
				local speed = self.speed

				self.nextAnim = nil
				if self.gamestate == 'dry' then self.nextAnim = 'idle_dry' 
				else self.nextAnim = 'idle' end

				local dx, dy = 0, 0
				if self.y > (waterLevel-1)*tileSize then
					if self.gamestate == 'dry' then 
						self.gamestate = 'wet' 
						self.speedy = self.swimspeed
						self.speedx = self.swimspeed
					end
					if love.keyboard.isDown('down') or love.keyboard.isDown('s') then
						dy = self.speedy * 2 * dt
						self.sprite.flipY = true
						self.nextAnim = 'movey'
					elseif love.keyboard.isDown('up') or love.keyboard.isDown('w') then
						dy = -self.speedy * 2 * dt
						self.sprite.flipY = false
						self.nextAnim = 'movey'
						if self.y < (waterLevel+2)*tileSize then
							dy = dy/2
							self.nextAnim = 'idle'
						end
					else
						self.sprite.flipY = false
					end
				else
					dy = self.speedy * 2 * dt
				end

				if love.keyboard.isDown('right') or love.keyboard.isDown('d') then
					dx = self.speedx * dt
					self.sprite.flipX = false
					if self.gamestate == 'dry' then
						self.nextAnim = 'movex_dry'
					else
						self.nextAnim = 'movex'
					end
					self.sprite.flipY = false
				elseif love.keyboard.isDown('left') or love.keyboard.isDown('a') then
					dx = -self.speedx * dt
					self.sprite.flipX = true
					if self.gamestate == 'dry' then
						self.nextAnim = 'movex_dry'
					else
						self.nextAnim = 'movex'
					end
					self.sprite.flipY = false
				end

				if self.nextAnim ~= self.currentAnim then
					self.currentAnim = self.nextAnim
					self.sprite:switch(self.currentAnim)
				end


				if dx ~= 0 or dy ~= 0 then
					local cols
					local playerFilter = function (item, other)
						if other:sub(1,4) == 'trea'  then
							return 'cross'
						elseif other:sub(1,4) == 'wall'  then
							return 'slide'
						else
							return nil
					 	end
					end

					self.x, self.y, cols, cols_len = world:move(self.bumpName, self.x + dx, self.y + dy, playerFilter)
					self.x, self.x = self.x + dx, self.y + dy


					cam:setPosition(players[pid].x, players[pid].y)
					for i=1, cols_len do
						local other = cols[i].other
						if other:sub(1,4) == 'trea'  then
							self.currentTreasure = other
						else 
							-- if self.activeTreasure then
							-- 	self.activeTreasure.hovered = false
							-- 	self.activeTreasure = nil
							-- end
							self.currentTreasure = nil
					 	end
					end
				end
			end
		end


-------- countdown breath -----------------------
		if self.gamestate == 'wet' then 
			self.tWater = self.tWater + dt
			if self.tWater > breakTime and self.tank then 
				tankBubbler = Bubbler(10,2)
				self.tank = false 
			end
			if self.tWater > breakTime+6 and tankBubbler then 
				tankBubbler = nil
			end
			if not self.tank and not self.win then
				if self.breath > 0 then
					self.breath = self.breath - dt*self.breathRate
				elseif self.alive then
					self.breath = 0
					self.alive = false
					self.bubbler = nil
					self.sprite.flipY = false
					self.currentAnim = 'dead'
					self.nextAnim = 'dead'
					self.sprite:switch('dead')
				end
			end
		end

		if self.currentTreasure then
			self.activeTreasure = treasureAt(world:getRect(self.currentTreasure))

			if self.activeTreasure.active then 
				self.score = self.score + self.activeTreasure.value
			end
			self.activeTreasure.active = false
		end

	else
		local cols
		local playerFilter = function (item, other)
			if other:sub(1,4) == 'trea'  then
				return 'cross'
			elseif other:sub(1,4) == 'wall'  then
				return 'slide'
			else
				return nil
		 	end
		end

		self.x, self.y, cols, cols_len = world:move(self.bumpName, self.x, self.y, playerFilter)

		for i=1, cols_len do
			local other = cols[i].other
			if other:sub(1,4) == 'trea'  then
				self.currentTreasure = other
			else 
				-- if self.activeTreasure then
				-- 	self.activeTreasure.hovered = false
				-- 	self.activeTreasure = nil
				-- end
				self.currentTreasure = nil
		 	end
		end

		if self.currentTreasure then
			self.activeTreasure = treasureAt(world:getRect(self.currentTreasure))

			if self.activeTreasure.active then 
				self.score = self.score + self.activeTreasure.value
			end
			self.activeTreasure.active = false
		end
	end



	if self.nextAnim and self.nextAnim ~= self.currentAnim then
		self.currentAnim = self.nextAnim
		self.sprite:switch(self.currentAnim)
	end
	if self.alive then self.bubbler:update(dt, self.x+4, self.y-2) end
	if tankBubbler then tankBubbler:update(dt, self.x+4, self.y-2) end
	self.sprite:update(dt)
end

function treasureAt(x,y)
	for i = 1, #map.treasure do
		if map.treasure[i].x == x and map.treasure[i].y == y then return map.treasure[i] end
	end
	return nil
end


function Player:spriteInit()
	self.sprite  = sodapop.newAnimatedSprite()
	self.sprite:setAnchor(function ()
		return self.x+4,self.y+4
	end)
	--out of water
	self.sprite:addAnimation('idle_dry', {
		image       = playerSheet,
		frameWidth  = 16,
		frameHeight = 16,
		frames      = {
			{7, self.palette, 7, self.palette, .8},
		},
	})
	-- in water
	self.sprite:addAnimation('idle', {
		image       = playerSheet,
		frameWidth  = 16,
		frameHeight = 16,
		frames      = {
			{1, self.palette, 2, self.palette, .8},
		},
	})

	self.sprite:addAnimation('movex', {
		image       = playerSheet,
		frameWidth  = 16,
		frameHeight = 16,
		frames      = {
			{3, self.palette, 4, self.palette, .4},
		},
	})
	self.sprite:addAnimation('movey', {
		image       = playerSheet,
		frameWidth  = 16,
		frameHeight = 16,
		frames      = {
			{5, self.palette, 6, self.palette, .4},
		},
	})
	
	self.sprite:addAnimation('movex_dry', {
		image       = playerSheet,
		frameWidth  = 16,
		frameHeight = 16,
		frames      = {
			{8, self.palette, 11, self.palette, .4},
		},
	})
	self.sprite:addAnimation('dead', {
		image       = playerSheet,
		frameWidth  = 16,
		frameHeight = 16,
		frames      = {
			{12, self.palette, 13, self.palette, .8},
		},
	})

end