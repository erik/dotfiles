-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- Load Debian menu entries
require("debian.menu")

require("vicious")
require("vicious.helpers")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/erik/.config/awesome/themes/current_theme/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "rxvt-unicode"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
--    awful.layout.suit.floating,
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

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
  names = { "1", "2", "3", "4", "5" },
}

floating_mode = false


for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

function update_song_info()
	if io.popen("pgrep mpd"):read() == nil then
		musicwidget.text = "Not playing"
		musicicon.image = pauseicon.image
		return
	end

	local pipe = io.popen("mpc -f '%artist% - %title% #[%album%#]'")
	local line = pipe:read()

	local playing = false
	
	if line == nil then
		return
	end

	if line:match("volume: n/a") then
		musicwidget.text = "Not playing"
	else
		local song, state = line, pipe:read()
		musicwidget.text = vicious.helpers.escape(song)

		if state:match("playing") then
			playing = true
		end
	end

	if playing then
		musicicon.image = playicon.image
	else
		musicicon.image = pauseicon.image
	end
end

function music_action(act)
	-- spawn and shuffle mpd if not already open
	if io.popen("pgrep mpd"):read() == nil then
		os.execute("mpd ~/.mpdconf && mpc ls | mpc add; mpc shuffle")
		os.execute("mpdscribble")
	end

	if act == 'play' then
		awful.util.spawn("mpc toggle")
	elseif act == 'stop' then
		awful.util.spawn("mpc stop")
	elseif act == 'next' then
		awful.util.spawn("mpc next")
	elseif act == 'prev' then
		awful.util.spawn("mpc prev")
	end

	update_song_info()
end

