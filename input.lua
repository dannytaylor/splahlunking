-- input.lua

function love.textinput (text)
    if scoreBox.active then
    	local t = ''
    	if string.len(scoreBox.text) == 0 then t = string.match(text,'%w*@*')
    	else  t = string.match(text,'%w*') end
		if t then 
			t = string.upper(t)
			if string.len(scoreBox.text) <= 11 then
	        	scoreBox.text = scoreBox.text .. t
    		end	
        end
    elseif hostBox.active then
    	local t = string.match(text,'%w*')
		if t then 
			t = string.upper(t)
			if string.len(hostBox.text) <= 11 then
	        	hostBox.text = hostBox.text .. t
    		end	
        end
    elseif ipBox.active then
    	local t = string.match(text,'%w*%.*')
		if t then 
			t = string.upper(t)
			if string.len(ipBox.text) <= 14 then
	        	ipBox.text = ipBox.text .. t
    		end	
        end
    end
end

function love.keypressed(key) -- key bindings
	if scoreBox.active then
		if key == 'escape' then
			scoreBox.active  = false
		elseif key == 'return' then
			local submitted = false
			local charnames = {
				'dive classic',
				'diva',
				'top dive',
				'mr dive',
				'evid',
				'sanic',
			}
			local comment = charnames[players[pid].palette]
			if scoreBox.text ~= '' then 

				local send = Dreamlo.add(scoreBox.text, players[pid].score, 0, comment )
				if send and send == "OK" then 
					-- if test == '' then 
						submitmsg = '>SCORE SUBMITTED!'
					-- elseif players[pid].score <= sc then submitmsg = '>SCORE TOO LOW' 
					
				else submitmsg = ' SUBMIT FAILED' end
				submitted = true
			end
			scoreBox.submitted = submitted
			scoreBox.active  = false
		elseif key == "backspace" then
			-- get the byte offset to the last UTF-8 character in the string.
			local byteoffset = utf8.offset(scoreBox.text, -1)

			if byteoffset then
				-- remove the last UTF-8 character.
				-- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
				scoreBox.text = string.sub(scoreBox.text, 1, byteoffset - 1)
			end
		end
	elseif hostBox.active then
		if key == 'escape' then
			hostBox.active  = false
			if sfx_button:isPlaying() then sfx_button:stop() end
			love.audio.play(sfx_button)
		elseif key == 'return' then
			local submitted = false
			if hostBox.text ~= '' then 
				if sfx_buttonClick:isPlaying() then sfx_buttonClick:stop() end
				love.audio.play(sfx_buttonClick)
				externalip = http.request('http://myip.dnsomatic.com/')
				mmAddLobby(hostBox.text)
				hostBox.active  = false

				initServer()
				initMap()
				menu.currentScreen = menu.screens['char']

			end
		elseif key == "backspace" then
			local byteoffset = utf8.offset(hostBox.text, -1)
			if byteoffset then hostBox.text = string.sub(hostBox.text, 1, byteoffset - 1) end
		end
	elseif ipBox.active then
		if key == 'escape' then
			if sfx_button:isPlaying() then sfx_button:stop() end
			love.audio.play(sfx_button)
			ipBox.active  = false
			ipBox.text = ''
		elseif key == 'return'  then
			if sfx_buttonClick:isPlaying() then sfx_buttonClick:stop() end
			love.audio.play(sfx_buttonClick)
			initClient()
			if client and not connectswitch then
				client:connect()
				connectswitch = true
				connectmsg = "TRYING CONNECTION..."
			end

		elseif key == "backspace" then
			local byteoffset = utf8.offset(ipBox.text, -1)
			if byteoffset then ipBox.text = string.sub(ipBox.text, 1, byteoffset - 1) end
		end
	elseif lobbyBox.active then
		if key == 'escape' then
			if sfx_button:isPlaying() then sfx_button:stop() end
			love.audio.play(sfx_button)
			lobbyBox.active  = false
			lobbyBox.index = 1 
		elseif key == 'up' or key == 'w' then
			if lobbyBox.index>1 then
				if sfx_button:isPlaying() then sfx_button:stop() end
				love.audio.play(sfx_button)
				if lobbyBox.top == lobbyBox.index then lobbyBox.top = lobbyBox.top -1 end
				lobbyBox.index = lobbyBox.index - 1
			end

		elseif key == 'down' or key == 's' then

			if lobbyBox.index<#lobbyList then
				if sfx_button:isPlaying() then sfx_button:stop() end
				love.audio.play(sfx_button)
				if lobbyBox.top < lobbyBox.index - 2 then lobbyBox.top = lobbyBox.top + 1 end
				lobbyBox.index = lobbyBox.index + 1
			end
		elseif (key == 'left' or key == 'right' or key == 'a' or key == 'd' ) and #lobbyList > 0 then
			if sfx_button:isPlaying() then sfx_button:stop() end
			love.audio.play(sfx_button)
			lobbyBox.ipbutton = not	lobbyBox.ipbutton 


		elseif key == 'return'  or key == 'x' then
			if sfx_buttonClick:isPlaying() then sfx_buttonClick:stop() end
			love.audio.play(sfx_buttonClick)
			if not lobbyBox.ipbutton then
				initClient()
				if client and not connectswitch then
					client:connect()
					connectswitch = true
					connectmsg = "TRYING CONNECTION..."
				end
			elseif lobbyBox.ipbutton then
				local clipboard = love.system.getClipboardText()
				local iptest = string.match(clipboard,"%d+.%d+.%d+.%d+")
				if clipboard == iptest then
					ipBox.text = clipboard
				end

				ipBox.active = true
			end
		end
	else
		if key == 'm' then 
			mute = not mute
			if currentsong then
				if mute then currentsong:stop()
				else currentsong:play()
				end
			end
		end
		if gamestate == 0 then
			if key == 'q' and menu.currentScreen == menu.screens['title'] then
				love.event.quit()
			elseif key == 'f1' and windowScale~=2 then 
				windowScale = 2
				windowW, windowH = viewW*windowScale, viewH*windowScale
				love.window.setMode(windowW, windowH, {msaa = 0})
			elseif key == 'f2' and windowScale~=4 then 
				windowScale = 4
				windowW, windowH = viewW*windowScale, viewH*windowScale
				love.window.setMode(windowW, windowH, {msaa = 0})
			elseif key == 'f3' and windowScale~=6 then 
				windowScale = 6
				windowW, windowH = viewW*windowScale, viewH*windowScale
				love.window.setMode(windowW, windowH, {msaa = 0})
			elseif key == 'f4' and windowScale~=8 then 
				love.window.setMode(windowW, windowH, {msaa = 0,fullscreen=true})
				windowScale = math.min(love.graphics.getWidth()/viewW,love.graphics.getHeight()/viewH)
				windowW, windowH = viewW*windowScale, viewH*windowScale
				love.window.setMode(windowW, windowH, {msaa = 0, fullscreen=true})
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
					mmRemoveLobby()
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
						mmAddLobby(hostBox.text)
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

			elseif key == 'return' and players[pid].surface and players[pid].win and players[pid].score>0  and not client and not server and not scoreBox.submitted then 
				scoreBox.active = true
				scoreBox.text = ''
			elseif key == 'x' or key == 'return'  then
				if not players[pid].emoteTimer and gametime > 0 and players[pid].alive then
					players[pid].emoteTimer = 0 
					-- love.audio.play(sfx_emote[players[pid].palette])
				end
			elseif key == 'y' and not client and not server then
				if players[pid].gamestate == 'dry' and love.keyboard.isDown('p') then 
					sfx_dolphin:play()	
					local rand = lume.randomchoice({7,players[pid].palette})
					players[pid]:spriteInit(rand)
					players[pid].currentAnim = 'poof'
					players[pid].nextAnim = 'poof'
					players[pid].sprite:switch('poof')
					players[pid].pooftimer = 0
				end
			end
			--dolphin powers
				-- elseif key == 'p' then
				-- 	if players[pid].emoteTimer and players[pid].emoteTimer>0 and gametime > 0 and players[pid].alive and not dolphinswitch then
				-- 		dolphinswitch = true

				-- 		-- local xflip = players[pid].sprite.flipX
				-- 		players[pid]:spriteInit(7)
				-- 		players[pid].currentAnim = 'poof'
				-- 		players[pid].nextAnim = 'poof'
				-- 		players[pid].dolphin = not players[pid].dolphin
				-- 		if players[pid].dolphin then 
				-- 			players[pid]:spriteInit(7)
				-- 			players[pid].breathRate = players[pid].breathRate - 1
				-- 			-- players[pid].speedx = players[pid].speedx + 10
				-- 			-- players[pid].speedy = players[pid].speedy + 10
				-- 		else 
				-- 			players[pid]:spriteInit(players[pid].palette)
				-- 			players[pid].breathRate = players[pid].breathRate + 1
				-- 			-- players[pid].speedx = players[pid].speedx - 10
				-- 			-- players[pid].speedy = players[pid].speedy - 10
				-- 		end
				-- 		players[pid].sprite:switch('poof')
				-- 		if client then
				-- 			client:send("dolphin",{
				-- 				p = pid,
				-- 				d = players[pid].dolphin 
				-- 			})
				-- 		elseif server then
				-- 			server:sendToAll('dolphin', {
				-- 				p = 1,
				-- 				d = players[pid].dolphin 
				-- 			})
				-- 		end
				-- 		sfx_dolphin:play()
				-- 	end
				-- end
		end
	end
