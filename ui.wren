import "xs_ec" for Component
import "xs_components" for GridSprite
import "xs_math" for Math

class Healthbar is Component {
    construct new() {}

    initialize() {
        _sprite = owner.getComponent(GridSprite)
    }

    update(dt) {
        if(Hero.hero) {
            _sprite.idx = 10 - Hero.hero.getComponent(Hero).health / 10
        }
    }
}

import "gameplay" for Hero