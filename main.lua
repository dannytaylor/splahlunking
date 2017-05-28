debug = true

-- main.lua
Object = require 'lib/classic'  	-- simple class module    	https://github.com/rxi/classic/
lume = require 'lib/lume'    		-- basic helper functions   https://github.com/rxi/lume/
gamera = require 'lib/gamera'
bump = require 'lib/bump'			-- collisions 				https://github.com/kikito/bump.lua
sodapop = require 'lib/sodapop'		-- sprite anim 				https://github.com/tesselode/sodapop
sock = require 'lib/sock'		-- networking				https://github.com/camchenry/sock.lua

require 'init'
require 'input'

require 'obj/Map'
require 'obj/Player'
require 'obj/Treasure'
require 'obj/UI'
require 'obj/Bubbler'

players = {}
currentPlayer = nil

gamestates = {[0]=splash, [1]=ingame, [2]=mainmenu}


function love.load()
	math.randomseed(os.time())
	init()

end


function love.update(dt)
	if debug then require("lib/lovebird").update() end-- debug in http://127.0.0.1:8000/ 'F1'
	currentPlayer:update(dt)
	ui:update(dt)
end


function love.draw()
	love.graphics.clear()
	-- 
	cam:draw(function()
	  	map:draw()

		currentPlayer:draw()

		-- for i=1,#players do
		-- 	players[i]:draw()
		-- end
	end)

	-- love.graphics.draw(lightMask, 0, 0, 0, windowScale, windowScale)

	ui:draw()


end