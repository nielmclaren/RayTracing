
class Rectangle extends Object {
  private float _x;
  private float _y;
  private float _width;
  private float _height;
  private PVector _topLeft;
  private PVector _topRight;
  private PVector _bottomRight;
  private PVector _bottomLeft;

  Rectangle(float x, float y, float width, float height) {
    _x = x;
    _y = y;
    _width = width;
    _height = height;

    _topLeft = new PVector(_x, _y);
    _topRight = new PVector(_x + _width, _y);
    _bottomRight = new PVector(_x + _width, _y + _height);
    _bottomLeft = new PVector(_x, _y + _height);
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
    if (d1.x == 0) {
      if (d0.x == 0) {
        return null;
      }

      float slope0 = d0.y / d0.x;
      float yIntercept0 = p0.y - p0.x * slope0;
      return new PVector(p1.x, p1.x * slope0 + yIntercept0);
    } else if (d1.y == 0) {
      if (d0.y == 0) {
        return null;
      }

      float slope0 = d0.y / d0.x;
      float yIntercept0 = p0.y - p0.x * slope0;
      return new PVector((p1.y - yIntercept0) / slope0, p1.y);
    }
    else {
/*
      float raySlope = rayDirection.y / rayDirection.x;
      float lineSlope = lineDirection.y / lineDirection.y;
      float rayYIntercept = rayPoint.y - rayPoint.x * rayDirection.y / rayDirection.x;
      float lineYIntercept = endpoint0.y - endpoint0.x * lineDirection.y / lineDirection.x;
      float x = (lineYIntercept - rayYIntercept) / (raySlope - lineSlope);
      float y = x * raySlope + rayYIntercept;

      PVector result = new PVector(x, y);
      float lineLength = PVector.dist(endpoint0, endpoint1);
      if (PVector.dist(endpoint0, result) < lineLength && PVector.dist(endpoint1, result) < lineLength) {
        return result;
      }
*/
    }
    return null;
  }

  String shape() {
    return "rectangle";
  }
}
