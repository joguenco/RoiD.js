const customerService = require('./customer-service')

async function routeCustomer (fastify) {
  fastify.get('/customers/:identification',
    { onRequest: [fastify.jwtAuth] },
    async (req, res) => {
      const identification = req.params.identification

      const customer = await customerService.getByIdentification(fastify.db, identification)

      if (Object.keys(customer).length > 0) {
        res.code(200)
        return customer
      }

      res.code(404)
    })

  fastify.post('/customers',
    { onRequest: [fastify.jwtAuth] },
    async (req, res) => {
      const customer = req.body

      const result = await customerService.create(fastify.db, customer)

      if (result.created) {
        res.code(201)
        return result.customer
      }

      return result.customer
    })

  fastify.put('/customers/:code',
    { onRequest: [fastify.jwtAuth] },
    async (req, res) => {
      const code = req.params.code
      const result = await customerService.update(fastify.db, req.body, code)

      if (result.updated) {
        res.code(201)
        return result.customer
      }

      if (Object.keys(result.customer).length === 0) {
        res.code(404)
        return
      }

      res.code(409)
      return result.customer
    })

  fastify.delete('/customers/:identification',
    { onRequest: [fastify.jwtAuth] },
    async (req, res) => {
      const identification = req.params.identification
      const result = await customerService.remove(fastify.db, identification)

      if (result) {
        res.code(204)
        return
      }

      res.code(404)
    })
}

module.exports = routeCustomer
