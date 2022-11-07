import "xs" for Data, Input, Render
import "xs_math" for Vec2, Math
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

        // Init all tiles to floow
        for (x in 0...width) {
            for (y in 0...height) {
                Level[x, y] = Type.floor
            }
            Fiber.yield(shortBrake)
        }

        // Top and bottom to wall
        for (x in 0...width) {
            Level[x, 0] = Type.wall
            Level[x, height-1] = Type.wall
            Fiber.yield(shortBrake)
        }

        // Left and right edge to wall
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

    static debugRender() {}
}

class Walker {
    construct new(position, direction, random) {
        _position = position
        _direction = direction
        _random = random
        _steps = 0
        Level[_position] = Type.floor
    }

    direction { _direction }
    direction=(d) { _direction = d }
    position { _position }
    position=(p) { _position = p }

    walk() {
        _steps = _steps + 1
        var turn = _random.float(0.0, 1.0) < 0.2
        if(turn) {
            _direction = _random.float(0.0, 1.0) < 0.5 ?
                _direction = Math.mod(_direction + 1, 4) :
                _direction = Math.mod(_direction - 1, 4)
        }
        _position = _position + Directions[_direction]
        if(inBounds && _steps < 39) {
            Level[_position] = Type.floor
            Level[-_position.x, _position.y] = Type.floor
            if( turn &&
                Gameplay.getFlags(_position.x, _position.y) == Type.floor &&
                _random.float(0.0, 1.0) < 0.25) {
                Create.something(_position.x, _position.y)
            }
            return true
        } else {
            _position = _position - Directions[_direction]
            Create.treasure(_position.x, _position.y)
            return false
        }
    }

    inBounds { _position.x > 0 && _position.x < Level.width - 1 && _position.y > 0 && _position.y < Level.height - 1 }
}

class RandomWalk {
    static generate() {
        __random = Random.new()
        
        for (x in 0...Level.width) {
            for (y in 0...Level.height) {
                Level[x, y] = Type.wall
            }
        }

        for(i in 0..5) {
            var wlk = Walker.new(Vec2.new(
                Level.width / 2 - 1,
                (Level.height / 2).round),
                __random.int(0, 5), __random)

            while(wlk.walk()) {
                Fiber.yield(0.0)
            }
        }
        
        postProcess()

        {
            var pos = findFree()
            Create.hero(pos.x, pos.y)        
        }

        for(i in 1..8) {
            var pos = findFree()
            Create.monster(pos.x, pos.y)
            Fiber.yield(0.0)
        }

        return 0.0
    }
    
    static postProcess() {
        var brake = Data.getNumber("Short Brake")
        var rem = []        
        for (x in 0...Level.width) {
            for (y in 0...Level.height) {
                var found = true
                for (nx in x-1..x+1) {
                    for (ny in y-1..y+1) {
                        if(Level.contains(nx, ny)) {
                            if(Level[nx, ny] != Type.wall) {
                                found = false
                            }
                        }
                    }
                }
                if(found) {
                    rem.add(Vec2.new(x, y))                    
                }
            }
        }

        var count = 0
        for(r in rem) {
            Level[r.x, r.y] = Type.empty
            count = count + 1
            if(count % 10 == 0) {
                Fiber.yield(brake)
            }
        }

        rem.clear()
        
        for (x in 1...Level.width - 1) {
            for (y in 1...Level.height - 1) {
                if(Level[x, y] == Type.wall) {
                    if( Level[x - 1, y] == Type.floor &&
                        Level[x + 1, y] == Type.floor &&
                        Level[x, y - 1] == Type.floor &&
                        Level[x, y + 1] == Type.floor) {
                        Create.pillar(x,y, true)
                        rem.add(Vec2.new(x, y))
                    }                     
                }                
            }
        }

        for (x in 1...Level.width - 1) {
            for (y in 1...Level.height - 1) {
                if(Level[x, y] == Type.wall) {
                    if(Level[x - 1, y] == Type.floor && Level[x + 1, y] == Type.floor) {
                        rem.add(Vec2.new(x, y))    
                    } 
                    if(Level[x, y - 1] == Type.floor && Level[x, y + 1] == Type.floor) {
                        rem.add(Vec2.new(x, y))    
                    } 
                }                
            }
        }      

        for(r in rem) {
            Level[r.x, r.y] = Type.floor
            Fiber.yield(brake)
        }  
    }

