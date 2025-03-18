const productService = require('./product-service')

async function routeProduct (fastify) {
  fastify.get('/products/:warehouse/:batch/:name',
    { onRequest: [fastify.jwtAuth] },
    async (req, res) => {
      const warehouse = req.params.warehouse
      const batch = req.params.batch
      const name = req.params.name

      const products = await productService.getByName(fastify.db, name, warehouse, batch)

      return products
    })

  fastify.get('/products/price/:code/:unit',
    { onRequest: [fastify.jwtAuth] },
    async (req, res) => {
      const code = req.params.code
      const unit = req.params.unit

      const priceResult = JSON.parse(await productService.getPrice(fastify.db, code, unit))

      console.log('priceResult', priceResult)
      if (parseFloat(priceResult.price) < 0) {
        res.code(404)
      }

      res.code(200)
      return priceResult
    })

  fastify.get('/products/price/barcode/:barcode',
    { onRequest: [fastify.jwtAuth] },
    async (req, res) => {
      const barcode = req.params.barcode
      const priceResult = await productService.getPriceByBarcode(fastify.db, barcode)
      res.code(200)
      return priceResult
    })
}

module.exports = routeProduct
