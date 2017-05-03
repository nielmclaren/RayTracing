
class World {
  private ArrayList<Light> _lights;
  private ArrayList<Object> _objects;

  World() {
    _lights = new ArrayList<Light>();
    _objects = new ArrayList<Object>();
  }

  World addLight(PVector position) {
    _lights.add(new Light(position));
    return this;
  }

  ArrayList<Light> lights() {
    return _lights;
  }

  World addRectangle(float x, float y, float width, float height, float rotation) {
    _objects.add(new Rectangle(x, y, width, height, rotation));
    return this;
  }

  ArrayList<Object> objects() {
    return _objects;
  }
}
