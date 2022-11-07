import "xs" for Data, Input, Render
import "xs_math"for Math, Bits, Vec2, Color
import "xs_assert" for Assert
import "xs_ec"for Entity, Component
import "xs_components" for Transform, Body, Renderable, Sprite, GridSprite, AnimatedSprite
import "random" for Random
import "types" for Type
import "directions" for Directions
import "data" for Grid, SpraseGrid, Queue

class Level {    
    
    static init() {
        __tileSize = Data.getNumber("Tile Size", Data.game)
        __width = Data.getNumber("Level Width", Data.game)
        __height = Data.getNumber("Level Height", Data.game)
        __grid = Grid.new(__width, __height, Type.empty)
        __light = Grid.new(__width, __height, 0)

        var tilesImage = Render.loadImage("[game]/assets/tiles_dungeon.png")
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

    static lightUp() {
        var lights = Entity.withTagOverlap(Type.player | Type.light)

        var unlit = lights.count != 0 ? 100 : 150

        for (x in 0...__width) {
            for (y in 0...__height) {
                __light[x, y] = unlit
            }
        }
        
        for(l in lights) {
            var t  = l.getComponent(Tile)
            for(x in (t.x-3)..(t.x+3)) {
                for(y in (t.y-3)..(t.y+3)) {
                    if(__light.valid(x, y)) {
                        var d = Vec2.distance(Vec2.new(t.x, t.y), Vec2.new(x, y))
                        __light[x, y] = Math.max(255 - d * 56, __light[x, y])
                    }
                }
            }
        }
    }

    static render() {
        Level.lightUp()
        var s = __tileSize  
        var sx = (__width - 1) * -s / 2
        var sy = (__height - 1)  * -s / 2
        for (x in 0...__width) {
            for (y in 0...__height) {
                var v = __grid[x, y]
                var px = sx + x * s
                var py = sy + y * s
                var sprite = null
                var lv = __light[x, y]
                var color = Color.new(lv, lv, lv, 255)
                if(v == Type.empty) {
                    Render.sprite(__emptySprite, px, py, -py, 1.0, 0.0, color.toNum, 0x0, Render.spriteCenter)
                } else if(v == Type.wall) {
                    var pos = Vec2.new(x, y)  
                    var flag = 0
                    for(i in 0...4) {
                        var n = pos + Directions[i]
                        if(__grid.valid(n.x, n.y) && __grid[n.x, n.y] == Type.wall) {
                            flag = flag | 1 << i  // |
                        }
                    }
                    Render.sprite(__wallSprites[flag], px, py, -py, 1.0, 0.0, color.toNum, 0x0, Render.spriteCenter)                    
                } else {
                    var i = (x + y) % __floorSprites.count
                    Render.sprite(__floorSprites[i], px, py, -py, 1.0, 0.0, color.toNum, 0x0, Render.spriteCenter)
                }
            }
        }
    }

    static tileSize { __tileSize }
    
    static width { __width }

    static height { __height }

    static random { __random }

    static contains(x, y) { __grid.valid(x, y) }    

    static [x, y] { __grid[x, y] }

    static [x, y]=(v) { __grid[x, y] = v }

    static [pos] { __grid[pos.x, pos.y] }

    static [pos]=(v) { __grid[pos.x, pos.y] = v }

    static getLight(x, y) {
        if(__light.valid(x, y)) {
            return __light[x, y]
        }
        return 0
    }
}

class Tile is Component {
    static init() {
        __tiles = SpraseGrid.new()
    }

    static add(x, y, tile) {
        if(!__tiles.has(x, y)) {
            __tiles[x, y] = []
        }
        var l = __tiles[x, y]
        l.add(tile)
        __tiles[x, y] = l
    }

    static remove(x, y, tile) {
        if(__tiles.has(x, y)) {
            var l = __tiles[x, y]
            l.removeAt(l.indexOf(tile))
        }
    }

    static move(fx, fy, tx, ty, tile) {
        remove(fx, fy, tile)
        add(tx, ty, tile)
    }

    static get(x, y) {
        if(__tiles.has(x, y)) {
            return __tiles[x, y]
        }
        return []
    }

    construct new(x, y) {
        _x = x
        _y = y
        _z = 0
        _toX = x
        _toY = y
        _t = 0
        Tile.add(x, y, this)
    }

