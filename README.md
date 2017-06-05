# [splahlunking](https://xhg.itch.io/splahlunking)
### (splash-spelunking)

forewarning: this code is an uncommented mess of spaghetti jam-code.

game made with löve in ~1 week (jam version ~3 days) for #divejam

map is randomly generated with higher value treasures weighted lower on the map. player stats are speed, lung capacity, strength (how treasure weight effects speed), and equipment quality (how quickly it breaks). haven't had much chance to test multiplayer, so notes on balancing are appreciated.

no spaces or colons/ports in the ip address. game uses UDP, port 22122 for forwarding. testing was mostly done on localhost, so there may be some unknown bugs that I couldn't catch.

there are some color consistency issues and readability issues I know, poor initial planning. I think fixing this up would be more trouble than it's worth at this point.


- **wasd**/**arrow keys**: move
- **x**/**return**: taunt/select
- **esc**: back/quit
- **m**: mute music
- **f1-f4**: change window scale
- **r**: return to character select on end

___

todo:
- mostly I'd just like to add some better tunes, but I'll have to practice making music more
- maybe new tilesets/characters if I need an art project to keep me busy
- some sfx additions and changes

___

other tools used:
- aseprite (art)
- [arne's 16 colour palette](https://androidarts.com/palette/16pal.htm)
- bfxr.net (sfx)
- beepbox.co (tunes)

löve libs used:
- [middleclass](https://github.com/kikito/middleclass)
- [gamera](https://github.com/kikito/gamera)
- [bump](https://github.com/kikito/bump.lua)
- [lume](https://github.com/rxi/lume/)
- [sodapop](https://github.com/tesselode/sodapop)
- [sock](https://github.com/camchenry/sock.lua)
- [bitser](https://github.com/gvx/bitser)
___

special thanks to devin for the feedback and playtesting with me
