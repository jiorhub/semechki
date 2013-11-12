module systems.playerinputsystem;

private {
    import derelict.sdl2.sdl;
    import artemisd.utils.type: TypeDecl;
    import artemisd.aspect: Aspect;
    import artemisd.entitysystem: EntitySystem;
    import main: Application, MouseListener, KeyListener;
    import artemisd.utils.bag;
    import artemisd.entity: Entity;
    import gamefield: GameField;
    import components;
    import command;
}

class PlayerInputSystem : EntitySystem, MouseListener, KeyListener {
    mixin TypeDecl;

    private {
        Application _application;
        GameField _gf;
        Entity _current = null;
        Command[] _commands;
    }

    public this(Application application) {
        super(Aspect.getEmpty());
        _application = application;
        _application.addMouseListener(this);
        _application.addKeyListener(this);
        _gf = _application.getGameField();
    }

    override
    void processEntities(Bag!Entity entities) {

    }

    void clickButton(ref SDL_Event event) {
        int x = event.motion.x / _gf.scale + 1;
        int y = event.motion.y / _gf.scale + 1;
        int pos = (y - 1) * _gf.countInLine + (x -1);

        Entity e = _gf.get(pos);
        if (e !is null) {
            Ceil ceil = e.getComponent!Ceil;
            if(event.button.button == SDL_BUTTON_LEFT) {
                ceil.isSelect = !ceil.isSelect;
            } else if (event.button.button == SDL_BUTTON_RIGHT) {
                ceil.isSelect = false;
            }
        }
    }

    void upButton(ref SDL_Event event) {
        int x = event.motion.x / _gf.scale + 1;
        int y = event.motion.y / _gf.scale + 1;
        int pos = (y - 1) * _gf.countInLine + (x -1);

        Entity e = _gf.get(pos);
        if (e !is null && event.button.button == SDL_BUTTON_LEFT) {
            Ceil ceil = e.getComponent!Ceil;
            if(_current is null) {
                if(ceil.isSelect)
                    _current = e;
            } else {
                Ceil curCeil = _current.getComponent!Ceil;
                if(_current.getId() == e.getId()) {
                    curCeil.isSelect = false;
                } else {
                    curCeil.isSelect = false;
                    ceil.isSelect = false;
                    if(curCeil.value == ceil.value || (curCeil.value + ceil.value) == 10) {
                        if(_gf.isPair(ceil, curCeil)) {
                            Command c1 = new DisableCeilCommand(_gf, ceil.pos);
                            c1.execute();
                            _commands ~= c1;
                            Command c2 = new DisableCeilCommand(_gf, curCeil.pos);
                            c2.execute();
                            _commands ~= c2;
                        }
                    }
                }
                _current = null;
            }
        }
    }

    void keyPressed(ref SDL_Event event) {

    }

    void keyReleased(ref SDL_Event event) {
        switch (event.key.keysym.sym) {
            case SDLK_LEFT:
                if(_commands.length > 0) {
                    Command c = _commands[$-1];
                    c.unexecute();
                    _commands = _commands[0..$-1];
                }
                break;
            default:
                break;
        }
    }

    protected override bool checkProcessing() {
        return true;
    }
}
