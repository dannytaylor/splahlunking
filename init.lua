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
	love.window.setTitle('SPLAHLUNKING')
	icon = love.image.newImageData('img/icon.png')

	love.window.setIcon(icon)

	local imgFont = love.graphics.newImage("img/font.png")

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
	local p1s = {x = 58, y = 7} 
	print('pid: '..pid..', numconnected: '.. numConnected)
	for i=1,numConnected do
		players[i] = Player((p1s.x+i*2)*tileSize,(p1s.y)*tileSize,i,menu.screens['char'].currentChar[i])
	end

	cam = gamera.new(0,0,map.w*tileSize,map.h*tileSize)
	cam:setScale(windowScale)
	cam:setPosition(players[pid].x, players[pid].y)

	ui = UI()
end
	


function initSprites() -- and quads
	playerSheet = love.graphics.newImage 'img/player.png'
	tileSheet = love.graphics.newImage 'img/tile.png'
	uiSheet = love.graphics.newImage 'img/uiSheet.png'
	treasureSheet = love.graphics.newImage 'img/treasureSheet.png'
	titlebuttons = love.graphics.newImage 'img/titlebuttons.png'
	charsheet = love.graphics.newImage 'img/charsheet.png'

	playerLight = love.graphics.newImage 'img/playerLight.png'
	lightMask = love.graphics.newImage 'img/light_mask.png'

	titlebg = love.graphics.newImage 'img/titlebg.png'
	titlebg2 = love.graphics.newImage 'img/connectbg.png'
	titlebg3 = love.graphics.newImage 'img/charbg.png'

	playerSheet:setFilter('nearest', 'nearest')
	tileSheet:setFilter('nearest', 'nearest')
	lightMask:setFilter('nearest', 'nearest')
	uiSheet:setFilter('nearest', 'nearest')
	treasureSheet:setFilter('nearest', 'nearest')
	playerLight:setFilter('nearest', 'nearest')
	titlebg:setFilter('nearest', 'nearest')
	titlebg2:setFilter('nearest', 'nearest')
	titlebuttons:setFilter('nearest', 'nearest')
	titlebg3:setFilter('nearest', 'nearest')
	charsheet:setFilter('nearest', 'nearest')

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
	
	trq = { -- treasure quads
		t1  = love.graphics.newQuad(0*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		t2  = love.graphics.newQuad(1*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		t3  = love.graphics.newQuad(2*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		t4  = love.graphics.newQuad(3*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		t5  = love.graphics.newQuad(4*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		tl1  = love.graphics.newQuad(0*tileSize,  2*tileSize, tileSize*2, tileSize*2, tilesetW, tilesetH),
		tl2  = love.graphics.newQuad(2*tileSize,  2*tileSize, tileSize*2, tileSize*2, tilesetW, tilesetH),

		txl1  = love.graphics.newQuad(0*tileSize,  4*tileSize, tileSize*4, tileSize*4, tilesetW, tilesetH),
	}

	tilesetW, tilesetH = titlebuttons:getWidth(), titlebuttons:getHeight()
	btq = { -- button title quads

		-- main splash
		b1  = love.graphics.newQuad(0*32,  0*32, 32, 32, tilesetW, tilesetH),
		b1a = love.graphics.newQuad(0*32,  1*32, 32, 32, tilesetW, tilesetH),
		b2  = love.graphics.newQuad(1*32,  0*32, 32, 32, tilesetW, tilesetH),
		b2a = love.graphics.newQuad(1*32,  1*32, 32, 32, tilesetW, tilesetH),
		b3  = love.graphics.newQuad(2*32,  0*32, 32, 32, tilesetW, tilesetH),
		b3a = love.graphics.newQuad(2*32,  1*32, 32, 32, tilesetW, tilesetH),

		-- multiplayer
		m1  = love.graphics.newQuad(3*32,  0*32, 32, 32, tilesetW, tilesetH),
		m1a = love.graphics.newQuad(3*32,  1*32, 32, 32, tilesetW, tilesetH),
		m2  = love.graphics.newQuad(4*32,  0*32, 32, 32, tilesetW, tilesetH),
		m2a = love.graphics.newQuad(4*32,  1*32, 32, 32, tilesetW, tilesetH),

		-- char select
		c1  = love.graphics.newQuad(5*32,  2*16, 24, 16, tilesetW, tilesetH),
		c1a = love.graphics.newQuad(5*32,  3*16, 24, 16, tilesetW, tilesetH),
		c2  = love.graphics.newQuad(5*32,  0*16, 32, 16, tilesetW, tilesetH),
		c2a = love.graphics.newQuad(5*32,  1*16, 32, 16, tilesetW, tilesetH),
		c3  = love.graphics.newQuad(5*32,  4*16, 32, 16, tilesetW, tilesetH),
		c3a = love.graphics.newQuad(5*32,  5*16, 32, 16, tilesetW, tilesetH),

	}

	tilesetW, tilesetH = charsheet:getWidth(), charsheet:getHeight()
	csq = { --char select icon quads
		--portraits
		love.graphics.newQuad(0*48,  1*24, 24, 32, tilesetW, tilesetH),
		love.graphics.newQuad(1*48,  1*24, 24, 32, tilesetW, tilesetH),
		love.graphics.newQuad(2*48,  1*24, 24, 32, tilesetW, tilesetH),
		love.graphics.newQuad(3*48,  1*24, 24, 32, tilesetW, tilesetH),
		love.graphics.newQuad(4*48,  1*24, 24, 32, tilesetW, tilesetH),

		love.graphics.newQuad(0*48,  0*24, 48, 24, tilesetW, tilesetH),
		love.graphics.newQuad(1*48,  0*24, 48, 24, tilesetW, tilesetH),
		love.graphics.newQuad(2*48,  0*24, 48, 24, tilesetW, tilesetH),
		love.graphics.newQuad(3*48,  0*24, 48, 24, tilesetW, tilesetH),
		love.graphics.newQuad(4*48,  0*24, 48, 24, tilesetW, tilesetH),
	}
end