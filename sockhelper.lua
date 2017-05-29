-- sockhelper.lua

function clientUpdate(dt)
	client:update()

	if client:getState() == "connected" then
		tick = tick + dt
	end

	if tick >= tickRate then
		tick = 0
		if ui then 
			client:send("clientinfo", {
				x      = players[pid].x,
				y      = players[pid].y,
				id     = pid,

				anim   = players[pid].currentAnim,
				flipX  = players[pid].sprite.flipX,
				flipY  = players[pid].sprite.flipY,

				score  = players[pid].score,
				breath = players[pid].breath,
			})
		end
	end

end

function serverUpdate(dt)
	server:update()

	tick = tick + dt
	if tick >= tickRate then
		tick = 0
		if ui then
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
				}
			end
			server:sendToAll("serverinfo", serverinfo)
		end
	end
end

function initServer()
	server = sock.newServer("*", 22122,3)
	server:setSerialization(bitser.dumps, bitser.loads)

	pid = 1

	server:on("connect", function(data, client)
		-- Send a message back to the connected client
		client:send("map",{
			m = binary_map,
			p = #players,
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

		players[id].x            = x
		players[id].y            = y

		players[id].nextAnim     = anim
		players[id].sprite.flipX = flipX
		players[id].sprite.flipY = flipY

		players[id].score        = score
		players[id].breath       = breath

	end)
end

function initClient()
	client = sock.newClient("localhost", 22122)
	client:setSerialization(bitser.dumps, bitser.loads)

	client:on("connect", function(data)
		print('connected')
	end)
	client:on("start", function(data)
		gamestate = data.state
		numConnected = data.num
		pid = client:getIndex() + 1
		startMatch()
		gamestate = 1
	end)
	client:on("map", function(data)
		binary_map = data.m
		mapdata = bitser.loads(binary_map)
		print('received map: w='..mapdata.w..' h='..mapdata.h)
		initMap()
	end)
	client:on("serverinfo", function(data)
		for i=1,numConnected do
			if i~=pid then
				local x                 = data[i].x
				local y                 = data[i].y

				local anim              = data[i].anim
				local flipX             = data[i].flipX
				local flipY             = data[i].flipY

				local score             = data[i].score
				local breath            = data[i].breath

				players[i].x            = x
				players[i].y            = y


				players[i].nextAnim     = anim
				players[i].sprite.flipX = flipX
				players[i].sprite.flipY = flipY

				players[i].score        = score
				players[i].breath       = breath
			end
		end
	end)
end 