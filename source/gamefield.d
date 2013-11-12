module gamefield;

private {
    import std.conv: to;
    import std.range: stride;
}

private {
    import artemisd.entity: Entity;
    import artemisd.world: World;
    import components;
}

class GameField {
    private {
        Entity[] _ceils;
        int _sizeW;
        int _sizeH;
        int _scale;
        World _world;
    }

    this(int sizeW, int sizeH, int scale) {
        _sizeW = sizeW;
        _sizeH = sizeH;
        _scale = scale;
    }

    void setWorld(ref World world) {
        _world = world;
    }

    void insertFront(short value) {
        Entity ceil = _world.createEntity();
        _ceils ~= ceil;

        int posX = cast(int)((_ceils.length - 1) % _sizeW) + 1;
        int posY = cast(int)((_ceils.length - 1) / _sizeW) + 1;
        ceil.addComponent(new Position((posX - 1) * _scale, (posY - 1) * _scale));
        ceil.addComponent(new Renderer(_scale));
        ceil.addComponent(new Ceil(value, cast(int)_ceils.length - 1));
        ceil.addToWorld();
    }

    void popFront() {
        _ceils = _ceils[0..$-1];
    }

    @property
    Entity front() {
        return _ceils[$-1];
    }

    void disable(int pos) {
        if(pos <= _ceils.length) {
            Entity e = _ceils[pos];
            Ceil ceil = e.getComponent!Ceil;
            ceil.isEnabled = false;
        }
    }

    void enable(int pos) {
        if(pos <= _ceils.length) {
            Entity e = _ceils[pos];
            Ceil ceil = e.getComponent!Ceil;
            ceil.isEnabled = true;
        }
    }

    Entity get(int pos) {
        if(pos > _ceils.length)
            return null;
        Entity e = _ceils[pos];
        Ceil ceil = e.getComponent!Ceil;
        return ceil.isEnabled ? e : null;
    }

    bool isPair(Ceil ceil1, Ceil ceil2) {
        Ceil maxCeil, minCeil;
        if(ceil1.pos > ceil2.pos) {
            maxCeil = ceil1;
            minCeil = ceil2;
        } else {
            maxCeil = ceil2;
            minCeil = ceil1;
        }

        Entity[] slice = _ceils[minCeil.pos..maxCeil.pos+1];
        foreach(ref Entity e ; slice[1..$]) {
            Ceil c = e.getComponent!Ceil;
            if(!c.isEnabled)
                continue;
            if(c.pos == maxCeil.pos)
                return true;
            else
                break;
        }

        foreach(ref Entity e ; stride(slice, _sizeW)[1..$]) {
            Ceil c = e.getComponent!Ceil;
            if(!c.isEnabled)
                continue;
            if(c.pos == maxCeil.pos)
                return true;
            else
                break;

        }
        return false;
    }

    @property
    int scale() {
        return _scale;
    }

    @property
    int countInLine() {
        return _sizeW;
    }

    int getWidth() {
        return _sizeW * _scale;
    }

    int getHeight() {
        return _sizeH * _scale;
    }
}
