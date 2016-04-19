var request = require('request')
var username = 'zachstednick@yahoo.com'
var password = 'XA86SK3FZ4Zs'
var options = {
      url: 'http://secure.prontocycleshare.com/profile/login',
          auth: {
                 user: username,
                 password: password
                                                }
}

request(options, function (err, res, body) {
      if (err) {
                  console.dir(err)
                  return
                    }
            console.dir('headers', res.headers)
            console.dir('status code', res.statusCode)
            console.dir(body)
})

