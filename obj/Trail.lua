-- Trail.lua

Trail = class('Trail')

function Trail:initialize()
	self.decaytimer = 0
	self.spawntimer = 0
	self.blips = {}
end

function Trail:update(dt,spawn,x,y)
	local spawn = spawn or false
	local x = x or 0
	local y = y or 0
	if spawn then self.spawntimer = self.spawntimer + dt end

	self.decaytimer = self.decaytimer + dt

	for i,b in ipairs(self.blips) do
		b.time = b.time + dt
		if b.time  > 4 then b = nil end
	end

	if (math.floor(self.spawntimer))%2 == 0 then
		self.spawntimer = self.spawntimer + 1
		self.blips[#self.blips+1] = {x=x,y=y,time=0}
	end
end

function Trail:draw()
	love.graphics.setColor(178, 220, 239)
	for i,b in ipairs(self.blips) do
		if b.time < 1 then
			love.graphics.rectangle('line', b.x-2, b.y-2, 4, 4)
		elseif b.time < 2 then 
			love.graphics.rectangle('line', b.x-1, b.y-1, 3, 3)
		elseif b.time < 3 then
			love.graphics.rectangle('line', b.x, b.y, 1,1)
		end
	end
	love.graphics.setColor(255, 255, 255)

end