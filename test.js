const tokenize = require('glsl-tokenizer')
const str = require('glsl-token-string')
const test = require('tape')
const path = require('path')
const shake = require('./')
const fs = require('fs')

test('glsl-token-function-shaker: gross.glsl', createTest('gross.glsl', true))
test('glsl-token-function-shaker: volcanic.glsl', createTest('volcanic.glsl', false))
test('glsl-token-function-shaker: seascape.glsl', createTest('seascape.glsl', false))
test('glsl-token-function-shaker: readme.glsl', createTest('readme.glsl', true))
test('glsl-token-function-shaker: no-args.glsl', createTest('no-args.glsl', false))

// NOTE: currently removes too much due to the presence of functions in #defines
// Probably needs to resolve all the preprocessors beforehand in a separate package?
test('glsl-token-function-shaker: clouds.glsl', createTest('clouds.glsl', true))

function createTest (file, shouldModify, shouldLog) {
  return function (t) {
    const fixture = fs.readFileSync(path.join(__dirname, 'fixtures', file), 'utf8')
    const tokens = tokenize(fixture)
    const stats = shake(tokens)

    const orig = fixture
    const next = str(tokens)
    if (shouldLog) console.error(next)

    t.ok(stats.iterations, 'ran at least one iteration')

    if (shouldModify) {
      t.ok(stats.functionsRemoved, 'removed at least one function')
      t.ok(stats.tokensRemoved, 'removed at least one token')
      t.ok(next.length < orig.length, 'reduced final size (' + (100 * next.length / orig.length).toFixed(3) + '% of original)')
    } else {
      t.ok(!stats.functionsRemoved, 'did not need to remove any functions')
      t.ok(!stats.functionsRemoved, 'did not need to remove any tokens')
      t.ok(next === orig, 'shader went completely untouched')
    }

    t.end()
  }
}
