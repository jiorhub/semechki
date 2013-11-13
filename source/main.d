module main;

private {
    import std.stdio: writeln;
    import std.string: toStringz;
    import std.conv: to;
}

private {
    import artemisd.all;
    import derelict.sdl2.ttf;
    import derelict.sdl2.sdl;
    import components;
    import systems;
    import gamefield: GameField;
}

enum SCREEN_FPS = 60;
enum SCREEN_TICK_PER_FRAME = 1000 / SCREEN_FPS;
enum WIDTH_CEIL = 35;

version(linux) {
    enum sharedLibSDL = "./lib/libSDL2.so";
    enum sharedLibSDLTTF = "./lib/libSDL2_ttf.so";
    enum sharedLibSDLImage = "./lib/libSDL2_image.so";
}

interface MouseListener {
    void clickButton(ref SDL_Event event);
    void upButton(ref SDL_Event event);
}

interface KeyListener {
    void keyPressed(ref SDL_Event event);
    void keyReleased(ref SDL_Event event);
}

class Application {
    private {
        MouseListener[] _mouseListeners;
        KeyListener[] _keyListeners;
        World _world;
        SDL_Window* _window;
        SDL_Renderer *_render;
        bool _quit;
        GameField _gf;
    }

    this(uint width, uint height, string title, GameField gf) {
        DerelictSDL2.load(sharedLibSDL);
        DerelictSDL2ttf.load(sharedLibSDLTTF);
        if (SDL_Init(SDL_INIT_VIDEO) < 0) {
            throw new Exception("Failed to init SDL: " ~ SDL_GetError().to!string);
        }
        if(TTF_Init() < 0) {
            throw new Exception("Failed to init TTF: " ~ SDL_GetError().to!string);
        }

        _window = SDL_CreateWindow(title.toStringz, 100, 100, width, height, SDL_WINDOW_SHOWN);
        if (_window is null) {
            throw new Exception("Failed to create window: " ~ SDL_GetError().to!string);
        }
        _render = SDL_CreateRenderer(_window, -1, SDL_RENDERER_ACCELERATED);
        if (_render is null) {
            throw new Exception("Failed to create render: " ~ SDL_GetError().to!string);
        }

        _gf = gf;
        _world = new World();
        _world.setSystem(new PlayerInputSystem(this));
        _world.setSystem(new RenderSystem(_render));
        _world.setSystem(new HudRenderSystem(_render));
        _world.setSystem(new MovementSystem(_gf));
        _world.initialize();
        _gf.setWorld(_world);
    }

    void run() {
        SDL_Event event;
        uint currentTime;
        uint lastTime;
        uint elapsedTime;

        _quit = false;
        while(!_quit) {
            currentTime = SDL_GetTicks();
            elapsedTime = currentTime - lastTime;
            lastTime = currentTime;

            while(SDL_PollEvent(&event)) {
                switch (event.type) {
                    case SDL_QUIT:
                        _quit = true;
                        break;
                    case SDL_MOUSEBUTTONDOWN:
                        foreach(listener ; _mouseListeners)
                            listener.clickButton(event);
                        break;
                    case SDL_MOUSEBUTTONUP:
                        foreach(listener ; _mouseListeners)
                            listener.upButton(event);
                        break;
                    case SDL_KEYUP:
                        foreach(listener ; _keyListeners)
                            listener.keyReleased(event);
                    case SDL_KEYDOWN:
                        if(event.key.keysym.unicode > 0) {
                            foreach(listener ; _keyListeners)
                                listener.keyPressed(event);
                        }
                    default:
                        break;
                }
            }

            SDL_SetRenderDrawColor(_render, 248, 248, 248, 255);
            SDL_RenderClear(_render);
            _world.setDelta(SCREEN_TICK_PER_FRAME);
            _world.process();
            SDL_RenderPresent(_render);

            uint frameTicks = SDL_GetTicks() - currentTime;
            if(frameTicks < SCREEN_TICK_PER_FRAME ) {
                SDL_Delay( SCREEN_TICK_PER_FRAME - frameTicks );
            }
        }
    }

    void exit() {
        _quit = true;
    }

    void addMouseListener(MouseListener listener) {
        _mouseListeners ~= listener;
    }

    void addKeyListener(KeyListener listener) {
        _keyListeners ~= listener;
    }

    GameField getGameField() {
        return _gf;
    }

    void initGame() {
        foreach(short val ; 1..10) {
            _gf.insertFront(1);
        }
        foreach(short val ; 1..10) {
            _gf.insertFront(1);
            _gf.insertFront(val);
        }
    }
}

void main() {
    GameField gf = new GameField(9, 15, WIDTH_CEIL);
    Application app = new Application(gf.getWidth(), gf.getHeight, "Семечки", gf);
    app.initGame();
    app.run();
}
