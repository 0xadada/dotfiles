local gears     = require("gears")
local awful     = require("awful")
awful.rules     = require("awful.rules")
                  require("awful.autofocus")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local naughty   = require("naughty")
local menubar   = require("menubar")
vicious         = require("vicious")
vicious_contrib = require("vicious.contrib")
local lain      = require("lain")
local io        = { popen = io.popen }

-- Error handling ------------------------------------------------------
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

-- Variable definitions ------------------------------------------------
-- Themes define colours, icons, font and wallpapers.
local home        = os.getenv("HOME")
local themes_root = "/usr/share/awesome/themes/"
local themes_home = home .. "/.config/awesome/themes/"
beautiful.init(themes_home .. "gruvbox" .. "/theme.lua")
terminal          = "urxvt"
editor            = os.getenv("EDITOR") or "nano"
editor_cmd        = terminal .. " -e " .. editor
modkey            = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
theme.useless_gap_width   = 50
theme.zenburn_icons       = "/usr/share/awesome/themes/zenburn/layouts/"
theme.lain_icons          = "/usr/share/awesome/lib/lain/icons/layout/zenburn/"
theme.layout_uselesspiral = theme.zenburn_icons .. "spiral.png"
theme.layout_uselesstile  = theme.zenburn_icons .. "tile.png"
theme.layout_centerwork   = theme.lain_icons .. "centerwork.png"
local layouts =
{
    lain.layout.uselesspiral,            -- 1
    lain.layout.uselesstile,             -- 2
    lain.layout.centerwork,              -- 3
    awful.layout.suit.tile,              -- 4
    awful.layout.suit.max.fullscreen,    -- 5
    -- awful.layout.suit.tile,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.floating,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.magnifier
}

-- Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end

-- Tags ----------------------------------------------------------------
-- Define a tag table which hold all screen tags.
tags = {
    names  = { "🌎", "📃", "⌨", "💬", "📧", "🔊", "📀", },
    layout = { layouts[1], layouts[3], layouts[4],
               layouts[3], layouts[1], layouts[1],
               layouts[3] }
}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, tags.layout)
end

-- Menu ----------------------------------------------------------------
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it


-- Wibox ---------------------------------------------------------------
-- CPU temperature widget
cputempwidget = wibox.widget.textbox()
-- Register widget
vicious.register(cputempwidget,
    vicious.widgets.thermal,
    function(cputempwidget, args)
        temp_c = args[1]
        temp_f = math.floor( (temp_c * 1.8) + 32 )
        markup = '<span color="%s"><span font="Symbola 12">🌡</span>%s%s°F</span>'
        if temp_f > 200 then
            return string.format(markup, '#cc241d', '☠☠☠', temp_f)
        elseif temp_f > 176 then
            return string.format(markup, '#cc241d', '☠', temp_f)
        elseif temp_f > 158 then
            return string.format(markup, '#fabd2f', '', temp_f)
        elseif temp_f > 150 then
            return string.format(markup, '#fabd2f', '', temp_f)
        else
            return string.format(markup, '#83a598', '', temp_f)
        end
    end,
    20,
    "thermal_zone0")

-- CPU frequency widget
cpufreqwidget = wibox.widget.textbox()
-- Determine the number of CPUs we have
local nproc_f = io.popen("nproc")
local num_cpus = 1
for line in nproc_f:lines() do
    num_cpus = tonumber(line)
end
num_cpus = num_cpus - 1
-- Register widget
vicious.register(cpufreqwidget,
    vicious.widgets.cpufreq,
    function(cpufreqwidget, args)
        freqv_mhz = math.floor(args[1])
        freqv_ghz = math.floor(args[2])
        freqv_mv  = args[3]
        freqv_v   = args[4]
        governor  = args[5]
        markup = '<span color="%s">%s%sMHz</span>'
        if freqv_mhz > 2500 then
            return string.format(markup, '#cc241d', governor, freqv_mhz)
        elseif freqv_mhz > 1500 then
            return string.format(markup, '#fabd2f', governor, freqv_mhz)
        else
            return string.format(markup, '#83a598', governor, freqv_mhz)
        end
    end,
    10,
    "cpu" .. math.random(0, num_cpus))

-- Initialize CPU widget
cpuwidget = awful.widget.graph()
-- Graph properties
cpuwidget:set_width(32)
cpuwidget:set_background_color("#282828")
cpuwidget:set_color({ type = "linear",
                      from = { 0, 0 },
                      to = { 10,0 },
                      stops = { {0, "#cc241d"},
                                {0.5, "#689d6a"},
                                {1, "#83a598" }}
                    })