    update(dt) {
        var tr = owner.getComponent(Transform)

        if(moving) {
            _t = _t + dt * _invT 
            if(_t >= 1) {               
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

        var s = owner.getComponentSuper(Sprite)
        if(s != null) {
            var l = Level.getLight(x, y)
            s.mul = Color.new(l,l,l, 255).toNum
            s.layer = -tr.position.y + 1000 + _z
        }
    }

    move(dx, dy, time) {
        if(!moving) {
            _toX = _x + dx
            _toY = _y + dy
            _invT = 1 / time
            Tile.move(_x, _y, _toX, _toY, this)
        }
    }

    finalize() {
        Tile.remove(_x, _y, this)
    }
    
    x { _x }
    y { _y }
    z { _z }
    z=(v) { _z = v }
    moving { _x != _toX ||  _y != _toY }
}


class Character is Component {
    static idle         { 0 }
    static selected     { 1 }
    static moving       { 2 }
    static attacking    { 3 }
    static pain         { 4 }

    construct new(attackable, health, damage) {
        _attackable = attackable
        _health = health
        _damage = damage
        _state = Character.idle
        _direction = Directions.downIdx
        _flags = [  Render.spriteCenter,
                    Render.spriteCenter,
                    Render.spriteCenter,
                    Render.spriteCenter | Render.spriteFlipX] 
        _anims = [  "up" , "side", "down", "side"]
        __stateNames = ["W", "S", "M", "A", "P"]
    }

    initialize() {
        _anim = owner.getComponent(AnimatedSprite)
        _tile = owner.getComponent(Tile)
    }

    update(dt) {
        // This is the same as having a character controller where after every action/animation it goes to idle
        if((_state == Character.attacking || _state == Character.moving || _state == Character.pain) &&
            _anim.isDone && !_tile.moving) {
            _state = Character.idle
            _anim.playAnimation("idle")
            _anim.mode = AnimatedSprite.loop
        }

        if(_health <= 0) {
            owner.delete()
        }

        if(Data.getBool("Debug Draw", Data.debug)) {
            var pos = Level.calculatePos(_tile)
            Render.setColor(1, 1, 1, 1)
            var state = __stateNames[_state]
            Render.shapeText("%(owner.name)", pos.x - 7, pos.y + 7, 1)
            Render.shapeText("%(state)", pos.x - 7, pos.y, 1)
        }
    }

    turn() { true }  // Implement turn logic here one and return true when done

    checkTile(dir, type) {
        var d = Directions[dir]
        var x = _tile.x + d.x
        var y = _tile.y + d.y
        var flag = Level[x, y]
        for(t in Tile.get(x, y)) {
            // System.print("tile=[%(t.x), %(t.y)] name=%(t.owner.name) tag=%(t.owner.tag) )")    
            flag = flag | t.owner.tag // |
        }
        // System.print("loc=[%(x),%(y)] type=%(type) flag=%(flag) res=%(Bits.checkBitFlagOverlap(type, flag))")
        return Bits.checkBitFlagOverlap(type, flag)
    }

    moveTile(dir) {
        //System.print("Moving from position [%(_tile.x),%(_tile.y)] in direction [%(dir)]")
        var d = Directions[dir]
        _tile.move(d.x, d.y, 0.3) //TODO: Take this from Data
        _anim.playAnimation("walk " + _anims[dir])
        _anim.flags = _flags[dir]
        _anim.mode = AnimatedSprite.once
        _state = Character.moving
    }

    attackTile(dir) {
        System.print("Attacking from position [%(_tile.x),%(_tile.y)] in direction [%(dir)]")
        _state = Character.attacking
        _anim.playAnimation("attack " + _anims[dir])
        _anim.flags = _flags[dir]
        _anim.mode = AnimatedSprite.once
        var d = Directions[dir]
        var x = _tile.x + d.x
        var y = _tile.y + d.y
        for(t in Tile.get(x, y)) {
            if(Bits.checkBitFlag(_attackable, t.owner.tag)) {
                var c = t.owner.getComponentSuper(Character)
                c.recieveAttack(dir, _damage)
            }
        }
    }

    recieveAttack(dir, damage) {        
        System.print("Getting pain position [%(_tile.x),%(_tile.y)] in direction [%(dir)]")
        dir = (dir + 2) % 4
        _anim.playAnimation("pain " + _anims[dir])
        _anim.mode = AnimatedSprite.once
        _anim.flags = _flags[dir]
        _state = Character.pain
        _health = _health - damage
    }

    select() {
        //System.print("Select %(owner.name)")
        _state = Character.selected
    }

    state { _state }
    state=(v) { _state = v}
    tile { _tile }
    health { _health }
    damage { _damage }
}

class Hero is Character {    
    construct new() {
        super(Type.enemy, Data.getNumber("Hero Health"), Data.getNumber("Hero Damage"))
        _buttons = [Input.gamepadDPadUp,
                    Input.gamepadDPadRight,
                    Input.gamepadDPadDown,
                    Input.gamepadDPadLeft ]
        _keys = [   Input.keyUp,
                    Input.keyRight,
                    Input.keyDown,
                    Input.keyLeft]
    }

    turn() {        
        if(state == Character.selected) {
            var dir = getDirection()
            if(dir >= 0) {
                _direction = Directions[dir]
                if(checkTile(dir, Type.enemy)) {
                    attackTile(dir)
                } else if(!checkTile(dir, Type.blocking)) {
                    moveTile(dir)
                }
            }    
        } else if (state == Character.idle) {
            return true   
        }
        return false
    }

    getDirection() {
        for(dir in 0...4) {
            if(Input.getButtonOnce(_buttons[dir]) || Input.getKeyOnce(_keys[dir])) {
                return dir
            }
        }
        return -1
    }

    static turn() {
        if(Hero.hero) {
            var hero = Hero.hero.getComponent(Hero)
            hero.select()
            while(true && Hero.hero != null) {
                if(hero.turn()) {
                    return
                }
                Fiber.yield()
            }
        }
    }

    static hero {
        if(__hero != null) {
            return __hero
        }
        var pls = Entity.withTagOverlap(Type.player)
        if(pls.count == 1) {
            __hero = pls[0]            
        }
        return __hero
    }

 }

 class Monster is Character {
    construct new() {
        super(Type.player, Data.getNumber("Monster Health"), Data.getNumber("Monster Damage"))         
    }

    turn() {
        if(state == Character.selected) {
            var dir = getDirection()                                                         
            if(dir >= 0) {
                _direction = Directions[dir]
                if(checkTile(dir, Type.player)) {
                    attackTile(dir)
                } else if(!checkTile(dir, Type.blocking)) {
                    moveTile(dir)
                }
            } else {
                // System.print("Monster %(owner.name) is going to idle")
                state = Character.idle
                return true
            }
        } else if (state == Character.idle) {
            return true   
        }
        return false
    }

    getDirection() {
        // System.print("getting Direction for %(owner.name)")
        if(__fill) {
            if(__fill.has(tile.x, tile.y)) {
                return __fill[tile.x, tile.y]
            }
        }
        return -1
    }

    static turn() {
        floodFill()
        Fiber.yield()
        var enemies = Entity.withTagOverlap(Type.enemy)
        for(e in enemies) {
            var s = e.getComponent(Monster)
            s.select()
            s.turn()
            var wait = s.state == Character.attacking ? 12 : 8
            for(i in  1...wait) {
                Fiber.yield()
            }
        }
    }

    static floodFill() {
        if(Hero.hero) {
            var hero = Hero.hero.getComponent(Tile)
            var open = Queue.new()
            open.push(Vec2.new(hero.x, hero.y))
            __fill = SpraseGrid.new()
            __fill[hero.x, hero.y] = Directions.noneIdx
            var count = 50
            while(!open.empty() && count > 0) {
                var next = open.pop()
                for(i in 0...4) {
                    var nghb = next + Directions[i]
                    if(Level.contains(nghb.x, nghb.y) && !__fill.has(nghb.x, nghb.y)) {
                        var flags = Gameplay.getFlags(nghb.x, nghb.y)
                        if(!Bits.checkBitFlagOverlap(flags, Type.monsterBlock)) {
                            __fill[nghb.x, nghb.y] = (i + 2) % 4 // Opposite direction 
                            open.push(nghb)
                        }
                    }                     
                }
                count = count - 1
                Fiber.yield(0.0)
            }   
        }
    }

    static debugRender() { 
        Render.setColor(0xFF0000FF)    
        if(__fill != null) { 
            for (x in 0...Level.width) {
                for (y in 0...Level.height) {
                    if(__fill.has(x, y)) { 
                        var dr = Directions[__fill[x, y]]
                        var fr = Level.calculatePos(x, y)
                        var to = Level.calculatePos(x + dr.x, y + dr.y)
                        Render.line(fr.x, fr.y, to.x, to.y)
                    }
                }
            }
        }
    }
 }

 class Camera is Component {
    construct new() {
        System.print("new")
    }

    update(dt) {
        return
        var pls = Entity.withTag(Type.player)
        if(pls.count != 0) {
            var p = pls[0]
            var t = p.getComponent(Transform)
            Render.setOffset(-t.position.x, -t.position.y) 
        }
    }
 }

 class Gameplay {
    static generating   { 0 }
    static playerTurn   { 1 }
    static computerTurn { 2 }

    static init() {
        __turn = computerTurn
        __turnFiber = Fiber.new { }
        //var ui = Create.healthbar()
    }    

    static update(dt) {
        if(__turnFiber.isDone) {
            if(__turn == playerTurn) {
                __turn = computerTurn
                __turnFiber = Fiber.new { Monster.turn() }
            } else if(__turn == computerTurn) {
                __turn = playerTurn
                __turnFiber = Fiber.new { Hero.turn() }
            }    
        } else {
            __turnFiber.call()
        }
    }

    static getFlags(x, y) {
        if(Level.contains(x, y)) {
            var flag = Level[x, y]
            for(t in Tile.get(x, y)) {
                flag = flag | t.owner.tag // |
            }
            return flag
        } else {
            return
        }
    }

    static debugRender() {
        return
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
                    Render.setColor(0x1111118F)  
                } else if (v == Type.wall) {
                    Render.setColor(0x8383038F)
                } else {
                    Render.setColor(0x3333338F)
                }
                
                Render.circle(px, py, 8, 32)

                for (t in Tile.get(x, y)) {
                    var tag = t.owner.tag
                    if (tag == Type.enemy) {
                        Render.setColor(0x1111FF8F)  
                    } else if (tag == Type.player) {
                        Render.setColor(0x11FF338F)
                    } else {
                        Render.setColor(0x3333338F)
                    }
                    Render.disk(px, py, 2.0, 9)
                    px = px + 2
                    py = py + 2
                }
            }
        }

        Render.setColor(0xFF0000FF)
        Monster.debugRender()
    }
 }

import "create" for Create 