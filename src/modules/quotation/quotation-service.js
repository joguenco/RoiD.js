const oracledb = require('oracledb')

exports.saveQuotation = async (db, quotation) => {
  const sql = `BEGIN
                :result := pkg_quotation.fun_save_quotation('${quotation}');
              END;`

  const resultProducts = await db.fun(sql,
    {
      result: { dir: oracledb.BIND_OUT, type: oracledb.STRING, maxSize: 9000 }
    }
  )

  return resultProducts.outBinds.result
}
