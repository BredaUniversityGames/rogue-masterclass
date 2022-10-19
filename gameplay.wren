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
        if(moving) {
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
    //isDone { _x == _toX &&  _y == _toY }
    moving { _x != _toX ||  _y != _toY }
}


class Character is Component {
    static idle         { 0 }
    static active       { 1 }
    static walking      { 2 }
    static attacking    { 3 }
    static pain         { 4 }

    construct new(attackable) {
        _attackable = attackable
        _state = Character.idle
        _direction = Directions.downIdx

        _flags = [  Render.spriteCenter,
                    Render.spriteCenter,
                    Render.spriteCenter,
                    Render.spriteCenter | Render.spriteFlipX] 
        _anims = [  "up" , "side", "down", "side"]
    }

    update() {
        var s = owner.getComponent(AnimatedSprite)
        var tl = owner.getComponent(Tile)
        /*
        if(_state == Character.walking) {
            if(!tl.moving) {
                _state = Character.idle
                s.playAnimation("idle")
                s.mode = AnimatedSprite.loop
            }
        } else if(_state == Character.attacking || _state == Character.pain) {
            if(s.isDone) {
                _state = Character.idle
                s.playAnimation("idle")
                s.mode = AnimatedSprite.loop
            }
        } else */ if(_state == Character.active) {
            for(dir in 0...4) {                                                              
                if(shouldMove(dir)) {                    
                    _direction = Directions[dir]
                    s.flags = _flags[dir]
                    if(checkTile(dir, _attackable)) {
                        attackTile(dir)
                        s.playAnimation("attack " + _anims[dir])
                        s.mode = AnimatedSprite.once
                        __state = Character.attacking
                    } else if(!checkTile(dir, Type.blocking)) {
                        moveTile(dir)
                        s.playAnimation("walk " + _anims[dir])
                        s.mode = AnimatedSprite.once
                        __state = Character.walking
                    }
                }    
            }     
        }

        
        //System.print("s.isDone: %(s.isDone) s.mode:%(s.mode) tl.moving:%(tl.moving)")
        if((__state == Character.attacking || __state == Character.walking || __state == Character.pain) &&
            s.isDone && !tl.moving) {
            _state = Character.idle
            s.playAnimation("idle")
            s.mode = AnimatedSprite.loop
        }
    }

    update(dt) {          
        if(Data.getBool("Debug Draw", Data.debug)) {
            var tl = owner.getComponent(Tile)
            var pos = Level.calculatePos(tl)
            Render.setColor(1, 1, 1, 1)
            Render.text("s:%(_state)", pos.x - 7, pos.y, 1)
        }
    }

    shouldMove(dir) { false } // Implement this one

    checkTile(dir, type) {
        var d = Directions[dir]
        var tl = owner.getComponent(Tile)
        var x = tl.x + d.x
        var y = tl.y + d.y
        var flag = Level[x, y]
        for(t in Tile.get(x, y)) {
            // System.print("tile=[%(t.x), %(t.y)] name=%(t.owner.name) tag=%(t.owner.tag) )")    
            flag = flag | t.owner.tag // |
        }
        // System.print("loc=[%(x),%(y)] type=%(type) flag=%(flag) res=%(Bits.checkBitFlagOverlap(type, flag))")
        return Bits.checkBitFlagOverlap(type, flag)
    }

    moveTile(dir) {
        var d = Directions[dir]
        _state = Character.walking
        var tl = owner.getComponent(Tile)
        tl.move(d.x, d.y, 0.3)
        // Gameplay.step()
    }

    attackTile(dir) {
        var tl = owner.getComponent(Tile)
        _state = Character.attacking
        var d = Directions[dir]
        var x = tl.x + d.x
        var y = tl.y + d.y
        for(t in Tile.get(x, y)) {
            if(Bits.checkBitFlagOverlap(Type.player, t.owner.tag)) {
                var c = t.owner.getComponentSuper(Character)
                c.recieveAttack(dir)
            }
        }
        // Gameplay.step()
    }

    recieveAttack(dir) {        
        var s = owner.getComponent(AnimatedSprite)
        dir = (dir + 2) % 4
        s.playAnimation("pain " + _anims[dir])
        s.mode = AnimatedSprite.once
        s.flags = _flags[dir]
        _state = Character.pain
    }

    state { _state }
    state=(v) { _state = v}
}

