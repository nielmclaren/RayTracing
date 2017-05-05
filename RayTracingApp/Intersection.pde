
class Intersection {
  private PVector _point;
  private PVector _normal;

  Intersection(PVector point, PVector normal) {
    _point = point;
    _normal = normal;
  }

  public PVector point() {
    return _point;
  }

  public PVector normal() {
    return _normal;
  }
}
