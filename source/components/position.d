module components.position;

private {
    import artemisd.utils.type;
    import artemisd.component;
}

final class Position : Component {
    mixin TypeDecl;

    int x;
    int y;

    this(int x, int y) {
        this.x = x;
        this.y = y;
    }
}