class Hero is Character {    
    construct new() {
        super(Type.enemy)
        _buttons = [Input.gamepadDPadUp,
                    Input.gamepadDPadRight,
                    Input.gamepadDPadDown,
                    Input.gamepadDPadLeft ]
        _keys = [   Input.keyUp,
                    Input.keyRight,
                    Input.keyDown,
                    Input.keyLeft]
    }

    shouldMove(dir) {      
        // System.print("shouldMove")  
        return Input.getButtonOnce(_buttons[dir]) || Input.getKeyOnce(_keys[dir])
    }
 }

 class Slime is Character {
    construct new() {
        super(Type.player)
        _buttons = [Input.gamepadDPadUp,
                    Input.gamepadDPadRight,
                    Input.gamepadDPadDown,
                    Input.gamepadDPadLeft ]
        _keys = [   Input.keyUp,
                    Input.keyRight,
                    Input.keyDown,
                    Input.keyLeft]            
    }

    shouldMove(dir) {
        var ownTile = owner.getComponent(Tile)
        var playerTile = Gameplay.player.getComponent(Tile)
        var d = Directions[dir]
        var currentPos = Vec2.new(ownTile.x, ownTile.y)    
        var movePos = currentPos + d
        var playerPos = Vec2.new(playerTile.x, playerTile.y)
        var flag = Level[movePos.x, movePos.y]
        //for(t in Tile.get(movePos.x, movePos.y)) {
        //    flag = (flag | t.owner.tag) // |
        //}
        var val =   Vec2.distance(movePos, playerPos) < Vec2.distance(currentPos, playerPos) &&
                    Bits.checkBitFlagOverlap(flag, Type.floor | Type.player) // |                    
        if(!val) {
            state = Character.idle
        }        
        return val
    }
 }

 class Gameplay {
    static generating   { 0 }
    static playerTurn   { 1 }
    static computerTurn { 2 }

    static init() {
        __state = generating
        __queue = []
        __player = null
    }    

    static update(dt) {
        if(__state == Gameplay.generating) {            
            return
        }        

        // Process entity queue
        if(__queue.count != 0) {
            var e = __queue[0]
            var c = e.getComponentSuper(Character)
            c.update()
            if(c.state == Character.idle) {
                __queue.removeAt(0)
                if(__queue.count != 0) {
                    e = __queue[0]
                    c = e.getComponentSuper(Character)
                    c.state = Character.active // Consider activate
                }
            }
        } else {
            step()
        }
    }

    static start() {        
        var pls = Entity.entitiesWithTag(Type.player)
        if(pls.count == 1) {
            System.print("start")
            __player = pls[0]            
            var c = pls[0].getComponentSuper(Character)
            c.state = Character.active
            __queue.addAll(pls)
            __state = playerTurn
        }
    }

    static step() {
        System.print("step queue.count:%(__queue.count)")
        if(__queue.count == 0) {
            if(__state == Gameplay.playerTurn) {
                System.print("step player")
                __queue.addAll(Entity.entitiesWithTag(Type.enemy))
                __state = Gameplay.computerTurn
            } else if(__state == Gameplay.computerTurn) {
                System.print("step computer")
                __queue.addAll(Entity.entitiesWithTag(Type.player))
                __state = Gameplay.playerTurn
            }    
        }
    }

    static ready {
        return __queue.count != 0
    }

    static player { __player }

    static debugRender() {
        var dbg = Data.getBool("Debug Draw", Data.debug)
        if(!dbg) {
            return
        }

        var s = Level.tileSize  
        var sx = (Level.width - 1) * -s / 2
        var sy = (Level.height - 1) * -s / 2
        for (x in 0...Level.width) {
            for (y in 0...Level.height) {
                var v = Level[x, y]
                var px = sx + x * s
                var py = sy + y * s
                var color = null
                if (v == Type.empty) {
                    Render.setColor(0x111111FF)  
                } else if (v == Type.wall) {
                    Render.setColor(0xFF3333FF)
                } else {
                    Render.setColor(0x333333FF)
                }
                Render.circle(px, py, 3.0, 12)

                for (t in Tile.get(x, y)) {
                    var tag = t.owner.tag
                    if (tag == Type.enemy) {
                        Render.setColor(0x1111FFFF)  
                    } else if (tag == Type.player) {
                        Render.setColor(0x11FF33FF)
                    } else {
                        Render.setColor(0x333333FF)
                    }
                    Render.disk(px, py, 2.0, 9)
                    px = px + 2
                    py = py + 2
                }
            }
        }
    }
 }
