-- {{{2 Volume Control
local wibox=require("wibox")
local awful=require("awful")

local volume_cardid  = 0
local volume_channel = "Master"
function volume (mode, widget)
  if mode == "update" then
    local fd = io.popen("amixer -c " .. volume_cardid .. " -- sget " .. volume_channel)
    local status = fd:read("*all")
    fd:close()
 
    local volume = string.match(status, "(%d?%d?%d)%%") or 0
    volume = string.format("% 3d", volume)
 
    status = string.match(status, "%[(o[^%]]*)%]") or ''
 
    if string.find(status, "on", 1, true) then
      volume = '♫' .. volume .. "%"
    else
      volume = '♫' .. volume .. '<span color="red">M</span>'
    end
    volume_widget:set_markup(volume)
  elseif mode == "up" then
    io.popen("amixer -q -c " .. volume_cardid .. " sset " .. volume_channel .. " 9%+"):read("*all")
    volume("update", widget)
  elseif mode == "down" then
    io.popen("amixer -q -c " .. volume_cardid .. " sset " .. volume_channel .. " 9%-"):read("*all")
    volume("update", widget)
  else
    io.popen("amixer -c " .. volume_cardid .. " sset " .. volume_channel .. " toggle"):read("*all")
    volume("update", widget)
  end
end

volume_clock = timer({ timeout = 10 })
volume_clock:connect_signal("timeout", function () volume("update", volume_widget) end)
volume_clock:start()
 
volume_widget = wibox.widget.textbox()
volume_widget:set_align("righ")
--volume_widget:set_width("45")
volume_widget:buttons(awful.util.table.join(
  awful.button({ }, 4, function () volume("up", volume_widget) end),
  awful.button({ }, 5, function () volume("down", volume_widget) end),
  awful.button({ }, 1, function () volume("mute", volume_widget) end)
))

volume("update", volume_widget)
