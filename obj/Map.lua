-- Map.lua

Map = Object:extend()



function Map:new()
	self.w, self.h = 0,0
	self.state = {}
	self.caveState = {}
	self.tileState = {}

 	-- build random map
	self:init()
	self:buildCave()
	self:drill()

	-- assign hitboxes and quad images
	self:bumpBuild()
	self:drill()
	self:setQuads()

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
	for i=1, self.w do -- initialize map as empty first
		for j=1, self.h do
			self:setColor(i,j)
			love.graphics.rectangle('fill', (i-1)*tileSize, (j-1)*tileSize, tileSize, tileSize)
			love.graphics.setColor(255, 255, 255)
			if self.tileState[i][j] == 0 then do end
			else love.graphics.draw(tileSheet,self.tileState[i][j],(i-1)*tileSize, (j-1)*tileSize)
			end

			
		end
	end
end

function Map:setColor(x,y)
	if self.state[x][y] == 'floor' then
		if y < waterLevel then -- above water line
			love.graphics.setColor(178, 220, 239)
		else
			love.graphics.setColor(49, 162, 242)
		end
	elseif self.state[x][y] == 'wall' then
		love.graphics.setColor(0, 0, 0)
	elseif self.state[x][y] == 'empty' then
		love.graphics.setColor(128, 128, 128)
	else
		love.graphics.setColor(255, 255, 255)
	end
end

-- http://www.roguebasin.com/index.php?title=Cellular_Automata_Method_for_Generating_Random_Cave-Like_Levels
function Map:buildCave()
	caveW, caveH = self.w, self.h - 12

	cellIter = 12
	caveGen = 0.52
	currentIter = 1

	self.caveState = {}
	for i=1, self.w do -- initialize cave, 0.46
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
	if floodPercent < 0.35 then 
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
		self:drillHole(holeX[i],waterLevel+1)
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
	for i = 1, self.w do
		for j = 1, self.h do
			if self.state[i][j] == 'wall' then
				self:numNeighbors(i,j)
			else
				self.tileState[i][j] = 0
			end
		end
	end
end

function Map:numNeighbors(x,y) -- no diagonals
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
			if dir[2]     == 1 and dir[3] == 1 and dir[4] == 1  then self.tileState[x][y] = tq.gi0
			elseif dir[3] == 1 and dir[4] == 1 and dir[1] == 1 then self.tileState[x][y] = tq.gi90
			else self.tileState[x][y] = tq.gi270
			end
		else
			if dir[2]     == 1 and dir[3] == 1 and dir[4] == 1 then self.tileState[x][y] = tq.i0
			elseif dir[3] == 1 and dir[4] == 1 and dir[1] == 1 then self.tileState[x][y] = tq.i90
			elseif dir[4] == 1 and dir[1] == 1 and dir[2] == 1 then self.tileState[x][y] = tq.i180
			elseif dir[1] == 1 and dir[2] == 1 and dir[3] == 1 then self.tileState[x][y] = tq.i270
			end
		end
	elseif 	num == 2 then
		if y < waterLevel then
			if dir[3]     == 1 and dir[4] == 1 then self.tileState[x][y] = tq.gt0
			else self.tileState[x][y] = tq.gt180
			end
		else 
			if dir[3]     == 1 and dir[4] == 1 then self.tileState[x][y] = tq.l0
			elseif dir[4] == 1 and dir[1] == 1 then self.tileState[x][y] = tq.l90
			elseif dir[1] == 1 and dir[2] == 1 then self.tileState[x][y] = tq.l180
			elseif dir[2] == 1 and dir[3] == 1 then self.tileState[x][y] = tq.l270
			elseif dir[1] == 1 and dir[3] == 1 then self.tileState[x][y] = tq.l0b
			else self.tileState[x][y] = tq.l90b
			end
		end
	elseif 	num == 1 then 
		if dir[3]     == 1 then self.tileState[x][y] = tq.t0
		elseif dir[4] == 1 then self.tileState[x][y] = tq.t90
		elseif dir[1] == 1 then self.tileState[x][y] = tq.t180
		elseif dir[2] == 1 then self.tileState[x][y] = tq.t270
		end
	else 	self.tileState[x][y] = 0
	end
end