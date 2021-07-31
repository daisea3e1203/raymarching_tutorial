precision highp float;

// Constants
// ----------------------------------------
#define PI 3.1415925359
#define TWO_PI 6.2831852
#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURFACE_DIST .01

// Xforms
// ----------------------------------------
mat4 translate(vec3 t) {
  return mat4(1., 0, 0, -t.x, 0, 1, 0, -t.y, 0, 0, 1, -t.z, 0, 0, 0, 1);
}

mat4 rotateX(float angle) {
  float c = cos(angle);
  float s = sin(angle);
  return mat4(1, 0., 0, 0, 0, c, -s, 0, 0, s, c, 0, 0, 0, 0, 1);
}

mat4 rotateY(float angle) {
  float c = cos(angle);
  float s = sin(angle);
  return mat4(c, 0., s, 0, 0, 1, 0, 0, -s, 0, c, 0, 0, 0, 0, 1);
}

mat4 rotateZ(float angle) {
  float c = cos(angle);
  float s = sin(angle);
  return mat4(c, -s, 0., 0, s, c, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
}

// Geometry
// ----------------------------------------
// Plane (y=0)
float distPlane(vec3 p) {
  // Distance from the global plane
  return p.y;
}
// Box
float distBox(vec3 p, vec3 r) {
  vec3 q = abs(p) - r;
  return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}
// Sphere
float distSphere(vec3 p, float r) {
  // Random displacement
  float disp = sin(5.0 * p.x + iTime) * sin(5.0 * p.y) * sin(5.0 * p.z) * 0.15;
  // Distance from the surface of the sphere
  return length(p) - r + disp;
}
// Calculate the distance to the nearest geometry from given position p
float getDist(vec3 p) {
  // The minimum distance regarding all geometry
  // float d = min(distSphere(p), distPlane(p));
  // float d = min(box, distPlane(p));
  vec4 boxP = vec4(p, 1.) * translate(vec3(1, 1, 6.)) * rotateY(iTime * 0.5) *
              rotateX(20.);
  vec4 sphereP = vec4(p, 1.) * translate(vec3(-1., 1., 6.));
  float d = min(min(distBox(boxP.xyz, vec3(0.5)), distPlane(p)),
                distSphere(sphereP.xyz, 0.75));
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

  return normalize(n);
}

float getLight(vec3 p) {
  // Light position
  vec3 lightPos = vec3(5. * sin(iTime), 5., 5.0 * cos(iTime));
  // Light vector
  vec3 l = normalize(lightPos - p);
  vec3 n = getNormal(p);

  // Diffuse Lighting
  float dif = dot(n, l);
  dif = clamp(dif, 0., 1.);

  // Shadows
  float d = rayMarch(p + n * SURFACE_DIST * 15., l);

  if (d < length(lightPos - p))
    dif *= .1;

  return dif;
}

void main() {
  // Center and normalize coordinate
  vec2 uv = (gl_FragCoord.xy - .5 * iResolution.xy) / iResolution.y;
  // Ray origin (Camera Position)
  vec3 ro = vec3(0, 1, 0);
  // Ray direction
  //     Third dimension represents the focal length
  vec3 rd = normalize(vec3(uv.x, uv.y, 1));
  float d = rayMarch(ro, rd);
  // Surface Position
  vec3 p = ro + rd * d;
  // Diffuse Lighting
  float dif = getLight(p);
  vec3 albedo = vec3(1.0, 1.0, 1.0);
  vec3 color = vec3(dif) * albedo;

  // Set the output color
  gl_FragColor = vec4(color, 1.0);
}