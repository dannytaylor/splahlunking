-- Player.lua

Player = class('Player')

breakTime = 35

function Player:initialize(x,y,id,skin)
	self.x = x 
	self.y = y
	self.id = id or 1
	self.bumpName = 'player'..self.id
	world:add(self.bumpName, self.x,self.y,tileSize-1,tileSize-1)


	self.right = true 	-- == not left
	self.up = true 		-- == not down
	self.move = false

	-- movement
	self.speedx, self.speedy = 8, 48 --dry speed
	if mapsel == 3 then self.speedx, self.speedy = 32,32 end
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
	self.emoteTimer = nil
	self.bubbler = Bubbler()

	-- for UI
	self.score = 0
	self.breath = 100
	self.breathRate = 1.5
	self.tWater = 0

	self.scoreMax = 100
	self.speedMin = 1

	self.alive = true
	self.tank = true
	self.win = false
	self.surface = false

	self.deadtimer = 0
	deadtime = 5

	self:spriteInit()
	self:playerStats()
end

function Player:playerStats()
	local sp = self.palette
	if sp == 1 then
		self.swimspeed = 35 -- higher linearly better
		self.breathRate = 2 -- lower better
		self.speedMin = 0.80 -- max speed adjustment 
		self.scoreMax = 80 -- min speed at score
		-- self.tWater = -x --higher break points
	elseif sp == 2 then
		self.swimspeed = 42
		self.breathRate = 2.4
		self.speedMin = 0.8
		self.scoreMax = 60 -- min speed at score
	elseif sp == 3 then
		self.swimspeed = 24
		self.breathRate = 1.6
		self.speedMin = 1
		self.scoreMax = 100 -- min speed at score
	elseif sp == 4 then
		self.swimspeed = 32
		self.breathRate = 1.8
		self.speedMin = 0.90
		self.tWater = 6
		self.scoreMax = 50 -- min speed at score
	elseif sp == 5 then
		self.swimspeed = 28
		self.breathRate = 2.2
		self.tWater = -6 --higher break points
		self.speedMin = 0.8
		self.scoreMax = 60 -- min speed at score
	elseif sp == 6 then
		if debug then
			self.swimspeed = 80
			self.breathRate = 10
			self.tWater = math.max(1,breakTime-2) --higher break points
			self.speedMin = 1
			self.scoreMax = 60 -- min speed at score
		else
			self.swimspeed = 60
			self.breathRate = 5
			self.tWater = breakTime/2 --higher break points
			self.speedMin = 1
			self.scoreMax = 60 -- min speed at score
		end
	end
	
end

function Player:draw()
	-- if debug then
	-- 	love.graphics.setColor(255, 0, 255)
	-- 	love.graphics.rectangle('fill', self.x, self.y, tileSize-1, tileSize-1)
	-- 	love.graphics.setColor(255, 255, 255)
	-- end
	if self.y > (waterLevel + 2)*tileSize and self.alive then self.bubbler:draw()	end
	if tankBubbler and self.y > (waterLevel + 2)*tileSize then tankBubbler:draw() end

	if self.splashtimer and splashx and mapsel ~= 3 then
		self.splash:draw(splashx+4,0)
	end
	if self.gamestate == 'dry' then
		self.sprite:draw(0,-3)
	else
		self.sprite:draw()
	end
end

