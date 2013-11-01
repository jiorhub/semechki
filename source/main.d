module main;

private {
    import std.stdio: writeln;
    import std.string: toStringz;
    import std.conv: to;
    import derelict.sdl2.ttf;
    import derelict.sdl2.sdl;
    import gamefield;
    import command;
    import application;
}

enum WIDTH_CEIL = 35;
enum FONT_FILE_NAME = "resource/DroidSans.ttf";

class Game : SDLApplication {
    private {
        Ceil _current;
        SDL_Texture *numTextures[short];
        TTF_Font *font = null;
        GameField _gf;
        Command[] _commands;
    }

    this(int hCountCeil, string title) {
        int width = hCountCeil * WIDTH_CEIL;
        _gf = new GameField(hCountCeil);
        super(width, width, title);
    }

    override
    void onInit() {
        SDL_Color fontColor = { 0, 0, 0 };
        font = TTF_OpenFont(FONT_FILE_NAME, 22);
        if(font is null){
            throw new Exception("Failed to load font: " ~ FONT_FILE_NAME ~ " " ~ TTF_GetError().to!string);
        }
        foreach(short n; 1..10) {
            SDL_Surface *surf = TTF_RenderText_Blended(font, toStringz(n.to!string), fontColor);
            SDL_Texture *texture = SDL_CreateTextureFromSurface(_render, surf);
            numTextures[n] = texture;
            SDL_FreeSurface(surf);
        }
        TTF_CloseFont(font);

        initGame();
        addUpdateFunction(&this.drawGameField);
        addEventFunction(&this.mouseEvent);
    }

    void initGame() {
        foreach(short val ; 1..10) {
            _gf.insertFront(val);
        }
        foreach(short val ; 1..10) {
            _gf.insertFront(1);
            _gf.insertFront(val);
        }
    }

    void drawGameField() {
        SDL_SetRenderDrawColor(_render, 102, 102, 102, 255);
        SDL_Rect rectangle = {
                w: WIDTH_CEIL,
                h: WIDTH_CEIL
            };
        SDL_Rect rectFont;
        foreach(int y, ref Ceil[] line; _gf.getCeils()) {
            rectangle.y = y * WIDTH_CEIL;
            rectFont.y = y * WIDTH_CEIL + 5;
            foreach(int x, Ceil ceil; line) {
                rectangle.x = x * WIDTH_CEIL;
                rectFont.x = x * WIDTH_CEIL + 10;
                if (ceil !is null && ceil.isSelect) {
                    SDL_SetRenderDrawColor(_render, 231, 246, 145, 255);
                    SDL_RenderFillRect(_render, &rectangle);
                }
                SDL_SetRenderDrawColor(_render, 102, 102, 102, 255);
                SDL_RenderDrawRect(_render, &rectangle);
                if(ceil !is null) {
                    SDL_Texture *tex = numTextures[ceil.value];
                    SDL_QueryTexture(tex, null, null, &rectFont.w, &rectFont.h);
                    SDL_RenderCopy(_render, tex, null, &rectFont);
                }
            }
        }
        SDL_SetRenderDrawColor(_render, 255, 255, 255, 255);
    }

    void mouseEvent(SDL_Event event) {
        if(event.type == SDL_MOUSEBUTTONDOWN) {
            int x = event.motion.x / WIDTH_CEIL + 1;
            int y = event.motion.y / WIDTH_CEIL + 1;
            Ceil ceil = _gf.get(x, y);
            if (ceil !is null) {
                ceil.select(true);
            }
        }

        if(event.type == SDL_MOUSEBUTTONUP) {
            int x = event.motion.x / WIDTH_CEIL + 1;
            int y = event.motion.y / WIDTH_CEIL + 1;
            Ceil ceil = _gf.get(x, y);
            if(ceil !is null) {
                if(_current is null) {
                    _current = ceil;
                } else {
                    _current.select(false);
                    ceil.select(false);
                    if(_current.value == ceil.value || (_current.value + ceil.value) == 10) {
                        Command com1 = new ChangeCeilCommand(_gf, _current.x, _current.y, null);
                        Command com2 = new ChangeCeilCommand(_gf, ceil.x, ceil.y, null);
                        com1.execute();
                        com2.execute();
                        _commands ~= com1;
                        _commands ~= com2;
                    }
                    _current = null;
                }
            }
        }
    }
}


void main() {
    DerelictSDL2.load();
    Game game = new Game(9, "Семечки");
    game.start();
}
