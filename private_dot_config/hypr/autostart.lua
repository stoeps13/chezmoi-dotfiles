-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:

hl.on("hyprland.start", function()
	hl.exec_cmd("qs -c noctalia-shell")
	hl.exec_cmd("systemctl --user start hyprpolkitagent")
	hl.exec_cmd("/usr/bin/shelly")
	hl.exec_cmd("/usr/bin/fractal")
	hl.exec_cmd("/usr/bin/tuxedo-control-center")
	hl.exec_cmd("flatpak run org.davmail.DavMail")
end)