function Player:update(dt)
	if pid == self.id then

		gametime = gametime + dt
	
		if not self.win then
			-- if gametime > gametimeMax then
			-- 	self.win = true
			-- 	if currentsong then currentsong:stop() end
			-- 	currentsong = song3
			if self.tWater > breakTime and self.y < (waterLevel-1)*tileSize then
				self.win = true
				self.surface = true

				if mapsel ~= 3 then love.audio.play(sfx_splash) end
				self.splash:goToFrame(1)
				splashx = self.x
				self.splashtimer = 0


				if currentsong then currentsong:stop() end
				currentsong = song3
			end
			if self.alive and not self.win and not self.emoteTimer and (gametime > 6 or debug) then

				self.nextAnim = nil
				if self.gamestate == 'dry' and mapsel ~= 3 then self.nextAnim = 'idle_dry' 
				else self.nextAnim = 'idle' end

				local dx, dy = 0, 0
				if self.y > (waterLevel-1)*tileSize then
					if self.gamestate == 'dry' then
						self.gamestate = 'wet' 

						if mapsel ~= 3 then love.audio.play(sfx_splash) end
						self.splash:goToFrame(1)
						splashx = self.x
						self.splashtimer = 0

						self.speedy = self.swimspeed
						self.speedx = self.swimspeed
					end
					if love.keyboard.isDown('down') or love.keyboard.isDown('s') then
						dy = self.speedy * 2 * dt
						self.sprite.flipY = true
						self.nextAnim = 'movey'
					elseif love.keyboard.isDown('up') or love.keyboard.isDown('w') then
						if not self.tank or self.y > (waterLevel-0.8)*tileSize then
								dy = -self.speedy * 2 * dt
								self.sprite.flipY = false
								self.nextAnim = 'movey'
								if self.y < (waterLevel+0.5)*tileSize then
									dy = dy/2
									self.nextAnim = 'idle'
								end
						end
					else
						self.sprite.flipY = false
					end
				else
					if mapsel == 3 then 
						if love.keyboard.isDown('up') or love.keyboard.isDown('w') then
							dy = -self.speedy * 2 * dt
						elseif love.keyboard.isDown('down') or love.keyboard.isDown('s') then 
							dy = self.speedy * 2 * dt
						end
					else
						dy = self.speedy * 2 * dt
					end
				end

				if love.keyboard.isDown('right') or love.keyboard.isDown('d') then
					dx = self.speedx * dt
					self.sprite.flipX = false
					if self.gamestate == 'dry' and mapsel ~= 3 then
						self.nextAnim = 'movex_dry'
					else
						self.nextAnim = 'movex'
					end
					self.sprite.flipY = false
				elseif love.keyboard.isDown('left') or love.keyboard.isDown('a') then
					dx = -self.speedx * dt
					self.sprite.flipX = true
					if self.gamestate == 'dry' and mapsel ~= 3 then
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
					dx = dx*self.weight
					dy = dy*self.weight
					local cols
					local playerFilter = function (item, other)
						if other:sub(1,4) == 'trea'  then
							return 'cross'
						elseif other:sub(1,4) == 'brea'  then
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
							self.currentTreasure = nil
						end
						if other:sub(1,4) == 'brea'  then
							self.currentBreath = other
						else 
							self.currentBreath = nil
					 	end
					end
				end
			end
		end

		-------- countdown breath -----------------------
		if self.gamestate == 'wet' then 
			self.tWater = self.tWater + dt
			if self.tWater > breakTime and self.tank then 
				love.audio.play(sfx_explode)
				currentsong:stop()
				currentsong = song2
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
					love.audio.play(sfx_death)
					currentsong:stop()
					currentsong = song3
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
				if self.score <= self.scoreMax and self.gamestate == 'wet' then
					self.weight = math.max(self.speedMin, 1-self.speedMin*self.score/self.scoreMax)
				end
				if sfx_collect:isPlaying() then sfx_collect:stop() end
				love.audio.play(sfx_collect)
			end
			self.activeTreasure.active = false
		elseif self.currentBreath and not self.tank then
			self.activeBreath = breathAt(world:getRect(self.currentBreath))
			if self.activeBreath.active then
				self.breath = self.breath + breathPlus
				if self.breath > 100 then self.breath = 100 end
				if sfx_collect:isPlaying() then sfx_collect:stop() end
				love.audio.play(sfx_collect)
			end
			self.activeBreath.active = false
		end


	else
		local cols
		local playerFilter = function (item, other)
			if other:sub(1,4) == 'trea'  then
				return 'cross'
			elseif other:sub(1,4) == 'brea'  then
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
				self.currentTreasure = nil
		 	end
		 	if other:sub(1,4) == 'brea'  then
				self.currentBreath = other
			else 
				self.currentBreath = nil
		 	end
		end

		if self.currentTreasure then
			self.activeTreasure = treasureAt(world:getRect(self.currentTreasure))
			self.activeTreasure.active = false
		elseif self.currentBreath and not self.tank then
			self.activeBreath = breathAt(world:getRect(self.currentBreath))
			self.activeBreath.active = false
		end
	end

	if self.emoteTimer and self.alive then
		if self.emoteTimer == 0 then
			self.sprite:switch('emote')
			self.nextAnim = 'emote'
			self.currentAnim = 'emote'
		end

		self.emoteTimer = self.emoteTimer + dt
		if 
			self.emoteTimer > 0.8 then self.emoteTimer = nil 
			if self.gamestate == 'dry' then
				self.sprite:switch("idle_dry")
				self.nextAnim = 'idle_dry'
				self.currentAnim = 'idle_dry'
			else
				self.sprite:switch("idle")
				self.nextAnim = 'idle'
				self.currentAnim = 'idle'
			end
		end
	elseif self.nextAnim and self.nextAnim ~= self.currentAnim then
		self.currentAnim = self.nextAnim
		self.sprite:switch(self.currentAnim)
	end

	if self.alive and not self.surface then self.bubbler:update(dt, self.x+4, self.y-2) end
	if tankBubbler then tankBubbler:update(dt, self.x+4, self.y-2) end
	if self.splashtimer then
		self.splashtimer = self.splashtimer + dt
		self.splash:update(dt) 
		if self.splashtimer > 0.5 then self.splashtimer = nil end
	end

	self.sprite:update(dt)
