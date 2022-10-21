import "xs" for Data, Input, Render
import "xs_math" for Vec2
import "gameplay" for Level, Tile
import "types" for Type
import "directions" for Directions
import "random" for Random

class Randy {

    static generate() {
        var random = Random.new()
        var level = 9
        var shortBrake = Data.getNumber("Short Brake")
        var longBrake = Data.getNumber("Long Brake")
        var width = Level.width
        var height = Level.height

        for (x in 0...width) {
            for (y in 0...height) {
                Level[x, y] = Type.floor
            }
            Fiber.yield(shortBrake)
        }

        for (x in 0...width) {
            Level[x, 0] = Type.wall
            Level[x, height-1] = Type.wall
            Fiber.yield(shortBrake)
        }

        for (y in 0...height) {
            Level[0, y] = Type.wall
            Level[width-1, y] = Type.wall
            Fiber.yield(shortBrake)
        }

        var hw = (width / 2).round - 1
        var hh = (height / 2).round - 1
        for(i in 0...5) {
            var x = random.int(1, hw)
            var y = random.int(1, hh)
            Level[x + hw, y + hh] = Type.wall
            Fiber.yield(longBrake)
            Level[x + hw, hh - y] = Type.wall
            Fiber.yield(longBrake)            
            Level[hw - x, y + hh] = Type.wall
            Fiber.yield(longBrake)
            Level[hw - x, hh - y] = Type.wall
            Fiber.yield(longBrake)
        }

        var fire = true
        for (x in 1...hw) {
            for (y in 1...hh) {
                var px = x + hw
                var py = y + hh
                if(Level[px, py] == Type.wall) {
                    var count = 0                    
                    for (i in -1..1) {
                        for (j in -1..1) {
                            if(Level[px+i, py+j] == Type.wall) {
                                count = count + 1
                            }                            
                        }
                    }
                    if(count == 1) {
                        Level[x + hw, y + hh] = Type.floor
                        Create.pillar(x + hw, y + hh, fire)
                        Fiber.yield(shortBrake)

                        Level[x + hw, hh - y] = Type.floor
                        Create.pillar(x + hw, hh - y, fire)
                        Fiber.yield(shortBrake)            

                        Level[hw - x, y + hh] = Type.floor
                        Create.pillar(hw - x, y + hh, fire)
                        Fiber.yield(shortBrake)

                        Level[hw - x, hh - y] = Type.floor
                        Create.pillar(hw - x, hh - y, fire)
                        Fiber.yield(shortBrake)

                        fire = false
                    }
                }                
            }            
        }

        for(i in 0...5) {
            var pos = findFree(random)
            Create.something(pos.x, pos.y)
            Fiber.yield(shortBrake)
        }

        Create.hero(hw, hh)
        Fiber.yield(shortBrake)

        Create.door(hw, Level.height - 1, false)
        Level[hw, Level.height - 1] = Type.floor
        Fiber.yield(shortBrake)

        Create.door(0, hh, true)
        Level[0, hh] = Type.floor
        Fiber.yield(shortBrake)

        Create.door(Level.width - 1, hh, true)
        Level[Level.width - 1, hh] = Type.floor
        Fiber.yield(shortBrake)

        for(i in 0...level) {
            var pos = findFree(random)
            Create.slime(pos.x, pos.y)
            Fiber.yield(longBrake)
        }
        return 0.0
    }

    static findFree(random) {        
        for(i in 1...100) {
            var x = random.int(1, Level.width - 1)
            var y = random.int(1, Level.height - 1)
            if(Level.isValidPosition(x, y) && Level[x, y] == Type.floor && Tile.get(x,y).count == 0) {
                return Vec2.new(x,y)
            }
        }
    }
}

import "create" for Create