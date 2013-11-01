module gamefield;

private {
    import std.conv: to;
}

//ячейка
class Ceil {
    private {
        short _value;
        bool _isSelect = false;
    }
    int x;
    int y;

    this(short value) {
        _value = value;
    }

    @property
    short value() {
        return _value;
    }

    @property
    bool isSelect() {
        return _isSelect;
    }

    @property
    void select(bool isSelect) {
        _isSelect = isSelect;
    }

    override
    string toString() {
        return _value.to!string;
    }
}

class GameField {
    private {
        Ceil[][] _ceils;
        int _width;
    }

    this(int width) {
        _width = width;
    }

    void insertFront(short value) {
        Ceil ceil = new Ceil(value);
        if(!_ceils.length || _ceils[$-1].length >= _width) {
            _ceils ~= [ceil];
        } else {
            _ceils[$-1] ~= ceil;
        }
        ceil.y = cast(int)_ceils.length;
        ceil.x = cast(int)_ceils[$-1].length;
    }

    void popFront() {
        _ceils[$-1] = _ceils[$-1][0..$-1];
        if(!_ceils[$-1].length)
            _ceils = _ceils[0..$-1];
    }

    @property
    Ceil front() {
        return _ceils[$-1][$-1];
    }

    void remove(int x, int y) {
        _ceils[y-1][x-1] = null;
    }

    void set(int x, int y, Ceil ceil) {
        _ceils[y-1][x-1] = ceil;
    }

    Ceil get(int x, int y) {
        if (y > _ceils.length)
            return null;
        if (x > _ceils[0].length)
            return null;
        return _ceils[y-1][x-1];
    }

    ref Ceil[][] getCeils() {
        return _ceils;
    }
}
