module command;

private {
    import gamefield;
}

interface Command {
    void execute();
    void unexecute();
}

class InsertCommand : Command {
    GameField _gf;
    short _value;

    this(GameField gf, short value) {
        _value = value;
        _gf = gf;
    }

    void execute() {
        _gf.insertFront(_value);
    }

    void unexecute() {
        _gf.popFront();
    }
}

class MultiInsertCommand : Command {
    GameField _gf;
    short[] _values;
    InsertCommand[] _commands;

    this(GameField gf, short[] values) {
        _values = values;
        _gf = gf;
    }

    void execute() {
        foreach(short val ; _values) {
            InsertCommand comm = new InsertCommand(_gf, val);
            comm.execute();
            _commands ~= comm;
        }
    }

    void unexecute() {
        while (_commands.length) {
            Command comm = _commands[$-1];
            comm.unexecute();
            _commands = _commands[0..$-1];
        }
    }
}

class DisableCeilCommand : Command {
    GameField _gf;
    int _pos;

    this(GameField gf, int pos) {
        _gf = gf;
        _pos = pos;
    }

    void execute() {
        _gf.disable(_pos);
    }

    void unexecute() {
        _gf.enable(_pos);
    }
}

class MultiDisableCeilCommand : Command {
    GameField _gf;
    int[] _values;
    Command[] _commands;

    this(GameField gf, int[] values...) {
        _gf = gf;
        _values = values;
    }

    void execute() {
        foreach(int val ; _values) {
            Command comm = new DisableCeilCommand(_gf, val);
            comm.execute();
            _commands ~= comm;
        }
    }

    void unexecute() {
        while (_commands.length) {
            Command comm = _commands[$-1];
            comm.unexecute();
            _commands = _commands[0..$-1];
        }
    }
}

