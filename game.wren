import "xs" for Data, Input, Render     // These are the parts of the xs we will be using
import "xs_math"for Math, Bits, Vec2, Color
import "xs_assert" for Assert
import "xs_ec"for Entity, Component
import "xs_components" for Transform, Body, Renderable, Sprite, GridSprite, AnimatedSprite
import "random" for Random              // Random is a part of the Wren library
import "sparse_grid" for SpraseGrid
import "types" for Type
import "directions" for Directions

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

class RoguealotClass {
    construct new() {}

    tileSize { _tileSize }

    width { _width }

    height { _height }

    random { _random }

    calculatePos(tile) {
        return calculatePos(tile.x, tile.y)
    }

    calculatePos(tx, ty) {
        var sx = (_width - 1) * -_tileSize / 2.0
        var sy = (_height - 1)  * -_tileSize / 2.0
        var px = sx + tx * _tileSize
        var py = sy + ty * _tileSize
        return Vec2.new(px, py)        
    }

    calculateTile(pos) {
        var sx = (_width - 1.0) * -_tileSize / 2.0
        var sy = (_height - 1.0)  * -_tileSize / 2.0
        var tx = (pos.x - sx) / _tileSize
        var ty = (pos.y - sy) / _tileSize
        return Vec2.new(tx.round, ty.round)
    }

    config() {
        // Using a file instead
    }

    init() {
        Entity.init()
        Tile.init()

        _tileSize = Data.getNumber("Tile Size", Data.game)
        _width = Data.getNumber("Level Width", Data.game)
        _height = Data.getNumber("Level Height", Data.game)

        _level = 0                
        _random = Random.new()
        _state = State.generating
        _time = 0

        _grid = SpraseGrid.new(Type.empty)
        _entities = SpraseGrid.new(null)

        _shortBrake = Data.getNumber("Short Brake")
        _longBrake = Data.getNumber("Long Brake")

        var tilesImage = Render.loadImage("[game]/assets/tiles_dungeon.png")
        var heroImage = Render.loadImage("[game]/assets/chara_hero.png")
        var slimeImage = Render.loadImage("[game]/assets/chara_slime.png")

        _emptySprite = Render.createGridSprite(tilesImage, 20, 24, 3, 0)

        _wallSprites = [
            Render.createGridSprite(tilesImage, 20, 24, 0, 8),     // 0000
            Render.createGridSprite(tilesImage, 20, 24, 0, 11),     // 0001
            Render.createGridSprite(tilesImage, 20, 24, 1, 8),     // 0010
            Render.createGridSprite(tilesImage, 20, 24, 1, 10),     // 0011
            Render.createGridSprite(tilesImage, 20, 24, 0, 9),     // 0100
            Render.createGridSprite(tilesImage, 20, 24, 0, 10),     // 0101
            Render.createGridSprite(tilesImage, 20, 24, 1, 9),     // 0110
            Render.createGridSprite(tilesImage, 20, 24, 3, 11),     // 0111
            Render.createGridSprite(tilesImage, 20, 24, 3, 8),     // 1000
            Render.createGridSprite(tilesImage, 20, 24, 2, 10),     // 1001    
            Render.createGridSprite(tilesImage, 20, 24, 2, 8),     // 1010
            Render.createGridSprite(tilesImage, 20, 24, 3, 10),     // 1011
            Render.createGridSprite(tilesImage, 20, 24, 2, 9),     // 1100
            Render.createGridSprite(tilesImage, 20, 24, 1, 11),     // 1101
            Render.createGridSprite(tilesImage, 20, 24, 2, 11),     // 1110    
            Render.createGridSprite(tilesImage, 20, 24, 3, 9)      // 1111    

        ]

        /*
        _floorSprites = [
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
        */


        _floorSprites = [
            Render.createGridSprite(tilesImage, 20, 24, 14, 8),
            Render.createGridSprite(tilesImage, 20, 24, 15, 8),
            Render.createGridSprite(tilesImage, 20, 24, 14, 9),
            Render.createGridSprite(tilesImage, 20, 24, 15, 9)
        ]

        _playerSprite = Render.createGridSprite(heroImage, 4, 11, 0, 0)
        _enemySprite = Render.createGridSprite(slimeImage, 4, 11, 0, 0)

        _genFiber =  Fiber.new { generate() }
    }   
    
