-- init.lua

tileSize = 8
viewW, viewH = 16*tileSize, 10*tileSize
windowScale = 4

waterLevel = 12
maxTreasure = 30
maxLargeTreasure = 3

numConnected = 1
tick = 0
tickRate = 1/60



function init()
	windowW, windowH = viewW*windowScale, viewH*windowScale
	love.window.setMode(windowW, windowH, {msaa = 0})

	local imgFont = love.graphics.newImage("img/font.png")
	font = love.graphics.newImageFont(imgFont, " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,-!$:;'", 1)
	love.graphics.setFont(font)

	initSprites()
	if gamestate == 0 then
		initMenu()
	elseif gamestate == 1 then
		initMap()
	end
end

function initMenu()
	menu = Menu()
end

function initMap()
	if server then
		map = Map()
		mapdata = map:packageData()
		binary_map = bitser.dumps(mapdata)

	elseif client then
		if not mapdata then print('no map data!') end
		map = Map(mapdata)

	else -- single player
		map = Map()
		pid = 1
		startMatch()
	end
end

function startMatch()
	-- init players
	local p1s = {x = 59, y = 7} 
	print('pid: '..pid..', numconnected: '.. numConnected)
	for i=1,numConnected do
		players[i] = Player((p1s.x+i)*tileSize,(p1s.y)*tileSize,i)
	end

	cam = gamera.new(0,0,map.w*tileSize,map.h*tileSize)
	cam:setScale(windowScale)
	cam:setPosition(players[pid].x, players[pid].y)

	ui = UI()
end
	


function initSprites() -- and quads
	playerSheet = love.graphics.newImage 'img/player.png'
	tileSheet = love.graphics.newImage 'img/tile.png'
	lightMask = love.graphics.newImage 'img/light_mask.png'
	uiSheet = love.graphics.newImage 'img/uiSheet.png'
	treasureSheet = love.graphics.newImage 'img/treasureSheet.png'
	playerLight = love.graphics.newImage 'img/playerLight.png'
	titlebg = love.graphics.newImage 'img/titlebg.png'
	titlebg2 = love.graphics.newImage 'img/titlebg2.png'

	playerSheet:setFilter('nearest', 'nearest')
	tileSheet:setFilter('nearest', 'nearest')
	lightMask:setFilter('nearest', 'nearest')
	uiSheet:setFilter('nearest', 'nearest')
	treasureSheet:setFilter('nearest', 'nearest')
	playerLight:setFilter('nearest', 'nearest')
	titlebg:setFilter('nearest', 'nearest')
	titlebg2:setFilter('nearest', 'nearest')

	playerAnimInit()

	local tilesetW, tilesetH = tileSheet:getWidth(), tileSheet:getHeight()
	tq = { --tile quads

		-- flat
		i0   = love.graphics.newQuad(0*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		i90  = love.graphics.newQuad(0*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		i180 = love.graphics.newQuad(0*tileSize,  2*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		i270 = love.graphics.newQuad(0*tileSize,  3*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		-- island
		o = love.graphics.newQuad(1*tileSize,  0, tileSize, tileSize, tilesetW, tilesetH),

		-- l
		l0   = love.graphics.newQuad(2*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		l90  = love.graphics.newQuad(2*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		l180 = love.graphics.newQuad(2*tileSize,  2*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		l270 = love.graphics.newQuad(2*tileSize,  3*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		-- l pipe
		l0p  = love.graphics.newQuad(1*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		l90p = love.graphics.newQuad(1*tileSize,  2*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		-- t
		t0   = love.graphics.newQuad(3*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		t90  = love.graphics.newQuad(3*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		t180 = love.graphics.newQuad(3*tileSize,  2*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		t270 = love.graphics.newQuad(3*tileSize,  3*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		-- grass i
		gi0	  = love.graphics.newQuad(4*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		gi90  = love.graphics.newQuad(4*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		gi270 = love.graphics.newQuad(4*tileSize,  3*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		-- grass t
		gt0   = love.graphics.newQuad(5*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		gt180 = love.graphics.newQuad(5*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		-- corners
		c0    = love.graphics.newQuad(6*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		c90   = love.graphics.newQuad(6*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		c180  = love.graphics.newQuad(6*tileSize,  2*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		c270  = love.graphics.newQuad(6*tileSize,  3*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		black = love.graphics.newQuad(7*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
	}

	tilesetW, tilesetH = uiSheet:getWidth(), uiSheet:getHeight()
	uiq = { -- ui quads
		bubble_s   = love.graphics.newQuad(0*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		bubble_l   = love.graphics.newQuad(0*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		score1   = love.graphics.newQuad(1*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		score2   = love.graphics.newQuad(1*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),
	}

	tilesetW, tilesetH = treasureSheet:getWidth(), treasureSheet:getHeight()
	trq = {
		t1  = love.graphics.newQuad(0*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		t2  = love.graphics.newQuad(1*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		t3  = love.graphics.newQuad(2*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		t4  = love.graphics.newQuad(3*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		t5  = love.graphics.newQuad(4*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		tl1  = love.graphics.newQuad(0*tileSize,  2*tileSize, tileSize*2, tileSize*2, tilesetW, tilesetH),
		tl2  = love.graphics.newQuad(2*tileSize,  2*tileSize, tileSize*2, tileSize*2, tilesetW, tilesetH),

		txl1  = love.graphics.newQuad(0*tileSize,  4*tileSize, tileSize*4, tileSize*4, tilesetW, tilesetH),
	}
end

function playerAnimInit()
	local psw,psh = playerSheet:getWidth(), playerSheet:getHeight()
	local psNum = psh/16
	pGrid = anim8.newGrid(16, 16, psw,psh)
	pAnim = {}
	for i=1,psNum do
		pAnim[i] = {}
		pAnim[i]['idle'] = anim8.newAnimation(pGrid('1-2',i), 0.8)
		pAnim[i]['movex'] = anim8.newAnimation(pGrid('3-4',i), 0.4)
		pAnim[i]['movey'] = anim8.newAnimation(pGrid('5-6',i), 0.4)
		pAnim[i]['idle_dry'] = anim8.newAnimation(pGrid('7-7',i), 0.8)
		pAnim[i]['movex_dry'] = anim8.newAnimation(pGrid('8-11',i), 0.4)
	end
end