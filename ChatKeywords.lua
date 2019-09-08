local CKW = CreateFrame('Frame')
local f1 = CreateFrame("Frame", nil, UIParent)

ChatKeywordsDB = ChatKeywordsDB or {}
ChatKeywordsDB.global = ChatKeywordsDB.global or {}

local find = string.find
local select = select
local tContains = tContains
local words = {}
local timer = C_Timer.NewTimer(0, nil)
local savedAuthor = ''

------------------------------------------------------------------------------
--
-- 1. Event Loops
--
------------------------------------------------------------------------------

function CKW:OnEvent(e, ...)
	if e == 'PLAYER_LOGIN' then
		print('ChatKeywords: player log in')
	end
end


function CKW:OnLoad()
	self:SetToplevel(true)
	self:Hide()
	
	self:SetScript('OnEvent', function(_, ...)
		self:OnEvent(...)
	end)

	for _,e in next, ({	'PLAYER_LOGIN',
						'UI_ERROR_MESSAGE' }) do
		self:RegisterEvent(e)
	end

end

CKW:OnLoad()



------------------------------------------------------------------------------
--
-- 2. Command List
--
------------------------------------------------------------------------------

SLASH_CHATKEYWORDS1, SLASH_CHATKEYWORDS2, SLASH_CHATKEYWORDS3  = '/ck', '/ckw', '/chatkeywords'
function SlashCmdList.CHATKEYWORDS(msg)
	local _, _, cmd, args = find(msg, '%s?(%w+)%s?(.*)')
	if not cmd or cmd == '' or cmd == 'help' then
		print('Chat Keywords: /ck /ckw /chatkeywords')
		print('  /ck reset                Clear all keywords')
		print('  /ck set (keywords) Set a keyword, Example: /ck set MC')
	elseif cmd == 'reset' then
		words = {}
		f1:Hide()
		print('ChatKeywords reset done')
	elseif cmd == 'set' and args ~= '' then
		tinsert(words, args)
		print('ChatKeywords are:')
		for idx, word in ipairs(words) do
			print(word)	
		end
	end
end



------------------------------------------------------------------------------
--
-- 3. Display Frame
--
------------------------------------------------------------------------------

local function initTextFrame()
	f1:SetWidth(100)
	f1:SetHeight(22)
	f1:SetPoint("TOP", 0, -100)
	f1.text = f1:CreateFontString(nil, "ARTWORK", "QuestFont_Shadow_Huge")
	f1.text:SetPoint("CENTER",0,0)
	f1:Hide()

	-- User Interaction
	f1:EnableMouse(true)
	f1:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			--SendChatMessage('/w '..savedAuthor..' ', "SAY")
			--DEFAULT_CHAT_FRAME.editBox:SetText("/raresist") ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
			ChatFrame_OpenChat('/w '..savedAuthor..' ')
		end
	end)
end

local function showTextFrame(text)
	f1.text:SetText(text)
	f1:Show()
	timer:Cancel()
	timer = C_Timer.NewTimer(120, function()
		f1:Hide() -- only show 2min
	end)
end

initTextFrame()



------------------------------------------------------------------------------
--
-- 4. Chat Message Filter
--
------------------------------------------------------------------------------

local function printMsg(event, channel, name, msg)
	local text = "[" .. channel .. "][" .. name .. "]" .. ": " .. msg

	showTextFrame(text)

	-- GameTooltip:SetOwner(UIParent,"ANCHOR_NONE") 
	-- GameTooltip:SetPoint("CENTER",0,-360) 
	-- GameTooltip:AddLine(text) 
	-- GameTooltip:Show()

	-- UIErrorsFrame:AddMessage(text)
end

local function hookMessage(self, event, msg, author, arg10, channel, name, arg11, arg12, arg13, arg14, arg15, arg16, playerid, ...)
	for idx, word in ipairs(words) do
		if strfind(msg, word) then
			savedAuthor = author
			printMsg(event, channel, name, msg)
		end
	end

	return false
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_COMMUNITIES_CHANNEL", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", hookMessage)	

