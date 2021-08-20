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
  // vec4 s = vec4(0, 1, 6. + sin(iTime) * 3., 1.);
  vec4 s = vec4(0, 1, 6., 1.);
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

vec3 getNormal(vec3 p) {
  float d = getDist(p);
  // (Epsilon)
  vec2 e = vec2(.01, 0);

  // First order approximation of the derivitive (Forward difference)
  // vec3 n = d - vec3(getDist(p - e.xyy), getDist(p - e.yxy), getDist(p -
  // e.yyx));

  // First order approximation of the derivitive
  vec3 n = vec3(getDist(p + e.xyy) - getDist(p - e.xyy),
                getDist(p + e.yxy) - getDist(p - e.yxy),
                getDist(p + e.yyx) - getDist(p - e.yyx));

  // Normalize vector because n represents a direction.
  return normalize(n);
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
  vec3 p = ro + rd * d;
  // (Depends on the scene scale)
  float zdepth = d / 10.;
  vec3 normal = getNormal(p);

  // Set the output color
  gl_FragColor = vec4(normal, 1.0);
}