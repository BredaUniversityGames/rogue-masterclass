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
            Create.monster(pos.x, pos.y)
            Fiber.yield(longBrake)
        }
        return 0.0
    }

    static findFree(random) {        
        for(i in 1...100) {
            var x = random.int(1, Level.width - 1)
            var y = random.int(1, Level.height - 1)
            if(Level.contains(x, y) && Level[x, y] == Type.floor && Tile.get(x,y).count == 0) {
                return Vec2.new(x,y)
            }
        }
    }
}

class Walker {
    construct new(position, direction) {
        _position = position
        _direction = direction
    }

    direction { _direction }
    direction=(d) { _direction = d }
    position { _position }
    position=(p) { _position = p }
}

class RandomWalk {

    static walk(wlaker) {   // Step?

    }

    static generate() {
        var random = Random.new()

        //var level = 9

        var shortBrake = Data.getNumber("Short Brake")
        var longBrake = Data.getNumber("Long Brake")
        var width = Level.width
        var height = Level.height

        for (x in 0...width) {
            for (y in 0...height) {
                Level[x, y] = Type.floor
            }
        }

        for (y in 0...height) {
            Level[0, y] = Type.wall
            Level[width-1, y] = Type.wall
        }

        var hw = (width / 2).round - 1
        var hh = (height / 2).round - 1
        for(i in 0...5) {
            var x = random.int(1, hw)
            var y = random.int(1, hh)
            Level[x + hw, y + hh] = Type.wall
            Level[x + hw, hh - y] = Type.wall 
            Level[hw - x, y + hh] = Type.wall
            Level[hw - x, hh - y] = Type.wall
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

                        Level[x + hw, hh - y] = Type.floor
                        Create.pillar(x + hw, hh - y, fire)

                        Level[hw - x, y + hh] = Type.floor
                        Create.pillar(hw - x, y + hh, fire)

                        Level[hw - x, hh - y] = Type.floor
                        Create.pillar(hw - x, hh - y, fire)

                        fire = false
                    }
                }                
            }            
        }

        for(i in 0...5) {
            var pos = findFree(random)
            Create.something(pos.x, pos.y)
        }

        Create.hero(hw, hh)

        Create.door(hw, Level.height - 1, false)
        Level[hw, Level.height - 1] = Type.floor

        Create.door(0, hh, true)
        Level[0, hh] = Type.floor

        Create.door(Level.width - 1, hh, true)
        Level[Level.width - 1, hh] = Type.floor

        for(i in 0...level) {
            var pos = findFree(random)
            Create.monster(pos.x, pos.y)
        }
        return 0.0
    }

    static findFree(random) {        
        for(i in 1...100) {
            var x = random.int(1, Level.width - 1)
            var y = random.int(1, Level.height - 1)
            if(Level.contains(x, y) && Level[x, y] == Type.floor && Tile.get(x,y).count == 0) {
                return Vec2.new(x,y)
            }
        }
    }
}


class BSPer {
    static generate() {
        var random = Random.new()
        // var level = 9
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

        split(  Vec2.new(0, 0),
                Vec2.new(Level.width, Level.height),
                random)

        return 0.0
    }

    static split(from, to, random) {
        var shortBrake = Data.getNumber("Short Brake")
        var longBrake = Data.getNumber("Long Brake")
        var padd = 3 //Data.getNumber("Offest")
        Fiber.yield(shortBrake)

        var dx = to.x - from.x
        var dy = to.y - from.y

        if(dx >= dy && dx > 8) {
            var spl = random.int(from.x + padd, to.x - padd)

            //var spl = (from.x + dx / 2).round
            for (y in from.y...to.y) {
                Level[spl, y] = Type.wall
            }
            split(  from, Vec2.new(spl, to.y), random)
            split(  Vec2.new(spl, from.y), to, random)

        } else if(dy > 8) {
            //var spl = (from.y + dy / 2).round
            var spl = random.int(from.y + padd, to.y - padd)
            for (x in from.x...to.x) {
                Level[x, spl] = Type.wall                
            }
            split(  from, Vec2.new(to.x, spl), random)
            split(  Vec2.new(from.x, spl), to, random)
        } else {
            // Room is small enough
            decorate(from, to, random)
        } 
    }

    static decorate(from, to, random) {

    }
}

import "create" for Create