-- mmhelper.lua
if debug then 
	mmServer = 'http://localhost:5000/'
	mmdebug = 'debug'
else 
	mmServer = 'http://splahrver.herokuapp.com/'
	mmdebug = ''
end
externalip = ''
connectmsg = '' 
http.TIMEOUT = 8

-- to wake mm server
request = wapi.request({
	method = "GET",
	url = "mmServer"
	})


function mmGetList()
    connectmsg = 'FETCHING LOBBIES...' 
	return http.request(mmServer .. 'l?'..dreamlo_secret)
end

function mmAddLobby(name)
	lobby = true
	lobbytimer = 0
    connectmsg = 'STARTING LOBBY...' 
	return http.request(mmServer .. 'a?secret='..dreamlo_secret..'&name='..name.. '&ip='..externalip .. '&num=' .. numConnected .. '&' .. mmdebug)
end

function mmRemoveLobby()
	http.TIMEOUT = 0.5
	lobby = false
	lobbytimer = 0
	http.request(mmServer .. 'r?secret='..dreamlo_secret..'&ip='..externalip .. '&' .. mmdebug)
	http.TIMEOUT = 10
end


function lobbyUpdate(dt)
	if lobby then
		lobbytimer = lobbytimer + dt
		if lobbytimer > 60 then
			mmAddLobby(hostBox.text)
			lobbytimer = 0
		end
	end
end

lobby = false
lobbytimer = 0

hostBox = {
	x = 18,
	y = 30,
	bg = love.graphics.newImage 'img/hostbox.png',
	tx = 24,
	ty = 45,
	text = '',
	active = false,
}

lobbyBox = {
	x = 19,
	y = 12,
	bg = love.graphics.newImage 'img/lobbybox.png',
	index = 1,
	top = 1,
	tx = 27,
	ty = 26,
	text = '',
	active = false,
	ipbutton = false,
}

ipBox = {
	x = 6,
	y = 26,
	bg = love.graphics.newImage 'img/ipbox.png',
	tx = 12,
	ty = 35,
	text = '',
	active = false,
}


lobbyList = {}

