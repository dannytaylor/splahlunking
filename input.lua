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
		if key == 'f1' and windowScale~=2 then 
			windowScale = 2
			windowW, windowH = viewW*windowScale, viewH*windowScale
			love.window.setMode(windowW, windowH, {msaa = 0})
		elseif key == 'f2' and windowScale~=4 then 
			windowScale = 4
			windowW, windowH = viewW*windowScale, viewH*windowScale
			love.window.setMode(windowW, windowH, {msaa = 0})
		elseif key == 'f3' and windowScale~=8 then 
			windowScale = 8
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
			matchinprogress = true

			menu.screens['char'].buttons[3].img = btq.c2
			menu.screens['char'].buttons[3].imgActive = btq.c2a

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

		-- return to char sel
		elseif key == 'r' then
			if alldone and not client then -- and match == over then
				gamestate = 0
				tankBubbler = nil

				if currentsong then currentsong:stop() end
				currentsong = song1
				menu.currentScreen = menu.screens['char']

				if server then
					if numConnected ~=  server:getClientCount()+1 then
						numConnected = server:getClientCount()+1
						local cl = server:getClients() -- clientlist
						for i=2,numConnected do
							cl[i-1]:send("newpid",{
								n = i
								})
						end
					end

					server:sendToAll('returntochar', {
						num = numConnected,
					})

					map = Map()
					mapdata = map:packageData()
					binary_map = bitser.dumps(mapdata)

					server:sendToAll("map",{
						m = binary_map,
						n = numConnected
					})
				end
			end
		elseif key == 'q' and debug then
			cam:setScale(cam:getScale()*2)
		elseif key == 'e' and debug then
			cam:setScale(cam:getScale()/2)
		elseif key == 'g' and debug  then
			map = Map()
			world:add('player', players[pid].x,players[pid].y,tileSize,tileSize)
		elseif key == 'x' or key == 'return'  then
			if not players[pid].emoteTimer and gametime > 0 and players[pid].alive then
				players[pid].emoteTimer = 0 
			end
		end
	end
end

function menukeys(key)
	local mcs = menu.currentScreen
	if mcs == menu.screens['char'] then
		if key == 'f4' then
			menu.screens['char'].currentChar[pid] = 6
			if sfx_buttonClick:isPlaying() then sfx_buttonClick:stop() end
			love.audio.play(sfx_buttonClick)
		end
		if mcs.currentButton.name == 'char' then
			if key == 'down' or key == 's' then
				local cc = menu.screens['char'].currentChar[pid]
				cc = cc - 1
				if cc < 1 then cc = 6 end
				menu.screens['char'].currentChar[pid] = cc
				if sfx_buttonClick:isPlaying() then sfx_buttonClick:stop() end
				love.audio.play(sfx_buttonClick)
			elseif  key == 'up' or key == 'w' then	
				local cc = menu.screens['char'].currentChar[pid]
				cc = cc + 1
				if cc > 6 then cc = 1 end
				menu.screens['char'].currentChar[pid] = cc
				if sfx_buttonClick:isPlaying() then sfx_buttonClick:stop() end
				love.audio.play(sfx_buttonClick)
			end
		elseif mcs.currentButton.name == 'map' and not client then
			if key == 'down' or key == 's' then
				if sfx_buttonClick:isPlaying() then sfx_buttonClick:stop() end
				love.audio.play(sfx_buttonClick)
				if mapsel == 3 then mapsel = 1
				else mapsel = mapsel + 1 end
			elseif  key == 'up' or key == 'w' then	
				if sfx_buttonClick:isPlaying() then sfx_buttonClick:stop() end
				love.audio.play(sfx_buttonClick)
				if mapsel == 1 then mapsel = 3
				else mapsel = mapsel - 1 end
			end
		end

	end

	if key == 'escape' then
		connectswitch = false
		connectmsg = nil
		if sfx_button:isPlaying() then sfx_button:stop() end
		love.audio.play(sfx_button)
		if mcs == menu.screens['title'] then
			love.event.quit()
		else
			menu.currentScreen = menu.screens['title']
			menu.screens['char'].buttons[3].img = btq.c2
			menu.screens['char'].buttons[3].imgActive = btq.c2a
			numConnected = 1
			if client then 
				if client:isConnected() then client:disconnect() end 
				client = nil
			end
			if server then 
				server:destroy()
				server = nil
			end
		end
	elseif key == 'left' or key == 'a' then
		if not client then
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
		end
	elseif key == 'right' or key == 'd' and not client then
		if not client then
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
		end
	elseif key == 'up' or key == 'w' then
	elseif key == 'down' or key == 's' then
		
	elseif key == 'return' or key == 'x' then
		love.audio.play(sfx_buttonClick)

		mcs.currentButton.action()
		if not client and mcs == menu.screens['char'] and mcs.buttonIndex ~=3 then
			mcs.currentButton.active = false
			mcs.buttonIndex = mcs.buttonIndex + 1
			mcs.currentButton = mcs.buttons[mcs.buttonIndex]
			mcs.currentButton.active = true
		end
	end
end