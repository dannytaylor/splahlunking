-- sockhelper.lua

function clientUpdate(dt)
	client:update()

	if client:getState() == "connected" then
		tick = tick + dt
	end

	if tick >= tickRate then
		tick = 0
		if gamestate == 0 and menu.currentScreen == menu.screens['char'] then
			local clientinfo = {
				id = pid,
				char = menu.screens['char'].currentChar[pid]
			}
			client:send("charclient", clientinfo)
		elseif ui then 
			client:send("clientinfo", {
				x      = players[pid].x,
				y      = players[pid].y,
				id     = pid,

				anim   = players[pid].currentAnim,
				flipX  = players[pid].sprite.flipX,
				flipY  = players[pid].sprite.flipY,

				score  = players[pid].score,
				breath = players[pid].breath,
				alive = players[pid].alive,

				surface = players[pid].surface,
				win = players[pid].win,
			})
		end
	end

end

function serverUpdate(dt)
	server:update()

	tick = tick + dt
	if tick >= tickRate then
		tick = 0
		if gamestate == 0 and menu.currentScreen == menu.screens['char'] then
			local serverinfo = {
				num = numConnected,
				chars = menu.screens['char'].currentChar,
				msel = mapsel
			}
			server:sendToAll("charserver", serverinfo)
		elseif gamestate == 1 and ui then
			local serverinfo = {}
			for i=1,numConnected do
				serverinfo[i] = {
					x      = players[i].x,
					y      = players[i].y,

					anim   = players[i].currentAnim,
					flipX  = players[i].sprite.flipX,
					flipY  = players[i].sprite.flipY,

					score  = players[i].score,
					breath = players[i].breath,
					alive = players[i].alive,

					time = gametime,
					ad = alldone,
				}
			end
			server:sendToAll("serverinfo", serverinfo)
		end
	end
end

function initServer()
	ip_host = love.system.getClipboardText()
	-- server = sock.newServer(ip_host, 22122,3)
	server = sock.newServer('*', 22122,3)
	local hostip = server:getSocketAddress()

	hostip = string.sub(hostip, 1, string.find(hostip,':')-1)
	print (hostip)
	-- love.system.setClipboardText(hostip)
	server:setSerialization(bitser.dumps, bitser.loads)

	pid = 1

	server:on("connect", function(data, client)
		-- Send a message back to the connected client
		numConnected= server:getClientCount() + 1

		client:send("map",{
			m = binary_map,
			n = numConnected
			})
	end)
	server:on("clientinfo", function(data)
		local id                 = data.id
		local x                  = data.x
		local y                  = data.y

		local anim               = data.anim
		local flipX              = data.flipX
		local flipY              = data.flipY

		local score              = data.score
		local breath             = data.breath
		local alive	             = data.alive

		local surface      		= data.surface
		local win      		 	= data.win

		players[id].x            = x
		players[id].y            = y

		players[id].nextAnim     = anim
		players[id].sprite.flipX = flipX
		players[id].sprite.flipY = flipY

		players[id].score        = score
		players[id].breath       = breath
		players[id].alive      	 = alive

		players[id].surface      = surface
		players[id].win      	 = win
	end)
	server:on("charclient", function(data)
		menu.screens['char'].currentChar[data.id] = data.char
	end)
end

function initClient()
	if debug then
		ip_join = 'localhost'
	else
		ip_join = love.system.getClipboardText()
	end
	client = sock.newClient(ip_join, 22122)
	client:setSerialization(bitser.dumps, bitser.loads)

	client:on("connect", function(data)
		print('connected')
	end)
	client:on("start", function(data)
		gamestate = data.state
		numConnected = data.num
		mapsel = data.msel
		print(pid)
		startMatch()
		gamestate = 1
	end)
	client:on("map", function(data)
		map = {}
		binary_map = data.m
		pid = data.n
		mapdata = bitser.loads(binary_map)
		initMap()
		menu.currentScreen = menu.screens['char']
	end)
	client:on("serverinfo", function(data)
		local time  = data[1].time
		gametime	= time
		alldone = data[1].ad

		for i=1,numConnected do
			if i~=pid then
				local x                 = data[i].x
				local y                 = data[i].y

				local anim              = data[i].anim
				local flipX             = data[i].flipX
				local flipY             = data[i].flipY

				local score             = data[i].score
				local breath            = data[i].breath
				local alive           	= data[i].alive

				local win           	= data[i].win
				local surface           = data[i].surface


				players[i].x            = x
				players[i].y            = y


				players[i].nextAnim     = anim
				players[i].sprite.flipX = flipX
				players[i].sprite.flipY = flipY

				players[i].score        = score
				players[i].breath       = breath
				players[i].alive       	= alive

				players[i].surface      = surface
				players[i].win       	= win


			end
		end
	end)
	client:on('charserver', function(data)
		numConnected = data.num
		for i=1, numConnected do
			if i ~= pid then
				menu.screens['char'].currentChar[i] = data.chars[i]
				mapsel = data.msel
				menu.screens['char'].currentChar[i] = data.chars[i]
			end
		end
	end)
	client:on('returntochar', function(data)
		gamestate = 0
		numConnected = data.num
		ui = nil
		gametime = 0
		tankBubbler = nil
		if currentsong then currentsong:stop() end
		currentsong = song1
		players = {}
	end)
end 