module components.renderer;

private {
    import artemisd.utils.type;
    import artemisd.component;
}

class Renderer : Component {
    mixin TypeDecl;

    int size;

    this(int size) {
        this.size = size;
    }
}
