const fp = require('fastify-plugin')

async function helloPlugin (fastify) {
  fastify.decorate('hello', (name) => {
    return `Hello ${name}!`
  })
}

module.exports = fp(helloPlugin)
