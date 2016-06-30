precision mediump float;

float noise(float x, float y) {
  return 0.0; // K.I.S.S.
}

float noise(float x, float y, float z) {
  return 0.0;
}

float noise(float x, float y, float z, float w) {
  return 0.0;
}

void main() {
  gl_FragColor = vec4(noise(gl_FragCoord.x, gl_FragCoord.y), 0, 0, 1);
}
