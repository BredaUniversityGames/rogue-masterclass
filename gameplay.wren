import "xs" for Data, Input, Render
import "xs_math"for Math, Bits, Vec2, Color
import "xs_assert" for Assert
import "xs_ec"for Entity, Component
import "xs_components" for Transform, Body, Renderable, Sprite, GridSprite, AnimatedSprite
import "random" for Random
import "sparse_grid" for SpraseGrid
import "grid" for Grid
import "types" for Type
import "directions" for Directions

class Level {    
    
    static init() {
        __tileSize = Data.getNumber("Tile Size", Data.game)
        __width = Data.getNumber("Level Width", Data.game)
        __height = Data.getNumber("Level Height", Data.game)
        __grid = Grid.new(__width, __height, Type.empty)

        var tilesImage = Render.loadImage("[game]/assets/tiles_dungeon.png")
        var heroImage = Render.loadImage("[game]/assets/chara_hero.png")
        var slimeImage = Render.loadImage("[game]/assets/chara_slime.png")

        __emptySprite = Render.createGridSprite(tilesImage, 20, 24, 3, 0)

        __wallSprites = [
            Render.createGridSprite(tilesImage, 20, 24, 0, 8),      // 0000
            Render.createGridSprite(tilesImage, 20, 24, 0, 11),     // 0001
            Render.createGridSprite(tilesImage, 20, 24, 1, 8),      // 0010
            Render.createGridSprite(tilesImage, 20, 24, 1, 10),     // 0011
            Render.createGridSprite(tilesImage, 20, 24, 0, 9),      // 0100
            Render.createGridSprite(tilesImage, 20, 24, 0, 10),     // 0101
            Render.createGridSprite(tilesImage, 20, 24, 1, 9),      // 0110
            Render.createGridSprite(tilesImage, 20, 24, 3, 11),     // 0111
            Render.createGridSprite(tilesImage, 20, 24, 3, 8),      // 1000
            Render.createGridSprite(tilesImage, 20, 24, 2, 10),     // 1001
            Render.createGridSprite(tilesImage, 20, 24, 2, 8),      // 1010
            Render.createGridSprite(tilesImage, 20, 24, 3, 10),     // 1011
            Render.createGridSprite(tilesImage, 20, 24, 2, 9),      // 1100
            Render.createGridSprite(tilesImage, 20, 24, 1, 11),     // 1101
            Render.createGridSprite(tilesImage, 20, 24, 2, 11),     // 1110
            Render.createGridSprite(tilesImage, 20, 24, 3, 9)       // 1111

        ]

        __floorSprites = [
            Render.createGridSprite(tilesImage, 20, 24, 14, 8),
            Render.createGridSprite(tilesImage, 20, 24, 15, 8),
            Render.createGridSprite(tilesImage, 20, 24, 14, 9),
            Render.createGridSprite(tilesImage, 20, 24, 15, 9)
        ]

        __playerSprite = Render.createGridSprite(heroImage, 4, 11, 0, 0)
        __enemySprite = Render.createGridSprite(slimeImage, 4, 11, 0, 0)

    }

    static calculatePos(tile) {
        return calculatePos(tile.x, tile.y)
    }

    static calculatePos(tx, ty) {
        var sx = (__width - 1) * -__tileSize / 2.0
        var sy = (__height - 1)  * -__tileSize / 2.0
        var px = sx + tx * __tileSize
        var py = sy + ty * __tileSize
        return Vec2.new(px, py)        
    }

    static calculateTile(pos) {
        var sx = (__width - 1.0) * -__tileSize / 2.0
        var sy = (__height - 1.0)  * -__tileSize / 2.0
        var tx = (pos.x - sx) / __tileSize
        var ty = (pos.y - sy) / __tileSize
        return Vec2.new(tx.round, ty.round)
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
    }

    static tileSize { __tileSize }
    
    static width { __width }

    static height { __height }

    static random { __random }

    static isValidPosition(x, y) { __grid.isValidPosition(x, y) }    

    static [x, y] { __grid[x, y] }

    static [x, y]=(v) { __grid[x, y] = v }
}

class Tile is Component {
    static init() {
        __tiles = SpraseGrid.new([])
    }

    static add(x, y, tile) {
        var l = __tiles[x, y]
        l.add(tile)
        __tiles[x, y] = l
    }

