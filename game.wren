import "xs" for Data, Input, Render     // These are the parts of the xs we will be using
import "xs_math"for Math, Bits, Vec2, Color
import "xs_assert" for Assert
import "xs_ec"for Entity, Component
import "xs_components" for Transform, Body, Renderable, Sprite, GridSprite, AnimatedSprite
import "random" for Random              // Random is a part of the Wren library
import "sparse_grid" for SpraseGrid
import "types" for Type

class Directions {
    static [i] {
        if(i == 0) {
            return Vec2.new(0, 1)   // Up
        } else if(i == 1) {
            return Vec2.new(1, 0)   // Right
        } else if(i == 2) {
            return Vec2.new(0, -1)   // Down
        } else if(i == 3) {
            return Vec2.new(-1, 0)   // Left
        }
    }
}

class Walker {
    construct new(position, direction) {
        _position = position
        _direction = direction
    }

    direction { _direction }
    direction=(d) { _direction = d }
    position { _position }
    position=(p) { _position = p }
}


class State {
    static generating   { 0 }
    static playerTurn   { 1 }
    static computerTurn { 2 }
    static idle         { 3 }
}

class Game {
    static config() {
        // Using a file instead
    }


    static init() {
        Entity.init()

        __tileSize = Data.getNumber("Tile Size", Data.game)
        __width = Data.getNumber("Level Width", Data.game)
        __height = Data.getNumber("Level Height", Data.game)

        __level = 0                
        __random = Random.new()
        __state = State.generating
        __time = 0

        __grid = SpraseGrid.new(Type.empty)
        __entities = SpraseGrid.new(null)

        __shortBrake = Data.getNumber("Short Brake")
        __longBrake = Data.getNumber("Long Brake")

        var tilesImage = Render.loadImage("[game]/assets/tiles_dungeon.png")
        var heroImage = Render.loadImage("[game]/assets/chara_hero.png")
        var slimeImage = Render.loadImage("[game]/assets/chara_slime.png")

        __emptySprite = Render.createGridSprite(tilesImage, 20, 24, 3, 0)

        __wallSprites = [
            Render.createGridSprite(tilesImage, 20, 24, 0, 20),     // 0000
            Render.createGridSprite(tilesImage, 20, 24, 0, 23),     // 0001
            Render.createGridSprite(tilesImage, 20, 24, 1, 20),     // 0010
            Render.createGridSprite(tilesImage, 20, 24, 1, 22),     // 0011
            Render.createGridSprite(tilesImage, 20, 24, 0, 21),     // 0100
            Render.createGridSprite(tilesImage, 20, 24, 0, 22),     // 0101
            Render.createGridSprite(tilesImage, 20, 24, 1, 21),     // 0110
            Render.createGridSprite(tilesImage, 20, 24, 3, 23),     // 0111
            Render.createGridSprite(tilesImage, 20, 24, 3, 20),     // 1000
            Render.createGridSprite(tilesImage, 20, 24, 2, 22),     // 1001    
            Render.createGridSprite(tilesImage, 20, 24, 2, 20),     // 1010
            Render.createGridSprite(tilesImage, 20, 24, 3, 22),     // 1011
            Render.createGridSprite(tilesImage, 20, 24, 2, 21),     // 1100
            Render.createGridSprite(tilesImage, 20, 24, 1, 23),     // 1101
            Render.createGridSprite(tilesImage, 20, 24, 2, 23),     // 1110    
            Render.createGridSprite(tilesImage, 20, 24, 3, 21)      // 1111    

        ]

        __floorSprites = [
            Render.createGridSprite(tilesImage, 20, 24, 0, 0),
            Render.createGridSprite(tilesImage, 20, 24, 1, 0),
            Render.createGridSprite(tilesImage, 20, 24, 2, 0),
            Render.createGridSprite(tilesImage, 20, 24, 0, 1),
            Render.createGridSprite(tilesImage, 20, 24, 1, 1),
            Render.createGridSprite(tilesImage, 20, 24, 2, 1),
            Render.createGridSprite(tilesImage, 20, 24, 0, 2),
            Render.createGridSprite(tilesImage, 20, 24, 1, 2),
            Render.createGridSprite(tilesImage, 20, 24, 2, 2)
        ]

        __playerSprite = Render.createGridSprite(heroImage, 4, 11, 0, 0)
        __enemySprite = Render.createGridSprite(slimeImage, 4, 11, 0, 0)

        __genFiber =  Fiber.new { generate() }
    }   
    
