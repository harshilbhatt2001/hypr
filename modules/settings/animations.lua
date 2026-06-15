local beziers = {
	-- Overshoot
	{ name = "heavyOvershoot", points = { 0.53, 0.51, 0.4, 1.22 } },
	{ name = "lightOvershoot", points = { 0.33, 0.61, 0.63, 1.19 } },

	-- Linear
	{ name = "smoothSnap", points = { 0.32, 0.51, 0.44, 1 } },
	{ name = "smoothIn", points = { 0.25, 1, 0.5, 1 } },
	{ name = "smoothOutOvershoot", points = { 0.46, -0.25, 0.81, 0.51 } },

	-- Springs
	{ name = "hardSpring", kind = "spring" },
	{ name = "mediumSpring", kind = "spring", stiffness = 50, dampening = 10 },
	{ name = "heavierSpring", kind = "spring", mass = 1.3, stiffness = 50, dampening = 11 },
	{ name = "looseSpring", kind = "spring", dampening = 5, stiffness = 50 },
}

-- For every curve in the table (ik it says bezier stfu)
for _, bezier in ipairs(beziers) do
	-- If there are points then its not a spring
	if bezier.points then
		hl.curve(bezier.name, {
			type = "bezier",
			points = { { bezier.points[1], bezier.points[2] }, { bezier.points[3], bezier.points[4] } },
		})
	-- If its a spring
	elseif bezier.kind == "spring" then
		hl.curve(bezier.name, {
			type = "spring",
			-- If all the parameters are empty make a spring with the values from the wiki
			mass = bezier.mass or 1,
			stiffness = (bezier.stiffness or 70) + 430,
			dampening = (bezier.dampening or 10) + 26,
		})
	else
		-- You fucked something up
		hl.notification.create({ text = "invalid curve generated", icon = "warning", timeout = 8000 })
	end
end

local animations = {
	-- Window animations
	{ leaf = "windows", speed = 2, spring = "heavierSpring", style = "slide right" },
	{ leaf = "windowsOut", speed = 2, bezier = "heavyOvershoot", style = "popin 30%" },

	-- Fade
	{ leaf = "fade", speed = 2, bezier = "smoothIn" },

	-- Workspaces and Special
	{ leaf = "workspaces", speed = 2, bezier = "heavyOvershoot", style = "slidefade 20%" },
	{ leaf = "specialWorkspace", speed = 5, spring = "mediumSpring", style = "slidefadevert -80%" },
}

-- For every entry in the animation table
for _, anim in ipairs(animations) do
	-- If there is a bezier param
	if anim.bezier then
		hl.animation({
			leaf = anim.leaf,
			enabled = true,
			speed = anim.speed,
			bezier = anim.bezier or "",
			style = anim.style or "",
		})
	elseif anim.spring then
		-- Make a spring instead bcs apparently they're different idk
		hl.animation({
			leaf = anim.leaf,
			enabled = true,
			speed = anim.speed,
			spring = anim.spring or "",
			style = anim.style or "",
		})
	end
end
