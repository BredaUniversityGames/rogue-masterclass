import "xs" for Data, Input, Render     // These are the parts of the xs we will be using
import "xs_math"for Math, Bits, Vec2, Color
import "xs_assert" for Assert
import "xs_ec"for Entity, Component
import "xs_components" for Transform, Body, Renderable, Sprite, GridSprite, AnimatedSprite
import "random" for Random              // Random is a part of the Wren library
import "sparse_grid" for SpraseGrid
import "types" for Type

class TileMove is Component {
    construct new(from, to) {
        _from = from 
        _to = to
        _current = _from
    }
}

class Hero is Component {
    construct new() {}

    initilize() { }

    update(dt) {
        var s = owner.getComponent(AnimatedSprite)        
        if(Input.getButtonOnce(Input.gamepadDPadRight) || Input.getKeyOnce(Input.keyRight)) {
            s.playAnimation("walk side")
            s.flags = Render.spriteCenter
        } else if(Input.getButtonOnce(Input.gamepadDPadLeft) || Input.getKeyOnce(Input.keyLeft)) {
            s.playAnimation("walk side")
            s.flags = Render.spriteCenter | Render.spriteFlipX // |
        } else if(Input.getButtonOnce(Input.gamepadDPadDown) || Input.getKeyOnce(Input.keyDown)) {
            s.playAnimation("walk down")
            s.flags = Render.spriteCenter
            // moveTile(p.x, p.y, 0, -1)
        } else if(Input.getButtonOnce(Input.gamepadDPadUp) || Input.getKeyOnce(Input.keyUp)) {
            s.playAnimation("walk up")
            s.flags = Render.spriteCenter
            // moveTile(p.x, p.y, 0, 1)
        }
    }
 }

 import "game" for Game