import "xs" for Data, Input, Render
import "xs_math" for Vec2, Math
import "xs_containers" for Queue
import "gameplay" for Level, Tile
import "types" for Type
import "directions" for Directions
import "random" for Random

class SingleRoom {

    static generate(){
        //get some data that we will use later
        var shortBrake = Data.getNumber("Short Brake")
        var longBrake = Data.getNumber("Long Brake")
        var width = Level.width
        var height = Level.height

        // Init all tiles to floor
        for (x in 0...width) {
            for (y in 0...height) {
                Level[x, y] = Type.floor
            }
            Fiber.yield(shortBrake) //Wait for duration "shortBrake"
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

        Fiber.yield(longBrake)      
        
        //create gameplay objects
        Create.monster(15,15)
        Fiber.yield(shortBrake)      
        Create.hero(5,5)

        return 0.0
    }

    //this function is required in the class but you don't need to use/implement it
    static debugRender() {}
}


class Randy {

    static generate() {
        var random = Random.new()
        var level = 9
        var shortBrake = Data.getNumber("Short Brake")
        var longBrake = Data.getNumber("Long Brake")
        var width = Level.width
        var height = Level.height

        // Init all tiles to floor
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

        Create.hero(hw, hh)
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
            if(Level.contains(x, y) && Level[x, y] == Type.floor && Tile.get(x,y) == null) {
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
            if( turn &&
                Gameplay.getFlags(_position.x, _position.y) == Type.floor &&
                _random.float(0.0, 1.0) < 0.25) {
                Create.item(_position.x, _position.y)
            }
            return true
        } else {
            _position = _position - Directions[_direction]
            Create.item(_position.x, _position.y)
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
                        Level[x, y] = Type.floor
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
            if(Level.contains(x, y) && Level[x, y] == Type.floor && Tile.get(x,y) == null) {
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

    contains(point) {
        return point.x >= _from.x && point.x <= _to.x && point.y >= _from.y && point.y <= _to.y
    }

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

        // Split the whole level (recursively) to room
        split(Vec2.new(0, 0), Vec2.new(Level.width, Level.height))

        makeRooms()     // Carve out the rooms
        makeHalls()     // Connect the rooms
        postProcess()   // Remove extra wall tiles
        __graph = createGraph()
        addHero()       // Put our player on the map
        fillRoms()      // Add stuff to the rooms        

        return 0.0      // We done here
    }

    // Recurively split the space until is small enough for a 
    static split(from, to) {
        var shortBrake = Data.getNumber("Short Brake")
        var longBrake = Data.getNumber("Long Brake")
        var maxRoomSize = Data.getNumber("BSP Max Room Size")
        var padd = 4 // Leave this much on both sides when cutting
        var dx = to.x - from.x
        var dy = to.y - from.y

        if(dx > maxRoomSize || dy > maxRoomSize) {                                 // Room is too big, cut in half
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

    static createGraph() {
        var graph = {}
        for(i in 0...__rooms.count) {
            graph[i] = List.new()
        }
        for(hall in __halls) {
            var from = null
            var to = null
            for(i in 0...__rooms.count) {
                var room = __rooms[i]
                if(room.contains(hall.from)) {
                    from = i
                }
                if(room.contains(hall.to)) {
                    to = i
                }
            }
            if(from == null || to == null) {
                System.print("Hall not connected to room")
                continue
            }
            if(from == to) {
                System.print("Hall connects same room")
                continue
            }
            graph[from].add(to)
            graph[to].add(from)
        }
        return graph
    }

    static makeHalls() {
        var brake = Data.getNumber("Long Brake")
        var newHalls = []
        for(hall in __halls) {
            var dir = hall.to - hall.from
            var len = dir.magnitude.round
            dir = dir.normal
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
                    var from = mid + dir * -2
                    var to = mid + dir * 2
                    newHalls.add(Rect.new(from, to))
                    break
                }
            }            
            Fiber.yield(brake)                    
        }
        __halls = newHalls
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
    }

    static fillRoms() {

        // Find the terminal rooms
        var terminalRooms = []
        for(i in 0...__rooms.count) {
            var room = __rooms[i]
            var count = __graph[i].count    // The graph is bidirectional
            if(count == 1) terminalRooms.add(i)
        }

        // Spawn the hero in a random terminal room
        var heroRoom =  __random.sample(terminalRooms)
        var room = __rooms[heroRoom]
        var pos = findFree(room)
        Create.hero(pos.x, pos.y)

        // Get the distance from the hero to all other rooms
        __distances = {}
        var visited = List.new()
        var queue = Queue.new()
        queue.push([heroRoom, 0])
        visited.add(heroRoom)
        while(!queue.empty()) {
            var next = queue.pop()
            __distances[next[0]] = next[1]
            for(neigh in __graph[next[0]]) {
                if(!visited.contains(neigh)) {
                    queue.push([neigh, next[1] + 1])
                    visited.add(neigh)
                }
            }
        }

        //for(i in 0...__rooms.count) {
        //    
        //
        //}

        var brake = Data.getNumber("Short Brake")
        for(room in __rooms) {
            var dx = room.to.x - room.from.x
            var dy = room.to.y - room.from.y
            var area = dx * dy

            /* We could add some stuff here
            var stuff = area / 26
            for(i in 0...stuff) {
                var pos = findFree(room)
                Create.something(pos.x, pos.y)
                Fiber.yield(brake)
            }
            */ 

            var monsters = area * Data.getNumber("Monster Density")
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
            if(Level.contains(x, y) && Level[x, y] == Type.floor && Tile.get(x,y) == null) {
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
            Render.dbgColor(color)

            var from = Level.calculatePos(
                room.from.x,
                room.from.y) + off
            var to = Level.calculatePos(
                room.to.x,
                room.to.y) + off                        
            Render.dbgRect(from.x + 1, from.y + 1, to.x - 1, to.y- 1)
        }

        for(hall in __halls) {         
            var color = __colors[(hall.from.x + hall.from.y + hall.to.x + hall.to.y) % __colors.count]
            Render.dbgColor(color | 0x000000FF) // Make opaque |
            var from = Level.calculatePos(
                hall.from.x,
                hall.from.y) + off
            var to = Level.calculatePos(
                hall.to.x,
                hall.to.y) + off                        
            Render.dbgLine(from.x, from.y, to.x, to.y)            
        }

        if(__graph == null) return

        // Render the graph
        Render.dbgColor(0xFFFFFFFF)
        for(node in __graph.keys) {
            var from = __rooms[node]

            var fromPos = Level.calculatePos(
            from.from.x + (from.to.x - from.from.x) / 2,
            from.from.y + (from.to.y - from.from.y) / 2)
            var connections =  __graph[node].count  
            var distance = __distances[node]

            Render.dbgText("%(node)-%(connections)-%(distance)", fromPos.x, fromPos.y, 1)

            for(to in __graph[node]) {
                var to = __rooms[to]
                var toPos = Level.calculatePos(
                    to.from.x + (to.to.x - to.from.x) / 2,
                    to.from.y + (to.to.y - to.from.y) / 2)
                Render.dbgLine(fromPos.x, fromPos.y, toPos.x, toPos.y)
            }            
        }
    }

    static inset { __random.int(1, 3) }    
}

class MyRandomWalker {
    //Rene's first attempt at creating some proc gen recipe
    //1 pick random point in room, x distance from walls
    //2 pick random direction
    //3 create room of size min/max
    //4 pick a spot on the wall
    //5 store direction, create a door
    //6 create corridor of size min/max
    //7 decide to go back to 3 based on ???
    //8 end 

    static generate(){
        //get some data that we will use later
        var shortBrake = Data.getNumber("Short Brake")
        var longBrake = Data.getNumber("Long Brake")
        var width = Level.width
        var height = Level.height
        var minRoomSizeX = 2    //room size is without the walls
        var maxRoomSizeX = 6
        var minRoomSizeY = 3    
        var maxRoomSizeY = 8
        var corridorMinSize = 5
        var corridorMaxSize = 8

        __random = Random.new()


    //1 pick random point in room, 
        var posX = __random.int(1,width) 
        var posY = __random.int(1,height)
        Create.hero(posX, posY) //place a hero so I can see position

        Fiber.yield(longBrake)      
        
    //2 pick random direction
        var dir = __random.int(0,4)
        Fiber.yield(longBrake)      

    //3 create room of size min/max. TODO: fix rounding and do corners
        var roomSizeX = __random.int(minRoomSizeX, maxRoomSizeX)
        var roomSizeY = __random.int(minRoomSizeY, maxRoomSizeY)
        var halfSizeX = (roomSizeX/2).round     //TODO: rounding effectively only gives even random numbers. may need to add code for this.
        var halfSizeY = (roomSizeY/2).round     
        var walls = [] //used to store a list of created walls for later use
        var wallDirection = []

        //make sure that the room will fit on the screen
        var overflow = posX + halfSizeX + 1 - width //check right
        if (overflow > 0){
            posX = posX - overflow                
        } 
        overflow = posX - halfSizeX - 1 //check left
        if (overflow < 0){
            posX = posX - overflow                
        } 
        overflow = posY + halfSizeY + 1 - height //check top
        if (overflow > 0){
            posY = posY - overflow                
        }
        overflow = posY - halfSizeY - 1 //check bottom
        if (overflow < 0){
            posY = posY - overflow                
        }
       //Create.monster(posX, posY) //use monster as visualizer of changed PosX, PosY

        //start 2D for loop to create the room and put walls around it
        for (x in posX - halfSizeX ... posX + halfSizeX) {
            for (y in posY - halfSizeY ... posY + halfSizeY){
                Level[x, y] = Type.floor
                if (x == posX - halfSizeX) {    //left wall
                    Level[x-1, y] = Type.wall
                    walls.add(Vec2.new(x-1, y)) 
                    wallDirection.add(3)
                }
                if (x == posX + halfSizeX - 1) {  //right wall
                    Level[x+1, y] = Type.wall
                    walls.add(Vec2.new(x+1, y))
                    wallDirection.add(1)                    
                }
                if (y == posY - halfSizeY) {  //bottom wall
                    Level[x, y-1] = Type.wall
                    walls.add(Vec2.new(x, y-1))
                    wallDirection.add(2)
                }
                if (y == posY + halfSizeY - 1) {  //top wall
                    Level[x, y+1] = Type.wall
                    walls.add(Vec2.new(x, y+1))
                    wallDirection.add(0)                    
                }
            }
        }
        Fiber.yield(longBrake)      

    //4 pick a spot on the wall
    //5 store direction, create a door
        var doorIndex = __random.int(0,walls.count)
        var doorPos = walls[doorIndex]
        Level[doorPos] = Type.floor
        Fiber.yield(longBrake)      
         
    //6 create corridor of size min/max TODO: fix edge of screen
        var corridorSize = __random.int(corridorMinSize, corridorMaxSize)
        System.print(corridorSize)

        //Check direction of the coridor        
        var directionMultiplier = Vec2.new(0,0)
        if (wallDirection[doorIndex] == 0){ //Up
            directionMultiplier = Vec2.new(0,1)
            System.print("Up")
        } else if (wallDirection[doorIndex] == 1){ //Right
            directionMultiplier = Vec2.new(1,0)
            System.print("Right")
        } else if (wallDirection[doorIndex] == 2){ //Down
            directionMultiplier = Vec2.new(0,-1)
            System.print("Down")
        } else if (wallDirection[doorIndex] == 3){ //Left
            directionMultiplier = Vec2.new(-1,0)
            System.print("Left")
        }

        //create actual corridor
        for (i in 1 ... corridorSize + 1){
           var corridorPos = Vec2.new(doorPos.x + (i * directionMultiplier.x), doorPos.y + (i * directionMultiplier.y))
            if (directionMultiplier.x == 0){ //vertical
                Level[corridorPos.x - 1, corridorPos.y] = Type.wall
                Level[corridorPos.x + 1, corridorPos.y] = Type.wall
            } else{ //horizontal
                Level[corridorPos.x, corridorPos.y - 1] = Type.wall
                Level[corridorPos.x, corridorPos.y + 1] = Type.wall
            }
           Level[corridorPos] = Type.floor
        }
        Fiber.yield(longBrake)      

    //7 decide to go back to 3 based on ??? (requires refactor into functions)

    //8 populate gameplay objects 
       var monsterSpawnChance = 0.1
        for (x in 0...width){
            for (y in 0...height){
                if (Level[x,y] == Type.floor && __random.float(0.0, 1.0) < monsterSpawnChance){
                    Create.monster(x,y)
                }
                //System.print("hi")
            }
        }
        Fiber.yield(longBrake)      

        return 0.0
    }

    static debugRender() {}
}

import "create" for Create
import "gameplay" for Gameplay