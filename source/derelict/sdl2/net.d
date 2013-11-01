/*

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

*/
module derelict.sdl2.net;

private {
    import derelict.util.loader;
    import derelict.util.system;
    import derelict.sdl2.types;
    import derelict.sdl2.functions;

    static if(Derelict_OS_Windows)
        enum libNames = "SDL2_net.dll";
    else static if(Derelict_OS_Mac)
        enum libNames = "../Frameworks/SDL2_net.framework/SDL2_net, /Library/Frameworks/SDL2_net.framework/SDL2_net, /System/Library/Frameworks/SDL2_net.framework/SDL2_net";
    else static if(Derelict_OS_Posix)
        enum libNames = "libSDL2_net.so, libSDL2_net-2.0.so, libSDL2_net-2.0.so.0, /usr/local/lib/libSDL2.so, /usr/local/lib/libSDL2_net-2.0.so, /usr/local/lib/libSDL2_net-2.0.so.0";
    else
        static assert(0, "Need to implement SDL2_net libNames for this operating system.");
}

alias SDLNet_Version = SDL_version;

enum : Uint8 {
    SDL_NET_MAJOR_VERSION = 2,
    SDL_NET_MINOR_VERSION = 0,
    SDL_NET_PATCHLEVEL    = 0,
}

void SDL_NET_VERSION(SDL_version* X) {
    X.major = SDL_NET_MAJOR_VERSION;
    X.minor = SDL_NET_MINOR_VERSION;
    X.patch = SDL_NET_PATCHLEVEL;
}

struct IPaddress {
    Uint32 host;
    Uint16 port;
}

enum {
    INADDR_ANY = 0x00000000,
    INADDR_NONE = 0xFFFFFFFF,
    INADDR_LOOPBACK = 0x7f000001,
    INADDR_BROADCAST = 0xFFFFFFFF,
}

alias TCPsocket = void*;

enum SDLNET_MAX_UDPCHANNELS = 32;
enum SDLNET_MAX_UDPADRESSES = 4;

alias UDPsocket = void*;

struct UDPpacket {
    int channel;
    Uint8* data;
    int len;
    int maxlen;
    int status;
    IPaddress address;
}

struct _SDLNet_SocketSet;
alias _SDLNet_SocketSet* SDLNet_SocketSet;

struct _SDLNet_GenericSocket {
    int ready;
}
alias SDLNet_GenericSocket = _SDLNet_GenericSocket*;

nothrow int SDLNet_TCP_AddSocket( SDLNet_SocketSet set, void* sock ) {
    return SDLNet_AddSocket( set, cast( SDLNet_GenericSocket )sock );
}
alias SDLNet_UDP_AddSocket = SDLNet_TCP_AddSocket;

nothrow int SDLNet_TCP_DelSocket( SDLNet_SocketSet set, void* sock ) {
    return SDLNet_DelSocket( set, cast( SDLNet_GenericSocket )sock );
}
alias SDLNet_UDP_DelSocket = SDLNet_TCP_DelSocket;

nothrow bool SDLNet_SocketReady( void* sock ) {
    return sock && (cast( SDLNet_GenericSocket )sock).ready != 0;
}

