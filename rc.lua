package.path= package.path .. ';/usr/lib/python2.7/site-packages/powerline/bindings/awesome/?.lua'
require('powerline')
-- Standard awesome library
local gears = require("gears")
--其他文件可能要用awful，所以还是用作全局变量吧
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

-- Other things
local vicious= require("vicious")
require("volume")
require("caplock")
require("multiscreen")
require("autostart")



-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/mark/.config/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
browser = "/opt/google/chrome/google-chrome %U --disk-cache-dir=/home/mark/temp/ "

terminal = "xfce4-terminal"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
alt = "Mod1"
super = "Mod4"


--naughty config
--naughty.config.defaults.timeout          = 5
--naughty.config.defaults.screen           = 1
--naughty.config.defaults.position         = "top_right"
--naughty.config.defaults.margin           = 4
naughty.config.defaults.height           = 26
naughty.config.defaults.width            = 100
naughty.config.defaults.gap              = 3
naughty.config.defaults.ontop            = true
naughty.config.defaults.font             = "Ubuntu Mono 11"
naughty.config.defaults.icon             = nil
naughty.config.defaults.icon_size        = 16
--naughty.config.defaults.fg               = beautiful.fg_focus or '#ffffff'
--naughty.config.defaults.bg               = beautiful.bg_focus or '#535d6c'
--naughty.config.presets.normal.border_color     = beautiful.border_focus or '#535d6c'
naughty.config.defaults.border_width     = 1
naughty.config.defaults.hover_timeout    = nil

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
    names = { "1","Web", "IM", "4","5", "6"},
    layout ={ layouts[3], layouts[3],layouts[2], layouts[4],layouts[1], layouts[3] }
}


tags[1] = awful.tag(tags.names, s, tags.layout)
if screen.count()>1 then
    for s =2, screen.count() do
	tags[s] = awful.tag({"1","2","3","4","5","6"}, s, tags.layout)
    end
end
--master width factor
awful.tag.setproperty(tags[1][4], "mwfact", 0.70)
--number of master windows
--awful.tag.setnmaster(2, tags[1][4])
--colum number of slave windows
--awful.tag.setncol(2, tags[1][4])


-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
}
powermenu ={
   { "Logout", awesome.quit },
   { "Poweroff", "systemctl poweroff"},
   { "Reboot", "systemctl reboot"},
   { "Suspend", "systemctl suspend"},
   { "Hibernate", "systemctl hibernate"},
}
mymenu = {
   { "Terminal", terminal },
   { "Terminator", "terminator" },
   { "Skype", "skype" },
   { "QQ", "qq2012" },
   { "Pidgin", "pidgin" },
   { "Smplayer", "smplayer" }
}
mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Power", powermenu},
				    { "Favorite", mymenu, beautiful.awesome_icon },
				    { "Browser", browser},
				    { "File Manager", "thunar"},
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
menubar.cache_entries = true
--menubar.app_folders = { "/home/mark/.local/share/applications/", "/usr/share/applications/" }  --无效，似乎是因为有bug,这里的app_folders值无法传到menubar/init.rc中的menubar.get()
menubar.menu_gen.all_menu_dirs={ "~/.local/share/applications/", "/usr/share/applications/" } 
menubar.show_categories = true   -- Change to false if you want only programs to appear in the menu
-- }}}

