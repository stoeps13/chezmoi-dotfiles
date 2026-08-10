------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
	output = "eDP-1",
	mode = "2880x1800@60.0",
	position = "auto",
	scale = 1.5,
})
hl.monitor({
	output = "DP-1",
	mode = "3840x2160@30.0",
	position = "2880x-1000",
	scale = 1,
})
hl.monitor({
	output = "DP-2",
	mode = "3840x2160@30.0",
	position = "2880x-1000",
	scale = 1,
})
