-- Button.lua

Button = class('Button')

function Button:initialize(name,x,y,i1,i2,a)
	self.name = name
	self.x,self.y = x,y
	self.active = false

	self.img = i1
	self.imgActive = i2

	self.w = 32
	self.h = 32

	self.action = a or function()
		do end
	end
end

function Button:draw()
	
	if self.active then 
		-- love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
		if self.name == 'char' then
			love.graphics.draw(titlebuttons,self.imgActive,10+(pid-1)*29,45)
		elseif self.name == 'map' then
			love.graphics.draw(titlebuttons,self.imgActive,64,54+(mapsel-1)*8)
		else
			love.graphics.draw(titlebuttons,self.imgActive,self.x,self.y)
		end
	else
		if self.name == 'char' then
			love.graphics.draw(titlebuttons,self.img,10+(pid-1)*29,45)
		elseif self.name == 'map' then
		else
			love.graphics.draw(titlebuttons,self.img,self.x,self.y)
		end
	end
	
end

function Button:update(dt)
end 