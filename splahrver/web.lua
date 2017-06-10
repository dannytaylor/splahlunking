-- web.lua
xavante = require "xavante"
xavante.filehandler = require "xavante.filehandler"
hredir = require "xavante.redirecthandler"
http	= require 'socket.http'
require 'dreamlo_secret'

port = ...
lobbies = {}
ltimeout = 60*2
lobbystring = ''

dt = 0.1
servertime = 0

function updatelobbystring()
	lobbystring = ''
	for i=1,#lobbies do
		lobbystring = lobbystring .. lobbies[i].name .. '|' .. lobbies[i].ip ..'|'..lobbies[i].num..'\n'
	end
end

function removelobby(q)
	local sec,lname,lip = nil
	if q then sec,lip,dbg = string.match(q,'secret=(.*)&ip=(%d+.%d+.%d+.%d+)&*(%a*)') end
	if dbg == 'debug' then lip = 'localhost' end
	local lnum = #lobbies
	if sec == dreamlo_secret and lnum>0 then 
		for i=lnum,1,-1 do
			if lobbies[i].ip == lip then 
				print('lobby \'' .. lobbies[i].name .. '\'@'.. lobbies[i].ip ..' closed')
				table.remove(lobbies,i)
				updatelobbystring()
				return true
			end
		end 
	end
	return false
end

function addlobby(q)
	local sec,lname,lip = nil
	if q then sec,lname,lip,lnum,dbg = string.match(q,'secret=(.*)&name=(%w+)&ip=(%d+.%d+.%d+.%d+)&num=(%d+)&*(%a*)') end
	if sec == dreamlo_secret and lname and tonumber(lnum)<4 then 
		local ifip = true
		if dbg == 'debug' then lip = 'localhost' end
		if #lobbies>0 then
			for i = 1, #lobbies do
				if lip == lobbies[i].ip then
					lobbies[i].name = lname
					lobbies[i].num = lnum
					lobbies[i].time = 0
					ifip = false
				end
			end
		end
		if ifip then
			lobbies[#lobbies+1] = {
				ip = lip,
				name = lname,
				num = lnum,
				time = 0,
			}
			print ('lobby \''..lname .. '\'@' ..  lip .. ' added, id#' .. #lobbies .. ' with ' .. lnum .. 'ppl') 
			updatelobbystring()
		else
			print(lname .. ' re added with ' .. lnum .. 'ppl')
			updatelobbystring()
		end
		return true
	elseif tonumber(lnum) == 4 then
		local q2 = 'secret='.. sec .. '&ip='.. lip .. '&' .. dbg
		removelobby(q2)
	end
	return false
end

xavante.HTTP {
	server = { host = "*", port = tonumber(port) },
	defaultHost = {
	rules = {
		{
			match = "/$",
			with = hredir,
			params = {"index.html"}
		}, 
		{
			match = "/l$",
			with = function(req, res)
			res.headers["Content-type"] = "text/plain"
			local q = req.parsed_url.query
			if q == dreamlo_secret then res.content = lobbystring
			else res.content = 'forbidden' end
			
			return res
			end
		}, 
		{
			match = "/a$",
			with = function(req, res)
			res.headers["Content-type"] = "text/plain"
			local q = req.parsed_url.query
			if addlobby(q) then res.content = 'lobby added'
			else res.content = 'lobby not added' end
			return res
			end
		}, 
		{
			match = "/r$",
			with = function(req, res)
			res.headers["Content-type"] = "text/plain"
			local q = req.parsed_url.query
			if removelobby(q) then res.content = 'lobby removed'
			else res.content = 'lobby not removed' end
			return res
			end
		}, 
		{
			match = "/c$",
			with = function(req, res)
			res.headers["Content-type"] = "text/html"
			lobbies = {}
			lobbystring = ''
			res.content = 'lobbylist cleared'
			print('lobbies cleared')
			return res
			end
		}, 
		{
			match = ".",
			with = xavante.filehandler,
			params = { baseDir = "static/" }
		}
    }
  }
}

xavante.start(function()
		servertime = servertime + dt
		if servertime > 60*5 then
			http.request('http://splahrver.herokuapp.com/')
			servertime = 0
		end
		local lnum = #lobbies
		if lnum>0 then 
			for i=lnum,1,-1 do
				lobbies[i].time = lobbies[i].time + dt
				if lobbies[i].time > ltimeout then 
					print('lobby \'' .. lobbies[i].name .. '\' timed out')
					table.remove(lobbies,i)
				end
			end 
		end
		if lnum ~= #lobbies then
			updatelobbystring()
		end
end,
dt)
