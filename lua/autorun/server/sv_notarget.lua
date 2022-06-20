util.AddNetworkString("NoTargetNotify")

-- Networking | Workaround Spawn
util.AddNetworkString("ClientReadyNoTarget")

net.Receive( "ClientReadyNoTarget", function( len, ply )

	if ( GetConVar("NoTargetEnabled"):GetBool() == false ) then return end -- Is this thing on? 

	local ply = net.ReadEntity() 

	ply:NetworkVar( "Bool", 0, "NoTargetOn")

	ply:SetNoTargetOn( false ) -- The default value of NoTarget.

end )

-- Targets themselves
local function NoTargetSelf( commandPlayer )

	local isNoTarget = commandPlayer:GetNoTargetOn()

	-- Simple Check for True/False
	if (isNoTarget == true ) then

		commandPlayer:SetNoTargetOn( false )
		commandPlayer:SetNoTarget( false )
		Notification = "No Target Disabled"

	else

		commandPlayer:SetNoTargetOn( true )
		commandPlayer:SetNoTarget( true )
		Notification = "No Target Enabled"

	end

	-- Always sends the user a notification.
	net.Start("NoTargetNotify")
	net.WriteString(Notification)
	net.Send( commandPlayer )

	return 

end


-- Targets those infront of them
local function NoTargetFront( commandPlayer )

	local Target = commandPlayer:GetEyeTrace().Entity

	local Notification = "That is not a valid target!"

	-- Have to check the Target, since NoTarget has issues on bots,
	-- and we're only concerned about players.

	if not IsValid(Target) or not Target:IsPlayer() or Target:IsBot() then

		net.Start("NoTargetNotify")
		net.WriteString(Notification) 
		net.Send( commandPlayer )

		return 

	end

	local CheckTarget = Target:GetNoTargetOn()

	-- Same check as the one used for themselves, except it's on the Target.

	if (CheckTarget == true ) then 

		Target:SetNoTargetOn( false )
		Target:SetNoTarget( false )
		Notification = "No Target Disabled for "..Target:Nick()

	else

		Target:SetNoTargetOn( true )
		Target:SetNoTarget( true )
		Notification = "No Target Enabled for "..Target:Nick()

	end

	-- Notify the Command Player with who they hit with NoTarget.
	net.Start("NoTargetNotify")
	net.WriteString(Notification) 
	net.Send( commandPlayer )

	-- Notify the Target they've been hit with NoTarget.
	net.Start("NoTargetNotify")
	net.WriteString("No Target ".. (checkTarget and "Disabled" or "Enabled")) 
	net.Send( Target )

	return 

end

-- Targets those who's name they input ( wildcard )
local function NoTargetSearch( commandPlayer, command )

	local PlayerList = player.GetAll()

	for __, player in ipairs( PlayerList ) do

		Notification = "That's not a valid target!"

		local checkTarget = player:GetNoTargetOn()

		-- Same check as before, just have to be careful.
		if not IsValid( player ) or not player:IsPlayer() or player:IsBot() then

			net.Start("NoTargetNotify")
			net.WriteString(Notification)
			net.Send( commandPlayer )

			return 

		end

		-- Make sure they're all lowercase otherwise it'll struggle to search

		local search_name = string.lower( player:Nick() )
		local search_command = string.lower( command )

		-- string.find is a wildcard, it searches for patterns within the list of players
		-- We set the last part to True so it isn't greedy (return multiple values)

		if ( string.find( search_name,  search_command, nil, true ) ) then


			-- Similar to the @ function it's simply aims at the target.
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

			-- We notify them here because it's better code readability.
			-- And to prevent the original notification being overwriting.

			net.Start("NoTargetNotify")
			net.WriteString("No Target ".. (checkTarget and "Disabled" or "Enabled") )
			net.Send( player )

		end

		-- Notify the Command Player at what target they get.

		net.Start("NoTargetNotify")
		net.WriteString(Notification)
		net.Send( commandPlayer )

		return

	end

end

-- Main Function which reads the text and detects the command.
local function NoTargetActivate( commandPlayer, commandText )

	-- Grab everything after "!notarget " (yes the space is also excluded)
	local command = string.sub(commandText, 11)

	-- Realistically, this should be above everything but it shouldn't matter too much.
	if ( GetConVar("NoTargetEnabled"):GetBool() == false ) then return end

	-- Setting a notifcation string early because we're smarter programmers.
	local Notification = "That's not a valid input!"

	-- Check usergroup duh!
	local plyAllowed = NoTarget.Whitelist[commandPlayer:GetUserGroup()]


	-- We check the usergroup in the main function so we don't have to call the code
	-- multiple times or even make it a function, it's just simpler.
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
	
	-- Target those infront of them

	if (command == "@") then

		NoTargetFront( commandPlayer )
		return

	else
		-- Target those who's name they input!

		-- The reason this is an else, 
		-- is mostly because it breaks if I do if else, 
		-- I do not know why.

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

		-- This handy bit, hides the original text from the user so they simply see the end result
		-- Gives a much cleaner look

	end

end)
