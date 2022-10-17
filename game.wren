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

class State {
    static generating   { 0 }
    static playerTurn   { 1 }
    static computerTurn { 2 }
    static idle         { 3 }
}

class Game {

    static config() { /* Using a file instead */ }

    static  init() {
        Entity.init()
        Level.init()
        Tile.init()
        Create.init()

        __level = 0                
        __state = State.generating
        __time = 0

        var alg = Randy
        __genFiber =  Fiber.new { alg.generate() }
    }   
    
    static update(dt) {
        Entity.update(dt)


        __time = __time - dt
        if(__time <= 0.0) {
            if(!__genFiber.isDone) {
                __time = __genFiber.call()
            }
        }

        /*
        if(__state == State.playerTurn) {
            movePlayer()
        } else if(__state == State.computerTurn) {
            moveEnemies()
        }
        */
    }

    static render() {
        Level.render()
        Renderable.render() 
    }
 }

import "create" for Create
import "generators" for Randy
import "gameplay" for Hero, Tile
