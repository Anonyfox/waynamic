## Libs

## Code

MicroService = require('micros').MicroService
ms = new MicroService 'normalize'
ms.$set 'api', 'ws'

qc = 0.1
qc_tie = 1
qc_feeback = 1

# Calculate normalization: req.recommendations, req.activities
# Normalization means the readjustment of predictions against the qualifier
# the readjsutment works with the personal tie strength and the freinds own feedback
normalize = (req, res, next) ->
  recos = req.recos.reduce( (akk, reco) ->
    feedback = reco.item.feedback
    tie = user.tie

    correlation = reco.prediction
    correlation = correlation * tie * qc_tie
    correlation = correlation * feedback * qc_feedback

    if correlation > qc
      reco.prediction = correlation
      akk.push reco
    else akk
  , [])

  next req, res

ms.$install normalize

## Module Export

module.exports = ms