local SpeedrunSplitsPBLevel = 70
local SpeedrunSplitsLevelRange = 12
local SpeedrunSplitsFontSize = 13
local SpeedrunSplits_UpdateInterval = 1.0
local SpeedrunSplitsDeltaDiff = 300
local SpeedrunSplitsLevel = nil
local SpeedrunSplitsClassID = nil
local SpeedrunSplitsRaceID = nil
local SpeedrunSplitsTotalTime = 0
local SpeedrunSplitsLevelTime = 0
local SpeedrunSplitsDeltaTime = 0
local TimeSinceLastUpdate = 0
local SpeedrunSplitsMax = nil
local SpeedrunSplitsMin = nil
local SpeedrunSplitsLevelUp = nil
local MAX_LEVEL = 70


function SpeedrunSplits_OnLoad()
	this:RegisterEvent("ADDON_LOADED")
	this:RegisterEvent("PLAYER_LEVEL_UP")
	this:RegisterEvent("PLAYER_LOGIN")
end

function SpeedrunSplits_OnEvent(event)
	if (event == "ADDON_LOADED" and arg1 == "SpeedrunSplits") then
		_, SpeedrunSplitsRaceID = UnitRace("player")
		_, SpeedrunSplitsClassID = UnitClass("player")
		
		if SpeedrunSplitsPB == nil then
			SpeedrunSplitsPB = {}
		end
		if SpeedrunSplitsGold == nil then
			SpeedrunSplitsGold = {}
		end
		if SpeedrunSplits_tContains(SpeedrunSplitsPB, SpeedrunSplitsRaceID) == false then
			SpeedrunSplitsPB[SpeedrunSplitsRaceID] = {}
			SpeedrunSplitsGold[SpeedrunSplitsRaceID] = {}
		end
		if SpeedrunSplits_tContains(SpeedrunSplitsPB[SpeedrunSplitsRaceID], SpeedrunSplitsClassID) == false then
			SpeedrunSplitsPB[SpeedrunSplitsRaceID][SpeedrunSplitsClassID] = {}
			SpeedrunSplitsPB[SpeedrunSplitsRaceID][SpeedrunSplitsClassID][1] = 0
			SpeedrunSplitsGold[SpeedrunSplitsRaceID][SpeedrunSplitsClassID] = {}
			SpeedrunSplitsGold[SpeedrunSplitsRaceID][SpeedrunSplitsClassID][1] = 0
		end

		local f=CreateFrame("Frame","SpeedrunSplitsTimer",UIParent)
		f:SetWidth(1) 
		f:SetHeight(1) 
		f:SetAlpha(1)
		f:SetPoint("TOPLEFT",5,-145-SpeedrunSplitsLevelRange*SpeedrunSplitsFontSize)
		f.text = f:CreateFontString(nil,"ARTWORK") 
		f.text:SetFont("Fonts\\ARIALN.ttf", SpeedrunSplitsFontSize, "OUTLINE")
		f.text:SetWidth(100)
		f.text:SetPoint("TOPLEFT",0,0)
		f.text:SetJustifyH("LEFT")

		local fdelta = CreateFrame("Frame",nil,UIParent)
		fdelta:SetWidth(1)
		fdelta:SetHeight(1) 
		fdelta:SetAlpha(1)
		fdelta:SetPoint("TOPLEFT",62,-120)
		fdelta.text = fdelta:CreateFontString(nil,"ARTWORK") 
		fdelta.text:SetFont("Fonts\\ARIALN.ttf", SpeedrunSplitsFontSize, "OUTLINE")
		fdelta.text:SetWidth(100) 
		fdelta.text:SetPoint("TOPLEFT",0,0)
		fdelta.text:SetJustifyH("LEFT")

		f:SetScript("OnUpdate", function()
		TimeSinceLastUpdate = TimeSinceLastUpdate + arg1; 	
		if (TimeSinceLastUpdate > SpeedrunSplits_UpdateInterval) then
			SpeedrunSplitsTotalTime = SpeedrunSplitsTotalTime + SpeedrunSplits_UpdateInterval
			SpeedrunSplitsLevelTime = SpeedrunSplitsLevelTime + SpeedrunSplits_UpdateInterval

			local SpeedrunSplitsDiffColor = "|cffffffff"
			local SpeedrunSplitsDelta = ""
			local SpeedrunSplitsDeltaTime = 0
			for i=SpeedrunSplitsMin,SpeedrunSplitsMax do
				if i <= SpeedrunSplitsLevel and SpeedrunSplits_tContains(SpeedrunSplits, i) and SpeedrunSplits_tContains(SpeedrunSplitsPB[SpeedrunSplitsRaceID][SpeedrunSplitsClassID], i) then
					SpeedrunSplitsDeltaTime = SpeedrunSplits[i]-SpeedrunSplitsPB[SpeedrunSplitsRaceID][SpeedrunSplitsClassID][i]
					if SpeedrunSplitsDeltaTime < 0 then
						SpeedrunSplitsDiffColor = "|cff00aa00"
					elseif SpeedrunSplitsDeltaTime > 0 then
						SpeedrunSplitsDiffColor = "|cffff0000"
					end
				end
				if SpeedrunSplits_tContains(SpeedrunSplits, i) then
					if i <= SpeedrunSplitsLevel then
						SpeedrunSplitsDelta = SpeedrunSplitsDelta..SpeedrunSplitsDiffColor..SpeedrunSplitsTime(SpeedrunSplitsDeltaTime,1).."|r\n"
					end
				end
			end
			if SpeedrunSplitsLevel < MAX_LEVEL and SpeedrunSplits_tContains(SpeedrunSplitsPB[SpeedrunSplitsRaceID][SpeedrunSplitsClassID], SpeedrunSplitsLevel+1) then
				if SpeedrunSplitsPB[SpeedrunSplitsRaceID][SpeedrunSplitsClassID][SpeedrunSplitsLevel+1] - SpeedrunSplitsDeltaDiff < SpeedrunSplitsTotalTime then
					SpeedrunSplitsDeltaTime = SpeedrunSplitsTotalTime - SpeedrunSplitsPB[SpeedrunSplitsRaceID][SpeedrunSplitsClassID][SpeedrunSplitsLevel+1]
					if SpeedrunSplitsDeltaTime < 0 then
						SpeedrunSplitsDiffColor = "|cff00aa00"
					elseif SpeedrunSplitsDeltaTime > 0 then
						SpeedrunSplitsDiffColor = "|cffff0000"
					end
					SpeedrunSplitsDelta = SpeedrunSplitsDelta..SpeedrunSplitsDiffColor..SpeedrunSplitsTime(SpeedrunSplitsDeltaTime,1).."|r"
				end
			end
			
			fdelta.text:SetText(SpeedrunSplitsDelta)
			f.text:SetText(SpeedrunSplitsTime(SpeedrunSplitsTotalTime).."\n"..SpeedrunSplitsTime(SpeedrunSplitsLevelTime))

			TimeSinceLastUpdate = TimeSinceLastUpdate - SpeedrunSplits_UpdateInterval;
		end
		end)
	elseif (event == "PLAYER_LOGIN") then
		SpeedrunSplitsLevel = UnitLevel("player")

		if SpeedrunSplits == nil or SpeedrunSplitsLevel == 1 then
			SpeedrunSplits = {}
			SpeedrunSplits[1] = 0
		end

		RequestTimePlayed()
		this:RegisterEvent("TIME_PLAYED_MSG")
	elseif (event == "PLAYER_LEVEL_UP") then
		SpeedrunSplitsLevel = arg1
		SpeedrunSplitsLevelUp = 1
		RequestTimePlayed()
		this:RegisterEvent("TIME_PLAYED_MSG")
	end
	if event == "PLAYER_LOGIN" or event == "PLAYER_LEVEL_UP" then
		SpeedrunSplitsMax = SpeedrunSplitsLevel+1
		if SpeedrunSplitsMax > MAX_LEVEL then
			SpeedrunSplitsMax = MAX_LEVEL
		elseif SpeedrunSplitsMax < SpeedrunSplitsLevelRange+2 then
			SpeedrunSplitsMax = SpeedrunSplitsLevelRange+2
		end
		SpeedrunSplitsMin = SpeedrunSplitsMax-SpeedrunSplitsLevelRange
	end
	if (event == "TIME_PLAYED_MSG") then
		this:UnregisterEvent("TIME_PLAYED_MSG")
		SpeedrunSplits[SpeedrunSplitsLevel] = arg1 - arg2
		SpeedrunSplitsTotalTime = arg1
		SpeedrunSplitsLevelTime = arg2
		local SpeedunSplitsColor = "|cffffffff"
		if SpeedrunSplitsLevel > 1 then
			if (SpeedrunSplits_tContains(SpeedrunSplitsPB[SpeedrunSplitsRaceID][SpeedrunSplitsClassID], SpeedrunSplitsLevel) == false) then
				SpeedrunSplitsPB[SpeedrunSplitsRaceID][SpeedrunSplitsClassID][SpeedrunSplitsLevel] = SpeedrunSplits[SpeedrunSplitsLevel]
				if SpeedrunSplits_tContains(SpeedrunSplits, SpeedrunSplitsLevel-1) then
					SpeedrunSplitsGold[SpeedrunSplitsRaceID][SpeedrunSplitsClassID][SpeedrunSplitsLevel] = SpeedrunSplits[SpeedrunSplitsLevel] - SpeedrunSplits[SpeedrunSplitsLevel-1]
				end
			end
			if (SpeedrunSplits_tContains(SpeedrunSplitsPB[SpeedrunSplitsRaceID][SpeedrunSplitsClassID], SpeedrunSplitsLevel-1) and SpeedrunSplits_tContains(SpeedrunSplits, SpeedrunSplitsLevel-1)) then
				if (SpeedrunSplitsPB[SpeedrunSplitsRaceID][SpeedrunSplitsClassID][SpeedrunSplitsLevel] - SpeedrunSplitsPB[SpeedrunSplitsRaceID][SpeedrunSplitsClassID][SpeedrunSplitsLevel-1] >= SpeedrunSplits[SpeedrunSplitsLevel] - SpeedrunSplits[SpeedrunSplitsLevel-1]) then
					SpeedrunSplitsGold[SpeedrunSplitsRaceID][SpeedrunSplitsClassID][SpeedrunSplitsLevel] = SpeedrunSplits[SpeedrunSplitsLevel] - SpeedrunSplits[SpeedrunSplitsLevel-1]
				end
			end
		end

		SpeedrunSplitsGenerate(SpeedrunSplitsLevel)

		if (SpeedrunSplitsPBLevel == SpeedrunSplitsLevel or SpeedrunSplitsLevel == MAX_LEVEL) and SpeedrunSplitsLevelUp == 1 and SpeedrunSplits[SpeedrunSplitsLevel] <= SpeedrunSplitsPB[SpeedrunSplitsRaceID][SpeedrunSplitsClassID][SpeedrunSplitsLevel] then
			SpeedrunSplitsPB[SpeedrunSplitsRaceID][SpeedrunSplitsClassID] = SpeedrunSplits
			SpeedrunSplitsLevelUp = nil
		end
	end
