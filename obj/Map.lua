-- Map.lua

Map = class('Map')

cellIter              = 4
caveGen               = 0.524
floodThresh           = 0.37
waterLevel            = 10
startMaxTreasure      = 120
startMaxLargeTreasure = 16
startMaxBreaths       = 24
startMaxPU            = 50

maxAttempts           = 50000

function Map:initialize(data)
	if data then
		self.w, self.h      = data.w,data.h
		self.state          = data.s
		self.caveState      = {}
		self.tileState      = data.ts
		self.treasure       = {}
		self.breaths        = {}
		self.powerups       = {}
		self.treasurePoints = data.t
		self.breathPoints   = data.b
		self.powerPoints    = data.p
	else
		maxTreasure         = startMaxTreasure*(1+(numConnected-1)/8)
		maxLargeTreasure    = startMaxLargeTreasure*(1+(numConnected-1)/8)
		maxBreaths          = startMaxBreaths*(1+(numConnected-1)/8)
		maxPU               = math.max(startMaxPU,numConnected+1)
		self.w, self.h      = 0,0
		self.attempts       = 0
		self.state          = {}
		self.caveState      = {}
		self.tileState      = {}
		self.treasure       = {}
		self.treasurePoints = {}
		self.breaths        = {}
		self.breathPoints   = {}
		self.powerups       = {}
		self.powerPoints    = {}

	 	-- build random map
		self:init()
		self:buildCave()
		self:drill()

		-- assign hitboxes

		self:getTreasures()
		self:getBreaths()
		self:getPU()
	end

	self:bumpBuild()
	self:spawnTreasures()
	self:spawnBreaths()
	self:spawnPU()




	self:setQuads()
	self:setCanvas()
	-- self.lscale = 2
	-- self:setDecorations()

	love.graphics.setCanvas(pcirc)
	love.graphics.clear(0,0,0,0) 
	love.graphics.setColor(49, 162, 242, 255)
	love.graphics.circle('fill', viewW/2+6, viewH/2+2, viewH/2.62)
	love.graphics.setColor(255, 255, 255,255)
	love.graphics.setBlendMode("alpha")
	love.graphics.setCanvas()

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

	if mapsel ~=3 then 
		love.graphics.draw(pcirc, players[pid].x-68,players[pid].y-40,0,1,1)
	end

	if mapsel == 1 then love.graphics.setColor(0, 0, 0)
	elseif mapsel ==2 then love.graphics.setColor(27, 38, 50)
	elseif mapsel == 3 then love.graphics.setColor(47, 72, 78) end
	love.graphics.rectangle('fill', -64, 0, 64,self.h*tileSize+40)
	love.graphics.rectangle('fill', self.w*tileSize, 0, 64, self.h*tileSize+40)
	love.graphics.rectangle('fill', 0, self.h*tileSize, self.w*tileSize, 40)
	love.graphics.setColor(255,255,255)

	love.graphics.draw(self.tileCanvas, 0, 0, 0, 1, 1)


	for i=1,#self.treasure do
		self.treasure[i]:draw()
	end
	for i,b in ipairs(self.breaths) do
		b:draw()
	end
	for i,p in ipairs(self.powerups) do
		p:draw()
	end

	love.graphics.setColor(255, 255, 255)

	if mapsel ~=3 
		-- and players[pid].gamestate == 'wet' 
		and cpy > waterLevel*tileSize+28
		-- and players[pid].alive 
		and not players[pid].surface 
		and players[pid].deadtimer < deadtime then
			if mapsel == 1  then 
				love.graphics.setColor(0,0,0)
			else
				love.graphics.setColor(27, 38, 50)
			end
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
	for i,p in ipairs(self.powerups) do
		p:update(dt)
	end

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

	-- self:drawEE()

	love.graphics.setCanvas()
	self.tileCanvas:setFilter("nearest", "nearest")
end

function Map:setColor(x,y)
	local ss = self.state[x][y]
	if ss== 'floor' or ss== 'treasure' or ss== 'breath' or ss== 'PU' then
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
	-- for i = 10,self.w/2-10 do
	-- 	for j = math.floor(self.h/2), math.floor(self.h/2)+1 do
	-- 		self.caveState[i][j] = 0
	-- 	end
	-- end


	for i=1, cellIter do
		self:cellAuto()
		currentIter = currentIter + 1
	end

	self:floodFill()
	local caveArea = caveW*caveH
	local floodPercent = numFlood/caveArea
	if floodPercent < floodThresh then
		self.attempts = self.attempts + 1
		if self.attempts > 40000 then 
			self.attempts = 0
			caveGen = caveGen + 0.05
			floodThresh = floodThresh - 0.05
			self:initialize()
		end
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
	local attempts = 0
	while self.caveState[testx][testy] ~= 0 and attempts < maxAttempts do
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
	if self.state[x][y+1] == 'wall' and y<self.h-2 then
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
	local attempts1 = 0
	while not p1good and attempts1 < maxAttempts do
		x1,y1 = math.random(3,self.w-2), math.random(waterLevel+1,self.h-2)
		if self.state[x1][y1] == 'floor' and  self.state[x1][y1+1] == 'wall' then
			p1good = true
		end
		attempts1 = attempts1 + 1
	end
	if attempts1 >= maxAttempts then return x1,math.random(self.h,self.h*4),1 end
	if weighted then
		local attempts2 = 0
		while not p2good and attempts2 < maxAttempts do
			x2,y2 = math.random(3,self.w-2), math.random(waterLevel+1,self.h-2)
			if self.state[x2][y2] == 'floor' and  self.state[x2][y2+1] == 'wall' then
				p2good = true
			end
			attempts2 = attempts2 + 1
		end
		if attempts2 >= maxAttempts then return x1,math.random(self.h,self.h*4),1 end

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

	local attempts = 0
	while not p1good and attempts < maxAttempts do
		x1,y1 = math.random(3,self.w-2), math.random(math.floor(self.h/3),self.h-2)
		p1good = true
		-- if  self.state[x1][y1] == 'floor' and  
		-- 	self.state[x1][y1+1] == 'wall' and  
		-- 	self.state[x1+1][y1+1] == 'wall' and  
		-- 	self.state[x1+1][y1] == 'floor' and
		-- 	self.state[x1][y1-1] == 'floor' and  
		-- 	self.state[x1+1][y1-1] == 'floor'  then
		-- 	p1good = true
		-- end
		for i = 0,1 do
			for j = 0,1 do
				if self.state[x1+i][y1-i] ~= 'floor' then p1good = false end
			end
		end
		for i = 0,1 do
			if self.state[x1+i][y1+1] ~= 'wall' then p1good = false end
		end
		attempts = attempts + 1
	end
	if attempts >= maxAttempts then return x1,math.random(self.h,self.h*4),12 end
	for i = 0,1 do
		for j = 0,1 do
			self.state[x1+i][y1-j] = 'treasure'
		end
	end
	return x1,y1,14
