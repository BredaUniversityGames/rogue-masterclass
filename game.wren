import "xs" for Data, Input, Render     // These are the parts of the xs we will be using
import "xs_math" for Vec2
import "xs_assert" for Assert
import "random" for Random              // Random is a part of the Wren library
import "grid" for Grid

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

class State {
    static playerTurn   { 1 }
    static computerTurn { 2 }
    static idle         { 3 }
}

class Game {
    static empty    { 0 }
    static floor    { 1 } 
    static wall     { 2 }
    static player   { 3 }
    static enemy    { 4 }

    // static bomb   { 5 }

    static config() {
        Data.setString("Title", "Rogue Like", Data.system)
        Data.setNumber("Width", 640, Data.system)
        Data.setNumber("Height", 360, Data.system)
        Data.setNumber("Multiplier", 4, Data.system)
    }

    static init() {
        var gs = 11 // Grid size
        __level = 0                
        __random = Random.new()
        __state = State.playerTurn
        __time = 0
        __grid = Grid.new(gs, gs, Game.player)
        initLevel()

        var tilesImage = Render.loadImage("[game]/assets/tiles_dungeon.png")
        var heroImage = Render.loadImage("[game]/assets/chara_hero.png")
        var slimeImage = Render.loadImage("[game]/assets/chara_slime.png")

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
        //__floorSprite = Render.createGridSprite(tilesImage, 20, 24, 20, 1)
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
    }   
    
    static update(dt) {
        if(__state == State.playerTurn) {
            movePlayer()
        } else if(__state == State.computerTurn) {
            moveEnemies()
        } else if(__state == State.playerIdle) {
            waitSomeTime(dt)
        }
    }

    static render() {
        var s = 16
        var sx = (__grid.width - 1) * -s / 2
        var sy = (__grid.height-1)  * -s / 2

        for (x in 0...__grid.width) {
            for (y in 0...__grid.height) {
                var v = __grid[x, y]
                var px = sx + x * s
                var py = sy + y * s
                var sprite = null      
                var color = null
                if(v == Game.wall) {
                    var pos = Vec2.new(x, y)  
                    var flag = 0
                    for(i in 0...4) {
                        var n = pos + Directions[i]
                        if(__grid.isValidPosition(n.x, n.y) && __grid[n.x, n.y] == Game.wall) {
                            flag = flag | 1 << i  // |
                        }
                    }
                    Render.renderSprite(__wallSprites[flag], px, py, 1.0, 0.0, 0xFFFFFFFF, 0x0, Render.spriteCenter)                    
                } else {
                    var i = (x + y) % __floorSprites.count
                    Render.renderSprite(__floorSprites[i], px, py, 1.0, 0.0, 0xFFFFFFFF, 0x0, Render.spriteCenter)
                }

                if(v == Game.player) {
                    Render.renderSprite(__playerSprite, px, py, 1.0, 0.0, 0xFFFFFFFF, 0x0, Render.spriteCenter)                                        
                } else if(v == Game.enemy) {
                    Render.renderSprite(__enemySprite, px, py, 1.0, 0.0, 0xFFFFFFFF, 0x0, Render.spriteCenter)
                }
            }
        }
    }

    static initLevel() {
        __level = __level + 1

        for (x in 0...__grid.width) {
            for (y in 0...__grid.height) {
                __grid[x, y] = Game.floor
            }
        }

        for(i in 0...3) {
            var x = __random.int(1, 5)
            var y = __random.int(1, 5)
            __grid[x + 5, y + 5] = Game.wall
            __grid[x + 5, 5 - y] = Game.wall
            __grid[5 - x, y + 5] = Game.wall
            __grid[5 - x, 5 - y] = Game.wall
        }

        for (x in 0...__grid.width) {
            __grid[x, 0] = Game.wall
            __grid[x, __grid.height-1] = Game.wall
        }

        for (y in 0...__grid.height) {
            __grid[0, y] = Game.wall
            __grid[__grid.width-1, y] = Game.wall
        }

        __grid[5, 5] = Game.player

        for(i in 0...__level) {
            var found = false
            while(!found) {
                var x = __random.int(0, 11)
                var y = __random.int(0, 11)
                if(__grid.isValidPosition(x, y) && __grid[x, y] == Game.floor) {
                    __grid[x, y] = Game.enemy
                    found = true
                }
            }
        }

        __state = State.playerTurn
    }

    static moveTile(x, y, dx, dy) {
        if(__grid.isValidPosition(x + dx, y + dy)) {
            var v = __grid[x + dx, y + dy]
            if(v != Game.wall) {
                var val = __grid[x, y]
                __grid[x, y] = Game.floor
                __grid[x + dx, y + dy] = val
                __state = State.playerTurn
                System.print("Tile moved state: %(__state)")
                __grid.print()
                return true
            }
        }
        return false
    }

    static movePlayer() {
        var players = findAll(Game.player)
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

            var pn = findAll(Game.player)[0]
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
        var enemies = findAll(Game.enemy)
        if(enemies.count == 0) {
            initLevel()
            return
        }

        var p = findAll(Game.player)[0]
        for (e in enemies) {
            var d = p - e
            d = manhattanize(d)
            moveTile(e.x, e.y, d.x, d.y)            
        }
        __state = State.playerTurn
    }

    static findAll(type) {
        var all = []
        for (x in 0...__grid.width) {
            for (y in 0...__grid.height) {
                if(__grid[x, y] == type) {
                    all.add(Vec2.new(x, y))
                }
            }
        }
        return all
    }
 }
