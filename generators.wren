import "xs" for Data, Input, Render
import "xs_math" for Vec2, Math
import "gameplay" for Level, Tile
import "types" for Type
import "directions" for Directions
import "random" for Random

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
class BSP {
    static generate() {        
        __random = Random.new()
        __rooms = []
        __halls = []
        __colors = [ // Debug colors
            0x4d89f280, 0x2feff980, 0xed3bf980, 0x473bd380,
            0x72ffa180, 0x5c720180, 0xf25ca480, 0xe25dce80]
        __tilesImage = Render.loadImage("[game]/assets/Tileset/DerelictTileset.png")

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
        // Data.setBool("Debug Draw", false, Data.debug)
        makeHalls()     // Connect the rooms
        //postProcess()   // Remove extra wall tiles
        addHero()       // Put our player on the map
        // fillRoms()      // Add stuff to the rooms

        return 0.0      // We done here
    }

    // Recurively split the space until is small enough for a 
    static split(from, to) {
        var shortBrake = Data.getNumber("Short Brake")
        var longBrake = Data.getNumber("Long Brake")
        var paddx = 5 // Leave this much on both sides when cutting
        var paddy = 7 // Leave this much on both sides when cutting
        var dx = to.x - from.x
        var dy = to.y - from.y

        if(dx > 13 || dy > 15) { // Room is too big, cut in half
            if(dx >= dy) {  // Horizontal split
                var spl = __random.int(from.x + paddx, to.x - paddx)                  // Rand split along x
                __halls.add(Rect.new(Vec2.new(spl, from.y), Vec2.new(spl, to.y)))   // Add divide for a hall later
                split(from, Vec2.new(spl, to.y))                                    // Split left room (if needed)
                split(Vec2.new(spl, from.y), to)                                    // Split right room (if needed)
            } else {    // Vertical split
                var spl = __random.int(from.y + paddy, to.y - paddy)                  // Rand split along y
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
            room.from.x = room.from.x + 1
            room.to.x   = room.to.x == Level.width ? room.to.x - 1 : room.to.x
            room.from.y = room.from.y + 1
            room.to.y   = room.to.y == Level.height ? room.to.y - 1 : room.to.y
            // room.to.y   = room.to.y - 2

            // Carve out rooms
            for (x in room.from.x...room.to.x) {
                for (y in room.from.y...room.to.y) {
                    Level[x, y] = Type.floor
                }                
            }

            /*
            for (x in room.from.x...room.to.x) {
                for (y in (room.from.y - 2)...room.to.y) {
                    //Level[x, y] = Type.panel
                }                
            }
            */
            Fiber.yield(brake)                    
        }

        System.print("rooms: %(__rooms.count)")
    }

    static makeHalls() {
        var brake = Data.getNumber("Long Brake")
        for(hall in __halls) {
            var perp = hall.to - hall.from
            var len = perp.magnitude.round
            perp = perp.normalise
            var dir = perp.perp

            var list = List.new() 
            list.addAll(0...len)
            while(list.count > 0) {
                var i = list.removeAt((list.count / 2).floor)
                var mid = Math.lerp(hall.from, hall.to, i / len)
                mid.x = mid.x.round
                mid.y = mid.y.round
                var midp = mid + perp
                var up = mid + dir * -1
                var down = mid + dir * 1
                var upp = midp + dir * -1
                var downp = midp + dir * 1
                if( Level[up.x, up.y] == Type.floor &&
                    Level[down.x, down.y] == Type.floor &&
                    Level[upp.x, upp.y] == Type.floor &&
                    Level[downp.x, downp.y] == Type.floor) {
                        Level[mid.x, mid.y] = Type.floor
                        Level[midp.x, midp.y] = Type.floor
                    break
                }
            }
            Fiber.yield(brake)                    
        }
    }

    static awesomize() {
        return

        for (x in 0...Level.width) {
            for (y in 0...Level.height - 3) {
                var found = true
                if( Level[x, y] == Type.floor &&
                    Level[x, y + 1] == Type.wall &&
                    Level[x, y + 2] == Type.wall &&
                    Level[x, y + 3] == Type.wall) {

                    var w = Render.createGridSprite(__tilesImage, 21, 43, 134)
                    Level.pretty[x, y + 1] = w
                    Level.pretty[x, y + 2] = w
                }
            }
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
}

import "create" for Create
import "gameplay" for Gameplay