-- Player.lua

Player = Object:extend()



function Player:new(x,y)
	self.x = x 
	self.y = y
	self.bumpName = 'player'
	world:add(self.bumpName, self.x,self.y,tileSize,tileSize)

	self.gamestate = nil
	self.right = true 	-- == not left
	self.up = true 		-- == not down

	self.frame = 0

	self.speed = 32
	self.sprite = nil
	self.gamestate = 'dry'
	self:spriteInit()
end

function Player:draw()
	love.graphics.setColor(255, 0, 255)
	love.graphics.rectangle('fill', self.x, self.y, tileSize, tileSize)
	love.graphics.setColor(255, 255, 255)
	self.sprite:draw()
end

function Player:update(dt)
	local speed = self.speed

	local dx, dy = 0, 0

	if love.keyboard.isDown('right') then
		dx = speed * dt
		self.sprite.flipX = false
	elseif love.keyboard.isDown('left') then
		dx = -speed * dt
		self.sprite.flipX = true
	end

	if love.keyboard.isDown('down') then
		dy = speed * 2 * dt
		self.sprite.flipY = true
	elseif love.keyboard.isDown('up') then
		dy = -speed * 2 * dt
		self.sprite.flipY = false
	else
		self.sprite.flipY = false
	end

	if dx ~= 0 or dy ~= 0 then
		local cols

		
		self.x, self.y, cols, cols_len = world:move(self.bumpName, self.x + dx, self.y + dy)
		self.x, self.x = self.x + dx, self.y + dy
		cam:setPosition(currentPlayer.x, currentPlayer.y)

		for i=1, cols_len do
			local col = cols[i]
		end
	end

	self.sprite:update(dt)
end

function Player:spriteInit()
	self.sprite  = sodapop.newAnimatedSprite()
	self.sprite:setAnchor(function()
		return self.x+4, self.y+4
	end)

	self.sprite:addAnimation('idle', {
		image       = playerSheet,
		frameWidth  = 16,
		frameHeight = 16,
		frames      = {
			{1, 1, 2, 1, .5},
		},
	})

	self.sprite:addAnimation('movex', {
		image       = playerSheet,
		frameWidth  = 16,
		frameHeight = 16,
		frames      = {
			{3, 1, 4, 1, .5},
		},
	})
	self.sprite:addAnimation('movey', {
		image       = playerSheet,
		frameWidth  = 16,
		frameHeight = 16,
		frames      = {
			{5, 1, 6, 1, .5},
		},
	})

end