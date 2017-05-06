
class Object {
  private Material _material;

  Object() {
    _material = Material.vacuum();
  }

  Material material() {
    return _material;
  }

  Object material(Material material) {
    _material = material;
    return this;
  }

  Shape shape() {
    return Shape.OBJECT;
  }
}
