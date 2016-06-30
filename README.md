# glsl-token-function-shaker

Shakes out any unused functions from your GLSL shaders. Especially useful alongside tools such as [glslify](https://github.com/stackgl/glslify).

This is done by running through your shader and checking that each function is actually called. This even works with functions that share the same name but use a different number of arguments! For example, take the following shader:

``` glsl
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
```

After running it through `glsl-token-function-shaker`, you should get something like this in return:

``` glsl
precision mediump float;

float noise(float x, float y) {
  return 0.0; // K.I.S.S.
}

void main() {
  gl_FragColor = vec4(noise(gl_FragCoord.x, gl_FragCoord.y), 0, 0, 1);
}
```

This keeps the size of your shaders down, but can also be used to cut out errors in unused functions.

## Usage

Install `glsl-token-function-shaker` using [npm](https://npmjs.com/):

``` bash
npm install --save glsl-token-function-shaker
```

### `shake(tokens[, options])`

Takes an array of `tokens` from [glsl-tokenizer](https://github.com/stackgl/glsl-tokenizer) and removes unused functions. Accepts the following options:

* `ignore`: an array of strings containing the names of functions you'd like to keep in the shader, even if they're not being used. `void main();` is always preserved, as is the last function in the shader.

Modifies the `tokens` array in place, and returns some simple stats:

* `functionsRemoved`: the number of function declarations removed.
* `tokensRemoved`: the number of GLSL tokens removed.
* `iterations`: the number of function shaking iterations made.

``` javascript
const shake = require('glsl-token-function-shaker')
const stringify = require('glsl-token-string')
const tokenize = require('glsl-tokenizer')
const fs = require('fs')

const src = fs.readFileSync('shader.glsl', 'utf8')
const tokens = tokenize(src)

shake(tokens, { ignore: ['vert'] })

const shaken = stringify(tokens)
```

## License

MIT, see [LICENSE.md](LICENSE.md) for details.
