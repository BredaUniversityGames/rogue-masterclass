import "xs_math" for Vec2

class Directions {
    static upIdx    { 0 }
    static rightIdx { 1 }
    static downIdx  { 2 }
    static leftIdx  { 3 }

    static [i] {
        if(i == 0) {
            return Vec2.new(0, 1)   // Up
        } else if(i == 1) {
            return Vec2.new(1, 0)   // Right
        } else if(i == 2) {
            return Vec2.new(0, -1)   // Down
        } else if(i == 3) {
            return Vec2.new(-1, 0)   // Left
        }
    }

    static getIndex(vec) {
        if(vec.x == 0 && vec.y == 1) {
            return upIdx
        } else if(vec.x == 1 && vec.y == 0) {
            return rightIdx
        } else if(vec.x == 0 && vec.y == -1) {
            return downIdx
        } else if(vec.x == -1 && vec.y == 0) {
            return leftIdx 
        }
       
    } 
}