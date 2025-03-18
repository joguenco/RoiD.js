const serverOptions = {
  logger: {
    level: 'debug',
    transport: {
      targets: [
        {
          target: 'pino/file',
          options: {
            destination: require('path').join(__dirname,
              '../../server.log')
          },
          level: 'trace'
        },
        {
          target: 'pino/file',
          options: { destination: 1 }
        },
        {
          target: 'pino-pretty'
        }
      ]
    }
  }
}

module.exports = serverOptions
