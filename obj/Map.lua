-- Map.lua

Map = class('Map')

cellIter = 12
caveGen = 0.52
floodThresh = 0.40
waterLevel = 10
maxTreasure = 90
maxLargeTreasure = 12
maxBreaths = 20

function Map:initialize(data)
	if data then
		self.w, self.h = data.w,data.h
		self.state = data.s
		self.caveState = {}
		self.tileState = data.ts
		self.treasure = {}
		self.breaths = {}
		self.treasurePoints = data.t
		self.breathPoints = data.b
	else
		maxTreasure = 80*(1+(numConnected)/3)
		maxLargeTreasure = 12*(1+(numConnected)/3)
		maxBreaths = 24*(1+numConnected/3)
		self.w, self.h = 0,0
		self.attempts = 0 
		self.state = {}
		self.caveState = {}
		self.tileState = {}
		self.treasure = {}
		self.treasurePoints = {}
		self.breaths = {}
		self.breathPoints = {}

	 	-- build random map
		self:init()
		self:buildCave()
		self:drill()

		-- assign hitboxes

		self:getTreasures()
		self:getBreaths()
	end

	self:bumpBuild()
	self:spawnTreasures()
	self:spawnBreaths()

	self.playerlight  = sodapop.newAnimatedSprite()
	self.playerlight:setAnchor(function ()
		return players[pid].x+4,players[pid].y+4
	end)
	self.playerlight:addAnimation('default', {
		image       = playerLightSheet,
		frameWidth  = 80,
		frameHeight = 80,
		frames      = {
			{3, 1, 3, 1, 2},
		},
	})
	



	self:setQuads()
	self:setCanvas()
	-- self.lscale = 2
	-- self:setDecorations()

end