extern( C ) nothrow {
    alias da_SDLNet_Linked_Version = const( SDLNet_Version )* function();
    alias da_SDLNet_Init = int function();
    alias da_SDLNet_Quit = void function();
    alias da_SDLNet_ResolveHost = int function( IPaddress*, const( char )*, Uint16 );
    alias da_SDLNet_ResolveIP = const( char )* function( const( IPaddress )* );
    alias da_SDLNet_GetLocalAddresses = int function( IPaddress*, int );
    alias da_SDLNet_TCP_Open = TCPsocket function( IPaddress );
    alias da_SDLNet_TCP_Accept = TCPsocket function( TCPsocket );
    alias da_SDLNet_TCP_GetPeerAddress = IPaddress* function( TCPsocket );
    alias da_SDLNet_TCP_Send = int function( TCPsocket, const( void )*, int );
    alias da_SDLNet_TCP_Recv = int function( TCPsocket, void*, int );
    alias da_SDLNet_TCP_Close = void function( TCPsocket );
    alias da_SDLNet_AllocPacket = UDPpacket* function( int );
    alias da_SDLNet_ResizePacket = int function( UDPpacket*, int );
    alias da_SDLNet_FreePacket = void function( UDPpacket* );
    alias da_SDLNet_AllocPacketV = UDPpacket** function( int, int );
    alias da_SDLNet_FreePacketV = void function( UDPpacket** );
    alias da_SDLNet_UDP_Open = UDPsocket function( Uint16 );
    alias da_SDLNet_UDP_SetPacketLoss = void function( UDPsocket, int );
    alias da_SDLNet_UDP_Bind = int function( UDPsocket, int, const( IPaddress )* );
    alias da_SDLNet_UDP_Unbind = void function( UDPsocket, int );
    alias da_SDLNet_UDP_GetPeerAddress = IPaddress* function( UDPsocket, int );
    alias da_SDLNet_UDP_SendV = int function( UDPsocket, UDPpacket**, int );
    alias da_SDLNet_UDP_Send = int function( UDPsocket, int, UDPpacket* );
    alias da_SDLNet_UDP_RecvV = int function( UDPsocket, UDPpacket** );
    alias da_SDLNet_UDP_Recv = int function( UDPsocket, UDPpacket* );
    alias da_SDLNet_UDP_Close = void function( UDPsocket );
    alias da_SDLNet_AllocSocketSet = SDLNet_SocketSet function( int );
    alias da_SDLNet_AddSocket = int function( SDLNet_SocketSet, SDLNet_GenericSocket );
    alias da_SDLNet_DelSocket = int function( SDLNet_SocketSet, SDLNet_GenericSocket );
    alias da_SDLNet_CheckSockets = int function( SDLNet_SocketSet, Uint32 );
    alias da_SDLNet_FreeSocketSet = void function( SDLNet_SocketSet );
    alias da_SDLNet_SetError = void function( const( char )* fmt, ... );
    alias da_SDLNet_GetError = const( char )* function();
}

__gshared {
    da_SDLNet_Linked_Version SDLNet_Linked_Version;
    da_SDLNet_Init SDLNet_Init;
    da_SDLNet_Quit SDLNet_Quit;
    da_SDLNet_ResolveHost SDLNet_ResolveHost;
    da_SDLNet_ResolveIP SDLNet_ResolveIP;
    da_SDLNet_GetLocalAddresses SDLNet_GetLocalAddresses;
    da_SDLNet_TCP_Open SDLNet_TCP_Open;
    da_SDLNet_TCP_Accept SDLNet_TCP_Accept;
    da_SDLNet_TCP_GetPeerAddress SDLNet_TCP_GetPeerAddress;
    da_SDLNet_TCP_Send SDLNet_TCP_Send;
    da_SDLNet_TCP_Recv SDLNet_TCP_Recv;
    da_SDLNet_TCP_Close SDLNet_TCP_Close;
    da_SDLNet_AllocPacket SDLNet_AllocPacket;
    da_SDLNet_ResizePacket SDLNet_ResizePacket;
    da_SDLNet_FreePacket SDLNet_FreePacket;
    da_SDLNet_AllocPacketV SDLNet_AllocPacketV;
    da_SDLNet_FreePacketV SDLNet_FreePacketV;
    da_SDLNet_UDP_Open SDLNet_UDP_Open;
    da_SDLNet_UDP_SetPacketLoss SDLNet_UDP_SetPacketLoss;
    da_SDLNet_UDP_Bind SDLNet_UDP_Bind;
    da_SDLNet_UDP_Unbind SDLNet_UDP_Unbind;
    da_SDLNet_UDP_GetPeerAddress SDLNet_UDP_GetPeerAddress;
    da_SDLNet_UDP_SendV SDLNet_UDP_SendV;
    da_SDLNet_UDP_Send SDLNet_UDP_Send;
    da_SDLNet_UDP_RecvV SDLNet_UDP_RecvV;
    da_SDLNet_UDP_Recv SDLNet_UDP_Recv;
    da_SDLNet_UDP_Close SDLNet_UDP_Close;
    da_SDLNet_AllocSocketSet SDLNet_AllocSocketSet;
    da_SDLNet_AddSocket SDLNet_AddSocket;
    da_SDLNet_DelSocket SDLNet_DelSocket;
    da_SDLNet_CheckSockets SDLNet_CheckSockets;
    da_SDLNet_FreeSocketSet SDLNet_FreeSocketSet;
    da_SDLNet_SetError SDLNet_SetError;
    da_SDLNet_GetError SDLNet_GetError;
}

