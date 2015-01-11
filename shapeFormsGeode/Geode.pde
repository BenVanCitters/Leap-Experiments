class Geode {
  float radiusMax;
  float noiseAmp;
  PShape mesh;
  color strokeColor;
  color fillColorLower;
  color fillColorUpper;
  int totalVertex, totalSegments;
  
  Geode(float _radiusMax, int _totalVertex, int _totalSegments, float _noiseAmp, color _strokeColor, color _fillColorLower, color _fillColorUpper ) {
    radiusMax = _radiusMax;
    totalVertex = _totalVertex;
    totalSegments = _totalSegments;
    noiseAmp = _noiseAmp;
    strokeColor = _strokeColor;
    fillColorLower = _fillColorLower;
    fillColorUpper = _fillColorUpper;

    generateMesh();
  }

  void generateMesh() {
    float[][]  currCircle = new float[totalVertex][3];
    color[] currColor = new color[totalVertex];
    color[] prevColor = new color[totalVertex];

    mesh = createShape();
    mesh.colorMode(HSB);
    mesh.beginShape(TRIANGLE_STRIP);
    mesh.textureMode(NORMAL); //constrain texture coordinates to 0-1
    mesh.specular(77);
    
    mesh.shininess(100);
    mesh.stroke(255);
    mesh.strokeWeight(5);

    float noiseAvg = ((1.0/totalSegments)+(1.0/totalVertex))*noiseAmp;
    float noiseMin = 1.0-noiseAvg;
    float noiseMax = 1.0+noiseAvg; 

    float radius = radiusMax;
    for (float j=0; j<totalSegments; j++) {
      float percentOuter = j/(totalSegments-1);
      radius = sin(PI*percentOuter)*radiusMax;

      float angleOuter = percentOuter*PI;
      prevColor = currColor;

      for (int i=0; i<totalVertex; i++) {
        float x=0, y=0, z=0;
        
        float percent = float(i)/(totalVertex-1);
        float angle = TWO_PI*percent;

        float _noise = random(noiseMin, noiseMax);
        float _radius = radius*_noise;
        color vertexColor = calculateFill(_noise, noiseMin,noiseMax);
        PVector norm;
        if (j>0) 
        {
          mesh.fill(prevColor[i]);
          
          norm = new PVector(x, y, z);
          norm.normalize();
          mesh.normal(norm.x, norm.y, norm.z);
          mesh.vertex(x, y, z, random(1), random(1));
        }

        if (i==totalVertex-1) {
          x = currCircle[0][0];
          y = currCircle[0][1];
          z = currCircle[0][2];
          vertexColor = currColor[0];
        } else {
          x = cos(angle)*_radius;
          y = sin(angle)*_radius;
          if (j==totalSegments-1 || j==0) 
            z = (cos(angleOuter)*radiusMax)*(noiseMin+noiseAvg);
          else 
            z = cos(angleOuter)*radiusMax*_noise;
        }

        norm = new PVector(x, y, z);
        norm.normalize();
        mesh.normal(norm.x, norm.y, norm.z);
        mesh.fill(vertexColor);
        mesh.vertex(x, y, z, random(1), random(1));

        currCircle[i][0] = x;
        currCircle[i][1] = y;
        currCircle[i][2] = z;

        currColor[i] = vertexColor;
      }
    }
    mesh.endShape(CLOSE);
  }

  color calculateFill(float _noise, float _noiseMin, float _noiseMax) {

    float _hue = map(_noise, _noiseMin, _noiseMax, hue(fillColorLower), hue(fillColorUpper));
    float _sat = map(_noise, _noiseMin, _noiseMax, saturation(fillColorLower), saturation(fillColorUpper));
    float _bright = map(_noise, _noiseMin, _noiseMax, brightness(fillColorLower), brightness(fillColorUpper));
    float _alpha = map(_noise, _noiseMin, _noiseMax, alpha(fillColorLower), alpha(fillColorUpper)); 

    color _fill = color(_hue, _sat, _bright,_alpha);
    //println(_fill );
    return _fill;
  }
} 
