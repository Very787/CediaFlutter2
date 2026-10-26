const test = require('node:test');
const assert = require('node:assert/strict');
const {resources} = require('../server');

test('el catálogo remoto contiene al menos 20 registros propios', () => {
  assert.equal(resources.length, 20);
  assert.ok(resources.every((item) => item.id && item.title && item.description));
});
