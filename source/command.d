module command;

private {
    import gamefield;
}

interface Command {
    void execute();
    void unexecute();
}

//class InsertCommand : Command {
//    GameField _gf;
//    short _value;

//    this(GameField gf, short value) {
//        _value = value;
//        _gf = gf;
//    }

//    void execute() {
//        _gf.insertFront(_value);
//    }

//    void unexecute() {
//        _gf.popFront();
//    }
//}

//unittest {
//    GameField gf = new GameField(9);
//    Command comm = new InsertCommand(gf, 4);
//    comm.execute();
//    comm.unexecute();
//}

//class MultiInsertCommand : Command {
//    GameField _gf;
//    short[] _values;
//    InsertCommand[] _commands;

//    this(GameField gf, short[] values) {
//        _values = values;
//        _gf = gf;
//    }

//    void execute() {
//        foreach(short val ; _values) {
//            InsertCommand comm = new InsertCommand(_gf, val);
//            comm.execute();
//            _commands ~= comm;
//        }
//    }

//    void unexecute() {
//        while (_commands.length) {
//            Command comm = _commands[$-1];
//            comm.unexecute();
//            _commands = _commands[0..$-1];
//        }
//    }
//}

//unittest {
//    GameField gf = new GameField(9);
//    Command comm = new MultiInsertCommand(gf, [1, 2, 3, 4, 5]);
//    comm.execute();
//    comm.unexecute();
//    comm.execute();
//    comm.unexecute();
//}

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
