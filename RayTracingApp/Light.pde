
class Light {
  private PVector _position;

  Light(PVector position) {
    _position = position;
  }

  PVector position() {
    return _position;
  }

  Light position(PVector v) {
    _position = v;
    return this;
  }
}
