-- init.lua

tileSize = 8
viewW, viewH = 16*tileSize, 10*tileSize
windowScale = 4

waterLevel = 12
maxTreasure = 30
maxLargeTreasure = 2

function init()
	windowW, windowH = viewW*windowScale, viewH*windowScale
	love.window.setMode(windowW, windowH, {msaa = 0})

	initSprites()

	map = Map()

	--temp
	p1spawn = {x = 60, y = 7} 
	currentPlayer = Player(p1spawn.x*tileSize,p1spawn.y*tileSize)

	cam = gamera.new(0,0,map.w*tileSize,map.h*tileSize)
	cam:setScale(windowScale)
	cam:setPosition(currentPlayer.x, currentPlayer.y)

	ui = UI()
end

function initSprites() -- and quads
	playerSheet = love.graphics.newImage 'img/player.png'
	tileSheet = love.graphics.newImage 'img/tile.png'
	lightMask = love.graphics.newImage 'img/light_mask.png'
	uiSheet = love.graphics.newImage 'img/uiSheet.png'
	treasureSheet = love.graphics.newImage 'img/treasureSheet.png'


	playerSheet:setFilter('nearest', 'nearest')
	tileSheet:setFilter('nearest', 'nearest')
	lightMask:setFilter('nearest', 'nearest')
	uiSheet:setFilter('nearest', 'nearest')
	treasureSheet:setFilter('nearest', 'nearest')

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
	}
end