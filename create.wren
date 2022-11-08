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

    static camera() {
        var e = Entity.new()
        var c = Camera.new()
        e.addComponent(c)
    }

    static character(x, y, image) {
        var entity = Entity.new()
        var t = Transform.new(Level.calculatePos(x, y))
        var s = AnimatedSprite.new(image, 24, 4, 30) // Same image for all
        var tl = Tile.new(x, y)
        var f = 0
        s.addAnimation("idle", [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0])

        /*
        f = f + 4
        .addAnimation("selected",      [f,f,f,f,f,f,f,f,f+1,f+2,f+2,f+2,f+2,f+2,f+2,f+2,f+2,f+1,f+1,f+1])
        f = f + 4
        s.addAnimation("walk down",     [f,f,f,f+1,f+1,f+1,f+2,f+2,f+2,f+3,f+3,f+3])
        f = f + 4
        s.addAnimation("walk side",     [f,f,f,f+1,f+1,f+1,f+2,f+2,f+2,f+3,f+3,f+3])
        f = f + 4
        s.addAnimation("walk up",       [f,f,f,f+1,f+1,f+1,f+2,f+2,f+2,f+3,f+3,f+3])
        f = f + 4
        s.addAnimation("attack down",   [f,f,f,f+1,f+1,f+1,f+2,f+2,f+2,f+3,f+3,f+3])
        f = f + 4
        s.addAnimation("attack side",   [f,f,f,f+1,f+1,f+1,f+2,f+2,f+2,f+3,f+3,f+3])
        f = f + 4
        s.addAnimation("attack up",     [f,f,f,f+1,f+1,f+1,f+2,f+2,f+2,f+3,f+3,f+3])
        f = f + 4
        s.addAnimation("pain down",     [f,f,f,f+1,f+1,f+1,f+2,f+2,f+2,f+3,f+3,f+3])
        f = f + 4
        s.addAnimation("pain side",     [f,f,f,f+1,f+1,f+1,f+2,f+2,f+2,f+3,f+3,f+3])
        f = f + 4
        s.addAnimation("pain up",       [f,f,f,f+1,f+1,f+1,f+2,f+2,f+2,f+3,f+3,f+3])
        */

        s.playAnimation("idle")
        s.randomizeFrame(__random)
        s.flags = Render.spriteCenter
        entity.addComponent(t)
        entity.addComponent(s)        
        entity.addComponent(tl)
        return entity
    }

    static hero(x, y) {
        var entity = character(x, y, "[game]/assets/Creatures/Space Sargent/SpaceSargentIdle.png")
        var h = Hero.new()
        entity.addComponent(h)
        entity.tag = Type.player
        entity.name = "H%(nextID)"
        return entity
    }

    static monster(x, y) {
        var entity = character(x, y, "[game]/assets/Creatures/SwarmAlien/SwarmAlienIdle.png")
        var s = Monster.new()
        entity.addComponent(s)
        entity.tag = Type.enemy
        entity.name = "S%(nextID)"
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
        var s = GridSprite.new("[game]/assets/tiles_dungeon.png", 20, 24)
        s.idx = 368
        var tl = Tile.new(x, y)
        s.flags = Render.spriteCenter
        entity.addComponent(t)
        entity.addComponent(s)        
        entity.addComponent(tl)
        entity.tag = Type.wall
        entity.name = "C%(nextID)"
        return entity
    }
    
    static pillar(x, y, fire) {
        {   // Pillar 
            var entity = Entity.new()
            var pos = Level.calculatePos(x, y) + Vec2.new(0, Level.tileSize / 2)
            var t = Transform.new(pos)
            var s = GridSprite.new("[game]/assets/tiles_dungeon.png", 20, 12)
            if(fire) {
                s.idx = 185
            } else {
                s.idx = 187
            }
            var tl = Tile.new(x, y)
            s.flags = Render.spriteCenter
            entity.addComponent(t)
            entity.addComponent(s)        
            entity.addComponent(tl)
            entity.tag = Type.wall
            entity.name = "P%(nextID)"
        }
        if(fire){
            var entity = Entity.new()
            var pos = Level.calculatePos(x, y) + Vec2.new(0, Level.tileSize / 2)
            var t = Transform.new(pos)
            var tl = Tile.new(x, y)
            tl.z = 0.1
            var s = AnimatedSprite.new("[game]/assets/tiles_dungeon.png", 20, 12, 5)
            s.addAnimation("burn", [180, 181, 182, 183])
            s.playAnimation("burn")
            s.mode = AnimatedSprite.loop
            s.flags = Render.spriteCenter
            entity.addComponent(t)
            entity.addComponent(tl)
            entity.addComponent(s)        
            entity.name = "F%(nextID)"
            entity.tag = Type.light
        }
    }

    static wallTorch(x, y) {
        var entity = Entity.new()
        var pos = Level.calculatePos(x, y) + Vec2.new(0, Level.tileSize / 2)
        var t = Transform.new(pos)
        var tl = Tile.new(x, y)
        tl.z = 0.1
        var s = AnimatedSprite.new("[game]/assets/tiles_dungeon.png", 20, 12, 5)
        s.addAnimation("burn", [180, 181, 182, 183])
        s.playAnimation("burn")
        s.mode = AnimatedSprite.loop
        s.flags = Render.spriteCenter
        entity.addComponent(t)
        entity.addComponent(tl)
        entity.addComponent(s)        
        entity.name = "T%(nextID)"
        entity.tag = Type.light
    }

    static something(x, y) {
        return null
        var entity = Entity.new()
        var t = Transform.new(Level.calculatePos(x, y))
        var s = GridSprite.new("[game]/assets/tiles_dungeon.png", 20, 24)
        var stuff = [356, 357, 358, 396, 397, 398]
        var idx = __random.int(0, stuff.count)
        s.idx = stuff[idx]
        var tl = Tile.new(x, y)
        s.flags = Render.spriteCenter
        entity.addComponent(t)
        entity.addComponent(s)        
        entity.addComponent(tl)
        entity.tag = Type.wall
        entity.name = "F%(nextID)"
        return entity
    }

    static treasure(x, y) {
        var entity = Entity.new()
        var t = Transform.new(Level.calculatePos(x, y))
        var s = GridSprite.new("[game]/assets/tiles_dungeon.png", 20, 24)
        s.idx = 354
        var tl = Tile.new(x, y)
        s.flags = Render.spriteCenter
        entity.addComponent(t)
        entity.addComponent(s)        
        entity.addComponent(tl)
        entity.tag = Type.wall | Type.light
        entity.name = "F%(nextID)"
        return entity
    }

    static door(x, y, vertical) {
        var entity = Entity.new()
        var t = Transform.new(Level.calculatePos(x, y))
        var s = GridSprite.new("[game]/assets/tiles_dungeon.png", 20, 24)
        s.idx = vertical ? 235 : 234
        var tl = Tile.new(x, y)
        s.flags = Render.spriteCenter
        entity.addComponent(t)
        entity.addComponent(s)        
        entity.addComponent(tl)
        entity.tag = Type.door
        entity.name = "F%(nextID)"
        return entity
    }

    static healthbar() {
        {
            var entity = Entity.new()
            var t = Transform.new(Vec2.new(-152, 65))
            var s = Sprite.new("[game]/assets/health_bar_decoration.png")
            s.layer = 10000
            s.flags = Render.spriteOverlay
            entity.addComponent(t)
            entity.addComponent(s)        
            entity.name = "HealthbarBg %(nextID)"
        }
        {
            var entity = Entity.new()
            var t = Transform.new(Vec2.new(-138, 65))
            var s = GridSprite.new("[game]/assets/health_bar.png", 1, 11)
            s.layer = 10001
            s.flags = Render.spriteOverlay
            var h = Healthbar.new()
            entity.addComponent(t)
            entity.addComponent(s) 
            entity.addComponent(h)        
            entity.name = "Healthbar %(nextID)"
            return entity
        }
    }
}

import "gameplay" for Hero, Monster, Tile, Level, Camera