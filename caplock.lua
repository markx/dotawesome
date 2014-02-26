local wibox=require("wibox")
local awful=require("awful")

function init ()
    local fd = io.popen("xset -q")
    local state = fd:read("*a")
    fd:close()
    state = string.match(state, "LED mask:%s+%d%d%d%d%d%d%d(%d)")
    return state

end

function caplock_update (widget)

    if caplock_state == "1" then
	caplock_state='0'
	text = "| A |" 
    elseif caplock_state == '0' then
	caplock_state='1'
	text = "| a |" 
    else
	text= 'unknown'
    end
    --naughty.notify({title=caplock_state})
    --caplock_widget:set_markup(text)
    caplock_widget:set_text(text)
end

--caplock_clock = timer({timeout = 30})
--volume_clock:connect_signal("timeout", function () caplock_update(caplock_widget)end )
--caplock_clock:start()

caplock_widget = wibox.widget.textbox()
volume_widget:set_align("left")
caplock_state=init()
caplock_update(caplock_widget)





