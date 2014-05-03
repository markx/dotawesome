local wibox=require("wibox")
local awful=require("awful")
local naughty=require("naughty")

local caplock_state = nil
local nid = nil

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
	nid=naughty.notify({text = "Caplock Disabled",position="bottom_right",bg='#3D3D3D', fg='#ffffff',width = 130,height=50,timeout=3,replaces_id=nid}).id

    elseif caplock_state == '0' then
	caplock_state='1'
	text = "|A|" 
	nid=naughty.notify({text = "Caplock Enabled",position="bottom_right",bg='#3D3D3D',fg='#00FF00', width = 120,height=50,timeout=3,replaces_id=nid}).id
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
caplock_widget:set_font("DejaVuSansMono 11")
caplock_update()




