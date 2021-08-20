void main() {
  // Center and normalize coordinate
  vec2 uv = (gl_FragCoord.xy - .5 * iResolution.xy) / iResolution.y;
  vec3 color = vec3(uv, 0.0);

  // Set the output color
  gl_FragColor = vec4(color, 1.0);
}