end

function menukeys(key)
	local mcs = menu.currentScreen
	if mcs == menu.screens['char'] then
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
			-- elseif key=='p' then 
			-- 	menu.screens['char'].currentChar[pid] = 7
			-- 	love.audio.play(sfx_countdown2)
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
			if client then 
				client:disconnect()
			end
			if server then 
				mmRemoveLobby()
				server = nil
			end
			numConnected = 1
		end
	elseif key == 'left' or key == 'a' then
		if (not client or mcs~=menu.screens['char'] ) and menu.currentScreen~=menu.screens['leaderboard'] then
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
	elseif key == 'right' or key == 'd'then
		if (not client or mcs~=menu.screens['char'] ) and menu.currentScreen~=menu.screens['leaderboard'] then
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
		
	elseif (key == 'return' or key == 'x') and  menu.currentScreen~=menu.screens['leaderboard']  then
		if (menu.currentScreen~=menu.screens['char'] or not client) then love.audio.play(sfx_buttonClick) end

		mcs.currentButton.action()
		if not client and mcs == menu.screens['char'] and mcs.buttonIndex ~=3 then
			mcs.currentButton.active = false
			mcs.buttonIndex = mcs.buttonIndex + 1
			mcs.currentButton = mcs.buttons[mcs.buttonIndex]
			mcs.currentButton.active = true
		end
	end
end