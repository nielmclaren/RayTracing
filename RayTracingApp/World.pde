
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

  World addObject(Object object) {
    _objects.add(object);
    return this;
  }

  ArrayList<Object> objects() {
    return _objects;
  }
}
