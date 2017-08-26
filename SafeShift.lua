local msgForms = {
	cat = "Cat Form",
	bear = "Bear Form",
	direbear = "Dire Bear Form",
	travel = "Travel Form",
	moonkin = "Moonkin Form",
	aquatic = "Aquatic Form",
}
local fileLocalCD
local canUnshift = true

local SafeShift = CreateFrame("Frame")
SafeShift:RegisterEvent("ADDON_LOADED")

function SafeShift:OnEvent()
    if event == "ADDON_LOADED" and arg1 == "SafeShift" then
        -- Our saved variables, if they exist, have been loaded at this point.
        if SafeShiftOptions == nil then
            -- This is the first time this addon is loaded; set SVs to default values
            SafeShiftOptions = {
				unshiftCooldown = 0.5,	-- in seconds
			}
        end
		fileLocalCD = SafeShiftOptions.unshiftCooldown
	end
end
SafeShift:SetScript("OnEvent", SafeShift.OnEvent)

-- pilfered (and mangled) from SuperMacro (god bless)
local function FindBuff( obuff)
	local buff=strlower(obuff);
	local tooltip=GameTooltip;
	local textleft1=getglobal(tooltip:GetName().."TextLeft1");
	for i=0, 24 do
		tooltip:SetOwner(UIParent, "ANCHOR_NONE");
		tooltip:SetPlayerBuff(i);
		b = textleft1:GetText();
		tooltip:Hide();
		local c=nil;
		if ( b and strfind(strlower(b), buff) ) then
			return "buff", i, b;
		elseif ( c==b ) then
			break;
		end
	end
end	

function SafeShift:Shift(form)	
	local canShift = true
	local spell = msgForms[form]
	if FindBuff(spell) ~= nil then
		if canUnshift == true then
			CastSpellByName(spell)
			SafeShift:SetScript("OnUpdate", nil)
		end
	else
		CastSpellByName(spell)
		SafeShift:SetScript("OnUpdate", SafeShift.OnUpdate)
		canUnshift = false
	end
end

local total = 0
function SafeShift:OnUpdate()
    total = total + arg1
    if total >= fileLocalCD then
        -- DEFAULT_CHAT_FRAME:AddMessage("ping!")
        total = 0
		canUnshift = true
		SafeShift:SetScript("OnUpdate", nil)
    end
end


local printColors =
{
	DARK	= "|cffFF7D0A",
	MEDIUM	= "|cffFF9D4B",
	LIGHT	= "|cffFFB475",
}
--FONT_COLOR_CODE_CLOSE	= "|r",

local printStrings =
{
	TITLE		= string.format("%s[SafeShift]%s %sSafety measure against accidentally unshifting immediately after shapeshifting.", 
				printColors.DARK, FONT_COLOR_CODE_CLOSE, printColors.LIGHT),
	USAGE		= string.format("%sUsage:%s", printColors.MEDIUM, FONT_COLOR_CODE_CLOSE),
	SHIFT		= string.format("%s/safeshift%s [%scat%s | %sbear%s | %sdirebear%s | %stravel%s | %smoonkin%s | %saquatic%s] - safely shift into <form> without unshifting for the set period.", 
				printColors.DARK, FONT_COLOR_CODE_CLOSE, printColors.MEDIUM, FONT_COLOR_CODE_CLOSE, printColors.MEDIUM, FONT_COLOR_CODE_CLOSE,
				printColors.MEDIUM, FONT_COLOR_CODE_CLOSE, printColors.MEDIUM, FONT_COLOR_CODE_CLOSE, printColors.MEDIUM, FONT_COLOR_CODE_CLOSE, printColors.MEDIUM, FONT_COLOR_CODE_CLOSE),
	COOLDOWN	= string.format("%s/safeshift%s [%scd%s | %scooldown%s] <%svalue in seconds%s> - sets the safe period during which you may not unshift.", 
				printColors.DARK, FONT_COLOR_CODE_CLOSE, printColors.MEDIUM, FONT_COLOR_CODE_CLOSE, printColors.MEDIUM, FONT_COLOR_CODE_CLOSE, printColors.MEDIUM, FONT_COLOR_CODE_CLOSE),
	CURRENT_CD	= string.format("%sCurrent cooldown:%s %s%s", printColors.LIGHT, FONT_COLOR_CODE_CLOSE, printColors.MEDIUM, "%s"),
}

SLASH_SAFESHIFT1 = "/safeshift"
function SlashCmdList.SAFESHIFT(msg)
	msg = string.lower(msg)
	if msg == "" or msg == "help" then
		DEFAULT_CHAT_FRAME:AddMessage(printStrings.TITLE)
		DEFAULT_CHAT_FRAME:AddMessage(printStrings.USAGE)
		DEFAULT_CHAT_FRAME:AddMessage(printStrings.SHIFT)
		DEFAULT_CHAT_FRAME:AddMessage(printStrings.COOLDOWN)
		DEFAULT_CHAT_FRAME:AddMessage(string.format(printStrings.CURRENT_CD, fileLocalCD))
	else
		local args = {};
		for word in string.gfind(msg, "[^%s]+") do
			table.insert(args, word);
		end
		if args[1] == "cooldown" or args[1] == "cd" then
			local cd = tonumber(args[2])
			if cd then
				DEFAULT_CHAT_FRAME:AddMessage(string.format("[SafeShift] Setting unshift cooldown to %s second(s).", cd))
				SafeShiftOptions.unshiftCooldown = cd
				fileLocalCD = cd
			end
		elseif msgForms[args[1]] ~= nil then
			local form = args[1]
			if form then
				SafeShift:Shift(form)
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage("[SafeShift] Unknown command. Enter /SafeShift help for a list of commands.")
		end
	end
end