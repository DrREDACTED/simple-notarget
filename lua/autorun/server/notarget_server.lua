util.AddNetworkString("NoTargetNotify")

-- Networking | Workaround Spawn
util.AddNetworkString("ClientReadyNoTarget")

net.Receive( "ClientReadyNoTarget", function( len, ply )

	if ( GetConVar("NoTargetEnabled"):GetBool() == false ) then return end -- Is this thing on? 

	local ply = net.ReadEntity() 

	ply:NetworkVar( "Bool", 0, "NoTargetOn")

	ply:SetNoTargetOn( false ) -- The default value of NoTarget.

end )

local function NoTargetActivate( commandPlayer, commandText )

	if ( GetConVar("NoTargetEnabled"):GetBool() == false ) then return end

	-- Setting a notifcation string early because we're smarter programmers.
	local Notification = "That's not a valid input!"

	-- Check usergroup duh!
	local plyAllowed = NoTarget.Whitelist[commandPlayer:GetUserGroup()]

	if ( not plyAllowed and GetConVar("NoTargetWhitelist"):GetBool() == true ) then 

		Notification = "You are not allowed to use this command!"

		net.Start("NoTargetNotify")
		net.WriteString(Notification) 
		net.Send( commandPlayer )

		return 

	end

	local isNoTarget = commandPlayer:GetNoTargetOn()

	if ( string.sub(commandText, 11 ) == "^" or commandText == "!notarget" ) then

		if (isNoTarget == true) then

			commandPlayer:SetNoTargetOn( false )
			commandPlayer:SetNoTarget( false )
			Notification = "No Target Disabled"

		else

			commandPlayer:SetNoTargetOn( true )
			commandPlayer:SetNoTarget( true )
			Notification = "No Target Enabled"

		end

	end

	-- Isn't this a 100% simpler than that shitty ULX command thing we saw? God...

	if (string.sub(commandText, 11) == "@") then

		local target = commandPlayer:GetEyeTrace().Entity

		Notification = "That's not a valid target!"

		-- Check the thing is bloody moving first, don't wanna make a chair godly now ey?
		if not IsValid(target) or not target:IsPlayer() or target:IsBot() then 
		
			net.Start("NoTargetNotify")
			net.WriteString(Notification) 
			net.Send( commandPlayer )

			return 

		end

		local checkTarget = target:GetNoTargetOn()

		if ( checkTarget == true ) then

			target:SetNoTargetOn( false )
			target:SetNoTarget( false )
			Notification = "No Target Disabled for "..target:Nick()

		else

			target:SetNoTargetOn( true )
			target:SetNoTarget( true )
			Notification = "No Target Enabled for "..target:Nick()

		end

		net.Start("NoTargetNotify")
		net.WriteString("No Target ".. (checkTarget and "Disabled" or "Enabled"))
		net.Send( target )

	end

	net.Start("NoTargetNotify")
	net.WriteString(Notification)
	net.Send( commandPlayer )

end

-- Check for the Command | NoTarget Chat Check
hook.Add("PlayerSay", "NoTargetCheck", function( ply, text, teamChat)

	-- Haha! Uppercase can't hurt me!
	local commandText = string.lower( text )

	-- This isn't a spelling bee, don't write the correct word it and it won't work derp.
	if ( string.sub(commandText, 1, 9) == "!notarget" ) then

		NoTargetActivate( ply, text )

	end

end)
