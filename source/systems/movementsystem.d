module systems.movementsystem;

private {
    import artemisd.utils.type: TypeDecl;
    import artemisd.aspect: Aspect;
    import artemisd.entity: Entity;
    import components;
    import artemisd.systems.entityprocessingsystem: EntityProcessingSystem;
    import gamefield: GameField;
}

class MovementSystem : EntityProcessingSystem {
    mixin TypeDecl;

    private {
        GameField _gf;
    }

    this(GameField gf) {
        super(Aspect.getAspectForAll!(Position, Velocity));
        _gf = gf;
    }

    override
    void process(Entity e) {
        Position pos = e.getComponent!Position;
        Velocity vel = e.getComponent!Velocity;
        Ceil ceil = e.getComponent!Ceil;

        if(pos.y == 0)
            return;
        if(ceil.pos < _gf.countInLine)
            return;

        import std.stdio: writeln;
        

        Entity topEntity = _gf.get(ceil.pos - _gf.countInLine);
        if(topEntity !is null)
            return;    

        pos.x += vel.vectorX * world.getDelta();
        pos.y += vel.vectorY * world.getDelta();  
    }
}
