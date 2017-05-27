-- init.lua

tileSize = 8
viewW, viewH = 16*tileSize, 10*tileSize
windowScale = 4

waterLevel = 12

function init()
	windowW, windowH = viewW*windowScale, viewH*windowScale
	love.window.setMode(windowW, windowH, {msaa = 0})
	-- canvas = love.graphics.newCanvas(viewW, viewH,"normal",0)
	-- canvas:setFilter("nearest", "nearest")


	map = Map()

	initSprites()

	p1spawn = {x = 48, y = 6}
	currentPlayer = Player(p1spawn.x*tileSize,p1spawn.y*tileSize)

	cam = gamera.new(0,0,map.w*tileSize,map.h*tileSize)
	cam:setScale(windowScale)
	cam:setPosition(currentPlayer.x, currentPlayer.y)
end
function initSprites()
	playerSheet = love.graphics.newImage 'img/player.png'
	tileSheet = love.graphics.newImage 'img/tile.png'

	playerSheet:setFilter('nearest', 'nearest')
	tileSheet:setFilter('nearest', 'nearest')
end