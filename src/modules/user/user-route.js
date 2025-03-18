const userService = require('./user-service.js')

async function routeUser (fastify) {
  fastify.post('/signin', async (req, res) => {
    const userRequest = req.body

    const user = await userService.getByUsername(fastify.db, userRequest.username)

    if (!user) {
      res.code(404)
      return { message: 'User not found' }
    }

    const isValid = await userService.validatePassword(
      fastify.db, userRequest.password, user.password)

    if (!isValid) {
      res.code(401)
      return { message: 'Invalid password' }
    }

    const sellerParameter = await userService.getSellerParameterByUsername(
      fastify.db, userRequest.username)

    if (!sellerParameter) {
      res.code(404)
      return { message: 'Seller parameters not found' }
    }

    const token = fastify.jwt.sign({
      username: user.username,
      sellerCode: sellerParameter.sellerCode,
      sellerName: sellerParameter.sellerName,
      warehouse: sellerParameter.warehouse,
      batch: sellerParameter.batch
    })

    res.code(200)
    return { token }
  })
}

module.exports = routeUser