    update(dt) {
        Entity.update(dt)

        _time = _time - dt
        if(_time <= 0.0) {
            if(!_genFiber.isDone) {
                _time = _genFiber.call()
            }
        }

        /*
        if(_state == State.playerTurn) {
            movePlayer()
        } else if(_state == State.computerTurn) {
            moveEnemies()
        }
        */
    }

    render() {      
        var s = _tileSize  
        var sx = (_width - 1) * -s / 2
        var sy = (_height-1)  * -s / 2

        for (x in 0..._width) {
            for (y in 0..._height) {
                var v = _grid[x, y]
                var px = sx + x * s
                var py = sy + y * s
                var sprite = null      
                var color = null
                if(v == Type.empty) {
                    Render.renderSprite(_emptySprite, px, py, 1.0, 0.0, 0xFFFFFFFF, 0x0, Render.spriteCenter)
                } else if(v == Type.wall) {
                    var pos = Vec2.new(x, y)  
                    var flag = 0
                    for(i in 0...4) {
                        var n = pos + Directions[i]
                        if(_grid.isValidPosition(n.x, n.y) && _grid[n.x, n.y] == Type.wall) {
                            flag = flag | 1 << i  // |
                        }
                    }
                    Render.renderSprite(_wallSprites[flag], px, py, 1.0, 0.0, 0xFFFFFFFF, 0x0, Render.spriteCenter)                    
                } else {
                    var i = (x + y) % _floorSprites.count
                    Render.renderSprite(_floorSprites[i], px, py, 1.0, 0.0, 0xFFFFFFFF, 0x0, Render.spriteCenter)
                }
            }
        }

        Renderable.render() 
    }

    generate() {
        _level = 5

        for (x in 0..._width) {
            for (y in 0..._height) {
                _grid[x, y] = Type.floor
                Fiber.yield(_shortBrake)
            }
        }

        for (x in 0..._width) {
            _grid[x, 0] = Type.wall
            _grid[x, _height-1] = Type.wall
            Fiber.yield(_shortBrake)
        }

        for (y in 0..._height) {
            _grid[0, y] = Type.wall
            _grid[_width-1, y] = Type.wall
            Fiber.yield(_shortBrake)
        }

         for(i in 0...3) {
            var x = _random.int(1, 5)
            var y = _random.int(1, 5)
            _grid[x + 5, y + 5] = Type.wall
            Fiber.yield(_longBrake)
            _grid[x + 5, 5 - y] = Type.wall
            Fiber.yield(_longBrake)            
            _grid[5 - x, y + 5] = Type.wall
            Fiber.yield(_longBrake)
            _grid[5 - x, 5 - y] = Type.wall
            Fiber.yield(_longBrake)
        }

        Create.hero()
        //_grid[5, 5] = Type.player
        Fiber.yield(_longBrake)

        for(i in 0..._level) {
            var found = false
            while(!found) {
                var x = _random.int(0, 11)
                var y = _random.int(0, 11)
                if(_grid.isValidPosition(x, y) && _grid[x, y] == Type.floor) {
                    createSlime(x, y)
                    //_grid[x, y] = Type.enemy
                    found = true
                    Fiber.yield(_longBrake)
                }
            }
        }

        _state = State.playerTurn
        return 0.0
    }

    createSlime(x, y) {
        var sz = 16
        var sx = (_width - 1) * -sz / 2
        var sy = (_height-1)  * -sz / 2
        var px = sx + x * sz
        var py = sy + y * sz
        var slime = Entity.new()
        var t = Transform.new(Vec2.new(px, py))
        var s = AnimatedSprite.new("[game]/assets/chara_slime.png", 4, 11, 15)
        s.addAnimation("idle", [0,0,0,0,0,0,0,1,2,2,2,2,2,2,2])
        s.playAnimation("idle")
        s.randomizeFrame(_random)
        s.flags = Render.spriteCenter
        slime.addComponent(t)
        slime.addComponent(s)
        slime.name = "Slime"        
    }
 }

 var Game = RoguealotClass.new()
 var Roguealot = Game

import "create" for Create
import "gameplay" for Hero, Tile
