const fp = require('fastify-plugin')

module.exports = fp(async function (fastify) {
  fastify.decorate('jwtAuth', async function (request, reply) {
    try {
      await request.jwtVerify()
    } catch (err) {
      reply.status(401).send({ message: 'Unauthorized' })
    }
  })
})