    static findFree() {        
        for(i in 1...100) {
            var x = __random.int(1, Level.width - 1)
            var y = __random.int(1, Level.height - 1)
            if(Level.contains(x, y) && Level[x, y] == Type.floor && Tile.get(x,y).count == 0) {
                return Vec2.new(x,y)
            }
        }
    }

    static debugRender() {}
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


// Binary space partitioning based generator
class BSPer {
    static generate() {        
        __random = Random.new()
        __rooms = []
        __halls = []
        __colors = [ // Debug colors
            0x4d89f280, 0x2feff980, 0xed3bf980, 0x473bd380,
            0x72ffa180, 0x5c720180, 0xf25ca480, 0xe25dce80]

        var brake = Data.getNumber("Long Brake")

        // Start will walls everywhere
        for (x in 0...Level.width) {
            for (y in 0...Level.height) {
                Level[x, y] = Type.wall
            }
            Fiber.yield(0.0)
        }        

        Data.setBool("Debug Draw", true, Data.debug)

        // Split the whole level (recursively) to room
        split(Vec2.new(0, 0), Vec2.new(Level.width, Level.height))

        makeRooms()     // Carve out the rooms
        Data.setBool("Debug Draw", false, Data.debug)
        makeHalls()     // Connect the rooms
        postProcess()   // Remove extra wall tiles
        addHero()       // Put our player on the map
        fillRoms()      // Add stuff to the rooms

        return 0.0      // We done here
    }

    // Recurively split the space until is small enough for a 
    static split(from, to) {
        var shortBrake = Data.getNumber("Short Brake")
        var longBrake = Data.getNumber("Long Brake")
        var padd = 4 // Leave this much on both sides when cutting
        var dx = to.x - from.x
        var dy = to.y - from.y

        if(dx > 11 || dy > 11) { // Room is too big, cut in half
            if(dx >= dy) {  // Horizontal split
                var spl = __random.int(from.x + padd, to.x - padd)                  // Rand split along x
                __halls.add(Rect.new(Vec2.new(spl, from.y), Vec2.new(spl, to.y)))   // Add divide for a hall later
                split(from, Vec2.new(spl, to.y))                                    // Split left room (if needed)
                split(Vec2.new(spl, from.y), to)                                    // Split right room (if needed)
            } else {    // Vertical split
                var spl = __random.int(from.y + padd, to.y - padd)                  // Rand split along y
                __halls.add(Rect.new(Vec2.new(from.x, spl), Vec2.new(to.x, spl)))   // Add divide for a hall later
                split(from, Vec2.new(to.x, spl))                                    // Split bottom room (if needed)
                split(Vec2.new(from.x, spl), to)                                    // Split top room (if needed)
            }
        } else { // Room is small enough
            var rect = Rect.new(from, to)
            System.print("add room: %(rect)")
            __rooms.add(rect) // Save room
            Fiber.yield(longBrake)
        }
    }

