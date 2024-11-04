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

        var preview = Render.loadImage("[game]/assets/monochrome-transparent_packed.png")
        var r = 49
        var c = 22
        __tiles = {
            Type.empty: Render.createGridSprite(preview, r, c, 624),
            Type.floor: Render.createGridSprite(preview, r, c, 68),
            Type.wall: Render.createGridSprite(preview, r, c, 843),
            Type.player: Render.createGridSprite(preview, r, c, 28),
            Type.enemy: Render.createGridSprite(preview, r, c, 323),
            Type.door: Render.createGridSprite(preview, r, c, 799),
            Type.lever: Render.createGridSprite(preview, r, c, 259),
            Type.spikes: Render.createGridSprite(preview, r, c, 259),
            Type.chest: Render.createGridSprite(preview, r, c, 259),
            Type.crate: Render.createGridSprite(preview, r, c, 259),
            Type.pot: Render.createGridSprite(preview, r, c, 259),
            Type.stairs: Render.createGridSprite(preview, r, c, 259),
            Type.light: Render.createGridSprite(preview, r, c, 259)
        }

        __colors = {
            Type.empty: 0xFFFFFF80,
            Type.floor: 0xFFFFFFA0,
            Type.player: Data.getColor("Player Color", Data.game),
            Type.enemy: Data.getColor("Enemy Color", Data.game)
        }
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
        var sy = (__height - 1)  * -s / 2        
        for (x in 0...__width) {
            for (y in 0...__height) {
                var px = sx + x * s
                var py = sy + y * s
                var t = __grid[x, y]
                var tile = Tile.get(x, y)                
                if(tile != null) {                    
                    var pos = Level.calculatePos(tile)
                    var sprite = __tiles[tile.owner.tag]
                    var color = __colors[tile.owner.tag] == null ? 0xFFFFFFFF : __colors[tile.owner.tag]
                    Render.sprite(sprite, pos.x, pos.y, 0.0, 1.0, 0.0, color, 0x0, Render.spriteCenter)
                } else {
                    var sprite = __tiles[t]
                    var color = __colors[t] == null ? 0xFFFFFFFF : __colors[t]
                    if(sprite != null) {
                        Render.sprite(sprite, px, py, 0.0, 1.0, 0.0, color, 0x0, Render.spriteCenter)
                    }
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

// A compenent that represents a tile in the level
// It is used to store the position of the tile in the level
// but also to store all the tiles in the level as a static variable
class Tile is Component {
    static init() {
        __tiles = SpraseGrid.new()
    }

    static get(x, y) {
        if(__tiles.has(x, y)) return __tiles[x, y]
        return null
    }

    construct new(x, y) {
        _x = x
        _y = y
        __tiles[x, y] = this
    }

    move(dx, dy) {  
        __tiles.remove(_x, _y)
        _x = _x + dx
        _y = _y + dy
        __tiles[_x, _y] = this              
    }

    finalize() {
        __tiles.remove(_x, _y)
    }
    
    x { _x }
    y { _y }
}

class Character is Component {

    construct new(attackable, health, damage) {
        _attackable = attackable
        _health = health
        _damage = damage
        _direction = Directions.downIdx
    }

    initialize() {
        _anim = owner.getComponent(AnimatedSprite)
        _tile = owner.getComponent(Tile)
    }

    update(dt) {
        if(_health <= 0) {
            owner.delete()
        }

        if(Data.getBool("Debug Draw", Data.debug)) {
            var pos = Level.calculatePos(_tile)
            Render.dbgColor(0xFFFFFFFF)
            Render.dbgText("%(owner.name)", pos.x - 7, pos.y + 7, 1)
        }
    }

    turn() { true }  // Implement turn logic here one and return true when done

    checkTile(dir, type) {
        var d = Directions[dir]
        var x = _tile.x + d.x
        var y = _tile.y + d.y
        var flag = Level[x, y]
        var t = Tile.get(x, y)
        if(t != null) flag = flag | t.owner.tag // |
        return Bits.checkBitFlagOverlap(type, flag)
    }

    moveTile(dir) {
        var d = Directions[dir]
        _tile.move(d.x, d.y)
    }

    attackTile(dir) {
        System.print("Attacking from position [%(_tile.x),%(_tile.y)] in direction [%(dir)]")
        var d = Directions[dir]
        var x = _tile.x + d.x
        var y = _tile.y + d.y
        var t = Tile.get(x, y)
        if(t != null) {
            if(Bits.checkBitFlag(_attackable, t.owner.tag)) {
                var c = t.owner.getComponentSuper(Character)
                c.recieveAttack(dir, _damage)
            }
        }
    }

    recieveAttack(dir, damage) {        
        System.print("Getting pain position [%(_tile.x),%(_tile.y)] in direction [%(dir)]")
        dir = (dir + 2) % 4
        _health = _health - damage
    }

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
        __hero = this
    }

    turn() {     
        var dir = getDirection()
        if(dir >= 0) {
            _direction = Directions[dir]
            if(checkTile(dir, Type.enemy)) {
                attackTile(dir)
            } else if(!checkTile(dir, Type.blocking)) {
                moveTile(dir)
            }
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

    static turn() { __hero.turn() }

    static hero { __hero }
 }

 class Monster is Character {
    construct new() {
        super(Type.player, Data.getNumber("Monster Health"), Data.getNumber("Monster Damage"))         
    }

    turn() {
        var dir = getDirection()                                                         
        if(dir >= 0) {
            _direction = Directions[dir]
            if(checkTile(dir, Type.player)) {
                attackTile(dir)
            } else if(!checkTile(dir, Type.blocking)) {
                moveTile(dir)
            }
        } 
    }

    getDirection() {
        if(__fill) {
            if(__fill.has(tile.x, tile.y)) {
                return __fill[tile.x, tile.y]
            }
        }
        return -1
    }

    static turn() {
        var enemies = Entity.withTagOverlap(Type.enemy)        
        for(e in enemies) {
            floodFill()
            var s = e.getComponent(Monster)
            s.turn()                        
        }
        return true
    }

    static floodFill() {
        if(Hero.hero) {
            var hero = Hero.hero.owner.getComponent(Tile)
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
            }   
        }
    }

    static debugRender() { 
        Render.dbgColor(0xFF0000FF)    
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

 class Gameplay {
    static playerTurn   { 1 }
    static computerTurn { 2 }

    static init() {
        __state = playerTurn
    }    

    static update(dt) {

        if(__state == Gameplay.playerTurn) {
            if(Hero.turn()) {
                __state = Gameplay.computerTurn
            }
        } else if(__state == Gameplay.computerTurn) {
            if(Monster.turn()) {
                __state = Gameplay.playerTurn
            }            
        }
    }

    static getFlags(x, y) {
        if(Level.contains(x, y)) {
            var flag = Level[x, y]
            var t = Tile.get(x, y)
            if(t != null) flag = flag | t.owner.tag // |
            return flag
        } else {
            return
        }
    }    
 }

import "create" for Create 