class Type {
    static empty    { 0 << 0 }
    static floor    { 1 << 0 }
    static wall     { 1 << 1 }
    static player   { 1 << 2 }
    static enemy    { 1 << 3 }
    static door     { 1 << 4 }
    static lever    { 1 << 5 }
    static spikes   { 1 << 6 }
    static chest    { 1 << 7 }
    static crate    { 1 << 8 }
    static pot      { 1 << 9 }
    static stairs   { 1 << 10 }
    static light    { 1 << 11 }
    static panel    { 1 << 12 }

//    static attackable   { enemy }
    static blocking     { (wall | enemy | door | player) }
//    static character    { (player | enemy) }

    static monsterBlock { (wall | light | pot | chest) }
}