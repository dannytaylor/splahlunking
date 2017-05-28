-- menu.lua

Menu = Object:extend()

function Menu:new()
	self.screens = {}
	self.currentScreen = nil

	self.canvas = love.graphics.newCanvas(viewW*tileSize, viewH*tileSize,"normal",0)
	self.canvas:setFilter("nearest", "nearest")

	self:init()
end
	
function Menu:init()
	self:initScreens()
end

function Menu:draw()
	love.graphics.setCanvas(self.canvas)
	love.graphics.clear()

	self.currentScreen:draw()

	love.graphics.setCanvas()
	love.graphics.draw(self.canvas, 0, 0, 0, windowScale, windowScale)
end

function Menu:update(dt)
	self.currentScreen:update(dt)
end

function Menu:initScreens()
	self.screens = {
		['title'] = Screen(),
		['multi'] = Screen(),
		['join'] = Screen(),
		['char'] = Screen(),
	}
	local ss = self.screens

	ss['title'].bgImg = titlebg
	ss['title'].buttons = {
		Button(2*tileSize,viewH-16,'single', function ()
			gamestate = 1
			initMap()
		end
		),
		Button(6.5*tileSize,viewH-16,'multi'),
		Button(11*tileSize,viewH-16,'quit',function () 
			love.event.quit() 
		end
		),
	}
	ss['title'].buttonIndex =  1
	ss['title'].currentButton =  ss['title'].buttons[1]
	ss['title'].currentButton.active = true

	self.currentScreen = ss['title']

end
