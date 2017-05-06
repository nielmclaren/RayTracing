
static class Material {
  private float _indexOfRefraction;
  private boolean _isTransparent;
  private float _reflectivity;

  Material() {
    _indexOfRefraction = 0;
    _isTransparent = false;
    _reflectivity = 0;
  }

  Material(float indexOfRefraction) {
    _indexOfRefraction = indexOfRefraction;
    _isTransparent = false;
    _reflectivity = 0;
  }

  float indexOfRefraction() {
    return _indexOfRefraction;
  }

  Material indexOfRefraction(float v) {
    _indexOfRefraction = v;
    return this;
  }

  boolean isTransparent() {
    return _isTransparent;
  }

  Material isTransparent(boolean v) {
    _isTransparent = v;
    return this;
  }

  float reflectivity() {
    return _reflectivity;
  }

  Material reflectivity(float v) {
    _reflectivity = v;
    return this;
  }

  static Material vacuum() {
    return new Material(1);
  }

  static Material air() {
    return new Material(1.000277);
  }

  static Material water() {
    return new Material(4/3);
  }

  static Material glass() {
    return new Material(1.6);
  }

  static Material diamond() {
    return new Material(2.417);
  }
}
