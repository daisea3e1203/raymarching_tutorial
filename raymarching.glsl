precision highp float;

// Constants
// ----------------------------------------
#define PI 3.1415925359
#define TWO_PI 6.2831852
#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURFACE_DIST .01

// Geometry
// ----------------------------------------
// Distance from the plane at y=0
float distPlane(vec3 p) {
  // Distance from the global plane
  return p.y;
}

// Distance from the sphere
float distSphere(vec3 p) {
  // Sphere: (x, y, z, r)
  vec4 s = vec4(0, 1, 6. + sin(iTime) * 3., 1.);
  // Distance from the surface of the sphere
  return length(p - s.xyz) - s.w;
}

// Calculate the distance to the nearest geometry from given position p
float getDist(vec3 p) {
  // The minimum distance regarding all geometry
  float d = min(distSphere(p), distPlane(p));

  return d;
}

float rayMarch(vec3 ro, vec3 rd) {
  float d0 = 0.;
  for (int i = 0; i < MAX_STEPS; i++) {
    // Calculate the distance to the closest geometry,
    // and move by that distance
    vec3 p = ro + rd * d0;
    float ds = getDist(p);
    d0 += ds;
    // Quit if too close to any geo, or to far from all geo
    if (d0 > MAX_DIST || ds < SURFACE_DIST)
      break;
  }
  return d0;
}

void main() {
  // Center and normalize coordinate
  vec2 uv = (gl_FragCoord.xy - .5 * iResolution.xy) / iResolution.y;
  // Ray origin (Camera Position)
  vec3 ro = vec3(0, 1, 0);
  // Ray direction
  // Third dimension represents the focal length
  vec3 rd = normalize(vec3(uv.x, uv.y, 1));
  float d = rayMarch(ro, rd);
  // (Depends on the scene scale)
  d /= 10.;
  vec3 color = vec3(d);

  // Set the output color
  gl_FragColor = vec4(color, 1.0);
}