-- {{{ Wibox
-- my widget 
memwidget = wibox.widget.textbox()
mem_t = awful.tooltip({objects={memwidget} })
vicious.register(memwidget, vicious.widgets.mem, function(widget, args) mem_t:set_text(" RAM: " .. args[2] .. "MB / " .. args[3] .. "MB ")
                    return "Mem:"..args[1].."%"
                 end, 10)
wifiwidget = wibox.widget.textbox()
wifiicon = wibox.widget.imagebox()
vicious.register(wifiwidget, vicious.widgets.wifi, "SSID:${ssid} Q:${link}", 9,"wlp3s0")

 vicious.register(wifiicon, vicious.widgets.wifi,
           function (widget, args)
           link = args['{link}']
           -- wifiicon.visible = true	-- didnt help
           if link > 70 then
               wifiicon:set_image(beautiful.widget_wifi_hi)
           elseif link > 30 and link <= 70 then
               wifiicon:set_image(beautiful.widget_wifi_mid)
           elseif link > 0 and link <= 30 then
               wifiicon:set_image(beautiful.widget_wifi_low)
           else
               wifiicon:set_image(beautiful.widget_wifi_no)
           end
       end,3, "wlan0")
    


cpuwidget  = wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu, "CPU:$1%  ")
batwidget = wibox.widget.textbox()
vicious.register(batwidget, vicious.widgets.bat, "| $1$2 $3 | ", 31, "BAT0")

-- Create a textclock widget
mytextclock = awful.widget.textclock()
--require("calendar")
--calendar.addCalendarToWidget(mytextclock)



-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "bottom", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(powerline_widget)
    right_layout:add(cpuwidget)
    right_layout:add(memwidget)
    right_layout:add(batwidget)
    right_layout:add(wifiwidget)
    right_layout:add(wifiicon)
    right_layout:add(mylayoutbox[s])
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mytextclock)
    right_layout:add(caplock_widget)
    right_layout:add(volume_widget)


    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
    --下面两行是控制 在桌面滚动鼠标 切换tag的
    --awful.button({ }, 4, awful.tag.viewnext),
    --awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end),

    -- {{{mine
    --power control
    awful.key({modkey }, "t", function () awful.util.spawn("input") end),
    awful.key({ }, "XF86Sleep", function () awful.util.spawn("systemctl suspend") end),
    awful.key({ }, "XF86TouchpadOn", function () awful.util.spawn_with_shell("./scripts/touchpad-toggle.sh") end),
    awful.key({ }, "XF86TouchpadOff", function () awful.util.spawn_with_shell("./scripts/touchpad-toggle.sh") end),

    -- volume control
    awful.key({ }, "XF86AudioRaiseVolume", function () volume("up",tb_volume) end),
    awful.key({ }, "XF86AudioLowerVolume", function () volume("down",tb_volume) end),
    awful.key({ }, "XF86AudioMute", function () volume("mute",tb_volume) end),
    -- cap lock
    awful.key({ }, "Caps_Lock", function () caplock_toggle() end),
    
    -- App
    awful.key({ super,           }, "e", function () awful.util.spawn("thunar") end),
    awful.key({ super,           }, "c", function () awful.util.spawn_with_shell(browser) end),

    awful.key({ super,           }, "Print", function () awful.util.spawn_with_shell("sleep 0.1 && shootsc -d") end),
    awful.key({         "Control" }, "Print", function () awful.util.spawn_with_shell("sleep 0.1 && shootsc -s") end), --might be a bug, need sleep here to ensure the scrot -s 
    awful.key({                   }, "Print", function () awful.util.spawn_with_shell("shootsc") end),
    --demnu的快捷键，可能跟Menubar冲突
    awful.key({super }, "d", function() awful.util.spawn( "dmenu_run" ) end),

    awful.key({}, "XF86Display", xrandr)
    -- }}}
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({         "Mod1"	  }, "F4",     function (c) c:kill()                         end),
    awful.key({ modkey      	  }, "q",     function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "SmPlayer" },
      properties = { floating = true, tag = tags[1][1] } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "Gimp-2.8" },
      properties = { floating = true, tag = tags[1][6] } },
    { rule = { class = "Thunderbird" },
      properties = {  tag = tags[1][6] } },
    { rule = { class = "Geary" },
      properties = {  tag = tags[1][6] } },
-- IM
    { rule_any = { class = {"Pidgin","Skype"},  },
      properties = { tag = tags[1][3], switchtotag = true } },
    { rule  = { class = "Pidgin"},except ={ role= "buddy_list" },
      callback   = awful.client.setslave },
    { rule  = { class = "Skype", role= "ConversationsWindow" }, 
      callback   = awful.client.setslave },
    { rule  = { class = "Wine", instance= "QQ.exe" }, 
      properties = { tag = tags[1][3], floating = true } ,callback   = awful.client.setslave },

    { rule = { class  = "Google-chrome", role = "browser" },
       properties = { function(c)
                                  awful.client.movetotag(tags[mouse.screen][2], c)
				    client.focus = c
				    c:raise()
                                    end 
					    } },
    { rule = { instance = "plugin-container" },
      properties = { floating = true,
                     focus = yes } },

    { rule = { class = "net-minecraft-MinecraftLauncher" },
      properties = { floating = true } },
    { rule = { class = "Steam" },
      properties = {  tag = tags[1][5] } },
    {rule = {class = "Xfce4-notifyd", role = "xfce4-notifyd"},
	callback  = function (c) c.border_width=1000  end
    },
    {rule = {class = "Xfce4-termina"},
	callback  = function (c) c.border_width=1000  end
    }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    --[[
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)
    --]]
    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}


