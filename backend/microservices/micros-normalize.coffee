## Libs

## Code

MicroService = require('micros').MicroService
ms = new MicroService 'normalize'
ms.$set 'api', 'ws'

qc = 0.1
qc_tie = 1
qc_feedback = 1

# Calculate normalization: req.recommendations, req.activities
# Normalization means the readjustment of predictions against the qualifier
# the readjsutment works with the personal tie strength and the own item-feedback from friends
normalize = (req, res, next) ->
  tie = req.tie = 1
  req.recos = req.recos.filter (reco) ->
    feedback = reco.item.rating

    correlation = reco.prediction
    correlation = correlation * tie * qc_tie
    correlation = correlation * feedback * qc_feedback

    if correlation > qc
      reco.prediction = correlation
      true
    else false

  console.log req.recos
  next req, res

ms.$install normalize

## Module Export

module.exports = ms