const quotationService = require('./quotation-service.js')

async function routeQuotation (fastify) {
  fastify.post('/quotes',
    { onRequest: [fastify.jwtAuth] },
    async (req, res) => {
      const quotation = JSON.stringify(req.body)

      const result = await quotationService.saveQuotation(fastify.db, quotation)

      return result
    })
}

module.exports = routeQuotation
