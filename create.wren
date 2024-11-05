import "xs" for Data, Input, Render
import "xs_math"for Math, Bits, Vec2, Color
import "xs_ec"for Entity, Component
import "xs_components" for Transform, Body, Renderable, Sprite, GridSprite, AnimatedSprite
import "random" for Random
import "types" for Type
import "ui" for Healthbar

class Create {

    static init() {
        __random = Random.new()
        __id = 0
    }

    static character(x, y) {
        var entity = Entity.new()
        var t = Transform.new(Level.calculatePos(x, y))
        var tl = Tile.new(x, y)
        entity.addComponent(t)
        entity.addComponent(tl)
        return entity
    }

    static hero(x, y) {
        var entity = character(x, y)
        var h = Hero.new()
        entity.addComponent(h)
        entity.tag = Type.player
        entity.name = "H%(nextID)"
        return entity
    }

    static monster(x, y) {
        var entity = character(x, y)
        var s = Monster.new()
        entity.addComponent(s)
        entity.tag = Type.enemy
        entity.name = "M%(nextID)"
        return entity
    }

    static nextID {
        __id = __id + 1
        return __id
    }

    static spikes() {}

    static stairs() {}

    static crate() {
        var entity = Entity.new()
        var t = Transform.new(Level.calculatePos(x, y))
        var tl = Tile.new(x, y)
        s.flags = Render.spriteCenter
        entity.addComponent(t)
        entity.addComponent(tl)
        entity.tag = Type.wall
        entity.name = "C%(nextID)"
        return entity
    }
    
    static pillar(x, y, fire) {
        var entity = Entity.new()
        var pos = Level.calculatePos(x, y) + Vec2.new(0, Level.tileSize / 2)
        var t = Transform.new(pos)
        var tl = Tile.new(x, y)
        entity.addComponent(t)
        entity.addComponent(tl)
        entity.tag = Type.wall
        entity.name = "P%(nextID)"
    }

    static wallTorch(x, y) {
        var entity = Entity.new()
        var pos = Level.calculatePos(x, y) + Vec2.new(0, Level.tileSize / 2)
        var t = Transform.new(pos)
        var tl = Tile.new(x, y)
        tl.z = 0.1
        entity.addComponent(t)
        entity.addComponent(tl)
        entity.name = "T%(nextID)"
        entity.tag = Type.light
    }

    static something(x, y) {
        var entity = Entity.new()
        var t = Transform.new(Level.calculatePos(x, y))
        var tl = Tile.new(x, y)
        entity.addComponent(t)
        entity.addComponent(tl)
        entity.tag = Type.wall
        entity.name = "S%(nextID)"
        return entity
    }

    static treasure(x, y) {
        var entity = Entity.new()
        var t = Transform.new(Level.calculatePos(x, y))
        var tl = Tile.new(x, y)
        s.flags = Render.spriteCenter
        entity.addComponent(t)
        entity.addComponent(tl)
        entity.tag = Type.wall | Type.light
        entity.name = "F%(nextID)"
        return entity
    }

    static door(x, y, vertical) {
        var entity = Entity.new()
        var t = Transform.new(Level.calculatePos(x, y))
        var tl = Tile.new(x, y)
        entity.addComponent(t)
        entity.addComponent(tl)
        entity.tag = Type.door
        entity.name = "F%(nextID)"
        return entity
    }
}

import "gameplay" for Hero, Monster, Tile, Level