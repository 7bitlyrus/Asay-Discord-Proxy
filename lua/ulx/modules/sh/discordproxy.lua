local ratelimit = 30 -- Enforced time in seconds to wait between messages that are sent to Discord.
local servername = "My Server" -- Server name for messages.
local webhookurl   = "https://discordapp.com/api/webhooks/.../..." -- Discord webhook url.

-- Localization text, %s will be replaced with correct values.
local txtNoStaff = "There are no staff online."
local txtCooldown = "You are being ratelimited and your message was not sent to the staff team via Discord. Please wait %s seconds." -- Value: Seconds left.
local txtError = "An error occured and your message was not sent to the staff team via Discord."
local txtSent = "Your message was sent to the staff team via Discord."
local txtMsg = "**%s** `%s` has sent a message to admins on **%s**:\n%s" -- Values: Player Name, Player SteamID, Server Name, Message


hook.Add("ULibCommandCalled","asayhooker",function(ply,cmd,args) -- Hook to asay.
    if cmd == "ulx asay" and ply:query("ulx asay") then
        if #args < 1 then return end -- If they don't give a message, ignore it.

        local players = player.GetAll() -- If there is a admin online, also ignore it.
		for i=#players, 1, -1 do
			local v = players[ i ]
			if ULib.ucl.query( v, "ulx seeasay" ) then
				return
			end
		end

		if tonumber(ply:GetPData( "report-ratelimit", 0 )) > os.time() then -- Send an error if they're being ratelimted.
			ULib.tsayError(ply, txtNoStaff .. " " .. string.format(txtCooldown, ply:GetPData( "report-ratelimit", 0 )-os.time()), true)
			return
		end

		params = { content = string.format(txtMsg, ply:GetName(), ply:SteamID(), servername, table.concat(args," ")) } -- Prepare for discord send.

		http.Post( webhookurl, params, function( text, len, head, status ) -- Send to Discord.
			if status >= 400 then
				ULib.tsayError(ply, txtNoStaff .. " " .. txtError )
			end

			ULib.tsay(ply, txtNoStaff .. " " .. txtSent, true)
			ply:SetPData( "report-ratelimit", os.time()+ratelimit )

		end, function()
			ULib.tsayError(ply, txtNoStaff .. " " .. txtError )
		end )

        return
    end
end)