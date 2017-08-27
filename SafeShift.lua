local fileLocalCD
local canUnshift = true

local spellNameMap =
{
	direbear = "Dire Bear Form",
	bear = "Bear Form",
	aquatic = "Aquatic Form",
	cat = "Cat Form",
	travel = "Travel Form",
	moonkin = "Moonkin Form",
}

local forms = {}
forms.map = {}
function forms:Update()
	-- forms = {}
	forms.map = {}
	local numForms = GetNumShapeshiftForms()
	for i=1, numForms do
		local _, name = GetShapeshiftFormInfo(i);
		for form,spellName in pairs(spellNameMap) do
			if string.lower(name)==string.lower(spellName) then
				forms.map[form] = i
				break
			end
		end
	end
end

local SafeShift = CreateFrame("Frame")
SafeShift:RegisterEvent("ADDON_LOADED")
SafeShift:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")

function SafeShift:OnEvent()
	if event == "ADDON_LOADED" and arg1 == "SafeShift" then
		-- Our saved variables, if they exist, have been loaded at this point.
		if SafeShiftOptions == nil then
			-- This is the first time this addon is loaded; set SVs to default values
			SafeShiftOptions = {
				unshiftCooldown = 0.5,	-- in seconds
			}
		end		
		forms:Update()
		fileLocalCD = SafeShiftOptions.unshiftCooldown
	elseif event == "UPDATE_SHAPESHIFT_FORMS" then
		forms:Update()
	end
end
SafeShift:SetScript("OnEvent", SafeShift.OnEvent)

local function GetShapeshiftForm()
	for _,index in pairs(forms.map) do
		local _, _, active = GetShapeshiftFormInfo(index)
		if active then
			return index
		end
	end
	return 0	-- 0 = humanoid
end

function SafeShift:Shift(form)
	local formIndex = forms.map[form]
	local currentForm = GetShapeshiftForm()

	if formIndex == currentForm or currentForm ~= 0 then
		if canUnshift == true then
			CastShapeshiftForm(currentForm)
			SafeShift:SetScript("OnUpdate", nil)
		end
	else
		CastShapeshiftForm(formIndex)
		SafeShift:SetScript("OnUpdate", SafeShift.OnUpdate)
		canUnshift = false
	end
end

local total = 0
function SafeShift:OnUpdate()
    total = total + arg1
    if total >= fileLocalCD then
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
		elseif spellNameMap[args[1]] ~= nil then
			local form = args[1]
			if form then
				SafeShift:Shift(form)
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage("[SafeShift] Unknown command. Enter /SafeShift help for a list of commands.")
		end
	end
end