    static update(dt) {
        Entity.update(dt)

        __time = __time - dt
        if(__time <= 0.0) {
            while(!__genFiber.isDone) {
                __time = __genFiber.call()
            }
        }

        /*
        if(__state == State.playerTurn) {
            movePlayer()
        } else if(__state == State.computerTurn) {
            moveEnemies()
        }
        */
    }

    static render() {      
        var s = __tileSize  
        var sx = (__width - 1) * -s / 2
        var sy = (__height-1)  * -s / 2

        for (x in 0...__width) {
            for (y in 0...__height) {
                var v = __grid[x, y]
                var px = sx + x * s
                var py = sy + y * s
                var sprite = null      
                var color = null
                if(v == Type.empty) {
                    Render.renderSprite(__emptySprite, px, py, 1.0, 0.0, 0xFFFFFFFF, 0x0, Render.spriteCenter)
                } else if(v == Type.wall) {
                    var pos = Vec2.new(x, y)  
                    var flag = 0
                    for(i in 0...4) {
                        var n = pos + Directions[i]
                        if(__grid.isValidPosition(n.x, n.y) && __grid[n.x, n.y] == Type.wall) {
                            flag = flag | 1 << i  // |
                        }
                    }
                    Render.renderSprite(__wallSprites[flag], px, py, 1.0, 0.0, 0xFFFFFFFF, 0x0, Render.spriteCenter)                    
                } else {
                    var i = (x + y) % __floorSprites.count
                    Render.renderSprite(__floorSprites[i], px, py, 1.0, 0.0, 0xFFFFFFFF, 0x0, Render.spriteCenter)
                }
            }
        }

        Renderable.render() 
    }

    static generate() {
        __level = 5

        for (x in 0...__width) {
            for (y in 0...__height) {
                __grid[x, y] = Type.floor
                Fiber.yield(__shortBrake)
            }
        }

        for (x in 0...__width) {
            __grid[x, 0] = Type.wall
            __grid[x, __height-1] = Type.wall
            Fiber.yield(__shortBrake)
        }

        for (y in 0...__height) {
            __grid[0, y] = Type.wall
            __grid[__width-1, y] = Type.wall
            Fiber.yield(__shortBrake)
        }

         for(i in 0...3) {
            var x = __random.int(1, 5)
            var y = __random.int(1, 5)
            __grid[x + 5, y + 5] = Type.wall
            Fiber.yield(__longBrake)
            __grid[x + 5, 5 - y] = Type.wall
            Fiber.yield(__longBrake)            
            __grid[5 - x, y + 5] = Type.wall
            Fiber.yield(__longBrake)
            __grid[5 - x, 5 - y] = Type.wall
            Fiber.yield(__longBrake)
        }

        Game.createPlayer()


        //__grid[5, 5] = Type.player
        Fiber.yield(__longBrake)

        for(i in 0...__level) {
            var found = false
            while(!found) {
                var x = __random.int(0, 11)
                var y = __random.int(0, 11)
                if(__grid.isValidPosition(x, y) && __grid[x, y] == Type.floor) {
                    createSlime(x, y)
                    //__grid[x, y] = Type.enemy
                    found = true
                    Fiber.yield(__longBrake)
                }
            }
        }

        __state = State.playerTurn
        return 0.0
    }

