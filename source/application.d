module application;

private {
    import derelict.sdl2.sdl;
    import derelict.sdl2.ttf;
    import std.conv: to;
    import std.string: toStringz;
}

class SDLApplication {
    private {
        alias updateFunc = void delegate();
        alias eventFunc = void delegate(SDL_Event);
        updateFunc[] _updateFuncs;
        eventFunc[] _eventFuncs;
        bool _running = false;
        SDL_Window* _window = null;
    }

    protected {
        SDL_Renderer *_render = null;
    }

    version(linux) {
        enum sharedLibSDL = "./lib/libSDL2-2.0.so";
        enum sharedLibSDLTTF = "./lib/libSDL2_ttf.so";
    }

    this(uint width, uint height, string title) {
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

        _render = SDL_CreateRenderer(_window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
        if (_render is null) {
            throw new Exception("Failed to create render: " ~ SDL_GetError().to!string);
        }
        SDL_SetRenderDrawColor(_render, 248, 248, 248, 255);
        onInit();
    }

    void onQuit() {
        _running = false;
    }

    void onInit() {

    }

    private {
        void events(ref SDL_Event event) {
            while (SDL_PollEvent(&event)) {
                switch (event.type) {
                    case SDL_QUIT:
                        _running = false;
                        break;
                    default:
                        foreach(func; _eventFuncs) {
                            func(event);
                        }
                        break;
                }
            }
        }

        void run() {
            _running = true;
            while (_running) {
                SDL_Event event;
                events(event);
                SDL_RenderClear(_render);
                foreach(func; _updateFuncs) {
                    func();
                }
                SDL_RenderPresent(_render);
                SDL_Delay(1);
            }
            SDL_Quit();
        }
    }


    void addUpdateFunction(updateFunc func) {
        _updateFuncs ~= func;
    }

    void addEventFunction(eventFunc func) {
        _eventFuncs ~= func;
    }

    void start() {
        run();
    }
}