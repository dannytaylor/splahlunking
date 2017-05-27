-- main.lua
Object = require 'lib/classic'  	-- simple class module    	https://github.com/rxi/classic/
lume = require 'lib/lume'    		-- basic helper functions   https://github.com/rxi/lume/
gamera = require 'lib/gamera'
bump = require 'lib/bump'			-- collisions 				https://github.com/kikito/bump.lua
sodapop = require 'lib/sodapop'			-- sprite anim 				https://github.com/tesselode/sodapop

require 'init'
require 'input'

require 'obj/Map'
require 'obj/Player'

players = {}
currentPlayer = nil

gamestates = {[0]=splash, [1]=ingame, [2]=mainmenu}

debug = true


function love.load()
	math.randomseed(os.time())
	init()

end


function love.update(dt)
	if debug then require("lib/lovebird").update() end-- debug in http://127.0.0.1:8000/ 'F1'
	currentPlayer:update(dt)
end


function love.draw()
	love.graphics.clear()
	-- love.graphics.setCanvas(canvas)
	cam:draw(function()
	  	map:draw()
		currentPlayer:draw()
	end)

	-- love.graphics.draw(lightMask, 0, 0, 0, windowScale, windowScale)


	-- map:draw()
	-- currentPlayer:draw()	

	-- love.graphics.setCanvas()

	-- love.graphics.draw(canvas, 0, 0, 0, windowScale, windowScale)
	
	-- map:draw()
	-- currentPlayer:draw()	


end