local ratelimit = 30 -- Enforced time in seconds to wait between messages that are sent to Discord.
local servername = "My Server" -- Server name for messages.
local webhookurl   = "https://discordapp.com/api/webhooks/.../..." -- Discord webhook url.

-- Localization text, %s will be replaced with correct values.
local txtCooldown = "There are currently no staff members online. However, you are sending admin messages too fast and your message was not sent! Please wait %s seconds before sending another." -- Value: Seconds left.
local txtError = "There are currently no staff members online. Unfortunately, your message could not be delivered."
local txtSent = "There are currently no staff members online. Your message was sent to the staff team via Discord."
local txtMsg = "**%s** `%s` has sent the following message on **%s** while no staff were online:\n%s" -- Values: Player Name, Player SteamID, Server Name, Message


hook.Add("ULibCommandCalled","asayhooker",function(ply,cmd,args) -- Hook to asay.
	if not ply:IsValid() then return end -- If they arn't a valid player, ignore it, to avoid error.
		
	if cmd == "ulx asay" and ply:query("ulx asay") then
	if #args < 1 then return end -- If they don't give a message, ignore it.

	local players = player.GetAll() -- If there is a admin online, also ignore it.
	for i=#players, 1, -1 do
		local v = players[ i ]
		if ULib.ucl.query( v, "ulx seeasay" ) then
			return
		end
	end

	if tonumber(ply.reportrl || 0 ) > os.time() then -- Send an error if they're being ratelimted.
		ULib.tsayError(ply, string.format(txtCooldown, ply.reportrl-os.time()), true)
		return
	end

	params = { content = string.format(txtMsg, ply:GetName(), ply:SteamID(), servername, table.concat(args," ")) } -- Prepare for discord send.

	http.Post( webhookurl, params, function( text, len, head, status ) -- Send to Discord.
		if status >= 400 then
			ULib.tsayError(ply, txtError, true)
			return
		end

		ULib.tsayError(ply, txtSent, true)
		ply.reportrl = os.time()+ratelimit
	end, function()
		ULib.tsayError(ply, txtError, true)
	end )
	return

    end
end)
