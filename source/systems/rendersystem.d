module systems.rendersystem;

private {
    import std.conv: to, toStringz;
}

private {
    import derelict.sdl2.sdl;
    import derelict.sdl2.ttf;
    import artemisd.utils.type: TypeDecl;
    import artemisd.aspect: Aspect;
    import artemisd.entity: Entity;
    import components;
    import artemisd.systems.entityprocessingsystem: EntityProcessingSystem;
}

enum FONT_FILE_NAME = "resource/DroidSans.ttf";

struct RectSize {
    int w;
    int h;
}

class RenderSystem : EntityProcessingSystem {
    mixin TypeDecl;

    private {
        SDL_Renderer *_render;
        SDL_Texture *_textureBall;
        SDL_Texture *numTextures[short];
        RectSize[short] numSizes;
    }

    this(SDL_Renderer *render) {
        super(Aspect.getAspectForAll!(Position, Renderer, Ceil));
        _render = render;

        SDL_Color fontColor = { 0, 0, 0 };
        TTF_Font *font = TTF_OpenFont(FONT_FILE_NAME, 22);
        if(font is null){
            throw new Exception("Failed to load font: " ~ FONT_FILE_NAME ~ " " ~ TTF_GetError().to!string);
        }
        foreach(short n; 1..10) {
            SDL_Surface *surf = TTF_RenderText_Blended(font, toStringz(n.to!string), fontColor);
            SDL_Texture *texture = SDL_CreateTextureFromSurface(_render, surf);
            SDL_FreeSurface(surf);
            RectSize rect;
            SDL_QueryTexture(texture, null, null, &rect.w, &rect.h);

            numTextures[n] = texture;
            numSizes[n] = rect;
        }
        TTF_CloseFont(font);
    }

    override
    void process(Entity e) {
        Ceil ceil = e.getComponent!Ceil;
        if (!ceil.isEnabled)
            return;
        Position pos = e.getComponent!Position;
        Renderer ren = e.getComponent!Renderer;

        SDL_Rect rectBorder = {
            x: pos.x,
            y: pos.y,
            w: ren.size,
            h: ren.size
        };

        if (ceil !is null && ceil.isSelect) {
            SDL_SetRenderDrawColor(_render, 231, 246, 145, 255);
            SDL_RenderFillRect(_render, &rectBorder);
        }

        SDL_SetRenderDrawColor(_render, 102, 102, 102, 255);
        SDL_RenderDrawRect(_render, &rectBorder);

        SDL_Texture *tex = numTextures[ceil.value];
        RectSize rectSize = numSizes[ceil.value];
        SDL_Rect rectNum = {
            x: pos.x + 12,
            y: pos.y + 5,
            w: rectSize.w,
            h: rectSize.h
        };
        SDL_RenderCopy(_render, tex, null, &rectNum);
    }
}