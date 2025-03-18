exports.getAll = async (db) => {
  const sql = 'SELECT code, name FROM v_identification_type'

  const result = await db.run(sql, [], false)
  const identification = []

  result.rows.map(record => {
    const data = {
      code: record[0],
      name: record[1]
    }

    return identification.push(data)
  })

  return identification
}
