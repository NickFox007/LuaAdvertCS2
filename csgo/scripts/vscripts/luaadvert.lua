-- INFO FOR LOADER: beginning

if LOADER_SETSCRIPTINFO ~= nil then LOADER_SETSCRIPTINFO("LuaAdvert", "Advertisiments for your server", "1.1", "Pisex & NF") end

-- INFO FOR LOADER: end



-- CONFIGURATION: beginning

local duration
local prefix

local messages = {}

function Adverts_LoadAdvertsConfig()
	local kv = LoadKeyValues("scripts/configs/adverts.ini")
	
	if kv ~= nil then
		prefix = kv['Configs']['prefix']
		duration = kv['Configs']['time']
		for k, v in pairs(kv['Messages']) do
			Adverts_LoadAdvertAndList(v)
		end

		return true
	else
		LoaderPrint("Couldn't load config file (scripts/configs/adverts.ini). Adverts script wasn't started.")
		return false
	end

end

-- CONFIGURATION: end

require "libs.timers"
require('hudcore')

local messages_count = 0

function Adverts_LoadAdvertAndList(message)
	messages[messages_count] = {}
	for k,v in pairs(message) do
		messages[messages_count][k] = v
	end
	messages_count = messages_count + 1
end

local messages_current = 0

if adverts_localtimer ~= nil then Timers:RemoveTimer(adverts_localtimer) end

function Adverts_ProcessAd(message)

	local case = 
	{
		['chat'] = function()
			HC_PrintChatAll(prefix .. message['text'])
		end,
		['panel'] = function()
			HC_ShowPanelInfo(message['text'], message['duration'])
		end,
		['center'] = function()
			HC_PrintCenterTextAll(message['text'])		
		end,
		['instr_hint'] = function()
			--HC_PrintCenterTextAll(message['text'])
			HC_ShowInstructorHint(message['text'], message['duration'], message['icon'])
		end
	}	
	
	if case[message['type']] then
		case[message['type']]()
	else
		print("Found message type '" .. message['type'] .. "' but it's not valid")
	end
end

function Adverts_PrintAd()
	Adverts_ProcessAd(messages[messages_current])
	messages_current = messages_current + 1
	if messages_current == messages_count then
		messages_current = 0
	end	
end

if Adverts_LoadAdvertsConfig() then

	adverts_localtimer = Timers:CreateTimer({
		endTime = duration,
		callback = function()
			Adverts_PrintAd()    
			return duration
		end
	})

end
