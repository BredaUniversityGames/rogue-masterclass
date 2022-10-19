import "xs" for Data, Input, Render
import "xs_math"for Math, Bits, Vec2, Color
import "xs_assert" for Assert
import "xs_ec"for Entity, Component
import "xs_components" for Transform, Body, Renderable, Sprite, GridSprite, AnimatedSprite
import "sparse_grid" for SpraseGrid
import "types" for Type
import "directions" for Directions
import "gameplay" for Level

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

class Game {
    static loading      { 0 }
    static generating   { 1 }
    static starting     { 2 }
    static playing      { 3 }
    static gameover     { 4 }

    static config() { /* Using a file instead */ }

    static  init() {
        Entity.init()
        Level.init()
        Tile.init()
        Create.init()
        Gameplay.init()
        
        __time = 0        
        __state = generating // Skip loading
        var alg = Randy
        __genFiber =  Fiber.new { alg.generate() }
    }   
    
    static update(dt) {  
        Gameplay.debugRender()
        if(__state == Game.generating) {
            genStep(dt)            
        } else if(__state == Game.starting ) {            
            if(Gameplay.ready) {
                __state = Game.playing                
            } else {
                Gameplay.start()
            }
        } else if(__state == Game.playing) {
            Gameplay.update(dt)
        }

        Entity.update(dt)        
    }

    static genStep(dt) {
        var visualize = Data.getBool("Visualize Generation", Data.debug)
        if(visualize) {
            __time = __time - dt
            if(__time <= 0.0) {
                if(!__genFiber.isDone) {
                    __time = __genFiber.call()
                } else {
                    __state = Game.starting
                    // Gameplay.start()
                }
            }
        } else {
            while(!__genFiber.isDone) {
                __genFiber.call()
            } 
            __state = starting
            // Gameplay.start()
        }
    }

    static render() {
        Level.render()
        Renderable.render()        
    }
 }

import "create" for Create
import "generators" for Randy
import "gameplay" for Hero, Tile, Gameplay