end

function Map:getXLFloorPoint()
	local x1,y1 = 2,2
	local p1good = false

	local attempts = 0
	while not p1good and attempts<maxAttempts do
		x1,y1 = math.random(3,self.w-4), math.random(math.floor(self.h*3/4),self.h-2)
		p1good = true
		for i=0,3 do
			if self.state[x1+i][y1+1] ~= 'wall' then p1good = false end
		end
		for i=0,3 do
			for j=0,3 do
				if self.state[x1+i][y1-j] ~= 'floor' then p1good = false end
			end
		end
		attempt = attempts + 1
	end
	if attempts >= maxAttempts then return x1,math.random(self.h,self.h*4),32 end
	for i=0,3 do
		for j=0,3 do
			self.state[x1+i][y1-j] = 'treasure'
		end
	end
	return x1,y1-2,32
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
		p 	= self.powerPoints,
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

function Map:getEmptyPoint(upper1,upper2) -- empty point no wall neighbors
	local x1,y1 = 3,3
	local p1good = false
	local upper1 = upper1 or waterLevel+10
	local upper2 = upper2 or math.floor(self.h/2)
	local attempts = 0
	while not p1good and attempts < maxAttempts do
		local ytop = math.random(upper1,upper2)
		x1,y1 = math.random(3,self.w-3), math.random(ytop,self.h-3)
		p1good = true
		for i = x1-1, x1+2 do
			for j = y1-1, y1+2 do
				if self.state[i][j] ~= 'floor' then
					p1good = false
				end
			end
		end
		attempts = attempts + 1
	end
	if attempts >= maxAttempts then return x1,math.random(self.h,self.h*4) end
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

function Map:getPU()
	local pup = self.powerPoints
	for i=1,maxPU do
		local a,b = self:getEmptyPoint()
		self.state[a][b] = 'PU'
		local type = lume.randomchoice({'dolphin','walrus','squid'})
		pup[#pup+1] = {x=a,y=b,t=type}
	end
	self.powerPoints = pup
end

function Map:spawnPU()
	local pup = self.powerPoints
	for i=1,#pup do
		self.powerups[#self.powerups+1] = Powerup(pup[i].x,pup[i].y,pup[i].t,i)
	end
end

-- easteregg decos
	-- function Map:drawEE()
	-- 	local x1,y1 = self:getEEPoint()
	-- 	local ee = lume.randomchoice({eeq[1],eeq[2]})
	-- 	love.graphics.draw(tiles[1],ee,(x1-1)*tileSize,y1*tileSize)
	-- end
	-- function Map:getEEPoint()
	-- 	local x1,y1 = 3,self.h-3
	-- 	local p1good = false

	-- 	local attempts = 0
	-- 	while not p1good and attempts<500 do
	-- 		x1,y1 = math.random(3,self.w-5), math.random(self.h*4/5,self.h-3)
	-- 		p1good = true
	-- 		for i = x1, x1+3 do
	-- 			if self.state[i][y1+1] ~= 'wall' then
	-- 				p1good = false
	-- 			end
	-- 			if self.state[i][y1] ~= 'floor' then
	-- 				p1good = false
	-- 			end
	-- 		end
	-- 		attempts = attempts + 1
	-- 	end
	-- 	return x1,y1
	-- end

-- map overlay drawing
	function mapoverlay_init()
		local framerate = 0.2
		if mapsel == 1 then framerate = 0.4 end
		moAni  = sodapop.newAnimatedSprite(64*tileSize,12*tileSize)
			moAni:addAnimation('default', {
				image       = moAni_sheets[mapsel],
				frameWidth  = 64,
				frameHeight = 64,
				frames      = {
					{1, 1, 4, 1, framerate},
				},
			})
	end
	function mapoverlay_update(dt)
		--update animations
		if mapsel == 3 then moAni:update(dt) end
	end
	function mapoverlay_draw()

		-- animations here
		if mapsel == 3 then moAni:draw() end
	end
