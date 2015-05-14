# Description:
#   Display browser support stats for a requested feature from caniuse.com
#
# Dependencies:
#   "fuzzy": "^0.1.0",
#   "request": "^2.51.0"
#
# Configuration:
#   NONE
#
# Commands:
#   hubot caniuse|can I use <feature name>
#
# Notes:
#   This might not ever work
#
# Author:
#   altryne

request = require 'request'
fuzzy = require 'fuzzy'
_ = require 'lodash'

exports.caniuse_data = []
url = "https://raw.github.com/Fyrd/caniuse/master/data.json"
request {url: url}, (err, res, body) ->
  if err
    console.log "Errors getting url: #{url}"
    return
  exports.caniuse_data = JSON.parse(body).data

module.exports = (robot) ->
  robot.respond /(?:can.?i.?use )(.*)/i, (msg) ->
    results = fuzzy.filter(msg.match[1], Object.keys(exports.caniuse_data))
    if results.length > 2
      msg.send "Found more than #{results.length - 1} results, please narrow down your search to one of the following: \n `#{_.pluck(results, 'string').join(', ')}`"
    else if results.length > 0
      msg.send prepareResult result for result in results
    else
      msg.send "Nothing found for query *#{msg.match[1]}*, try something else or go to caniuse.com yourself"

prepareResult = (result) ->
  res_obj = exports.caniuse_data[result.string]
  return "*#{res_obj.title}* (http://caniuse.com/#feat=#{result.string}):\n `#{browserVersion res_obj.stats}`"

browserVersion = (stats) ->
  support = []
  for browser, stat of stats
    supported = []
    for v, res of stat
      switch res
        when "y", "y x"
          supported.push v.split('-')[0]
    min_supported = _.min(supported, (x) -> parseFloat(x))
    min_supported_clean = if (min_supported == Infinity) then "-" else "#{min_supported}+"
    support.push "#{browser}:#{min_supported_clean}"
  return support.join(', ')
