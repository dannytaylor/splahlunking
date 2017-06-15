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
		love.graphics.setColor(157,157,157)
		love.graphics.print(connectmsg, 32, 4)
		love.graphics.setColor(255,255,255)
		if connectmsg == "TRYING CONNECTION" then
			spinner:draw()
		end
		if hostBox.active then
			love.graphics.draw(hostBox.bg, hostBox.x, hostBox.y)
			love.graphics.print(hostBox.text, hostBox.tx, hostBox.ty)
		elseif lobbyBox.active then
			love.graphics.draw(lobbyBox.bg, lobbyBox.x, lobbyBox.y)
			if #lobbyList>0 then
				local sy = 0
				for i = lobbyBox.top, math.min(lobbyBox.top+3,#lobbyList) do
					if i == lobbyBox.index then love.graphics.setColor(224, 111, 139)
					else love.graphics.setColor(255,255,255) end
					love.graphics.print(lobbyList[i].name,		lobbyBox.tx,			lobbyBox.ty+8*sy)
					love.graphics.print(lobbyList[i].num..'/4',	lobbyBox.tx+58,			lobbyBox.ty+8*sy)
					sy = sy+1
				end
				love.graphics.setColor(255,255,255)
			else
				love.graphics.print('NO LOBBIES FOUND-',	lobbyBox.tx,lobbyBox.ty)
				love.graphics.print('TRY AGAIN OR',	lobbyBox.tx,lobbyBox.ty+12)
				love.graphics.print('CONNECT VIA IP',	lobbyBox.tx,lobbyBox.ty+20)
				if #lobbyList==0 then 
					love.graphics.setColor(157, 157, 157)
					love.graphics.rectangle('fill', lobbyBox.x+36+26,  lobbyBox.y+49, 25, 8)
					love.graphics.setColor(255,255,255)
				end
			end
			if lobbyBox.ipbutton and not ipBox.active then
				love.graphics.rectangle('line', lobbyBox.x+36,  lobbyBox.y+50, 24, 7)
			elseif not ipBox.active then
				love.graphics.rectangle('line', lobbyBox.x+36+27,  lobbyBox.y+50, 24, 7)
			end
			if ipBox.active then
				love.graphics.draw(ipBox.bg, ipBox.x, ipBox.y)
				love.graphics.print(ipBox.text, ipBox.tx, ipBox.ty)
			end

		end
	end

	if self.currentScreen == self.screens['leaderboard'] then 
		if #leaderboard == 0 then 
			love.graphics.print("CONNECTION FAILED",11,31)
		else
			local lbi = 1
			for i = lbtop, math.min(lbtop+4,#leaderboard) do
				if i == lbindex then love.graphics.setColor(224, 111, 139)
				elseif i == 1 then  love.graphics.setColor(247, 226, 107)
				else love.graphics.setColor(255,255,255) end
				love.graphics.print(leaderboard[i].score,11,31+(lbi-1)*8)
				love.graphics.print(leaderboard[i].name,38,31+(lbi-1)*8)
				love.graphics.print(leaderboard[i].char,92,31+(lbi-1)*8)
				lbi = lbi + 1
			end
			love.graphics.setColor(255,255,255)

			-- love.graphics.setColor(224, 111, 139)
			-- for i = 1, math.min(#leaderboard,5) do
			-- 	love.graphics.print(leaderboard[i].score,11,31+(i-1)*8)
			-- 	love.graphics.print(leaderboard[i].name,38,31+(i-1)*8)
			-- 	love.graphics.print(leaderboard[i].char,92,31+(i-1)*8)
			-- 	love.graphics.setColor(255,255,255)
			-- end
		end
	end

	love.graphics.setCanvas()
	love.graphics.draw(self.canvas, 0, 0, 0, windowScale/menuscale, windowScale/menuscale)
end

function Menu:update(dt)
	if self.currentScreen == self.screens['title'] then 
		titlebgSprite:update(dt)
	end
	spinner:update(dt)
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
		Button('quit',80,48,btq.b3,btq.b3a,function () --actually now leaderboard button
			self.currentScreen = self.screens['leaderboard']
			quote = Dreamlo:get(Dreamlo.DataTypes.PIPE)
			leaderboard = {}
			lbindex = 1
			lbtop = 1
			if quote then for line in quote:gmatch("([^\r\n]*)[\r\n]") do
				local i = #leaderboard + 1
				-- local nm,sc,ch = string.match(line, '(@*%w*)|(%d+)|%d+|(%w+)')
				local nm,sc,ch = string.match(line, '(@*%w*)|(%d+)|%d+|(%w* *%w*)') 
				-- print(nm,sc,ch)
				ch = string.sub(string.upper(ch),1,7)
				leaderboard[i] = {name=nm,score=sc,char=ch}
			end end

			
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
			connectmsg = '' 
			hostBox.text = ''
			hostBox.active  = true
		end
		),
		Button('join',72,24, btq.m2,btq.m2a,function ()
			connectCounter = 0
			connectswitch = false
			connectmsg = '' 
			lobbyList = {}
			if mmawake then
				local ll = mmGetList()
				connectmsg = '' 
				if ll and string.match(ll,'(%w+)|(%w*.*%d*.*%d*.*%d*)|(%d+)')then 
					for line in ll:gmatch("([^\r\n]*)[\r\n]") do
						local i = #lobbyList + 1
						local name,ip,num = string.match(line, '(%w+)|(%w*.*%d*.*%d*.*%d*)|(%d+)')
						lobbyList[i] = {name=name,ip=ip,num=num}
					end 
				end
			else
				connectmsg = '' 
			end
			lobbyBox.active = true
			if #lobbyList == 0 then
				lobbyBox.ipbutton = true
			else
				lobbyBox.ipbutton = false
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
				if hostBox.text ~= '' then  mmRemoveLobby() end
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