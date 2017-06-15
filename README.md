
![](http://i.imgur.com/iyiFosV.gif)
## [on itch.io](https://xhg.itch.io/splahlunking)
### (splash-spelunking)

forewarning: this code is an uncommented mess of spaghetti jam-code.

game made with löve2d over 2 weeks (jam version in ~3 days) for #divejam. 128x80 pixels, 16 colours.

see [devlog](https://xhg.itch.io/splahlunking/devlog) for specific changelogs. I haven't had much chance to test multiplayer with other people, so notes on balancing and bug reports are appreciated. 

map is randomly generated with higher value treasures weighted lower on the map. breath bubbles are more likely to spawn lower. player stats are speed, lung capacity (breathrate), strength (how treasure weight effects speed), and equipment quality (how quickly it breaks). powerups increase your speed, reduce your breathing rate, or increase your treasure bounties and revert when they run out. all powerups increase your vision (except in space).

the lobby list is using heroku which shouldn't break or go down, but connecting directly by IP should still work if it does go down. host needs to forward UDP on port 22122. full leaderboards viewable on [dreamlo](http://dreamlo.com/lb/593513e8758d1503445e8fbf/pipe). entered names are alphanumeric (first character can be '@'). 

there are some color consistency issues and readability issues I know, poor initial planning. I think fixing this up would be more trouble than it's worth at this point. I've tried making new music, but I'm not very good at music so it probably won't get changed.


- **wasd**/**arrow keys**: move
- **x**/**return**: taunt/select
- **esc**: back/quit
- **r**: return to character select on end
- **m**: mute music
- **f1-f4**: change window scale/fullscreen

___

tools:
- aseprite (art)
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
- [dreamlo.lua](https://github.com/LucyLucyy97/Dreamlo-Lua) (leaderboard helper)
- [wapi](https://github.com/ulydev/wapi) (async http requests)

other:
- [dreamlo](http://dreamlo.com/) (leaderboard)
- [cell automata method](http://www.roguebasin.com/index.php?title=Cellular_Automata_Method_for_Generating_Random_Cave-Like_Levels) (map gen)
- [heroku](https://www.heroku.com/), [xavante](https://keplerproject.github.io/xavante/), and [lua buildpack](https://github.com/leafo/heroku-buildpack-lua) (lobby server)
- [arne's colour palette](https://androidarts.com/palette/16pal.htm)

___

special thanks to devin for the feedback and playtesting with me

___

bugs:
- rare map generation bug freezes the game (sorry, requires force close)
- http requests are not asynchronous so they will freeze the game if you have laggy internet
- crash on trying to start second server instance (you shouldn't be doing this but w/e)

missing features:
- keep track of #victories per player across multiple games
- good music
- ready-up in mp
- msg if port 22122 is closed
<!-- - scroll leaderboard
- text input sound
- trying connection spinner -->



