import "xs" for Data, Input, Render     // These are the parts of the xs we will be using
import "xs_math" for Vec2
import "xs_assert" for Assert
import "random" for Random              // Random is a part of the Wren library
import "grid" for Grid


class Player is Vec2 {
    
}

class State {
    static playerTurn   { 1 }
    static computerTurm { 2 }
    static idle         { 3 }
}


class Game {
    static empty    { 0 }
    static floor    { 1 } 
    static wall     { 2 }
    static player   { 3 }
    static enemy    { 4 }
    static bomb     { 5 }

    static config() {
        Data.setString("Title", "Gridr", Data.system)
        Data.setNumber("Width", 360, Data.system)
        Data.setNumber("Height", 240, Data.system)
        Data.setNumber("Multiplier", 4, Data.system)
    }

    static init() {
        var gs = 11 // Grid size
        __level = 1        
        __grid = Grid.new(gs, gs)
        __enemies = []
        __random = Random.new()
        __state = State.playerTurn
        __time = 0

        initLevel() 
    }   
    
    static update(dt) {
        if(__state == State.playerTurn) {
            movePlayer()
        } else if(__state == State.playerTurn) {
            moveEnemies()
        } else if(__state == State.playerIdle) {
            waitSomeTime(dt)
        }
    }

    static render() {
        var s = 9.0
        var sx = __grid.width * -s
        var sy = __grid.height * -s
        
        var backClr = 0xF4F4F4FF
        Render.setColor(backClr)

        var cEmpty  = 0xD8D8D8FF
        var cWall   = 0xAFAFAFFF
        var cPlayer = 0x7CA4D6FF
        var cEnemy  = 0xDF7EEBFF

        Render.rect(-180, -120, 180, 120)
        for (x in 0...__grid.width) {
            for (y in 0...__grid.height) {
                var v = __grid[x, y]
                var c            
                if(v == Game.player) {
                    c = cPlayer
                } else if(v == Game.enemy) {
                    c = cEnemy
                } else {
                    c = cEmpty
                }
                Render.setColor(c)
                Render.disk(sx + x * s * 2, sy + y * s * 2, s * 0.8, 24)
            }
        }        
    }

    static initLevel() {
        System.print("init")
        initPlayer(5, 5)

        for(i in 0..__level) {
            var found = false
            while(!found) {
                var x = __random.int(0, 11)
                var y = __random.int(0, 11)
                if(__grid.isValidPosition(x, y) && __grid[x, y] == Game.empty) {
                    initEnemy(x, y)
                    found = true
                }
            }
        }
    }

    static initPlayer(x, y) {
        __player = Vec2.new(x, y)
        __grid[x, y] = Game.player
    }

    static movePlayer(dx, dy) {
        var x = __player.x
        var y = __player.y
        var v = __grid[x, y]
        //Assert.equal(v, Game.player)
        if(__grid.isValidPosition(x + dx, y + dy)) {
            __grid[x, y] = Game.empty
            x = x + dx
            y = y + dy        
            __grid[x, y] = Game.player
            __player.x = x
            __player.y = y
            __state = State.playerTurn 
        }
    }

    static movePlayer() {
        if(Input.getButtonOnce(Input.gamepadDPadRight)) {
            movePlayer(1, 0)
        } else if(Input.getButtonOnce(Input.gamepadDPadLeft)) {
            movePlayer(-1, 0)
        } else if(Input.getButtonOnce(Input.gamepadDPadDown)) {
            movePlayer(0, -1)
        } else if(Input.getButtonOnce(Input.gamepadDPadUp)) {
            movePlayer(0, 1)
        }
    }

    static initEnemy(x, y) {
        var enemy = Vec2.new(x, y)
        __enemies.add(enemy)
        __grid[x, y] = Game.enemy
    }

    static moveEnemies() {

    }
 }
