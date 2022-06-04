
-- Networking | Workaround Intial Spawn
hook.Add( "InitPostEntity", "Ready", function()

	net.Start( "ClientReadyNoTarget" )
	net.WriteEntity( LocalPlayer() )
	net.SendToServer()

	-- God, code only runs once. I'm glad we worked that out...

end)

-- Notify the player | NoTarget Chat Notify
net.Receive("NoTargetNotify", function( len, ply  )

	local Text = net.ReadString()

	chat.AddText( Color(15, 95, 185), LocalPlayer():Nick(), Color( 225, 225, 225 ), " - "..Text ) 
	-- Haha! calling localplayer WOULD cause an error.

end)
