-- init.lua

tileSize = 8
viewW, viewH = 16*tileSize, 10*tileSize
windowScale = 4


numConnected = 1
tick = 0
tickRate = 1/60


gametime = 0


function init()
	windowW, windowH = viewW*windowScale, viewH*windowScale
	love.window.setMode(windowW, windowH, {msaa = 0})
	love.window.setTitle('SPLAHLUNKING')
	icon = love.image.newImageData('img/icon.png')

	love.window.setIcon(icon)
	love.graphics.setLineStyle('rough')

	font = love.graphics.newImageFont("img/font.png", " ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.,:;!='\"+", 1)
	love.graphics.setFont( font )

	initSounds()
	initSprites()
	if gamestate == 0 then
		initMenu()
	elseif gamestate == 1 then
		initMap()
	end
	mapsel = 1
end

function initMenu()
	menu = Menu()
end

function initMap()
	gametime = 0
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
	map:setQuads()
	map:setCanvas()
	-- init players
	local spawnx = { 59, 69, 57,71}
	print('pid: '..pid..', numconnected: '.. numConnected)
	for i=1,numConnected do
		players[i] = Player(spawnx[i]*tileSize,7*tileSize,i,menu.screens['char'].currentChar[i])
	end
	cam = gamera.new(0,0,map.w*tileSize,map.h*tileSize)
	cam:setScale(windowScale)
	cam:setPosition(players[pid].x, players[pid].y)

	ui = UI()
	matchinprogress = true
	alldone = false
end
	
function initSounds()
	sfx_button = love.audio.newSource("sfx/swap.wav","static")
	sfx_buttonClick = love.audio.newSource("sfx/click.wav","static")
	sfx_splash = love.audio.newSource("sfx/splash.wav","static")
	sfx_explode = love.audio.newSource("sfx/explode.wav","static")
	sfx_collect = love.audio.newSource("sfx/treasure.wav","static")
	sfx_death = love.audio.newSource("sfx/death.wav","static")
	sfx_bubble1 = love.audio.newSource("sfx/bubble1.wav","static")

	song1 =  love.audio.newSource("sfx/song1.wav")
	song2 = love.audio.newSource("sfx/song2.wav")
	song3 = nil

	currentsong = song1
	if not mute then currentsong:play() end
end

