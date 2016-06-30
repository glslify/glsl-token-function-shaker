precision mediump float;

vec4 test() {
  return vec4(1, 0, 1, 1);
}

void main() {
  gl_FragColor = test();
}
