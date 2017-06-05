
![](https://github.com/dannytaylor/splahlunking/raw/master/itch/banner.gif)
## [on itch.io](https://xhg.itch.io/splahlunking)
### (splash-spelunking)

forewarning: this code is an uncommented mess of spaghetti jam-code.

game made with löve in ~10 days (jam version ~3 days) for #divejam

map is randomly generated with higher value treasures weighted lower on the map. player stats are speed, lung capacity (breathrate), strength (how treasure weight effects speed), and equipment quality (how quickly it breaks). breath bubbles are more likely to spawn lower. haven't had much chance to test multiplayer, so notes on balancing are appreciated.

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
- maybe new tilesets/characters

___

tools:
- aseprite (art)
- [arne's colour palette](https://androidarts.com/palette/16pal.htm)
- bfxr.net (sfx)
- beepbox.co (tunes)

löve libs used:
- [middleclass](https://github.com/kikito/middleclass) (oop)
- [gamera](https://github.com/kikito/gamera) (camera)
- [bump](https://github.com/kikito/bump.lua) (collisions)
- [lume](https://github.com/rxi/lume/) (random and weighted choices)
- [sodapop](https://github.com/tesselode/sodapop) (sprite animations)
- [sock](https://github.com/camchenry/sock.lua) (networking)
- [bitser](https://github.com/gvx/bitser) (serialization)

[cell automata method](http://www.roguebasin.com/index.php?title=Cellular_Automata_Method_for_Generating_Random_Cave-Like_Levels) for map gen
___

special thanks to devin for the feedback and playtesting with me
