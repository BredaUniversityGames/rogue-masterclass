import "xs" for Data, Input, Render
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

        Create.hero(hw, hh)
        Fiber.yield(longBrake)

        for(i in 0...level) {
            var found = false
            while(!found) {
                var x = random.int(0, width)
                var y = random.int(0, height)
                if(Level.isValidPosition(x, y) && Level[x, y] == Type.floor) {
                    Create.slime(x, y)
                    found = true
                    Fiber.yield(longBrake)
                }
            }
        }
        return 0.0
    }
}

import "create" for Create