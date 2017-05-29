-- Player.lua

Player = class('Player')



function Player:initialize(x,y,id)
	self.x = x 
	self.y = y
	self.id = id or 1
	self.bumpName = 'player'..self.id
	world:add(self.bumpName, self.x,self.y,tileSize,tileSize)


	self.right = 1 	-- == not left
	self.up = 1 		-- == not down

	-- movement
	self.speedx, self.speedy = 8, 48 --dry speed
	self.swimspeed = 32
	self.weight = 1

	self.currentTreasure = nil
	self.activeTreasure = nil

	-- sprite info
	self.skin =self.id or 1
	self.anim = pAnim[self.skin]['idle']
	self.gamestate = 'dry'
	self.bubbler = Bubbler()

	-- for UI
	self.score = 0
	self.breath = 100
end

function Player:draw()
	self.anim:draw(playerSheet,self.x-4,self.y-6)
	if self.y > (waterLevel + 1)*tileSize then self.bubbler:draw()	end
end

function Player:update(dt)
	local right,up = true,true

	local speed = self.speed
	local nextAnim = pAnim[self.skin]['idle']
	if self.gamestate == 'dry' then nextAnim = pAnim[self.skin]['idle_dry'] end
	local dx, dy = 0, 0

	if self.y > (waterLevel-1)*tileSize then
		if self.gamestate == 'dry' then 
			self.gamestate = 'wet' 
			self.speedy = self.swimspeed
			self.speedx = self.swimspeed
		end
		if love.keyboard.isDown('down') then
			dy = self.speedy * 2 * dt
			self.up = false
			nextAnim = pAnim[self.skin]['movey']
		elseif love.keyboard.isDown('up') then
			dy = -self.speedy * 2 * dt
			nextAnim = pAnim[self.skin]['movey']
		else
		end
	else
		dy = self.speedy * 2 * dt
	end

	if love.keyboard.isDown('right') then
		dx = self.speedx * dt
		if self.gamestate == 'dry' then
			nextAnim= pAnim[self.skin]['movex_dry']
		else
			nextAnim = pAnim[self.skin]['movex']
		end
	elseif love.keyboard.isDown('left') then
		dx = -self.speedx * dt
		self.right = false
		if self.gamestate == 'dry' then
			nextAnim = pAnim[self.skin]['movex_dry']
		else
			nextAnim = pAnim[self.skin]['movex']
		end
		self.up = false
	end

	if nextAnim ~= self.anim then
		self.currentAnim = nextAnim
		self.anim = nextAnim

	end

	-- if not right  then self.anim:flipH() end
	-- if not up then self.anim:flipV() end


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

	if self.gamestate == 'wet' then 
		if self.breath > 0 then
			self.breath = self.breath - dt
		else
			self.breath = 0
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
	self.anim:update(dt)
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