    static moveTile(x, y, dx, dy) {
        if(__grid.isValidPosition(x + dx, y + dy)) {
            var v = __grid[x + dx, y + dy]
            if(v != Type.wall) {
                var val = __grid[x, y]
                __grid[x, y] = Type.floor
                __grid[x + dx, y + dy] = val
                __state = State.playerTurn
                System.print("Tile moved state: %(__state)")
                return true
            }
        }
        return false
    }

    static movePlayer() {
        var players = findAll(Type.player)
        if(players.count > 0) {
            var p = players[0]
            if(Input.getButtonOnce(Input.gamepadDPadRight) || Input.getKeyOnce(Input.keyRight)) {
                moveTile(p.x, p.y, 1, 0)
            } else if(Input.getButtonOnce(Input.gamepadDPadLeft) || Input.getKeyOnce(Input.keyLeft)) {
                moveTile(p.x, p.y, -1, 0)
            } else if(Input.getButtonOnce(Input.gamepadDPadDown) || Input.getKeyOnce(Input.keyDown)) {
                moveTile(p.x, p.y, 0, -1)
            } else if(Input.getButtonOnce(Input.gamepadDPadUp) || Input.getKeyOnce(Input.keyUp)) {
                moveTile(p.x, p.y, 0, 1)
            }

            var pn = findAll(Type.player)[0]
            if(pn != p) {
                __state = State.computerTurn
            }
        } else {
            __level = 0
            initLevel()
            return
        }
    }

    static manhattanize(dir) {
        if(dir.x.abs > dir.y.abs) {
            return Vec2.new(dir.x.sign, 0)
        } else {
            return Vec2.new(0, dir.y.sign)
        }
    }

    static moveEnemies() {
        var enemies = findAll(Type.enemy)
        if(enemies.count == 0) {
            initLevel()
            return
        }

        var p = findAll(Type.player)[0]
        for (e in enemies) {
            var d = p - e
            d = manhattanize(d)
            moveTile(e.x, e.y, d.x, d.y)            
        }
        __state = State.playerTurn
    }

    static findAll(type) {
        var all = []
        for (x in 0...__width) {
            for (y in 0...__height) {
                if(__grid[x, y] == type) {
                    all.add(Vec2.new(x, y))
                }
            }
        }
        return all
    }

    static createPlayer() {
        var player = Entity.new()
        var t = Transform.new(Vec2.new(0, 0))
        var s = AnimatedSprite.new("[game]/assets/chara_hero.png", 4, 11, 15)
        s.addAnimation("idle", [0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,1])
        s.addAnimation("selected", [4,4,4,4,4,4,4,4,5,6,6,6,6,6,6,6,5])
        s.addAnimation("walk down", [8,8,8,9,9,9,10,10,10,11,11,11])
        s.addAnimation("walk side", [12,12,12,13,13,13,14,14,14,15,15,15])
        s.addAnimation("walk up", [16,16,16,17,17,17,18,18,18,19,19,19])
        s.playAnimation("walk up")        
        s.flags = Render.spriteCenter
        var h = Hero.new()
        player.addComponent(t)
        player.addComponent(s)
        player.addComponent(h)
        player.name = "Player"
    }

    static createSlime(x, y) {
        var sz = 16
        var sx = (__width - 1) * -sz / 2
        var sy = (__height-1)  * -sz / 2
        var px = sx + x * sz
        var py = sy + y * sz
        var slime = Entity.new()
        var t = Transform.new(Vec2.new(px, py))
        var s = AnimatedSprite.new("[game]/assets/chara_slime.png", 4, 11, 12)
        s.addAnimation("idle", [0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2])
        s.playAnimation("idle")
        s.flags = Render.spriteCenter
        slime.addComponent(t)
        slime.addComponent(s)
        slime.name = "Slime"        
    }
 }

 import "gameplay" for Hero, TileMove