-- {{{ Wibox
--separator--------------------------------------------------------------------------
separator = widget({ type = "textbox" })
separator.text = " :: " --' <span color="#CC9393>|</span> '
-------------------------------------------------------------------------------------

--banshee----------------------------------------------------------------------------
-- this icon is set by fetch_song_info
musicicon = widget({type = "imagebox"})

playicon = widget({type = "imagebox" })
pauseicon = widget({type = "imagebox" })

playicon.image  = image("/home/erik/.config/awesome/icons/note-play.png")
pauseicon.image = image("/home/erik/.config/awesome/icons/note-pause.png") 

musicwidget = widget({ type = "textbox" })

musictimer = timer({ timeout = 5})
musictimer:add_signal("timeout", function()
	update_song_info()
end)
musictimer:start()
-------------------------------------------------------------------------------------

--network usage----------------------------------------------------------------------
dnicon = widget({ type = "imagebox" })
upicon = widget({ type = "imagebox" })
dnicon.image = image("/home/erik/.config/awesome/icons/net_down_02.png")
upicon.image = image("/home/erik/.config/awesome/icons/net_up_02.png")
-- Initialize widget
netwidget = widget({ type = "textbox" })
netwidget.margin = 2
netwidget.align = 'center'
-- Register widget
vicious.register(netwidget, vicious.widgets.net,
		'<span color="#CC9393">${wlan0 down_kb}</span> <span color="#7F9F7F">${wlan0 up_kb}</span>', 1)
-------------------------------------------------------------------------------------

--wifi-------------------------------------------------------------------------------
wicon = widget({ type = "imagebox" })
wicon.image = image("/home/erik/.config/awesome/icons/wifi_02.png")
wifiwidget = widget({ type = "textbox" })
-- Register Widget
vicious.register(wifiwidget, vicious.widgets.wifi, "${ssid}", 5, "wlan0")
-------------------------------------------------------------------------------------

--memory-----------------------------------------------------------------------------
memicon = widget({ type = "imagebox" })
memicon.image = image("/home/erik/.config/awesome/icons/mem.png")
memwidget = widget({ type = "textbox" })
-- Register widget
vicious.register(memwidget, vicious.widgets.mem, "$1%", 1)
-------------------------------------------------------------------------------------

--clock------------------------------------------------------------------------------
mytextclock = awful.widget.textclock({ align = "right" }, "%a %b %d, %H:%M:%S ", 1)
-------------------------------------------------------------------------------------
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
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add buttons to wibox
    
    mywibox[s].buttons = {
       awful.button({ }, 3, function ()
                               if instance then
                                  instance:hide()
                                  instance = nil
                               else
                                  instance = awful.menu.clients({ width=250 })
                               end
                         end)
    }

    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock, separator,
        upicon, netwidget, dnicon, separator,
	memwidget, memicon, separator,
        wifiwidget, wicon, separator,
        musicwidget, musicicon,
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

function link_selected_theme(t)
	print('selected.. ' .. t)
	awful.util.spawn('rm -f "/home/erik/.config/awesome/themes/current_theme"')
	awful.util.spawn('ln -sf "/home/erik/.config/awesome/themes/' .. t .. '/" "/home/erik/.config/awesome/themes/current_theme"')
	awesome.restart()
end


-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- Set multimedia keys-------------------------------------------------------------------------------
    awful.key({}, "XF86AudioPlay", function() music_action("play") end),
    awful.key({}, "XF86AudioStop", function() music_action("stop") end),
    awful.key({}, "XF86AudioNext", function() music_action("next") end),
    awful.key({}, "XF86AudioPrev", function() music_action("prev") end),
    awful.key({}, "XF86AudioMedia",function() awful.util.spawn("urxvt -tn rxvt-unicode -e ncmpcpp") end),
    -----------------------------------------------------------------------------------------------------

    -- theme switcher menu-------------------------------------------------------------------------------
    awful.key({ modkey, "Shift"   }, "t", function()
	local pipe = io.popen('ls ~/.config/awesome/themes')
	local themes = {}

	local ctr = 0

	while true do
		local theme = pipe:read()

		if theme == nil then break end
		if not (theme == 'current_theme') then
			ctr = ctr + 1
			themes[ctr] = { theme, function() link_selected_theme(theme) end }
		end
	end

    	local thememenu = awful.menu({ items = themes, width = 200 })

	thememenu:show({ keygrabber = true })
    end),
    -----------------------------------------------------------------------------------------------------

    -- Screen shot---------------------------------------------------------------------------------------
    awful.key({ modkey,           }, "s",
    	function()
		awful.util.spawn("import /home/erik/pictures/screenshots/" .. os.date('%Y-%m-%d-%H%M%S_import') .. ".png")
	end),
    awful.key({ }, "Print", function() awful.util.spawn("scrot -e 'mv $f ~/pictures/screenshots/'") end),
    -----------------------------------------------------------------------------------------------------

    -- dmenu launcher------------------------------------------------------------------------------------
    awful.key({ modkey,           }, "r",
    	function()
		awful.util.spawn("dmenu_run -b -i -p 'Run command:' -nb '" .. beautiful.bg_normal .. "' -nf '"
				 .. beautiful.fg_normal .. "' -sb '" .. beautiful.bg_focus .. "' -sf '" ..
				 beautiful.fg_focus .. "'")
	end),
    -----------------------------------------------------------------------------------------------------

    -- Wibox---------------------------------------------------------------------------------------------
    awful.key({ modkey }, "b",
    	function()
		mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
	end),
    -----------------------------------------------------------------------------------------------------

    -- Window list---------------------------------------------------------------------------------------
    awful.key({ modkey, "Shift"   }, "w", 
              function ()
                 if instance then
                    instance:hide()
                    instance = nil
                 else
                    instance = awful.menu.clients({ width=250 })
                    instance:show({ keygrabber=true })
                 end
           end),
    -----------------------------------------------------------------------------------------------------

    awful.key({ modkey, "Control" }, "t", function()
	local clients = client.get()
    	local tags={}
	for _, t in ipairs(awful.tag.selectedlist()) do
		tags[t.name] = true
	end
	
	for _, c in ipairs(clients) do
		for _, t in ipairs(c:tags()) do
			if tags[t.name] then
				if floating_mode then
					awful.titlebar.remove(c)
					awful.client.floating.set(c, false)
					floating_mode = false
				else
					awful.client.floating.set(c, true)
					awful.titlebar.add(c)
					floating_mode = true
				end
			end
		end
	end


    end),

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
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

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
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end)

--[[    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
--]]
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "x",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c)
    	if c.titlebar then
		awful.titlebar.remove(c)
	else
		awful.titlebar.add(c)
	end
    end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)



-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
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
		     size_hints_honor = false,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },

    { rule = { class = "Eog" },
      properties = { floating = true } },

    { rule = { class = "Teamspeak" },
      properties = { floating = true } },

    { rule = { class = "File-roller" },
      properties = { floating = true } },

    { rule = { class = "Nautilus" },
      properties = { floating = true } },

    { rule = { class = "MPlayer" },
      properties = { floating = true } },

    { rule = { class = "pinentry" },
      properties = { floating = true } },

    { rule = { class = "gimp" },
      properties = { floating = true } },
 
    { rule = { class = "Npviewer.bin" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    if floating_mode then
    	awful.titlebar.add(c, { modkey = modkey })
	awful.client.floating.set(c, true)
    end

    -- Make ncmpcpp windows float--------------------------
    if c.class == 'URxvt' and c.name == 'ncmpcpp' then
	awful.client.floating.set(c, true)
    end
    -------------------------------------------------------

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
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
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

naughty.config.default_preset.timeout 	= 10
naughty.config.default_preset.height	= 50
naughty.config.default_preset.width 	= 300