end

local f1 = CreateFrame("Frame",nil,UIParent)
f1:SetWidth(1) 
f1:SetHeight(1) 
f1:SetAlpha(1);
f1:SetPoint("TOPLEFT",5,-120)
f1.text = f1:CreateFontString(nil,"ARTWORK") 
f1.text:SetFont("Fonts\\ARIALN.ttf", SpeedrunSplitsFontSize, "OUTLINE")
f1.text:SetWidth(65)
f1.text:SetPoint("TOPLEFT",0,0)
f1.text:SetJustifyH("LEFT")
f1:Hide()
 
local f2 = CreateFrame("Frame",nil,f1)
f2:SetWidth(1) 
f2:SetHeight(1) 
f2:SetAlpha(1);
f2:SetPoint("TOPLEFT",120,0)
f2.text = f2:CreateFontString(nil,"ARTWORK") 
f2.text:SetFont("Fonts\\ARIALN.ttf", SpeedrunSplitsFontSize, "OUTLINE")
f2.text:SetWidth(65)
f2.text:SetPoint("TOPLEFT",0,0)
f2.text:SetJustifyH("LEFT")
f2:Hide()
 
function displayupdate(show, message)
    if show == 1 then
        f1.text:SetText(message)
        f1:Show()
    elseif show == 2 then
        f2.text:SetText(message)
        f2:Show()
    end
