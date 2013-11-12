module components.ceil;

private {
    import artemisd.utils.type;
    import artemisd.component;
}

class Ceil : Component {
    mixin TypeDecl;

    short value;
    bool isSelect = false;
    bool isEnabled = true;
    int pos;

    this(short value, int pos) {
        this.value = value;
        this.pos = pos;
    }
}
