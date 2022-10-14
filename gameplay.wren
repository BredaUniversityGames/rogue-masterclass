import "xs" for Data, Input, Render     // These are the parts of the xs we will be using
import "xs_math"for Math, Bits, Vec2, Color
import "xs_assert" for Assert
import "xs_ec"for Entity, Component
import "xs_components" for Transform, Body, Renderable, Sprite, GridSprite, AnimatedSprite
import "random" for Random              // Random is a part of the Wren library
import "sparse_grid" for SpraseGrid
import "types" for Type
import "directions" for Directions

class Tile is Component {
    static init() {
        __grid = SpraseGrid.new([])
    }

    static add(x, y, tile) {
        var l = __grid[x, y]
        l.add(tile)
        __grid[x, y] = l
    }

    static remove(x, y, tile) {
        var l = __grid[x, y]
        l.removeAt(l.indexOf(tile))
    }

    static move(fx, fy, tx, ty, tile) {
        remove(fx, fy, tile)
        add(tx, ty, tile)
    }

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
                tr.position = Roguealot.calculatePos(_x, _y)
            } else {
                var from = Roguealot.calculatePos(_x, _y)
                var to = Roguealot.calculatePos(_toX, _toY)
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
            // 
        } else if(_state == Hero.idle) {
            if(Input.getButtonOnce(Input.gamepadDPadRight) || Input.getKeyOnce(Input.keyRight)) {
                s.playAnimation("attack side")
                s.flags = Render.spriteCenter
                _direction = Directions.rightIdx
                moveTile(1, 0)                
            } else if(Input.getButtonOnce(Input.gamepadDPadLeft) || Input.getKeyOnce(Input.keyLeft)) {
                s.playAnimation("attack side")
                s.flags = Render.spriteCenter | Render.spriteFlipX // |
                _direction = Directions.leftIdx                
                moveTile(-1, 0)
            } else if(Input.getButtonOnce(Input.gamepadDPadDown) || Input.getKeyOnce(Input.keyDown)) {
                s.playAnimation("walk down")
                s.flags = Render.spriteCenter
                _direction = Directions.downIdx
                moveTile(0, -1)
            } else if(Input.getButtonOnce(Input.gamepadDPadUp) || Input.getKeyOnce(Input.keyUp)) {
                s.playAnimation("walk up")
                s.flags = Render.spriteCenter  
                _direction = Directions.upIdx
                moveTile(0, 1)
            }        
        }
        Render.setColor(1, 1, 1, 1)
        Render.text("State: %(_state)", 10, 10, 1)
    }

    moveTile(dx, dy) {
        _state = Hero.walking
        var tl = owner.getComponent(Tile)
        tl.move(dx, dy, 0.3)
    }

    attackTile() {
    }
 }

 class Slime is Component {

 }

 import "game" for Roguealot