-- Register widget
vicious.register(cpuwidget, vicious.widgets.cpu, " $1 ")

-- Memory usage widget
memwidget = wibox.widget.textbox()
-- Register widget
vicious.register(memwidget,
    vicious.widgets.mem,
    function(memwidget, args)
        markup = '<span color="%s">📈%s</span> '
        percent_used = args[1]
        if percent_used > 85 then
            return string.format(markup, '#cc241d', percent_used .. '%')
        elseif percent_used > 70 then
            return string.format(markup, '#fabd2f', percent_used .. '%')
        else
            return string.format(markup, '#ebdbb2', percent_used .. '%')
        end
    end,
    30)

-- Network widget
-- Initialize widget
netwidget = wibox.widget.textbox()
-- Register widget
vicious.register(netwidget,
    vicious_contrib.net,
    '<span color="#d3869b">📶${total down_kb}↙️</span>' ..
    '<span color="#83a598">↗️${total up_kb}</span> ')

-- Battery text widget
battextwidget = wibox.widget.textbox()
vicious.register(battextwidget,
    vicious.widgets.bat,
    function(battextwidget, args)
        markup = '<span color="%s">🔋%s %s ⌛%s <span font="Symbola 10">⚠️</span>%s</span> '
        bat_state      = args[1]
        percent_remain = args[2]
        time_left      = args[3]
        wear           = args[4]
        if bat_state ~= "⌁" then
            if percent_remain < 15 then
                return string.format(markup, '#cc241d', bat_state,
                                     percent_remain .. '%', time_left, wear)
            else
                return string.format(markup, '#8ec07c', bat_state,
                                     percent_remain .. '%', time_left, wear)
            end
        else
            return ''
        end
    end,
    61,
    "BAT0")

-- Volume text widget
volumewidget = wibox.widget.textbox()
vicious.register(volumewidget,
    vicious.widgets.volume,
    function(volumewidget, args)
        markup = '<span color="%s">%s%s</span> '
        emoji  = args[2]
        volume = args[1]
        if volume >= 90 then
            -- Red
            return string.format(markup, '#cc241d', emoji, volume)
        elseif volume >= 75 then
            -- Orange
            return string.format(markup, '#fabd2f', emoji, volume)
        else
            -- Gray
            return string.format(markup, '#ebdbb2', emoji, volume)
        end
    end,
    2,
    'Master')

-- Create a textclock
datetimewidget = wibox.widget.textbox()
vicious.register(datetimewidget,
    vicious.widgets.date,
    '<span>%a %b %d, %H:%M</span>',
    30)

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
    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end))
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ },
                        1,
                        function (c)
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
                     awful.button({ },
                        3,
                        function ()
                          if instance then
                              instance:hide()
                              instance = nil
                          else
                              instance = awful.menu.clients({
                                  theme = { width = 250 }
                              })
                          end
                        end),
                     awful.button({ },
                        4,
                        function ()
                          awful.client.focus.byidx(1)
                          if client.focus then client.focus:raise() end
                        end),
                     awful.button({ },
                        5,
                        function ()
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
    mywibox[s] = awful.wibox({ position = "top",
                               screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(cpufreqwidget)
    right_layout:add(cputempwidget)
    right_layout:add(cpuwidget)
    right_layout:add(memwidget)
    right_layout:add(netwidget)
    right_layout:add(battextwidget)
    right_layout:add(volumewidget)
    right_layout:add(datetimewidget)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end

-- Mouse bindings ------------------------------------------------------
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

-- Key bindings --------------------------------------------------------
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
    awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
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

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)

-- Rules ---------------------------------------------------------------
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}

-- Signals -------------------------------------------------------------
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

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
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
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
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- Autostarts ----------------------------------------------------------
function run_once(cmd)
    findme = cmd
    firstspace = cmd:find(" ")
    if firstspace then
        findme = cmd:sub(0, firstspace-1)
    end
    awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

-- Programs to run once at startup
run_once("xcalib ~/.colorprofiles/MacBookPro7,1-Color-LCD8DD3C7B2-39C2-BCC4-E3C0-DB1AADED70FC.icc")
run_once("xflux -z 02143")
run_once("xsetroot -solid '#454545'")
run_once("xautolock -locker slock -time 5 -notify 30 -corners 0+00 -cornerdelay 3 -cornersize 10")
run_once("xbindkeys")
