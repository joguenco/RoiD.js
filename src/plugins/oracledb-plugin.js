const fp = require('fastify-plugin')
const oracledb = require('oracledb')

async function dbPlugin (server, opts) {
  oracledb.initOracleClient({ libDir: opts.libDir })
  let connection
  let run
  let fun

  try {
    run = async (sql, binds, autoCommit) => {
      connection = await oracledb.getConnection(opts.dbAccess)
      const result = await connection.execute(sql, binds, { autoCommit })

      return result
    }
  } catch (error) {
    connection.release()
  }

  try {
    fun = async (sql, binds) => {
      connection = await oracledb.getConnection(opts.dbAccess)
      const result = await connection.execute(sql, binds)

      return result
    }
  } catch (error) {
    connection.release()
  }

  server.decorate('db', { run, fun }).addHook('onClose', async (instance, done) => {
    // You can add a hook to close the database connection when the server closes
    await connection.close()
    done()
  })
}

module.exports = fp(dbPlugin)
