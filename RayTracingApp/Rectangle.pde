
class Rectangle extends Object {
  private float _x;
  private float _y;
  private float _width;
  private float _height;
  private float _rotation;
  private PVector _topLeft;
  private PVector _topRight;
  private PVector _bottomRight;
  private PVector _bottomLeft;
  private PVector _topNormal;
  private PVector _rightNormal;
  private PVector _bottomNormal;
  private PVector _leftNormal;

  Rectangle(float centerX, float centerY, float width, float height) {
    init(centerX, centerY, width, height, 0);
  }

  Rectangle(float centerX, float centerY, float width, float height, float rotation) {
    init(centerX, centerY, width, height, rotation);
  }

  private void init(float centerX, float centerY, float width, float height, float rotation) {
    _x = centerX;
    _y = centerY;
    _width = width;
    _height = height;
    _rotation = rotation;

    float w = _width/2;
    float h = _height/2;
    float cosine = cos(_rotation);
    float sine = sin(_rotation);

    _topLeft = new PVector(_x - w * cosine + h * sine, _y - w * sine - h * cosine);
    _topRight = new PVector(_x + w * cosine + h * sine, _y + w * sine - h * cosine);
    _bottomRight = new PVector(_x + w * cosine - h * sine, _y + w * sine + h * cosine);
    _bottomLeft = new PVector(_x - w * cosine - h * sine, _y - w * sine + h * cosine);

    _topNormal = new PVector(_topRight.y - _topLeft.y, _topLeft.x - _topRight.x);
    _rightNormal = new PVector(_bottomRight.y - _topRight.y, _topRight.x - _bottomRight.x);
    _bottomNormal = new PVector(_bottomLeft.y - _bottomRight.y, _bottomRight.x - _bottomLeft.x);
    _leftNormal = new PVector(_topLeft.y - _bottomLeft.y, _bottomLeft.x - _topLeft.x);
    _topNormal.normalize();
    _rightNormal.normalize();
    _bottomNormal.normalize();
    _leftNormal.normalize();
  }

  float x() {
    return _x;
  }

  float y() {
    return _y;
  }

  float width() {
    return _width;
  }

  float height() {
    return _height;
  }

  float rotation() {
    return _rotation;
  }

  PVector getRayIntersection(PVector source, PVector direction) {
    PVector top = getRayLineSegmentIntersection(source, direction, _topLeft, _topRight);
    PVector right = getRayLineSegmentIntersection(source, direction, _topRight, _bottomRight);
    PVector bottom = getRayLineSegmentIntersection(source, direction, _bottomRight, _bottomLeft);
    PVector left = getRayLineSegmentIntersection(source, direction, _bottomLeft, _topLeft);
    PVector[] intersections = {top, right, bottom, left};

    PVector result = null;
    float resultDist = Float.MAX_VALUE;
    for (int i = 0; i < intersections.length; i++) {
      PVector intersection = intersections[i];
      if (intersection == null) continue;
      float dist = PVector.dist(intersection, source);
      if (dist < resultDist) {
        result = intersection;
        resultDist = dist;
      }
    }

    return result;
  }

  private PVector getRayLineSegmentIntersection(PVector rayPoint, PVector rayDirection, PVector endpoint0, PVector endpoint1) {
    PVector lineDirection = PVector.sub(endpoint1, endpoint0);
    lineDirection.normalize();

    PVector intersection = getLineIntersection(rayPoint, rayDirection, endpoint0, lineDirection);
    if (intersection == null || PVector.sub(intersection, rayPoint).dot(rayDirection) <= 0) {
      return null;
    }

    float length = PVector.dist(endpoint1, endpoint0);
    if (PVector.dist(intersection, endpoint0) < length && PVector.dist(intersection, endpoint1) < length) {
      return intersection;
    }

    return null;
  }

  private PVector getLineIntersection(PVector p0, PVector d0, PVector p1, PVector d1) {
    float slope0 = d0.y / d0.x;
    float slope1 = d1.y / d1.x;
    float yIntercept0 = p0.y - p0.x * slope0;
    float yIntercept1 = p1.y - p1.x * slope1;

    if (d1.x == 0) {
      if (d0.x == 0) {
        return null;
      }
      return new PVector(p1.x, p1.x * slope0 + yIntercept0);
    } else if (d1.y == 0) {
      if (d0.y == 0) {
        return null;
      }
      return new PVector((p1.y - yIntercept0) / slope0, p1.y);
    } else if (d0.x == 0) {
      return new PVector(p0.x, p0.x * slope1 + yIntercept1);
    } else  if (d0.y == 0) {
      return new PVector((p0.y - yIntercept1) / slope1, p0.y);
    }

    float x;
    float y;
    if (slope0 > slope1) {
      x = (yIntercept1 - yIntercept0) / (slope0 - slope1);
      y = x * slope0 + yIntercept0;
    } else {
      y = (slope1 * yIntercept0 - slope0 * yIntercept1) / (slope1 - slope0);
      x = (y - yIntercept0) / slope0;
    }
    return new PVector(x, y);
  }

  Shape shape() {
    return Shape.RECTANGLE;
  }
}
