async function routePing (fastify) {
  fastify.get('/ping', async () => {
    return { message: 'pong' }
  })
}

module.exports = routePing
