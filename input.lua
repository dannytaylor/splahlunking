-- input.lua

function love.keypressed(key) -- key bindings
	if key == 'm' then 
		mute = not mute
		if currentsong then
			if mute then currentsong:stop()
			else currentsong:play()
			end
		end
	end
	if gamestate == 0 then
		if key == 'f2' and windowScale == 4 then 
			windowScale = 8
			windowW, windowH = viewW*windowScale, viewH*windowScale
			love.window.setMode(windowW, windowH, {msaa = 0})
		elseif key == 'f1' and windowScale == 8 then 
			windowScale = 4
			windowW, windowH = viewW*windowScale, viewH*windowScale
			love.window.setMode(windowW, windowH, {msaa = 0})
		end
		menukeys(key)
	end
	if gamestate == 1 then
		if key == 'escape' then
			gamestate = 0

			-- reset everythin
			numConnected = 1
			players = {}
			map = {}
			ui = nil
			gametime = 0
			tankBubbler = nil
			if currentsong then currentsong:stop() end
			currentsong = song1

			love.graphics.setLineWidth(2)
			if client then 
				client:disconnect() 
				client = nil
			end
			if server then 
				server:destroy()
				server = nil
			end
			menu.currentScreen = menu.screens['title']
			-- love.event.quit()
		elseif key == 'q' and debug then
			cam:setScale(cam:getScale()*2)
		elseif key == 'e' and debug then
			cam:setScale(cam:getScale()/2)
		elseif key == 'r' and debug  then
			map = Map()
			world:add('player', players[pid].x,players[pid].y,tileSize,tileSize)
		end
	end
end

function menukeys(key)
	local mcs = menu.currentScreen

	if mcs == menu.screens['char'] and mcs.currentButton.name == 'char' then
		if key == 'down' or key == 's' then
			local cc = menu.screens['char'].currentChar[pid]
			cc = cc - 1
			if cc < 1 then cc = 5 end
			menu.screens['char'].currentChar[pid] = cc
		elseif  key == 'up' or key == 'w' then	
			local cc = menu.screens['char'].currentChar[pid]
			cc = cc + 1
			if cc > 5 then cc = 1 end
			menu.screens['char'].currentChar[pid] = cc
		end
	end

	if key == 'escape' then
		if sfx_button:isPlaying() then sfx_button:stop() end
		love.audio.play(sfx_button)
		if mcs == menu.screens['title'] then
			love.event.quit()
		else
			menu.currentScreen = menu.screens['title']
			numConnected = 1
			if client then 
				client:disconnect() 
				client = nil
			end
			if server then 
				server:destroy()
				server = nil
			end
		end
	elseif key == 'left' or key == 'a' then
		if sfx_button:isPlaying() then sfx_button:stop() end
		love.audio.play(sfx_button)
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
	elseif key == 'right' or key == 'd' then
		if sfx_button:isPlaying() then sfx_button:stop() end
		love.audio.play(sfx_button)
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
	elseif key == 'up' or key == 'w' then
		if sfx_button:isPlaying() then sfx_button:stop() end
		love.audio.play(sfx_button)
	elseif key == 'down' or key == 's' then
		if sfx_button:isPlaying() then sfx_button:stop() end
		love.audio.play(sfx_button)
		
	elseif key == 'return' or key == 'x' then
		love.audio.play(sfx_buttonClick)
		mcs.currentButton.action()
	end
end