class DerelictSDL2NetLoader: SharedLibLoader {
    public this() {
        super( libNames );
    }

    protected override void loadSymbols() {
        bindFunc(cast(void**)&SDLNet_Linked_Version, "SDLNet_Linked_Version");
        bindFunc(cast(void**)&SDLNet_Init, "SDLNet_Init");
        bindFunc(cast(void**)&SDLNet_Quit, "SDLNet_Quit");
        bindFunc(cast(void**)&SDLNet_ResolveHost, "SDLNet_ResolveHost");
        bindFunc(cast(void**)&SDLNet_ResolveIP, "SDLNet_ResolveIP");
        bindFunc(cast(void**)&SDLNet_GetLocalAddresses, "SDLNet_GetLocalAddresses");
        bindFunc(cast(void**)&SDLNet_TCP_Open, "SDLNet_TCP_Open");
        bindFunc(cast(void**)&SDLNet_TCP_Accept, "SDLNet_TCP_Accept");
        bindFunc(cast(void**)&SDLNet_TCP_GetPeerAddress, "SDLNet_TCP_GetPeerAddress");
        bindFunc(cast(void**)&SDLNet_TCP_Send, "SDLNet_TCP_Send");
        bindFunc(cast(void**)&SDLNet_TCP_Recv, "SDLNet_TCP_Recv");
        bindFunc(cast(void**)&SDLNet_TCP_Close, "SDLNet_TCP_Close");
        bindFunc(cast(void**)&SDLNet_AllocPacket, "SDLNet_AllocPacket");
        bindFunc(cast(void**)&SDLNet_ResizePacket, "SDLNet_ResizePacket");
        bindFunc(cast(void**)&SDLNet_FreePacket, "SDLNet_FreePacket");
        bindFunc(cast(void**)&SDLNet_AllocPacketV, "SDLNet_AllocPacketV");
        bindFunc(cast(void**)&SDLNet_FreePacketV, "SDLNet_FreePacketV");
        bindFunc(cast(void**)&SDLNet_UDP_Open, "SDLNet_UDP_Open");
        bindFunc(cast(void**)&SDLNet_UDP_SetPacketLoss, "SDLNet_UDP_SetPacketLoss");
        bindFunc(cast(void**)&SDLNet_UDP_Bind, "SDLNet_UDP_Bind");
        bindFunc(cast(void**)&SDLNet_UDP_Unbind, "SDLNet_UDP_Unbind");
        bindFunc(cast(void**)&SDLNet_UDP_GetPeerAddress, "SDLNet_UDP_GetPeerAddress");
        bindFunc(cast(void**)&SDLNet_UDP_SendV, "SDLNet_UDP_SendV");
        bindFunc(cast(void**)&SDLNet_UDP_Send, "SDLNet_UDP_Send");
        bindFunc(cast(void**)&SDLNet_UDP_RecvV, "SDLNet_UDP_RecvV");
        bindFunc(cast(void**)&SDLNet_UDP_Recv, "SDLNet_UDP_Recv");
        bindFunc(cast(void**)&SDLNet_UDP_Close, "SDLNet_UDP_Close");
        bindFunc(cast(void**)&SDLNet_AllocSocketSet, "SDLNet_AllocSocketSet");
        bindFunc(cast(void**)&SDLNet_AddSocket, "SDLNet_AddSocket");
        bindFunc(cast(void**)&SDLNet_DelSocket, "SDLNet_DelSocket");
        bindFunc(cast(void**)&SDLNet_CheckSockets, "SDLNet_CheckSockets");
        bindFunc(cast(void**)&SDLNet_FreeSocketSet, "SDLNet_FreeSocketSet");
        bindFunc(cast(void**)&SDLNet_SetError, "SDLNet_SetError");
        bindFunc(cast(void**)&SDLNet_GetError, "SDLNet_GetError");
    }
}

__gshared DerelictSDL2NetLoader DerelictSDL2Net;

shared static this() {
    DerelictSDL2Net = new DerelictSDL2NetLoader;
}