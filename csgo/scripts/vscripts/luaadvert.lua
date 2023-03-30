-- INFO FOR LOADER: beginning

if LOADER_SETSCRIPTINFO ~= nil then LOADER_SETSCRIPTINFO("LuaAdvert", "Advertisiments for your server", "1.0", "Pisex & NF") end

-- INFO FOR LOADER: end



-- CONFIGURATION: beginning

local duration
local prefix

local messages = {}

function LoadAdvertsConfig()
	local kv = LoadKeyValues("scripts/configs/adverts.ini")
	
	if kv ~= nil then
		prefix = kv['Configs']['prefix']
		duration = kv['Configs']['time']
		for k, v in pairs(kv['Messages']) do
			LoadAdvertAndList(v)
		end

		return true
	else
		LoaderPrint("Couldn't load config file (scripts/configs/adverts.ini). Adverts script wasn't started.")
		return false
	end

end

-- CONFIGURATION: end

require('timers')
require('hudcore')

local messages_count = 0

function LoadAdvertAndList(message)
	messages[messages_count] = {}
	for k,v in pairs(message) do
		messages[messages_count][k] = v
	end
	messages_count = messages_count + 1
end

local messages_current = 0

if localtimer ~= nil then Timers:RemoveTimer(localtimer) end

function ProcessAd(message)
	
	if message['type'] == "chat" then
		HC_PrintChatAll(prefix .. message['text'])
	else
		if message['type'] == "panel" then
			HC_ShowPanelInfo(message['text'], message['duration'])
		else
			if message['type'] == "center" then
				HC_PrintCenterTextAll(message['text'])
			end
		end
	end	
end

function PrintAd()
	ProcessAd(messages[messages_current])
	messages_current = messages_current + 1
	if messages_current == messages_count then
		messages_current = 0
	end	
end

if LoadAdvertsConfig() then

	localtimer = Timers:CreateTimer({
		endTime = duration,
		callback = function()
			PrintAd()    
			return duration
		end
	})

end