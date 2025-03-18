const fastify = require('fastify')
const cors = require('@fastify/cors')
const dotenv = require('dotenv')
const serverOptions = require('./util/logger.js')
const dbOracle = require('./plugins/oracledb-plugin.js')
const jwt = require('./plugins/jwt-plugin.js')

const routePing = require('./modules/ping/ping-route.js')
const routeVersion = require('./modules/version/version-route.js')
const routeIdentification = require('./modules/identification/indentification-route.js')
const routeCustomer = require('./modules/customer/customer-route.js')
const routeUser = require('./modules/user/user-route.js')
const routeProduct = require('./modules/product/product-route.js')
const routeQuotation = require('./modules/quotation/quotation-route.js')

dotenv.config({ path: '.env' })

const server = fastify(serverOptions)

server.register(cors, {})

server.register(require('@fastify/jwt'), {
  secret: process.env.SECRET_KEY
})

server.register(dbOracle, {
  dbAccess: {
    user: process.env.NODE_ORACLEDB_USER || 'hr',
    password: process.env.NODE_ORACLEDB_PASSWORD || 'hr',
    connectString: process.env.NODE_ORACLEDB_CONNECTIONSTRING || 'localhost/xe'
  },
  libDir: process.env.NODE_ORACLEDB_LIBDIR
})

server.register(jwt)

if (process.env.NODE_ENV === 'development') {
  server.register(routeVersion)
}

server.register(routePing)
server.register(routeIdentification)
server.register(routeCustomer)
server.register(routeUser)
server.register(routeProduct)
server.register(routeQuotation)

const start = async () => {
  try {
    await server.listen({ port: 3000, host: '0.0.0.0' })
  } catch (err) {
    server.log.error(err)
    process.exit(1)
  }
}

start()
