# control script for Torch control of browsers at remote displays
#
# list screens - list available screens for a control group # show screens - show overlays with aliases on screens for a control group
# list tabs on <screen> - list tab URLs on a screen
# show (<tab index>|<alias>|<url>) on <screen> (as <alias>) - change screen to given tab index or alias
# rotate <screen> every <time> - automatically advance through tabs every <time> interval
# close tab on <screen> - close current tab
# refresh <screen> - refreshes current tab on screen
# next <screen> - changes to next tab on screen
# prev(ious) <screen> - changes to previous tab on screen

qs = require 'querystring'

LIGHTER_ADDRESS = '10.10.1.107'

tellTorch = (msg, path, extra={}) ->
  data = qs.stringify extra
  path = path + '?' + data

  try
    msg.http('http://' + LIGHTER_ADDRESS)
      .path(path)
      .port('5000')
      .header('X-User', msg.message.user.name)
      .header('X-Channel', msg.message.user.room)
      .get() (err, res, body) ->
        if res.statusCode == 200
          body = "ok, sure" if body == "null"
          msg.send body
        else
          msg.send "your request is bad and you should feel bad"
  catch error
    msg.send "lighter shat itself: " + error

module.exports = (robot) ->
  robot.respond /list screens$/i, (msg) ->
    tellTorch msg, 'list'

  robot.respond /(show|enumerate|enum) screens$/i, (msg) ->
    tellTorch msg, 'enumerate'

  robot.respond /list tabs on (\w+)$/i, (msg) ->
    tellTorch msg, "#{msg.match[1]}/list"

  robot.respond /what's on (\w+)$/i, (msg) ->
    tellTorch msg, "#{msg.match[1]}/details"

  robot.respond /show (\S+) on (\w+)$/i, (msg) ->
    tellTorch msg, "#{msg.match[2]}/show", {'tab': msg.match[1]}

  robot.respond /close tab on (\w+)$/i, (msg) ->
    tellTorch msg, "#{msg.match[1]}/close"

  robot.respond /refresh (\w+)$/i, (msg) ->
    tellTorch msg, "#{msg.match[1]}/refresh"

  robot.respond /next tab on (\w+)$/i, (msg) ->
    tellTorch msg, "#{msg.match[1]}/next"

  robot.respond /prev(ious)? tab on (\w+)$/i, (msg) ->
    tellTorch msg, "#{msg.match[2]}/prev"

  robot.respond /fullscreen on (\w+)$/i, (msg) ->
    tellTorch msg, "#{msg.match[1]}/fullscreen_on"

  robot.respond /fullscreen off (\w+)$/i, (msg) ->
    tellTorch msg, "#{msg.match[1]}/fullscreen_off"

  robot.respond /rotate (\w+)(\severy)?(\d+)?(\ssecond)?s?$/i, (msg) ->
    time = parseInt(msg.match[3] or '5')
    tellTorch msg, "#{msg.match[1]}/rotate", {'enabled': true, 'time': time}

  robot.respond /stop rotating (\w+)$/i, (msg) ->
    tellTorch msg, "#{msg.match[1]}/rotate", {'enabled': false}

  robot.respond /peek(\sat)? (\S+) on (\w+)(\sfor)?(\d+)?(\ssecond)?s?$/i, (msg) ->
    time = parseInt(msg.match[5] or '15')
    tellTorch msg, "#{msg.match[3]}/peek", {'url': msg.match[2], 'duration': time}

  robot.respond /zoom in (\w+)$/i, (msg) ->
    tellTorch msg, "#{msg.match[1]}/zoom_in"

  robot.respond /zoom out (\w+)$/i, (msg) ->
    tellTorch msg, "#{msg.match[1]}/zoom_out"

  robot.respond /bring to front (\w+)$/i, (msg) ->
    tellTorch msg, "#{msg.match[1]}/bring_to_front"
