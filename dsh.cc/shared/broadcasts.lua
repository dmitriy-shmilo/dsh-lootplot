

umg.defineEvent("dsh.cc:runInitialized", { typelist = { "string", "string" }})
umg.definePacket("dsh.cc:runInitialized", { typelist = { "string", "string" }})

if client then
	client.on("dsh.cc:runInitialized", function(item, difficulty)
		umg.call("dsh.cc:runInitialized", item, difficulty)
	end)
end