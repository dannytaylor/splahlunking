-- Player.lua

Player = Object:extend()



function Player:new(x,y)
	self.x = x 
	self.y = y
	self.playerid = id or 1
	self.bumpName = 'player'
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
	self.sprite = nil
	self.gamestate = 'dry'
	self.palette = 1
	self:spriteInit()
	self.currentAnim = nil
	self.bubbler = Bubbler()

	-- for UI
	self.score = 0
	self.breath = 100
end

function Player:draw()
	-- love.graphics.setColor(255, 0, 255)
	-- love.graphics.rectangle('fill', self.x, self.y, tileSize, tileSize)
	-- love.graphics.setColor(255, 255, 255)
	self.sprite:draw()
	if self.y > (waterLevel + 1)*tileSize then self.bubbler:draw()	end
end

function Player:update(dt)

	local speed = self.speed
	local nextAnim = 'idle'
	if self.gamestate == 'dry' then nextAnim = 'dry_idle' end
	local dx, dy = 0, 0

	if self.y > (waterLevel-1)*tileSize then
		if self.gamestate == 'dry' then 
			self.gamestate = 'wet' 
			self.speedy = self.swimspeed
			self.speedx = self.swimspeed
		end
		if love.keyboard.isDown('down') then
			dy = self.speedy * 2 * dt
			self.sprite.flipY = true
			nextAnim = 'movey'
		elseif love.keyboard.isDown('up') then
			dy = -self.speedy * 2 * dt
			self.sprite.flipY = false
			nextAnim = 'movey'
		else
			self.sprite.flipY = false
		end
	else
		dy = self.speedy * 2 * dt
	end

	if love.keyboard.isDown('right') then
		dx = self.speedx * dt
		self.sprite.flipX = false
		if self.gamestate == 'dry' then
			nextAnim = 'dry_movex'
		else
			nextAnim = 'movex'
		end
		self.sprite.flipY = false
	elseif love.keyboard.isDown('left') then
		dx = -self.speedx * dt
		self.sprite.flipX = true
		if self.gamestate == 'dry' then
			nextAnim = 'dry_movex'
		else
			nextAnim = 'movex'
		end
		self.sprite.flipY = false
	end

	if nextAnim ~= self.currentAnim then
		self.currentAnim = nextAnim
		self.sprite:switch(nextAnim)
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


		cam:setPosition(currentPlayer.x, currentPlayer.y)
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

	if self.gamestate == 'wet' then 
		if self.breath > 0 then
			self.breath = self.breath - dt
		end
	end

	if self.currentTreasure then
		self.activeTreasure = treasureAt(world:getRect(self.currentTreasure))

		if self.activeTreasure.active then 
			self.score = self.score + self.activeTreasure.value
		end
		self.activeTreasure.active = false
	end

	self.bubbler:update(dt, self.x+4, self.y-2)
	self.sprite:update(dt)
end

function treasureAt(x,y)
	for i = 1, #map.treasure do
		if map.treasure[i].x == x and map.treasure[i].y == y then return map.treasure[i] end
	end
	return nil
end

local playerFilter = function (item, other)

	print(other)
	if other.sub(1,4) == 'trea'  then
		return 'cross'
	elseif other.sub(1,4) == 'wall'  then
		return 'slide'
	else
		return nil
 	end
end

function Player:spriteInit()
	self.sprite  = sodapop.newAnimatedSprite()
	self.sprite:setAnchor(function()
		return self.x+4, self.y+4
	end)
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
	--out of water
	self.sprite:addAnimation('dry_idle', {
		image       = playerSheet,
		frameWidth  = 16,
		frameHeight = 16,
		frames      = {
			{7, self.palette, 7, self.palette, .8},
		},
	})
	self.sprite:addAnimation('dry_movex', {
		image       = playerSheet,
		frameWidth  = 16,
		frameHeight = 16,
		frames      = {
			{8, self.palette, 11, self.palette, .4},
		},
	})
end