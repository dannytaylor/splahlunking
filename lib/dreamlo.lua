local http = require("socket.http")

local strDreamloURL = "http://dreamlo.com/lb/"
local strSecretCode, strPublicCode = ""

local function getDataTypeName(i)
	local TypeNames = {"xml", "json", "pipe", "quote"}
	return TypeNames[i]
end
local function getSortTypeName(i)
	local SortTypes = {"seconds", "seconds-asc", "date", "date-asc"}
	return SortTypes[i]
end
local Dreamlo = {}

Dreamlo.DataTypes = { XML=1, JSON=2, PIPE=3, QUOTE=4 }
Dreamlo.SortTypes = { SECONDS=1, SECONDS_ASC=2, DATE=3, DATE_ASC=4 }

Dreamlo.setSecretCode = function(str)
	strSecretCode = str
end

Dreamlo.setPublicCode = function(str)
	strPublicCode = str
end

Dreamlo.clear = function()
	return http.request(strDreamloURL .. strSecretCode .. "/clear")
end

Dreamlo.add = function(Player, Score, Time, Comment)
	if Player == nil or Score == nil then return end

	local url = strDreamloURL .. strSecretCode .. "/add/" .. Player .. "/" .. Score

	if Time ~= nil then
		url = url .. "/" .. Time

		if Comment ~= nil then
			url = url .. "/" .. Comment
		end
	end

	return http.request(url)
end

Dreamlo.delete = function(Player)
	return http.request(strDreamloURL .. strSecretCode .. "/delete/" .. Player)
end

function Dreamlo:get(data_type, sort_type)
	if data_type == self.DataTypes.XML   or
	   data_type == self.DataTypes.JSON  or
   	   data_type == self.DataTypes.PIPE  or
	   data_type == self.DataTypes.QUOTE then

	   local url = strDreamloURL .. strPublicCode .. "/" .. getDataTypeName(data_type)

		if sort_type == self.SortTypes.SECONDS or
		   sort_type == self.SortTypes.SECONDS_ASC or
		   sort_type == self.SortTypes.DATE or
		   sort_type == self.SortTypes.DATE_ASC then
			url = url .. "-" .. getSortTypeName(sort_type)
		end

		return http.request(url)
	end
	return "Invalid data-type"
end

function Dreamlo:getFromTo(First, Amount, DataType, SortType)
	if First == nil or Amount == nil then return end

	if DataType == self.DataTypes.XML   or
	   DataType == self.DataTypes.JSON  or
   	   DataType == self.DataTypes.PIPE  or
	   DataType == self.DataTypes.QUOTE then

		local url = strDreamloURL .. strPublicCode .. "/" .. getDataTypeName(DataType)

		if SortType == self.SortTypes.SECONDS or
		   SortType == self.SortTypes.SECONDS_ASC or
		   SortType == self.SortTypes.DATE or
		   SortType == self.SortTypes.DATE_ASC then
			url = url .. "-" .. getSortTypeName(SortType)
		end

		return http.request(url .. "/" .. First .. "/" .. Amount)
	end
	return "Invalid data-type"
end

function Dreamlo:getPlayer(Player)
	if Player == nil then return end
	return http.request(strDreamloURL .. strPublicCode .. "/pipe-get/" .. Player)
end

return Dreamlo
