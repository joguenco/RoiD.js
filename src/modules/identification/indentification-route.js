const identificationService = require('./identification-service')

async function routeIdentification (fastify) {
  fastify.get('/identifications/types',
    { onRequest: [fastify.jwtAuth] },
    async () => {
      return identificationService.getAll(fastify.db)
    })
}

module.exports = routeIdentification
