const oracledb = require('oracledb')
const _ = require('lodash')

exports.getByName = async (db, name, warehouse, batch) => {
  const sql = `BEGIN
                :result := PKG_QUOTATION.FUN_PRODUCT_JSON(:name, :warehouse, :batch);
              END;`

  const resultProducts = await db.fun(sql,
    {
      name,
      warehouse,
      batch,
      result: { dir: oracledb.BIND_OUT, type: oracledb.STRING, maxSize: 900000 }
    }
  )

  return resultProducts.outBinds.result
}

exports.getPrice = async (db, code, unit) => {
  const sql = `BEGIN
                :result := PKG_QUOTATION.FUN_PRICE_JSON(:code, :unit);
              END;`

  const resultProducts = await db.fun(sql,
    {
      code,
      unit,
      result: { dir: oracledb.BIND_OUT, type: oracledb.STRING, maxSize: 900000 }
    }
  )

  return resultProducts.outBinds.result
}

exports.getPriceByBarcode = async (db, barcode) => {
  const sql = `select 
                code, barcode, name, price, uom 
                from v_product_prices 
                where barcode = :barcode`

  const result = await db.run(sql, [barcode])

  const product = []

  result.rows.map(record => {
    const data = {
      code: record[0],
      barcode: record[1],
      name: record[2],
      price: record[3],
      uom: record[4]
    }
    return product.push(data)
  }
  )

  return _.mapKeys(product[0], (value, key) => _.camelCase(key))
}