end

function treasureAt(x,y) -- gets the treasure at x,y
	for i = 1, #map.treasure do
		if map.treasure[i].x == x and map.treasure[i].y == y then return map.treasure[i] end
	end
	return nil
end

function breathAt(x,y) -- gets the breath at x,y
	for i = 1, #map.breaths do
		if map.breaths[i].x == x and map.breaths[i].y == y then return map.breaths[i] end
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
		frameHeight = 24,
		frames      = {
			{7, self.palette, 7, self.palette, .8},
		},
	})
	-- in water
	self.sprite:addAnimation('idle', {
		image       = playerSheet,
		frameWidth  = 16,
		frameHeight = 24,
		frames      = {
			{1, self.palette, 2, self.palette, .8},
		},
	})

	self.sprite:addAnimation('movex', {
		image       = playerSheet,
		frameWidth  = 16,
		frameHeight = 24,
		frames      = {
			{3, self.palette, 4, self.palette, .4},
		},
	})
	self.sprite:addAnimation('movey', {
		image       = playerSheet,
		frameWidth  = 16,
		frameHeight = 24,
		frames      = {
			{5, self.palette, 6, self.palette, .4},
		},
	})
	
	self.sprite:addAnimation('movex_dry', {
		image       = playerSheet,
		frameWidth  = 16,
		frameHeight = 24,
		frames      = {
			{8, self.palette, 11, self.palette, .4},
		},
	})
	self.sprite:addAnimation('dead', {
		image       = playerSheet,
		frameWidth  = 16,
		frameHeight = 24,
		frames      = {
			{12, self.palette, 13, self.palette, .8},
		},
	})
	self.sprite:addAnimation('emote', {
		image       = playerSheet,
		frameWidth  = 16,
		frameHeight = 24,
		frames      = {
			{14, self.palette, 21, self.palette, .1},
		},
	})

	self.splash  = sodapop.newAnimatedSprite(0,8*tileSize+6)
	self.splash:addAnimation('default', {
		image       = splashsheet,
		frameWidth  = 16,
		frameHeight = 8,
		frames      = {
			{1, 1, 4, 1, .1},
		},
	})

	
end