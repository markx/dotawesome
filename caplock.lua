local wibox=require("wibox")
local awful=require("awful")

function caplock_update ()
    local fd = io.popen("xset -q")
    local state = fd:read("*a")
    fd:close()
    caplock_state = string.match(state, "LED mask:%s+%d%d%d%d%d%d%d(%d)")
    if caplock_state == "1" then
	--the last state is "ON", so now it should be "OFF"
	text = "|A|" 
    elseif caplock_state == '0' then
	text = "|a|" 
    else
	text= 'unknown'
    end
    caplock_widget:set_markup(text)

end 

function caplock_toggle ()

    if caplock_state == "1" then
	--the last state is "ON", so now it should be "OFF"
	caplock_state='0'
	text = "|a|" 
    elseif caplock_state == '0' then
	caplock_state='1'
	text = "|A|" 
    else
	text= 'unknown'
    end
    --naughty.notify({title=caplock_state})
    caplock_widget:set_markup(text)
    --caplock_widget:set_text(text)
end

caplock_clock = timer({timeout = 30})
caplock_clock:connect_signal("timeout", function () caplock_update() end )
caplock_clock:start()

caplock_widget = wibox.widget.textbox()
caplock_widget:set_align("left")
caplock_widget:set_font("Mono 10")
caplock_update()




