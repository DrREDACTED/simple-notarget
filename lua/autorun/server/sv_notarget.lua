util.AddNetworkString("NoTargetNotify")

-- Networking | Workaround Spawn
util.AddNetworkString("ClientReadyNoTarget")

net.Receive( "ClientReadyNoTarget", function( len, ply )

	if ( GetConVar("NoTargetEnabled"):GetBool() == false ) then return end -- Is this thing on? 

	local ply = net.ReadEntity() 

	ply:NetworkVar( "Bool", 0, "NoTargetOn")

	ply:SetNoTargetOn( false ) -- The default value of NoTarget.

end )

local function NoTargetSelf( commandPlayer )

	local isNoTarget = commandPlayer:GetNoTargetOn()

	if (isNoTarget == true ) then

		commandPlayer:SetNoTargetOn( false )
		commandPlayer:SetNoTarget( false )
		Notification = "No Target Disabled"

	else

		commandPlayer:SetNoTargetOn( true )
		commandPlayer:SetNoTarget( true )
		Notification = "No Target Enabled"

	end

	net.Start("NoTargetNotify")
	net.WriteString(Notification)
	net.Send( commandPlayer )

	return 

end

local function NoTargetFront( commandPlayer )

	local Target = commandPlayer:GetEyeTrace().Entity

	local Notification = "That is not a valid target!"

	if not IsValid(Target) or not Target:IsPlayer() or Target:IsBot() then

		net.Start("NoTargetNotify")
		net.WriteString(Notification) 
		net.Send( commandPlayer )

		return 

	end

	local CheckTarget = Target:GetNoTargetOn()

	if (CheckTarget == true ) then 

		Target:SetNoTargetOn( false )
		Target:SetNoTarget( false )
		Notification = "No Target Disabled for "..Target:Nick()

	else

		Target:SetNoTargetOn( true )
		Target:SetNoTarget( true )
		Notification = "No Target Enabled for "..Target:Nick()

	end


	net.Start("NoTargetNotify")
	net.WriteString(Notification) 
	net.Send( commandPlayer )

	net.Start("NoTargetNotify")
	net.WriteString("No Target ".. (checkTarget and "Disabled" or "Enabled")) 
	net.Send( Target )

	return 

end

local function NoTargetSearch( commandPlayer, command )

	local PlayerList = player.GetAll()

	for __, player in ipairs( PlayerList ) do

		Notification = "That's not a valid target!"

		local checkTarget = player:GetNoTargetOn()

		if not IsValid( player ) or not player:IsPlayer() or player:IsBot() then

			net.Start("NoTargetNotify")
			net.WriteString(Notification)
			net.Send( commandPlayer )

			return 

		end

		local search_name = string.lower( player:Nick() )
		local search_command = string.lower( command )

		if ( string.find( search_name,  search_command, nil, true ) ) then

			checkTarget = player:GetNoTargetOn()

			if (checkTarget == true ) then

				player:SetNoTargetOn( false )
				player:SetNoTarget( false )
				Notification = "No Target Disabled for "..player:Nick()

			else

				player:SetNoTargetOn( true )
				player:SetNoTarget( true )
				Notification = "No Target Enabled for "..player:Nick()

			end

			net.Start("NoTargetNotify")
			net.WriteString("No Target ".. (checkTarget and "Disabled" or "Enabled") )
			net.Send( player )

		end

		net.Start("NoTargetNotify")
		net.WriteString(Notification)
		net.Send( commandPlayer )

		return

	end

end

local function NoTargetActivate( commandPlayer, commandText )

	local command = string.sub(commandText, 11)

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

	-- Target themselves

	if ( command == "^" or commandText == "!notarget" ) then

		NoTargetSelf( commandPlayer )
		return

	end
	-- Isn't this a 100% simpler than that shitty ULX command thing we saw? God...
	-- Target those infront of them

	if (command == "@") then

		NoTargetFront( commandPlayer )
		return

	else
		-- Target those who's name they input!

		NoTargetSearch( commandPlayer, command )
		return 

	end

	-- Just in case
	net.Start("NoTargetNotify")
	net.WriteString(Notification)
	net.Send( commandPlayer )

end

-- Check for the Command | NoTarget Chat Check
hook.Add("PlayerSay", "NoTargetCheck", function( ply, text, teamChat)

	if ( GetConVar("NoTargetEnabled"):GetBool() == false ) then return end -- Is this thing on? 

	-- Haha! Uppercase can't hurt me!
	local commandText = string.lower( text )

	-- This isn't a spelling bee, don't write the correct word it and it won't work derp.
	if ( string.sub(commandText, 1, 9) == "!notarget" ) then

		NoTargetActivate( ply, text )

		return ""

	end

end)