end

function SpeedrunSplitsTime(time, diff)
	local plusminus = "+"
	if diff == 1 and time < 0 then
		time = -time
		plusminus = "-"
	end
	local h = floor(time/60/60)
	local m = floor((time-h*60*60)/60)
	local s = floor(time-h*60*60-m*60)
	if (h < 10) then
		h = "0"..tostring(h)
	else
		h = tostring(h)
	end
	if (m < 10) then
		m = "0"..tostring(m)
	else
		m = tostring(m)
	end
	if (s < 10) then
		s = "0"..tostring(s)
	else
		s = tostring(s)
	end
	if diff == nil then
		return h..":"..m..":"..s
	elseif h ~= "00" then
		return plusminus..h..":"..m..":"..s
	elseif m ~= "00" then
		return plusminus..m..":"..s
	elseif s ~= "00" then
		return plusminus..s
	else
		return ""
	end
end

function SpeedrunSplitsGenerate()
	local SpeedrunSplitsText = ""
	local SpeedrunSplitsSplitTime = ""
	for i=SpeedrunSplitsMin,SpeedrunSplitsMax do
		local SpeedrunSplitsDiffColor = "|cffffffff"
		if i > SpeedrunSplitsMin then
			SpeedrunSplitsText = SpeedrunSplitsText.."\n"
			SpeedrunSplitsSplitTime = SpeedrunSplitsSplitTime.."\n"
		end
		SpeedrunSplitsText = SpeedrunSplitsText.."Level "..i
		if i <= SpeedrunSplitsLevel and SpeedrunSplits_tContains(SpeedrunSplitsPB[SpeedrunSplitsRaceID][SpeedrunSplitsClassID], i) then
			local SpeedrunSplitsDiff = SpeedrunSplits[i]-SpeedrunSplitsPB[SpeedrunSplitsRaceID][SpeedrunSplitsClassID][i]
			if SpeedrunSplitsDiff < 0 then
				SpeedrunSplitsDiffColor = "|cff00aa00"
			elseif SpeedrunSplitsDiff > 0 then
				SpeedrunSplitsDiffColor = "|cffff0000"
			end
			if SpeedrunSplits_tContains(SpeedrunSplitsGold[SpeedrunSplitsRaceID][SpeedrunSplitsClassID], i) and SpeedrunSplits_tContains(SpeedrunSplits, i-1) then
				if SpeedrunSplitsGold[SpeedrunSplitsRaceID][SpeedrunSplitsClassID][i] == SpeedrunSplits[i]-SpeedrunSplits[i-1] then
					SpeedrunSplitsDiffColor = "|cffffff00"
				end
			end
			SpeedrunSplitsSplitTime = SpeedrunSplitsSplitTime..SpeedrunSplitsDiffColor..SpeedrunSplitsTime(SpeedrunSplits[i]).."|r"
		elseif SpeedrunSplits_tContains(SpeedrunSplitsPB[SpeedrunSplitsRaceID][SpeedrunSplitsClassID], i) then
			SpeedrunSplitsSplitTime = SpeedrunSplitsSplitTime..SpeedrunSplitsTime(SpeedrunSplitsPB[SpeedrunSplitsRaceID][SpeedrunSplitsClassID][i])
		end
	end
	displayupdate(1, SpeedrunSplitsText)
	displayupdate(2, SpeedrunSplitsSplitTime)
end

function SpeedrunSplits_tContains(table, index)
	for key,_ in pairs(table) do
		if key == index then
			return true
		end
	end
	return false
end