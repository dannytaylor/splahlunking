-- input.lua

function love.keypressed(key) -- key bindings
	if key == 'escape' then
		love.event.quit()
	elseif key == 'q' and debug then
		cam:setScale(cam:getScale()*2)
	elseif key == 'e' and debug then
		cam:setScale(cam:getScale()/2)

	-- elseif key == 'left' then
	-- 	currentPlayer.sprite:switch 'movex'
	-- elseif key == 'right' then
	-- 	currentPlayer.sprite:switch 'movex'
	-- elseif key == 'up' then
	-- 	currentPlayer.sprite:switch 'movey'
	-- elseif key == 'down' then
	-- 	currentPlayer.sprite:switch 'movey'

	elseif key == 'r' and debug  then
		map = Map()
		world:add('player', currentPlayer.x,currentPlayer.y,tileSize,tileSize)
	elseif key == 'f1' and debug then -- open debug window
		love.system.openURL( 'http://127.0.0.1:8000/' )
	end
end

function love.keyreleased(key)
	currentPlayer.sprite:switch 'idle'
end