function Map:init()
	local mapImg = love.image.newImageData('img/map_base.png')
	self.w, self.h = mapImg:getWidth(), mapImg:getHeight()


	-- init state grid to empty
	for i=1, self.w do -- initialize map as empty first
		self.state[i] = {}
		self.tileState[i] = {}
		for j=1, self.h do
			self.tileState[i][j] = 0
			if (255 == mapImg:getPixel( i - 1, j - 1 )) then
				self.state[i][j] = 'floor'
			elseif (0 == mapImg:getPixel( i - 1, j - 1 )) then
				self.state[i][j] = 'wall'
			elseif (128 == mapImg:getPixel( i - 1, j - 1 )) then
				self.state[i][j] = 'empty'
			else
				self.state[i][j] = 'empty'
			end
		end
	end

	-- get our entrance holes
	holeX = {}
	for i = 1, self.w do
		if (255 == mapImg:getPixel( i - 1, waterLevel-1)) then
			holeX[#holeX+1] = i
		end
	end



end

function Map:draw()
	local cpy = players[pid].y -- current player y
	if mapsel == 3 then
		love.graphics.setColor(0,0,0)
	else
		love.graphics.setColor(0, 87, 132)
	end
	love.graphics.rectangle('fill', 0,0, self.w*tileSize, self.h*tileSize)
	love.graphics.setColor(255, 255, 255)

	if mapsel ~=3 then self:playertracker() end

	love.graphics.draw(self.tileCanvas, 0, 0, 0, 1, 1)

	for i=1,#self.treasure do
		self.treasure[i]:draw()
	end
	for i,b in ipairs(self.breaths) do
		b:draw()
	end
	love.graphics.setColor(255, 255, 255)

	if mapsel ~=3 
		-- and players[pid].gamestate == 'wet' 
		and cpy > waterLevel*tileSize+28
		and players[pid].palette ~=5 
		-- and players[pid].alive 
		and not players[pid].surface 
		and players[pid].deadtimer < deadtime then
			if mapsel == 1  then 
				love.graphics.setColor(0,0,0)
			else
				love.graphics.setColor(27, 38, 50)
			end
			-- local ls = self.lscale
			love.graphics.draw(lightMask, players[pid].x-124, cpy-76, 0, 1,1 )
			love.graphics.setColor(255,255,255)
	end
end

function Map:update(dt)
	-- if self.lscale > 1 and players[pid].tWater < 3 then self.lscale = 2 - players[pid].tWater/3
	-- else self.lscale = 1 
	-- end

	for i,t in ipairs(self.treasure) do
		t:update(dt)
	end
	for i,b in ipairs(self.breaths) do
		b:update(dt)
	end

	self.playerlight:update(dt)
end

function Map:setCanvas()
	self.tileCanvas = love.graphics.newCanvas(self.w*tileSize, self.h*tileSize,"normal",0)
	love.graphics.setCanvas(self.tileCanvas)

	for i=1, self.w do
		for j=1, self.h do
			if self.tileState[i][j] == 0 then
				self:setColor(i,j)
				love.graphics.rectangle('fill', (i-1)*tileSize, (j-1)*tileSize, tileSize, tileSize)
				love.graphics.setColor(255, 255, 255)
			else 
				love.graphics.draw(tiles[mapsel],self.tileState[i][j],(i-1)*tileSize, (j-1)*tileSize)
			end
		end
	end
	love.graphics.draw(camp[mapsel], 48*tileSize, 0)
	love.graphics.setCanvas()
	self.tileCanvas:setFilter("nearest", "nearest")
end

function Map:setColor(x,y)
	if self.state[x][y] == 'floor' or self.state[x][y] == 'treasure' or self.state[x][y] == 'breath' then
		if mapsel == 3 then love.graphics.setColor(0,0,0)
		else
			if y < waterLevel then -- above water line
				love.graphics.setColor(178, 220, 239)
			else
				love.graphics.setColor(0, 87, 132,0)
			end
		end
	elseif self.state[x][y] == 'wall' then
		if mapsel ==3 then love.graphics.setColor(47, 72, 78)
		elseif mapsel == 2 then love.graphics.setColor(27, 38, 50)
		else love.graphics.setColor(0, 0, 0) end

	elseif self.state[x][y] == 'empty' then
		love.graphics.setColor(128, 128, 128)
	else
		love.graphics.setColor(255, 255, 255)
	end
end

function Map:playertracker()
	love.graphics.setColor(49, 162, 242)
	-- love.graphics.circle('fill', players[pid].x, players[pid].y, viewH/2)
	self.playerlight:draw()
	love.graphics.setColor(255, 255, 255)
end


-- http://www.roguebasin.com/index.php?title=Cellular_Automata_Method_for_Generating_Random_Cave-Like_Levels
function Map:buildCave()
	caveW, caveH = self.w, self.h - 12


	currentIter = 1

	self.caveState = {}
	for i=1, self.w do 
		self.caveState[i] = {}
		for j=1, self.h do
			self.caveState[i][j] = lume.weightedchoice({ [0] = caveGen, [1] = 1-caveGen })
			-- 1 = wall, 0 = floor
		end
	end


	for i=1, cellIter do
		self:cellAuto()
		currentIter = currentIter + 1
	end

	self:floodFill()
	local caveArea = caveW*caveH
	local floodPercent = numFlood/caveArea
	if floodPercent < floodThresh then
		self.attempts = self.attempts + 1
		if self.attempts > 10000 then love.event.quit() end
		self:buildCave()
		return false
	end -- redo if not enough filled

	self:fillUnconnected()

	for i=1, caveW do --
		for j=1, caveH do
			if self.caveState[i][j] == 1 then
				self.state[i][j + 12] = 'wall'
			elseif self.caveState[i][j] == 0 then
				self.state[i][j + 12] = 'floor'
			else
				self.state[i][j + 12] = 'floor'
			end
		end
	end


end


function Map:cellAuto()
	local caveStateIter = {}
	for i = 1, caveW do
		caveStateIter[i] = {}
		for j = 1, caveH do
			if i == 1 or j == 1 or i == 2 or j == 2 or i == caveW or j == caveH or i == caveW - 1 or j == caveH - 1 then
				caveStateIter[i][j] = 1
			else
				if self:checkNeighbors(i,j) then
					caveStateIter[i][j] = 1
				else
					caveStateIter[i][j] = 0
				end
			end
		end
	end
	for i = 1, caveW do
		for j = 1, caveH do
			self.caveState[i][j] = caveStateIter[i][j]
		end
	end
end

function Map:checkNeighbors(x,y)
	local num = 0
	for i = x - 1, x + 1 do
		for j = y - 1, y + 1 do
			if self.caveState[i][j] == 1 then
				num = num + 1
			end
		end
	end
	if num > 4 then
		return true
	end
	if currentIter < math.ceil(cellIter/2) then
		num = 0
		for i = x - 2, x + 2 do
			for j = y - 2, y + 2 do
				if self.caveState[i][j] == 1 then
					num = num + 1
				end
			end
		end
		if num < 1 then
			return true
		end
	end

	return false
end



function Map:floodFill()
	numFlood = 0
	local testx, testy = math.floor(lume.random(3 , caveW - 2)), math.floor(lume.random(3 , caveH- 2))
	while self.caveState[testx][testy] ~= 0 do
		testx, testy = math.floor(lume.random(3 , caveW - 2)), math.floor(lume.random(3 , caveH- 2))
	end
	self:floodRec(testx,testy)
end

function Map:floodRec(x,y)
	self.caveState[x][y] = 2
	numFlood = numFlood + 1
	if self.caveState[x][y - 1] == 0 then self:floodRec(x,y - 1) end
	if self.caveState[x + 1][y] == 0 then self:floodRec(x + 1,y) end
	if self.caveState[x][y + 1] == 0 then self:floodRec(x,y + 1) end
	if self.caveState[x - 1][y] == 0 then self:floodRec(x - 1,y) end
end

function Map:fillUnconnected()
	for i = 1, caveW do
		for j = 1, caveH do
			if self.caveState[i][j] == 0 then
				self.caveState[i][j] = 1
			end
		end
	end
end

function Map:drill()
	for i = 1, #holeX do
		self:drillHole(holeX[i],waterLevel+2)
	end
end


function Map:drillHole(x,y)
	self.state[x][y] = 'floor'
	if self.state[x][y+1] == 'wall' then
		self:drillHole(x,y+1)
	end
end

function Map:bumpBuild()
	world = bump.newWorld(64)
	for i = 1, self.w do
		for j = 1, self.h do
			if self.state[i][j] == 'wall' then
				world:add('wall'..i..'x'..j, (i - 1)*tileSize, (j - 1)*tileSize, tileSize,tileSize)
			end
		end
	end
end

function Map:setQuads()

	-- border tiles
	for i = 1, self.w do
		for j = 1, self.h do
			if self.state[i][j] == 'wall' then
				self:assignBorders(i,j)
			else
				self.tileState[i][j] = 0
			end
		end
	end

	-- corner connectors
	for i = 1, self.w do
		for j = 1, self.h do
			if self.state[i][j] == 'wall' and self.tileState[i][j] == 0 then
				self:assignCorners(i,j)
			end
		end
	end

	-- fill in bg
	for i = 1, self.w-1 do
		for j = waterLevel, self.h-1 do
			if self.state[i][j] == 'floor' then
				self.tileState[i][j] = lume.weightedchoice({
					[tq.w1] = 2,
					[tq.w2] = 1,
					[tq.w3] = 2,
					[tq.w4] = 1,
					[tq.blank] = 194,
					})
			end
		end
	end

	-- add decorations
	for i = 1, self.w-1 do
		for j = waterLevel, self.h-1 do
			if self.state[i][j] == 'floor' and self.state[i][j+1] == 'wall' then
				self.tileState[i][j] = lume.weightedchoice({
					[tq.d00] = 2, [tq.d01] = 2, [tq.d02] = 2, [tq.d03] = 2, [tq.d04] = 2,
					[tq.d10] = 1, [tq.d11] = 1, [tq.d12] = 1, [tq.d13] = 1, [tq.d14] = 1,
					[tq.d00] = 1, [tq.d21] = 1, [tq.d22] = 1, [tq.d23] = 1, [tq.d24] = 1,
					[tq.d00] = 1, [tq.d31] = 1, [tq.d32] = 1, [tq.d33] = 1, [tq.d34] = 1,
					-- 16 decorations, 20 odds
					[tq.blank] = 10,
					})
			end
		end
	end
end

function Map:assignBorders(x,y) -- no diagonals
	local num = 0
	local dir = {0,0,0,0}
	if x == 1 or y == 1 or x == self.w or y == self.h then 
		self.tileState[x][y] =0 
		return
	end
	if self.state[x][y-1] == 'wall' then 
		num = num + 1 
		dir[1] = 1
	end
	if self.state[x+1][y] == 'wall' then 
		num = num + 1 
		dir[2] = 1
	end
	if self.state[x][y+1] == 'wall' then 
		num = num + 1 
		dir[3] = 1
	end
	if self.state[x-1][y] == 'wall' then 
		num = num + 1 
		dir[4] = 1
	end

	if 	num == 0 then self.tileState[x][y] = tq.o
	elseif 	num == 3 then 
		if y < waterLevel then
			if dir[2]     == 1 and dir[3] == 1 and dir[4] == 1  then self.tileState[x][y] = lume.randomchoice({tq.gi0,tq.gi0b})
			elseif dir[3] == 1 and dir[4] == 1 and dir[1] == 1 then self.tileState[x][y] = lume.randomchoice({tq.gi90,tq.gi90b})
			else self.tileState[x][y] = lume.randomchoice({tq.gi270,tq.gi270b})
			end
		else
			if dir[2]     == 1 and dir[3] == 1 and dir[4] == 1 then self.tileState[x][y] = lume.randomchoice({tq.i0,tq.i0b})
			elseif dir[3] == 1 and dir[4] == 1 and dir[1] == 1 then self.tileState[x][y] = lume.randomchoice({tq.i90,tq.i90b})
			elseif dir[4] == 1 and dir[1] == 1 and dir[2] == 1 then self.tileState[x][y] = lume.randomchoice({tq.i180,tq.i180b})
			elseif dir[1] == 1 and dir[2] == 1 and dir[3] == 1 then self.tileState[x][y] = lume.randomchoice({tq.i270,tq.i270b})
			end
		end
	elseif 	num == 2 then
		if y < waterLevel then
			if dir[3]     == 1 and dir[4] == 1 then self.tileState[x][y] = lume.randomchoice({tq.gt0,tq.gt0b})
			else self.tileState[x][y] = lume.randomchoice({tq.gt180,tq.gt180b})
			end
		else 
			if dir[3]     == 1 and dir[4] == 1 then self.tileState[x][y] = lume.randomchoice({tq.l0,tq.l0b})
			elseif dir[4] == 1 and dir[1] == 1 then self.tileState[x][y] = lume.randomchoice({tq.l90,tq.l90b})
			elseif dir[1] == 1 and dir[2] == 1 then self.tileState[x][y] = lume.randomchoice({tq.l180,tq.l180b})
			elseif dir[2] == 1 and dir[3] == 1 then self.tileState[x][y] = lume.randomchoice({tq.l270,tq.l270b})
			elseif dir[1] == 1 and dir[3] == 1 then self.tileState[x][y] = lume.randomchoice({tq.l0p,tq.l0pb})
			else self.tileState[x][y] = lume.randomchoice({tq.l90p,tq.l90pb})
			end
		end
	elseif 	num == 1 then 
		if dir[3]     == 1 then self.tileState[x][y] = lume.randomchoice({tq.t0,tq.t0b})
		elseif dir[4] == 1 then self.tileState[x][y] = lume.randomchoice({tq.t90,tq.t90b})
		elseif dir[1] == 1 then self.tileState[x][y] = lume.randomchoice({tq.t180,tq.t180b})
		elseif dir[2] == 1 then self.tileState[x][y] = lume.randomchoice({tq.t270,tq.t270b})
		end
	else 	self.tileState[x][y] = 0
	end
end

function Map:assignCorners(x,y)
	if x == 1 or y == 1 or x == self.w or y == self.h then self.tileState[x][y] = 0
	elseif	self.state[x+1][y-1] ~= 'wall' then self.tileState[x][y] = lume.randomchoice({tq.c0 ,tq.c0b})
	elseif 	self.state[x+1][y+1] ~= 'wall' then self.tileState[x][y] = lume.randomchoice({tq.c90 ,tq.c90b})
	elseif 	self.state[x-1][y+1] ~= 'wall' then self.tileState[x][y] = lume.randomchoice({tq.c180 ,tq.c180b})
	elseif 	self.state[x-1][y-1] ~= 'wall' then self.tileState[x][y] = lume.randomchoice({tq.c270,tq.c270b})
	else self.tileState[x][y] = 0
	end
end

function Map:getTreasures()
	local tp = self.treasurePoints
	for i=1,maxTreasure do
		local a,b,c = self:getFloorPoint(true)
		self.state[a][b] = 'treasure'
		tp[#tp+1] = {x=a,y=b,v=c,s=1}
	end
	for i=1,maxLargeTreasure do
		local a,b,c = self:getLargeFloorPoint()
		self.state[a][b-1] = 'treasure'
		self.state[a+1][b-1] = 'treasure'
		self.state[a][b-2] = 'treasure'
		self.state[a+1][b-1] = 'treasure'
		tp[#tp+1] = {x=a,y=b-1,v=c,s=2}
	end
	local a,b,c = self:getXLFloorPoint()
	tp[#tp+1] = {x=a,y=b-1,v=c,s=4}
end

function Map:spawnTreasures()
	local tp = self.treasurePoints
	for i=1,#tp do
		self.treasure[#self.treasure+1] = Treasure(tp[i].x,tp[i].y,tp[i].v,tp[i].s)
	end
end

function Map:getFloorPoint(weighted)
	local x1,y1,x2,y2 = 2,2,2,2
	local p1good,p2good = false,false

	while not p1good do
		x1,y1 = math.random(3,self.w-2), math.random(waterLevel+1,self.h-2)
		if self.state[x1][y1] == 'floor' and  self.state[x1][y1+1] == 'wall' then
			p1good = true
		end
	end
	if weighted then
		while not p2good do
			x2,y2 = math.random(3,self.w-2), math.random(waterLevel+1,self.h-2)
			if self.state[x2][y2] == 'floor' and  self.state[x2][y2+1] == 'wall' then
				p2good = true
			end
		end

		local d1,d2 = lume.distance(x1,y1,self.w/2,0), lume.distance(x2,y2,self.w/2,0)
		local p = lume.weightedchoice({[{x1,y1}] = d1, [{x2,y2}] = d2})
		local value = math.ceil(2*math.random()*lume.distance(p[1],p[2],self.w/2,0)/20)
		return p[1],p[2],value
	else
		local value = math.ceil(2*math.random()*lume.distance(x1,y1,self.w/2,0)/20)
		return x1,y1,value
	end
end

function Map:getLargeFloorPoint()
	local x1,y1 = 2,2
	local p1good = false

	while not p1good do
		x1,y1 = math.random(3,self.w-2), math.random(math.floor(self.h/3),self.h-2)
		if  self.state[x1][y1] == 'floor' and  
			self.state[x1][y1+1] == 'wall' and  
			self.state[x1+1][y1+1] == 'wall' and  
			self.state[x1+1][y1] == 'floor' and
			self.state[x1][y1-1] == 'floor' and  
			self.state[x1+1][y1-1] == 'floor'  then
			p1good = true
		end
	end
	return x1,y1,14
end

function Map:getXLFloorPoint()
	local x1,y1 = 2,2
	local p1good = false

	while not p1good do
		x1,y1 = math.random(3,self.w-4), math.random(math.floor(self.h*3/4),self.h-2)
		p1good = true
		for i=1,4 do
			if self.state[x1+i-1][y1+1] == 'floor' then p1good = false end
		end
		for i=1,4 do
			for j=1,4 do
				if self.state[x1+i-1][y1-j+1] == 'wall' then p1good = false end
			end
		end

	end
	for i=0,4 do
		for j=0,4 do
			self.state[x1+i][y1-j] = 'treasure'
		end
	end
	return x1,y1,24
end

function Map:packageData()
	local ts = {} -- tilestate

	for i=1,self.w do
		ts[i] = {}
		for j=1,self.h do
			ts[i][j] = 0
		end
	end

	local mapdata = {
		w 	= self.w,
		h 	= self.h,
		s 	= self.state,
		t 	= self.treasurePoints,
		b 	= self.breathPoints,
		ts 	= ts
	}
	return mapdata
end


function Map:getBreaths()
	local bp = self.breathPoints
	for i=1,maxBreaths do
		local a,b = self:getEmptyPoint()
		self.state[a][b] = 'breath'
		bp[#bp+1] = {x=a,y=b}
	end
end

function Map:getEmptyPoint() -- empty point no wall neighbors
	local x1,y1 = 3,3
	local p1good = false

	while not p1good do
		local ytop = math.random(waterLevel+10,math.floor(self.h/2))
		x1,y1 = math.random(3,self.w-3), math.random(ytop,self.h-3)
		p1good = true
		for i = x1-1, x1+2 do
			for j = y1-1, y1+2 do
				if self.state[i][j] ~= 'floor' then
					p1good = false
				end
			end
		end
	end
	for i = x1-1, x1+2 do
		for j = y1-1, y1+2 do
			self.state[i][j] = 'breath'
		end
	end
	return x1,y1
end

function Map:spawnBreaths()
	local bp = self.breathPoints
	for i=1,#bp do
		self.breaths[#self.breaths+1] = Breath(bp[i].x,bp[i].y,i)
	end
end



