exports.getByUsername = async (db, username) => {
  const sql = `SELECT
                  username,
                  password
              FROM
                  v_users
              WHERE 
                  username = :username
                  AND status = 'Active'`

  const result = await db.run(sql, [username], false)
  const user = []

  result.rows.map(record => {
    const data = {
      username: record[0],
      password: record[1]
    }

    return user.push(data)
  })

  return user[0]
}

exports.getSellerParameterByUsername = async (db, username) => {
  const sql = `SELECT
                  seller_code,
                  seller_name,
                  warehouse,
                  batch
              FROM
                  v_seller_parameters
              WHERE
                  username = upper(:username)`

  const result = await db.run(sql, [username], false)
  const sellerParameter = []

  result.rows.map(record => {
    const data = {
      sellerCode: record[0],
      sellerName: record[1],
      warehouse: record[2],
      batch: record[3]
    }

    return sellerParameter.push(data)
  })

  return sellerParameter[0]
}

exports.validatePassword = async (db, password, encryptedPassword) => {
  const sql = `SELECT
                  hash_md5(:password)
              FROM
                  dual`

  const result = await db.run(sql, [password], false)
  const md5Password = result.rows[0][0]

  if (md5Password === encryptedPassword) {
    return true
  }

  return false
}