function initSprites() -- and quads
	playerSheet = love.graphics.newImage 'img/player.png'
	tiles = {
		love.graphics.newImage 'img/tiles1.png',
		love.graphics.newImage 'img/tiles2.png',
		love.graphics.newImage 'img/tiles3.png',
	}
	uiSheet = love.graphics.newImage 'img/uiSheet.png'
	treasureSheet = love.graphics.newImage 'img/treasureSheet.png'
	titlebuttons = love.graphics.newImage 'img/titlebuttons.png'
	charsheet = love.graphics.newImage 'img/charsheet.png'

	playerLightSheet = love.graphics.newImage 'img/playerLightSheet.png'
	lightMask = love.graphics.newImage 'img/light_mask.png'
	overlay_dead = love.graphics.newImage 'img/overlay_dead.png'

	titlebg = love.graphics.newImage 'img/titlebg.png'
	titlebg2 = love.graphics.newImage 'img/connectbg.png'
	titlebg3 = love.graphics.newImage 'img/charbg.png'
	camp = {
		love.graphics.newImage 'img/camp1.png',
		love.graphics.newImage 'img/camp2.png',
		love.graphics.newImage 'img/camp3.png',
	}

	sparklesheet = love.graphics.newImage 'img/sparklesheet.png'
	splashsheet = love.graphics.newImage 'img/splash.png'



	local tilesetW, tilesetH = tiles[1]:getWidth(), tiles[2]:getHeight()
	tq = { --tile quads

		-- flat
		i0   = love.graphics.newQuad(0*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		i90  = love.graphics.newQuad(0*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		i180 = love.graphics.newQuad(0*tileSize,  2*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		i270 = love.graphics.newQuad(0*tileSize,  3*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		i0b   = love.graphics.newQuad(0*tileSize,  4*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		i90b  = love.graphics.newQuad(0*tileSize,  5*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		i180b = love.graphics.newQuad(0*tileSize,  6*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		i270b = love.graphics.newQuad(0*tileSize,  7*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		-- island
		o = love.graphics.newQuad(1*tileSize,  0, tileSize, tileSize, tilesetW, tilesetH),
		ob = love.graphics.newQuad(1*tileSize,  4*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		-- l
		l0   = love.graphics.newQuad(2*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		l90  = love.graphics.newQuad(2*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		l180 = love.graphics.newQuad(2*tileSize,  2*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		l270 = love.graphics.newQuad(2*tileSize,  3*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		l0b   = love.graphics.newQuad(2*tileSize,  4*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		l90b  = love.graphics.newQuad(2*tileSize,  5*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		l180b = love.graphics.newQuad(2*tileSize,  6*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		l270b = love.graphics.newQuad(2*tileSize,  7*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		-- l pipe
		l0p  = love.graphics.newQuad(1*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		l90p = love.graphics.newQuad(1*tileSize,  2*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		l0pb  = love.graphics.newQuad(1*tileSize,  5*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		l90pb = love.graphics.newQuad(1*tileSize,  6*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		-- t
		t0   = love.graphics.newQuad(3*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		t90  = love.graphics.newQuad(3*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		t180 = love.graphics.newQuad(3*tileSize,  2*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		t270 = love.graphics.newQuad(3*tileSize,  3*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		t0b   = love.graphics.newQuad(3*tileSize,  4*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		t90b  = love.graphics.newQuad(3*tileSize,  5*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		t180b = love.graphics.newQuad(3*tileSize,  6*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		t270b = love.graphics.newQuad(3*tileSize,  7*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		-- grass i
		gi0	  = love.graphics.newQuad(4*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		gi90  = love.graphics.newQuad(4*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		gi270 = love.graphics.newQuad(4*tileSize,  3*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		gi0b 	= love.graphics.newQuad(4*tileSize,  4*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		gi90b  = love.graphics.newQuad(4*tileSize,  5*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		gi270b = love.graphics.newQuad(4*tileSize,  7*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		-- grass t
		gt0   = love.graphics.newQuad(5*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		gt180 = love.graphics.newQuad(5*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		gt0b   = love.graphics.newQuad(5*tileSize,  4*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		gt180b = love.graphics.newQuad(5*tileSize,  5*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		-- corners
		c0    = love.graphics.newQuad(6*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		c90   = love.graphics.newQuad(6*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		c180  = love.graphics.newQuad(6*tileSize,  2*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		c270  = love.graphics.newQuad(6*tileSize,  3*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		c0b    = love.graphics.newQuad(6*tileSize,  4*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		c90b   = love.graphics.newQuad(6*tileSize,  5*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		c180b  = love.graphics.newQuad(6*tileSize,  6*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		c270b  = love.graphics.newQuad(6*tileSize,  7*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		black = love.graphics.newQuad(7*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		blank = love.graphics.newQuad(7*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		w1 = love.graphics.newQuad(8*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		w2 = love.graphics.newQuad(8*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		w3 = love.graphics.newQuad(8*tileSize,  2*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		w4 = love.graphics.newQuad(8*tileSize,  3*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		d00 = love.graphics.newQuad(9*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		d01 = love.graphics.newQuad(9*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		d02 = love.graphics.newQuad(9*tileSize,  2*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		d03 = love.graphics.newQuad(9*tileSize,  3*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		d04 = love.graphics.newQuad(9*tileSize,  4*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		d10 = love.graphics.newQuad(10*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		d11 = love.graphics.newQuad(10*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		d12 = love.graphics.newQuad(10*tileSize,  2*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		d13 = love.graphics.newQuad(10*tileSize,  3*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		d14 = love.graphics.newQuad(10*tileSize,  4*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		d20 = love.graphics.newQuad(11*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		d21 = love.graphics.newQuad(11*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		d22 = love.graphics.newQuad(11*tileSize,  2*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		d23 = love.graphics.newQuad(11*tileSize,  3*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		d24 = love.graphics.newQuad(11*tileSize,  4*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		d30 = love.graphics.newQuad(12*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		d31 = love.graphics.newQuad(12*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		d32 = love.graphics.newQuad(12*tileSize,  2*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		d33 = love.graphics.newQuad(12*tileSize,  3*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		d34 = love.graphics.newQuad(12*tileSize,  4*tileSize, tileSize, tileSize, tilesetW, tilesetH),
	}

	tilesetW, tilesetH = uiSheet:getWidth(), uiSheet:getHeight()
	uiq = { -- ui quads
		bubble_s   = love.graphics.newQuad(0*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		bubble_l   = love.graphics.newQuad(0*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		score1   = love.graphics.newQuad(1*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		score2   = love.graphics.newQuad(1*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		dead   	 = love.graphics.newQuad(3*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		winning  = love.graphics.newQuad(3*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		hl  	 = love.graphics.newQuad(3*tileSize,  2*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		surface	 = love.graphics.newQuad(3*tileSize,  3*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		tank1  	 = love.graphics.newQuad(0*tileSize,  3*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		tank2  	 = love.graphics.newQuad(0*tileSize,  4*tileSize, tileSize, tileSize, tilesetW, tilesetH),

		tankmsg  	 = love.graphics.newQuad(0*tileSize,  5*tileSize, 6*tileSize, 2*tileSize, tilesetW, tilesetH),
		alivemsg  	 = love.graphics.newQuad(0*tileSize,  9*tileSize, 6*tileSize, 2*tileSize, tilesetW, tilesetH),
		client_msg 	 = love.graphics.newQuad(48,  56,6*tileSize, 2*tileSize, tilesetW, tilesetH),
		host_msg 	 = love.graphics.newQuad(48,  72, 6*tileSize, 2*tileSize, tilesetW, tilesetH),
		wait_msg 	 = love.graphics.newQuad(0,  56, 6*tileSize, 2*tileSize, tilesetW, tilesetH),
	}

	uiq2 = {
		love.graphics.newQuad(2*tileSize,  0*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		love.graphics.newQuad(2*tileSize,  1*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		love.graphics.newQuad(2*tileSize,  2*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		love.graphics.newQuad(2*tileSize,  3*tileSize, tileSize, tileSize, tilesetW, tilesetH),
		love.graphics.newQuad(2*tileSize,  4*tileSize, tileSize, tileSize, tilesetW, tilesetH),
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

		mapa = love.graphics.newQuad(3*16,  4*16, 32, 8, tilesetW, tilesetH),
		map = love.graphics.newQuad(3*16,  4.5*16, 32, 8, tilesetW, tilesetH),

		mapbg = love.graphics.newQuad(5*16,  4*16, 21, 24, tilesetW, tilesetH),


		hosting 	= love.graphics.newQuad(0*32,  64, 48,8, tilesetW, tilesetH),
		connected 	= love.graphics.newQuad(0*32,  72, 48,8, tilesetW, tilesetH)
	}

	mapicons = {
		love.graphics.newQuad(7*16,  4*16, 21, 6, tilesetW, tilesetH),
		love.graphics.newQuad(7*16,  4.5*16, 21,6, tilesetW, tilesetH),
		love.graphics.newQuad(7*16,  5*16, 21,6, tilesetW, tilesetH),
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
	bio = {
		love.graphics.newQuad(0,  4*16, 6*16,3*16, tilesetW, tilesetH),
		love.graphics.newQuad(96,  2*32, 5*16,2*16, tilesetW, tilesetH),
		love.graphics.newQuad(96,  3*32, 5*16,2*16, tilesetW, tilesetH),
		love.graphics.newQuad(176,  2*32, 5*16,2*16, tilesetW, tilesetH),
		love.graphics.newQuad(176,  3*32, 5*16,2*16, tilesetW, tilesetH),
		love.graphics.newQuad(176,  4*32, 5*16,2*16, tilesetW, tilesetH),
	}
end