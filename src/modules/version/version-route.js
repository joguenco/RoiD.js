const { platform, release, arch } = require('os')
const pkg = require('../../../package.json')

async function routeVersion (fastify) {
  const sql = `SELECT banner FROM v$version
    WHERE banner LIKE 'Oracle%'
    and ROWNUM = 1`

  const result = await fastify.db.run(sql, [], false)

  fastify.get('/version', async (req, rep) => {
    try {
      return {
        name: 'RoiD.js',
        author: pkg.author,
        version: pkg.version,
        versionOS: platform() + ' ' + release() + ' ' + arch(),
        versionRuntime: `Node ${process.version}`,
        versionSqlDatabase: result.rows[0][0]
      }
    } catch (e) {
      rep.code(500)
      return { error: e.message }
    }
  })
}

module.exports = routeVersion
