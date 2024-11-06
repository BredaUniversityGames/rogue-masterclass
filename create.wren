import "xs" for Data, Input, Render
import "xs_math"for Math, Bits, Vec2, Color
import "xs_ec"for Entity, Component
import "xs_components" for Transform, Body, Renderable, Sprite, GridSprite, AnimatedSprite
import "xs_tools" for Tools
import "random" for Random
import "types" for Type

/// This class is used to create entities in the game
/// by adding components to them
/// As a game programming pattern, it is a factory class
class Create {

    static initialize() {
        __random = Random.new()
        __id = 0

        // Create a list of all the types of monsters
        __monsterNames = {
            Type.bat: "Bat",
            Type.spider: "Spider",
            Type.ghost: "Ghost",
            Type.boss: "Boss",
            Type.scorpion: "Scorpion",
            Type.snake: "Snake"
        }
        __monsterStats = {
            Type.bat: Stats.new(1, 1, 0, 0.2),
            Type.spider: Stats.new(1, 1, 0, 0.5),
            Type.ghost: Stats.new(2, 1, 0, 0.5),
            Type.boss: Stats.new(4, 1, 0, 1),
            Type.scorpion: Stats.new(1, 1, 1, 0.2),
            Type.snake: Stats.new(1, 2, 0, 0.75)
        }
        __itemNames = {
            Type.helmet: "Helmet",
            Type.armor: "Armor",
            Type.sword: "Sword",
            Type.food: "Food"
        }
        __itemStats = {
            Type.helmet: Stats.new(0, 0, 1, 0),
            Type.armor: Stats.new(0, 0, 2, 0),
            Type.sword: Stats.new(0, 1, 0, 0),
            Type.food: Stats.new(1, 0, 0, 0)
        }
    }

    static character(x, y) {
        var entity = Entity.new()
        var t = Transform.new(Level.calculatePos(x, y))
        var tl = Tile.new(x, y)
        entity.add(t)
        entity.add(tl)
        return entity
    }

    static hero(x, y) {
        var entity = character(x, y)
        var h = Hero.new()
        entity.add(h)
        var s = Stats.new(10, 1, 0, 0)
        entity.add(s)
        entity.tag = Type.player
        entity.name = "Hero"
        return entity
    }

    static monster(x, y) {
        var entity = character(x, y)
        var m = Monster.new()
        entity.add(m)
        var type = Tools.pickOne([
            Type.bat, Type.spider, Type.ghost,
            Type.boss, Type.scorpion, Type.snake])
        var s = __monsterStats[type].clone()
        entity.add(s)
        entity.tag = type
        entity.name = __monsterNames[type]
        return entity
    }

    static item(x, y) {
        var entity = Entity.new()
        var tl = Transform.new(Level.calculatePos(x, y))
        entity.add(tl)
        var t = Tile.new(x, y)
        entity.add(t)
        var type = Tools.pickOne([
            Type.helmet, Type.armor, Type.sword, Type.food])
        entity.tag = type
        entity.name = __itemNames[type]
        return entity
    }

    static nextID {
        __id = __id + 1
        return __id
    }

    /*
    static spikes() {}

    static stairs() {}

    static crate() {
        var entity = Entity.new()
        var t = Transform.new(Level.calculatePos(x, y))
        var tl = Tile.new(x, y)
        s.flags = Render.spriteCenter
        entity.add(t)
        entity.add(tl)
        entity.tag = Type.wall
        entity.name = "C%(nextID)"
        return entity
    }
    
    static pillar(x, y, fire) {
        var entity = Entity.new()
        var pos = Level.calculatePos(x, y) + Vec2.new(0, Level.tileSize / 2)
        var t = Transform.new(pos)
        var tl = Tile.new(x, y)
        entity.add(t)
        entity.add(tl)
        entity.tag = Type.wall
        entity.name = "P%(nextID)"
    }

    static wallTorch(x, y) {
        var entity = Entity.new()
        var pos = Level.calculatePos(x, y) + Vec2.new(0, Level.tileSize / 2)
        var t = Transform.new(pos)
        var tl = Tile.new(x, y)
        tl.z = 0.1
        entity.add(t)
        entity.add(tl)
        entity.name = "T%(nextID)"
        entity.tag = Type.light
    }

    static something(x, y) {
        var entity = Entity.new()
        var t = Transform.new(Level.calculatePos(x, y))
        var tl = Tile.new(x, y)
        entity.add(t)
        entity.add(tl)
        entity.tag = Type.wall
        entity.name = "S%(nextID)"
        return entity
    }

    static treasure(x, y) {
        var entity = Entity.new()
        var t = Transform.new(Level.calculatePos(x, y))
        var tl = Tile.new(x, y)
        s.flags = Render.spriteCenter
        entity.add(t)
        entity.add(tl)
        entity.tag = Type.wall | Type.light
        entity.name = "F%(nextID)"
        return entity
    }

    static door(x, y, vertical) {
        var entity = Entity.new()
        var t = Transform.new(Level.calculatePos(x, y))
        var tl = Tile.new(x, y)
        entity.add(t)
        entity.add(tl)
        entity.tag = Type.door
        entity.name = "F%(nextID)"
        return entity
    }
    */
}

import "gameplay" for Hero, Monster, Tile, Level, Stats