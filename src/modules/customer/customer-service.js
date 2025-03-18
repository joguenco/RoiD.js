const _ = require('lodash')

exports.getByIdentification = async (db, identification) => {
  const sql = `SELECT
                    code,
                    identification_type,
                    identification,
                    firstname,
                    lastname,
                    legal_name,
                    trade_name,
                    email,
                    address,
                    address_alternative,
                    phone,
                    seller_code,
                    observation
                FROM
                    v_customers
                WHERE
                    identification = :identification`

  const result = await db.run(sql, [identification], false)
  const customer = []

  result.rows.map(record => {
    const data = {
      code: record[0],
      identification_type: record[1],
      identification: record[2],
      firstname: record[3],
      lastname: record[4],
      legal_name: record[5],
      trade_name: record[6],
      email: record[7],
      address: record[8],
      address_alternative: record[9],
      phone: record[10],
      seller_code: record[11],
      observation: record[12]
    }

    return customer.push(data)
  })

  return _.mapKeys(customer[0], (value, key) => _.camelCase(key))
}

exports.getByCode = async (db, code) => {
  const sql = `SELECT
                    code,
                    identification_type,
                    identification,
                    firstname,
                    lastname,
                    legal_name,
                    trade_name,
                    email,
                    address,
                    address_alternative,
                    phone,
                    seller_code,
                    observation
                FROM
                    v_customers
                WHERE
                    code = :code`

  const result = await db.run(sql, [code], false)
  const customer = []

  result.rows.map(record => {
    const data = {
      code: record[0],
      identification_type: record[1],
      identification: record[2],
      firstname: record[3],
      lastname: record[4],
      legal_name: record[5],
      trade_name: record[6],
      email: record[7],
      address: record[8],
      address_alternative: record[9],
      phone: record[10],
      seller_code: record[11],
      observation: record[12]
    }

    return customer.push(data)
  })

  return _.mapKeys(customer[0], (value, key) => _.camelCase(key))
}

exports.create = async (db, customer) => {
  const customerExisted = await this.getByIdentification(db, customer.identification)

  if (Object.keys(customerExisted).length > 0) {
    return {
      created: false,
      customer: customerExisted
    }
  }

  const sql = `INSERT INTO v_customers (
                  identification_type,
                  identification,
                  firstname,
                  lastname,
                  legal_name,
                  trade_name,
                  email,
                  address,
                  address_alternative,
                  phone,
                  seller_code,
                  observation
                ) VALUES (:v1, :v2, :v3, :v4, :v5, :v6, :v7, :v8, :v9, :v10, :v11, :v12)`

  const params = [
    customer.identificationType,
    customer.identification,
    customer.firstname,
    customer.lastname,
    customer.legalName,
    customer.tradeName,
    customer.email,
    customer.address,
    customer.addressAlternative,
    customer.phone,
    customer.sellerCode,
    customer.observation
  ]

  const result = await db.run(sql, params, true)

  if (result.rowsAffected > 0) {
    const customerCreated = await this.getByIdentification(db, customer.identification)

    return {
      created: true,
      customer: customerCreated
    }
  }

  return {
    created: false,
    customer: {}
  }
}

exports.update = async (db, customer, code) => {
  const customerExisted = await this.getByCode(db, code)

  if (Object.keys(customerExisted).length === 0) {
    return {
      updated: false,
      customer: {}
    }
  }

  const sql = `UPDATE v_customers SET
                  identification_type = :v1,
                  identification = :v2,
                  firstname = :v3,
                  lastname = :v4,
                  legal_name = :v5,
                  trade_name = :v6,
                  email = :v7,
                  address = :v8,
                  address_alternative = :v9,
                  phone = :v10,
                  observation = :v11
                WHERE
                  code = :v12`

  const params = [
    customer.identificationType,
    customer.identification,
    customer.firstname,
    customer.lastname,
    customer.legalName,
    customer.tradeName,
    customer.email,
    customer.address,
    customer.addressAlternative,
    customer.phone,
    customer.observation,
    code
  ]

  const result = await db.run(sql, params, true)

  if (result.rowsAffected > 0) {
    const customerUpdated = await this.getByIdentification(db, customer.identification)

    return {
      updated: true,
      customer: customerUpdated
    }
  }

  return {
    updated: false,
    customer: await this.getByIdentification(db, customer.identification)
  }
}
exports.remove = async (db, identification) => {
  const sql = 'DELETE FROM v_customers WHERE identification = :identification'

  const result = await db.run(sql, [identification], true)

  if (result.rowsAffected > 0) {
    return true
  }

  return false
}