    static makeRooms() {
        var brake = Data.getNumber("Long Brake")
        var min = 6 // Don't make small rooms smaller
        for(room in __rooms) {
            // Room size [dx, dy]
            var dx = room.to.x - room.from.x
            var dy = room.to.y - room.from.y
            // Calc from and to with an inset

            room.from.x = dx > min ? room.from.x + inset : room.from.x + 1
            room.to.x   = dx > min ? room.to.x   - inset : room.to.x   - 1
            room.from.y = dy > min ? room.from.y + inset : room.from.y + 1
            room.to.y   = dy > min ? room.to.y   - inset : room.to.y   - 1

            // Carve out rooms
            for (x in room.from.x...room.to.x) {
                for (y in room.from.y...room.to.y) {
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
            var dir = hall.to - hall.from
            var len = dir.magnitude.round
            dir = dir.normalise
            dir = dir.perp

            var list = List.new() 
            list.addAll(0...len)
            while(list.count > 0) {
                var i = list.removeAt((list.count / 2).floor)
                var mid = Math.lerp(hall.from, hall.to, i / len)
                mid.x = mid.x.round
                mid.y = mid.y.round
                var up = mid + dir * -3
                var down = mid + dir * 3
                if( Level[up.x, up.y] == Type.floor &&
                    Level[down.x, down.y] == Type.floor) {
                    for(j in -2..2) {
                        var pos = mid + dir * j
                        pos.x = pos.x.round
                        pos.y = pos.y.round
                        Level[pos.x, pos.y] = Type.floor
                    }
                    break
                }
            }
            Fiber.yield(brake)                    
        }
    }

    static postProcess() {
        var brake = Data.getNumber("Short Brake")
        var rem = []
        for (x in 0...Level.width) {
            for (y in 0...Level.height) {
                var found = true
                for (nx in x-1..x+1) {
                    for (ny in y-1..y+1) {
                        if(Level.contains(nx, ny)) {
                            if(Level[nx, ny] != Type.wall) {
                                found = false
                            }
                        }
                    }
                }
                if(found) {
                    rem.add(Vec2.new(x, y))                    
                }
            }
        }

        for(r in rem) {
            Level[r.x, r.y] = Type.empty
            Fiber.yield(brake)
        }
    }

    static addHero() {
        var room = __rooms[0]
        var pos = findFree(room)
        Create.hero(pos.x, pos.y)
    }

    static fillRoms() {
        var brake = Data.getNumber("Short Brake")
        for(room in __rooms) {
            var dx = room.to.x - room.from.x
            var dy = room.to.y - room.from.y
            var area = dx * dy

            var stuff = area / 26
            for(i in 0...stuff) {
                var pos = findFree(room)
                Create.something(pos.x, pos.y)
                Fiber.yield(brake)
            }

            var monsters = area / 18
            for(i in 0...monsters) {
                var pos = findFree(room)
                Create.monster(pos.x, pos.y)
                Fiber.yield(brake)
            }


            var lightable = []
            for(x in room.from.x...room.to.x) {
                if(Level[x, room.to.y] == Type.wall) {
                    lightable.add(x)
                }
            }

            if(lightable.count <= 5 && lightable.count > 0) {
                System.print("lightable.count: %(lightable.count)")
                var x = lightable[(lightable.count / 2 - 1).round ]
                Create.wallTorch(x, room.to.y)    
            } else {
                var xl = lightable[(lightable.count / 2 - 1).round - 2]
                var xr = lightable[(lightable.count / 2 - 1).round + 2]
                Create.wallTorch(xl, room.to.y)
                Create.wallTorch(xr, room.to.y)
            }
            
            Fiber.yield(brake)
        }
    }

    static findFree(rect) {
        for(i in 1...100) {
            var x = __random.int(rect.from.x, rect.to.x)
            var y = __random.int(rect.from.y, rect.to.y)
            if(Level.contains(x, y) && Level[x, y] == Type.floor && Tile.get(x,y).count == 0) {
                return Vec2.new(x,y)
            }
        }
    }


    static debugRender() {
        var dbg = Data.getBool("Debug Draw", Data.debug)
        if(!dbg) {
            return
        }
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

        for(hall in __halls) {         
            var color = __colors[(hall.from.x + hall.from.y + hall.to.x + hall.to.y) % __colors.count]
            Render.setColor(color | 0x000000FF) // Make opaque |
            var from = Level.calculatePos(
                hall.from.x,
                hall.from.y) + off
            var to = Level.calculatePos(
                hall.to.x,
                hall.to.y) + off                        
            Render.line(from.x, from.y, to.x, to.y)            
        }
    }

    static inset { __random.int(1, 3) }    
}

import "create" for Create
import "gameplay" for Gameplay