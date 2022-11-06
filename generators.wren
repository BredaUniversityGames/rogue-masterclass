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

        Create.camera()

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

        Create.camera()

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


class Rect {
    construct new(from, to) {
        _from = from
        _to = to
    }

    toString { "[%(from.x),%(from.y)]-[%(to.x),%(to.y)]" }

    from { _from }
    to { _to }
}


class BSPer {
    static generate() {        
        __random = Random.new()
        __rooms = []
        __halls = []
        __colors = [
            0x4d89f280, 0x2feff980, 0xed3bf980, 0x473bd380,
            0x72ffa180, 0x5c720180, 0xf25ca480, 0xe25dce80]

        var shortBrake = Data.getNumber("Short Brake")
        var longBrake = Data.getNumber("Long Brake")
        var width = Level.width
        var height = Level.height

        for (x in 0...width) {
            for (y in 0...height) {
                Level[x, y] = Type.wall
            }
            //Fiber.yield(shortBrake)
        }

        for (x in 0...width) {
            Level[x, 0] = Type.wall
            Level[x, height-1] = Type.wall
            //Fiber.yield(shortBrake)
        }

        for (y in 0...height) {
            Level[0, y] = Type.wall
            Level[width-1, y] = Type.wall
            //Fiber.yield(shortBrake)
        }

        Fiber.yield(longBrake)
        var rooms = []
        split(  Vec2.new(0, 0),
                Vec2.new(Level.width, Level.height))

        makeRooms()
        makeHalls()

        return 0.0
    }

    static split(from, to) {
        var shortBrake = Data.getNumber("Short Brake")
        var longBrake = Data.getNumber("Long Brake")
        var padd = 4 //Data.getNumber("Offest")
        // Fiber.yield(shortBrake)

        var dx = to.x - from.x
        var dy = to.y - from.y

        // Render.rect(from.x, from.y, to.x, to.y)        

        if(dx > 11 || dy > 11) {
            if(dx >= dy) {
                var spl = __random.int(from.x + padd, to.x - padd)                
                var mid = ((from.y + to.y) / 2).round
                __halls.add(Rect.new(Vec2.new(spl-2, mid - 1), Vec2.new(spl+2, mid)))
                split(  from, Vec2.new(spl, to.y))
                split(  Vec2.new(spl, from.y), to)                
            } else {
                var spl = __random.int(from.y + padd, to.y - padd)
                var mid = ((from.x + to.x) / 2).round
                __halls.add(Rect.new(Vec2.new(mid - 1, spl - 2), Vec2.new(mid, spl + 2)))
                split(  from, Vec2.new(to.x, spl))
                split(  Vec2.new(from.x, spl), to)                
            }
        } else {
            var rect = Rect.new(from, to)
            System.print("add room: %(rect)")
            __rooms.add(rect)
            Fiber.yield(longBrake)
            // Room is small enough
            // decorate(from, to)
        }
    }

    static makeRooms() {
        var brake = Data.getNumber("Long Brake")
        var min = 6
        for(room in __rooms) {                 
            var dx = room.to.x - room.from.x
            var dy = room.to.y - room.from.y
            var fx = dx > min ? room.from.x + inset : room.from.x + 1
            var tx = dx > min ? room.to.x   - inset : room.to.x   - 1
            var fy = dy > min ? room.from.y + inset : room.from.y + 1
            var ty = dy > min ? room.to.y   - inset : room.to.y   - 1            
            for (x in fx...tx) {
                for (y in fy...ty) {
                    Level[x, y] = Type.floor
                }                
            }    
            Fiber.yield(brake)                    
        }

        System.print("rooms: %(__rooms.count)")
    }

    static makeHalls() {
        var brake = Data.getNumber("Long Brake")
        for(hall in __halls) {
            var fx = hall.from.x
            var fy = hall.from.y
            var tx = hall.to.x
            var ty = hall.to.y

            for (x in fx...tx) {
                for (y in fy...ty) {
                    Level[x, y] = Type.floor
                }                
            }    
            Fiber.yield(brake)                    
        }
    }



    static debugRender() {
        var dbg = Data.getBool("Debug Draw", Data.debug)
        if(!dbg) {
            return
        }
        //System.print("rooms: %(__rooms.count)")        
        var off = Vec2.new(Level.tileSize, Level.tileSize) * -0.5
        for(room in __rooms) {         
            var color = __colors[(room.from.x + room.from.y + room.to.x + room.to.y) % __colors.count]
            Render.setColor(color)

            var from = Level.calculatePos(
                room.from.x,
                room.from.y) + off
            var to = Level.calculatePos(
                room.to.x,
                room.to.y) + off                        
            Render.rect(from.x + 1, from.y + 1, to.x - 1, to.y- 1)
        }

        // System.print("halls: %(__halls.count)")
        for(hall in __halls) {         
            var color = __colors[(hall.from.x + hall.from.y + hall.to.x + hall.to.y) % __colors.count]
            Render.setColor(color)

            var from = Level.calculatePos(
                hall.from.x,
                hall.from.y) + off
            var to = Level.calculatePos(
                hall.to.x,
                hall.to.y) + off                        
            Render.rect(from.x, from.y, to.x, to.y)
        }
    }

    static inset { __random.int(1, 3) }

    //static inset { 1 }


    static decorate(from, to) {}
}

import "create" for Create