import "xs" for Data, Input, Render     // These are the parts of the xs we will be using
import "xs_math" for Vec2
import "random" for Random              // Random is a part of the Wren library
import "grid" for Grid

class Player is Vec2 {
    
}


class Game {
    static empty    { 0 }
    static wall     { 1 }
    static player   { 2 }
    static enemy    { 3 }
    static bomb     { 4 }

    static config() {
        Data.setString("Title", "Gridr", Data.system)
        Data.setNumber("Width", 360, Data.system)
        Data.setNumber("Height", 240, Data.system)
        Data.setNumber("Multiplier", 4, Data.system)
    }

    static init() {   
        __grid = Grid.new(11, 11)
        __grid.setValue(6, 2, Game.player)
        __grid.setValue(7, 5, Game.enemy)
        __grid.setValue(8, 3, Game.enemy)

        __player = Vec2.new(0, 0)
        __enemies = {}
        // __enemy = Vec2.new(100.0, 100.0)        
    }        
    
    static update(dt) {
        __grid.setValue(3, 3, Game.player)
    }

    static render() {
        var s = 9.0
        var sx = __grid.width * -s
        var sy = __grid.height * -s
        
        var backClr = 0xF4F4F4FF
        Render.setColor(backClr)

        var cEmpty  = 0xD8D8D8FF
        var cWall   = 0xAFAFAFFF
        var cPlayer = 0x7CA4D6FF
        var cEnemy  = 0xDF7EEBFF

        Render.rect(-180, -120, 180, 120)
        for (x in 0...__grid.width) {
            for (y in 0...__grid.height) {
                var v = __grid.getValue(x, y)
                var c            
                if(v == Game.player) {
                    c = cPlayer
                } else if(v == Game.enemy) {
                    c = cEnemy
                } else {
                    c = cEmpty
                }
                Render.setColor(c)
                Render.disk(sx + x * s * 2, sy + y * s * 2, s * 0.8, 24)
            }
        }
    }

    
}
