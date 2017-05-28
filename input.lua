-- input.lua

function love.keypressed(key) -- key bindings
	if gamestate == 0 then
		menukeys(key)
	end
	if gamestate == 1 then
		if key == 'escape' then
			love.event.quit()
		elseif key == 'q' and debug then
			cam:setScale(cam:getScale()*2)
		elseif key == 'e' and debug then
			cam:setScale(cam:getScale()/2)
		elseif key == 'r' and debug  then
			map = Map()
			world:add('player', players[pid].x,players[pid].y,tileSize,tileSize)
		end
	end

	if key == 'f1' and debug then -- open debug window
		love.system.openURL( 'http://127.0.0.1:8000/' )
	end
end

function menukeys(key)
	local mcs = menu.currentScreen
	if key == 'escape' then
		if mcs == menu.screens['title'] then
			love.event.quit()
		else
			menu.currentScreen = menu.screens['title']
			client = nil
			server = nil
		end
	elseif key == 'left'  then
		if #mcs.buttons > 1 then
			if mcs.buttonIndex == 1 then
				mcs.buttonIndex = #mcs.buttons
			else
				mcs.buttonIndex = mcs.buttonIndex-1
			end
			mcs.currentButton.active = false
			mcs.currentButton = mcs.buttons[mcs.buttonIndex]
			mcs.currentButton.active = true
		end
	elseif key == 'right' then
		if #mcs.buttons > 1 then
			if mcs.buttonIndex == #mcs.buttons then
				mcs.buttonIndex = 1
			else
				mcs.buttonIndex = mcs.buttonIndex+1
			end
			mcs.currentButton.active = false
			mcs.currentButton = mcs.buttons[mcs.buttonIndex]
			mcs.currentButton.active = true
		end
	elseif key == 'up' then
	elseif key == 'down' then
		
	elseif key == 'return' then
		mcs.currentButton.action()
	end
end