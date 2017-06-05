-- menu.lua

Menu = class('Menu')

menuscale = 1

function Menu:initialize()
	self.screens = {}
	self.currentScreen = nil

	self.canvas = love.graphics.newCanvas(viewW*tileSize*menuscale, viewH*tileSize*menuscale,"normal",0)
	self.canvas:setFilter("nearest", "nearest")

	titlebgSprite = sodapop.newAnimatedSprite(viewW/2, 40)
	titlebgSprite:addAnimation('bg', {
		image        = love.graphics.newImage 'img/titlebgSheet.png',
		frameWidth   = 128,
		frameHeight  = 80,
		frames       = {
		  {1, 1, 16, 1, .2},
		},
	})
	self:init() 
end
	
function Menu:init()
	self:initScreens()
end

function Menu:draw()
	love.graphics.setCanvas(self.canvas)
	love.graphics.clear()

	self.currentScreen:draw()
	if self.currentScreen == self.screens['title'] then 
		titlebgSprite:draw()
		-- if client then
		-- 	love.graphics.print('BAD HOST', 50, 8)
		-- end
	end

	if self.currentScreen == self.screens['multi'] then 
		if connectmsg then love.graphics.print(connectmsg, 32, 4) end
		-- love.graphics.print("ESC TO CANCEL", 40, 10)
	end

	if self.currentScreen == self.screens['leaderboard'] then 
		if #leaderboard == 0 then 
			love.graphics.print("CONNECTION",34,31)
			love.graphics.print("FAILED",34,39)
		else
			for i = 1, math.min(#leaderboard,5) do
				love.graphics.print(leaderboard[i].score,17,31+(i-1)*8)
				love.graphics.print(leaderboard[i].name,34,31+(i-1)*8)
				love.graphics.print(leaderboard[i].char,87,31+(i-1)*8)
			end
		end
	end

	love.graphics.setCanvas()
	love.graphics.draw(self.canvas, 0, 0, 0, windowScale/menuscale, windowScale/menuscale)
end

function Menu:update(dt)
	if self.currentScreen == self.screens['title'] then 
		titlebgSprite:update(dt)
	end
	self.currentScreen:update(dt)
end

function Menu:initScreens()
	self.screens = {
		['title'] = Screen(),
		['multi'] = Screen(),
		['join'] = Screen(),
		['char'] = Screen(),
		['leaderboard'] = Screen(),
	}

	-- screen setups
	self:ss_title()
	self:ss_multi()
	self:ss_char()
	self:ss_leaderboard()


	self.currentScreen = self.screens['title']

end

-- screensetup
function Menu:ss_title()
	local ss = self.screens

	ss['title'].bgImg = titlebg
	ss['title'].buttons = {
		Button('single', 16,48,btq.b1,btq.b1a,function ()
			pid = 1
			numConnected = 1
			self.currentScreen = self.screens['char']

		end
		),
		Button('multi',48,48,btq.b2,btq.b2a,function () 
			self.currentScreen = self.screens['multi']
			connectswitch = false
		end
		),
		Button('quit',80,48,btq.b3,btq.b3a,function () 
			quote = Dreamlo:get(Dreamlo.DataTypes.PIPE)
			leaderboard = {}
			if quote then for line in quote:gmatch("([^\r\n]*)[\r\n]") do
				local i = #leaderboard + 1
				local nm,sc,ch = string.match(line, '(%w+)|(%d+)|%d+|(%w+)') --|%d+/%d+/%d+ %d+:%d+:%d+ %w+|%d+')
				print(nm,sc,ch)
				ch = string.sub(string.upper(ch),1,8)
				leaderboard[i] = {name=nm,score=sc,char=ch}
			end end

			self.currentScreen = self.screens['leaderboard']
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
		Button('host', 24,24,btq.m1,btq.m1a,function ()
			initServer()
			initMap()
			print(pid)
			self.currentScreen = self.screens['char']
		end
		),
		Button('join',72,24, btq.m2,btq.m2a,function ()
			initClient()
			if client and not connectswitch then
				client:connect()
				connectswitch = true
				connectmsg = "TRYING CONNECTION..."
			end
		end),
	}
	ss['multi'].buttonIndex =  1
	ss['multi'].currentButton =  ss['multi'].buttons[1]
	ss['multi'].currentButton.active = true
end

function Menu:ss_char()
	local ss = self.screens
	ss['char'].isChar= true

	ss['char'].bgImg = titlebg3
	ss['char'].buttons = {
		Button('char',62,20, btq.c1,btq.c1a,function ()
			
		end
		),
		Button('map',64,54, btq.map,btq.mapa,function ()
			
		end
		),
		Button('start',94,61,btq.c2,btq.c2a,function ()
			
			if server then 
				numConnected = server:getClientCount() + 1
				server:sendToAll('start', {
					state = 1,
					num = numConnected,
					msel = mapsel
				})
				gamestate = 1
				startMatch()
			elseif not client then
				gamestate = 1
				numConnected = 1
				initMap()
			end
		end
		),
	}
	ss['char'].buttonIndex =  1
	ss['char'].currentButton =  ss['char'].buttons[1]
	ss['char'].currentButton.active = true
end

function Menu:ss_leaderboard()
	local ss = self.screens

	ss['leaderboard'].bgImg = leaderboardbg
end