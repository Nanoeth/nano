function tryTillResponse (txhash, done) {
  web3.eth.getTransactionReceipt(txhash, function (err, result) {
    if (!err && !result) {
      // Try again with a bit of delay
      setTimeout(function () { tryTillResponse(txhash, done) }, 500)
    } else {
      done(err, result)
    }
  })
}

function gup (name, url) {
  if (!url) url = location.href
  name = name.replace(/[\[]/, '\\\[').replace(/[\]]/, '\\\]')
  var regexS = '[\\?&]' + name + '=([^&#]*)'
  var regex = new RegExp(regexS)
  var results = regex.exec(url)
  return results == null ? null : results[1]
}

var gasLimit
function setGasLimit () {
  setTimeout(function () {
    web3.eth.getBlock('latest', function (err, block) {
      if (!err) {
        gasLimit = Math.floor(block.gasLimit - block.gasLimit / 1024)
      }
      setGasLimit()
    })
  }, 5000)
}
setGasLimit()