    static remove(x, y, tile) {
        var l = __tiles[x, y]
        l.removeAt(l.indexOf(tile))
    }

    static move(fx, fy, tx, ty, tile) {
        remove(fx, fy, tile)
        add(tx, ty, tile)
    }

    static get(x, y) { __tiles[x, y] }

    construct new(x, y) {
        _x = x
        _y = y
        _toX = x
        _toY = y
        _t = 0
        Tile.add(x, y, this)
    }

    update(dt) {
        if(!isDone) {
            _t = _t + dt * _invT 
            var tr = owner.getComponent(Transform)            
            if(_t >= 1) {
                Tile.move(_x, _y, _toX, _toY, this)
                _t = 0
                _x = _toX
                _y = _toY
                tr.position = Level.calculatePos(_x, _y)
            } else {
                var from = Level.calculatePos(_x, _y)
                var to = Level.calculatePos(_toX, _toY)
                tr.position = Math.lerp(from, to, _t)
            }            
        }
    }

    move(dx, dy, time) {
        _toX = _x + dx
        _toY = _y + dy
        _invT = 1 / time
    }

    finalize() {
        Tile.remove(_x, _y, this)
    }
    
    x { _x }
    y { _y }
    isDone { _x == _toX &&  _y == _toY }
} 

class Hero is Component {
    static idle         { 0 }
    static walking      { 1 }
    static attacking    { 2 }

    construct new() {
        _state = Hero.idle
        _direction = Directions.downIdx

        _buttons = [Input.gamepadDPadUp,
                    Input.gamepadDPadRight,
                    Input.gamepadDPadDown,
                    Input.gamepadDPadLeft ]
        _keys = [   Input.keyUp,
                    Input.keyRight,
                    Input.keyDown,
                    Input.keyLeft]
        _flags = [  Render.spriteCenter,
                    Render.spriteCenter,
                    Render.spriteCenter,
                    Render.spriteCenter | Render.spriteFlipX] 
        _anims = [  "up" , "side", "down", "side"]
    }

    initilize() { }    

    update(dt) {
        var s = owner.getComponent(AnimatedSprite)        
        var tl = owner.getComponent(Tile)
        if(_state == Hero.walking) {
            if(tl.isDone) {
                _state = Hero.idle
                s.playAnimation("idle")
            }
        } else if(_state == Hero.attacking) {            
            if(s.isDone) {
                _state = Hero.idle
                s.playAnimation("idle")
            }
        } else if(_state == Hero.idle) {
            for(dir in 0...4) {                                              
                if(Input.getButtonOnce(_buttons[dir]) || Input.getKeyOnce(_keys[dir])) {
                    _direction = Directions[dir]
                    s.flags = _flags[dir]
                    if(checkTile(dir, Type.attackable)) {
                        attackTile(dir)
                        s.playAnimation("attack " + _anims[dir])
                        // s.mode = AnimatedSprite.once
                    } else if(!checkTile(dir, Type.blocking)) {
                        moveTile(dir)
                        s.playAnimation("walk " + _anims[dir])
                        // s.mode = AnimatedSprite.once
                    }
                }    
            }     
        }
        Render.setColor(1, 1, 1, 1)
        Render.text("State: %(_state)", 10, 10, 1)
    }

    checkTile(dir, type) {
        var d = Directions[dir]
        var tl = owner.getComponent(Tile)
        var x = tl.x + d.x
        var y = tl.y + d.y
        var flag = Level[x, y]
        for(t in Tile.get(x, y)) {
            System.print("tile=[%(t.x), %(t.y)] name=%(t.owner.name) tag=%(t.owner.tag) )")    
            flag = flag | t.owner.tag // |
        }
        System.print("loc=[%(x),%(y)] type=%(type) flag=%(flag) res=%(Bits.checkBitFlagOverlap(type, flag))")
        return Bits.checkBitFlagOverlap(type, flag)
    }

    moveTile(dir) {
        var d = Directions[dir]
        _state = Hero.walking
        var tl = owner.getComponent(Tile)
        tl.move(d.x, d.y, 0.3)
    }

    attackTile(dir) {
        var tl = owner.getComponent(Tile)
        _state = Hero.attacking
    }
 }

 class Slime is Component {

 }

 class Gameplay {
    // Rules go here?
 }
