-- menu.lua

Menu = class('Menu')

menuscale = 2

function Menu:initialize()
	self.screens = {}
	self.currentScreen = nil

	self.canvas = love.graphics.newCanvas(viewW*tileSize*menuscale, viewH*tileSize*menuscale,"normal",0)
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
	love.graphics.draw(self.canvas, 0, 0, 0, windowScale/menuscale, windowScale/menuscale)
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

	-- screen setups
	self:ss_title()
	self:ss_multi()
	self:ss_char()


	self.currentScreen = self.screens['title']

end

-- screensetup
function Menu:ss_title()
	local ss = self.screens

	ss['title'].bgImg = titlebg
	ss['title'].buttons = {
		Button(2*tileSize,viewH-16,'single', function ()
			-- initServer()
			gamestate = 1
			initMap()
		end
		),
		Button(6.5*tileSize,viewH-16,'multi',function () 
			self.currentScreen = self.screens['multi']
		end
		),
		Button(11*tileSize,viewH-16,'quit',function () 
			love.event.quit() 
		end
		),
	}
	ss['title'].buttonIndex =  1
	ss['title'].currentButton =  ss['title'].buttons[1]
	ss['title'].currentButton.active = true
end

function Menu:ss_multi()
	local ss = self.screens

	ss['multi'].bgImg = titlebg2
	ss['multi'].buttons = {
		Button(4*tileSize,viewH-16,'host', function ()
			initServer()
			initMap()
			self.currentScreen = self.screens['char']
		end
		),
		Button(10*tileSize,viewH-16,'join', function ()
			initClient()
			client:connect()
			self.currentScreen = self.screens['char']
		end),
	}
	ss['multi'].buttonIndex =  1
	ss['multi'].currentButton =  ss['multi'].buttons[1]
	ss['multi'].currentButton.active = true
end

function Menu:ss_char()
	local ss = self.screens

	ss['char'].bgImg = titlebg
	ss['char'].buttons = {
		Button(4*tileSize,viewH-16,'char', function ()
			
		end
		),
		Button(10*tileSize,viewH-16,'start', function ()
			
			if server then 
				numConnected = server:getClientCount() + 1
				server:sendToAll('start', {
					state = 1,
					num = numConnected
				})
				gamestate = 1
				startMatch()
			end
		end
		),
	}
	ss['char'].buttonIndex =  1
	ss['char'].currentButton =  ss['char'].buttons[1]
	ss['char'].currentButton.active = true
end