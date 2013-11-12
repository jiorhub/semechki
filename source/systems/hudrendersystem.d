module systems.hudrendersystem;

private {
    import std.conv: to, toStringz;
    import std.string: format;
}

private {
    import derelict.sdl2.sdl;
    import derelict.sdl2.ttf;
    import artemisd.systems.voidentitysystem: VoidEntitySystem;
    import artemisd.utils.type: TypeDecl;
}

enum FONT_FILE_NAME = "resource/DroidSans.ttf";

public class HudRenderSystem : VoidEntitySystem {
    mixin TypeDecl;

    private {
        SDL_Renderer *_render;
        SDL_Color _fontColor = { 0, 0, 0 };
        TTF_Font *_font;
        int _fps;
    }

    this(SDL_Renderer *render) {
        super();
        _render = render;
        _font = TTF_OpenFont(FONT_FILE_NAME, 14);
        if(_font is null){
            throw new Exception("Failed to load font: " ~ FONT_FILE_NAME ~ " " ~ TTF_GetError().to!string);
        }
    }

    void printToRender(TTF_Font *font, string str, int x, int y) {
        SDL_Rect rectFont = {
            x : x,
            y : y
        };
        SDL_Surface *surf = TTF_RenderText_Blended(font, toStringz(str), _fontColor);
        SDL_Texture *texture = SDL_CreateTextureFromSurface(_render, surf);
        SDL_QueryTexture(texture, null, null, &rectFont.w, &rectFont.h);
        SDL_RenderCopy(_render, texture, null, &rectFont);
        SDL_DestroyTexture(texture);
        SDL_FreeSurface(surf);
    }

    override
    void processSystem() {
        static uint FPSTickCounter = 0;
        static uint FPSCounter = 0;

        FPSTickCounter += world.getDelta();
        FPSCounter++;

        if (FPSTickCounter >= 1000) {
            _fps = FPSCounter;
            FPSCounter = 0;
            FPSTickCounter = 0;
        }

        printToRender(_font, "FPS: %d".format(_fps), 10, 10);
        printToRender(_font, "Active entities: %d".format(world.getEntityManager().getActiveEntityCount()), 10, 25);
    }
}