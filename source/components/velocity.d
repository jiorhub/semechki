module components.velocity;

private {
    import artemisd.utils.type;
    import artemisd.component;
}

final class Velocity : Component {
    mixin TypeDecl;

    float vectorX;
    float vectorY;

    this(float vectorX, float vectorY) {
        this.vectorX = vectorX;
        this.vectorY = vectorY;
    }
}
