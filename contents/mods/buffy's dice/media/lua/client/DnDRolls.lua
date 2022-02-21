--***********************************************************
--**                    NECROPOLISRP.NET                   **
--**			 Mod Author: github.com/buffyuwu    	   **
--***********************************************************

require "ISUI/ISPanel"
require "ISUI/ISPanelJoypad"

DnDRules = {};

function DnDRules.setLocalSandboxVars()
	dicebudgetmax = SandboxVars.DnDRules.SkillBalance;
	over20crit = SandboxVars.DnDRules.Criticals; --should rolls plus modifiers over 20 be considered crits?
	if over20crit == nil then --there be dragons here
		over20crit = false; --default to false, just like in the sandboxoptions vars
	end
	if dicebudgetmax == nil then --there be dragons here
		dicebudgetmax = 30; --default to 30, just like in the sandboxoptions vars
	end
end
local rolling = false;
function ISSkillProgressBar:onMouseDown(x, y)
	local lvlSelected = math.floor(self:getMouseX()/20);

	self.level = self.char:getPerkLevel(self.perk:getType());

	self.xpForLvl = ISSkillProgressBar.getXpForLvl(self.perk, self.level);
    local special = " ";
    local modifier = ": ";
	local result = ZombRand(0, 20)+1; --this looks like shitcode, but trust me, the zombrand func doesnt ever roll on the ceiling number, only the low
	local spcresult = result + self.level
	local realroll = result;
    if self.level > 0 then
        modifier = " (" .. realroll .. " +" .. self.level .. " Modifier) : ";
    end
	
    if result >= 20 then
        special = " *green* **CRITICAL SUCCESS!** ";
	elseif result > 20 then
		result = 20
	elseif spcresult >= 20 and over20crit then
		special = " *green* **CRITICAL SUCCESS!** ";
    elseif result <= 1 then
        special = " *red* **CRITICAL FAILURE!** ";
    elseif spcresult == 0 then
        result = 1;
    end
	result = result + self.level;
	local combined = "*dice*" .. special .. get_rpname() .. " rolled " .. self.perk:getName() .. modifier .. result;
	if rolling and not isCtrlKeyDown() and not isShiftKeyDown() then
		if self.perk == Perks.DnDStrength or 
		self.perk == Perks.DnD1hMelee or
		self.perk == Perks.DnD2hMelee or
		self.perk == Perks.DnDDefense or
		self.perk == Perks.DnDEvasion or
		self.perk == Perks.DnDAccuracy or
		self.perk == Perks.DnDCharisma or
		self.perk == Perks.DnDPersuasion or
		self.perk == Perks.DnDDeception or
		self.perk == Perks.DnDIntelligence or
		self.perk == Perks.DnDWisdom or
		self.perk == Perks.DnDInsight or
		self.perk == Perks.DnDFirstAid or
		self.perk == Perks.DnDPerception or
		self.perk == Perks.DnDInitiative then
		processSayMessage(combined);
		getPlayer():getSquare():playSound("rollDice")
		return
	   end
	end
	local skillbudget = self.char:getPerkLevel(Perks.DnDStrength) + 
	self.char:getPerkLevel(Perks.DnD1hMelee) + 
	self.char:getPerkLevel(Perks.DnD2hMelee) + 
	self.char:getPerkLevel(Perks.DnDDefense) +
	self.char:getPerkLevel(Perks.DnDEvasion) +
	self.char:getPerkLevel(Perks.DnDAccuracy) +
	self.char:getPerkLevel(Perks.DnDCharisma) +
	self.char:getPerkLevel(Perks.DnDPersuasion) +
	self.char:getPerkLevel(Perks.DnDDeception) +
	self.char:getPerkLevel(Perks.DnDIntelligence) +
	self.char:getPerkLevel(Perks.DnDWisdom) + 
	self.char:getPerkLevel(Perks.DnDInsight) + 
	self.char:getPerkLevel(Perks.DnDFirstAid) + 
	self.char:getPerkLevel(Perks.DnDPerception) + 
	self.char:getPerkLevel(Perks.DnDInitiative);
	if skillbudget < dicebudgetmax and not rolling then
	    if self.perk == Perks.DnDStrength or 
	   self.perk == Perks.DnD1hMelee or
	   self.perk == Perks.DnD2hMelee or
	   self.perk == Perks.DnDDefense or
	   self.perk == Perks.DnDEvasion or
	   self.perk == Perks.DnDAccuracy or
	   self.perk == Perks.DnDCharisma or
	   self.perk == Perks.DnDPersuasion or
	   self.perk == Perks.DnDDeception or
	   self.perk == Perks.DnDIntelligence or
	   self.perk == Perks.DnDWisdom or
	   self.perk == Perks.DnDInsight or
	   self.perk == Perks.DnDFirstAid or
	   self.perk == Perks.DnDPerception or
	   self.perk == Perks.DnDInitiative then
			if self.level >= 6 then
				return
			else
				self.char:LevelPerk(self.perk:getType());
			end
	   
	    end
	elseif isCtrlKeyDown() and isShiftKeyDown() and skillbudget >= 1 and rolling then
		rolling = false;
		call_reset_skills()
		return
	elseif skillbudget == dicebudgetmax then
		if not rolling then
			getPlayer():addLineChatElement("Skills updated.", 0, 0, 1);
			print("budget exceeded, enabling rolling")
			rolling = true;
		end
	end
end

function ISCharacterInfo:render()
	local tabHeight = self.y
	local maxHeight = getCore():getScreenHeight() - ISWindow.TitleBarHeight - tabHeight - 20
	local y = 10

	if self.lastLevelUpTime > 0 then
		self.lastLevelUpTime = self.lastLevelUpTime - 0.0025
	elseif self.lastLevelUpTime < 0 then
		self.lastLevelUpTime = 0
	end

	ISSkillProgressBar.updateAlpha() -- FIXME: do this once per frame, not for each player
	-- how much skills pts we got ?
	if self.reloadSkillBar then
		self.progressBarLoaded = false;
		self.reloadSkillBar = false;
		for i,v in pairs(self.progressBars) do
			self:removeChild(v);
		end
		self.progressBars = {}

	end

	local top = y

	-- if we got a multiplier, we gonna anim that with ">, >>, >>>"
	 -- FIXME: do this once per frame, not for each player
	local ms = UIManager.getMillisSinceLastRender()
	ISCharacterInfo.timerMultiplierAnim = ISCharacterInfo.timerMultiplierAnim + ms;
	if ISCharacterInfo.timerMultiplierAnim <= 500 then
        ISCharacterInfo.animOffset = -1;
	elseif ISCharacterInfo.timerMultiplierAnim <= 1000 then
        ISCharacterInfo.animOffset = 0;
	elseif ISCharacterInfo.timerMultiplierAnim <= 1500 then
        ISCharacterInfo.animOffset = 15;
	elseif ISCharacterInfo.timerMultiplierAnim <= 2000 then
        ISCharacterInfo.animOffset = 30;
	else
		ISCharacterInfo.timerMultiplierAnim = 0;
	end

	local sorted = {}
	local nameToPerk = {}
	for k,v in pairs(self.perks) do
		local parentPerk = PerkFactory.getPerk(k)
		table.insert(sorted, parentPerk)
		nameToPerk[parentPerk:getName()] = k
	end

	table.sort(sorted, function(a,b)
		if a:isPassiv() then
			local dbg = 1
		end
		if a:isPassiv() and not b:isPassiv() then
			return true
		end
		if b:isPassiv() and not a:isPassiv() then
			return false
		end
		return not string.sort(a:getName(), b:getName())
	end)

	local left = 0
	local maxY = y
	local fontHgt = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
	local progressHgt = 18
	local rowHgt = math.max(fontHgt, progressHgt + 2)
	local skillbudget = self.char:getPerkLevel(Perks.DnDStrength) + 
	self.char:getPerkLevel(Perks.DnD1hMelee) + 
	self.char:getPerkLevel(Perks.DnD2hMelee) + 
	self.char:getPerkLevel(Perks.DnDDefense) +
	self.char:getPerkLevel(Perks.DnDEvasion) +
	self.char:getPerkLevel(Perks.DnDAccuracy) +
	self.char:getPerkLevel(Perks.DnDCharisma) +
	self.char:getPerkLevel(Perks.DnDPersuasion) +
	self.char:getPerkLevel(Perks.DnDDeception) +
	self.char:getPerkLevel(Perks.DnDIntelligence) +
	self.char:getPerkLevel(Perks.DnDWisdom) + 
	self.char:getPerkLevel(Perks.DnDInsight) + 
	self.char:getPerkLevel(Perks.DnDFirstAid) + 
	self.char:getPerkLevel(Perks.DnDPerception) + 
	self.char:getPerkLevel(Perks.DnDInitiative);
	
	if rolling then
    	self:drawText("Click a (Buffy Dice) skill to roll a d20.", left + 5, y, 1, 1, 1, 1, UIFont.Small);
		y = y + 20
		self:drawText("Ctrl + Shift Click a (Buffy Dice) skill to reset d20 skills.", left + 5, y, 1, 1, 1, 1, UIFont.Small);
		y = y + 5
	else
		self:drawText("Click a (Buffy Dice) skill to level it up.", left + 5, y, 1, 1, 1, 1, UIFont.Small);
		y = y + 25;
		self:drawText("Assigned: " .. skillbudget .. "/"..dicebudgetmax,left + 5, y, 1, 1, 1, 1, UIFont.Small);
		y = y + 5;
    end
    self:drawTexture(self.SkillBarSeparator, left, y + fontHgt + 10, 1,1,1,1);
    y = y + 40;
	for _,parentPerk in ipairs(sorted) do
		local perkList = self.perks[parentPerk:getType()]
		-- we first draw our parent name
		self:drawText(parentPerk:getName(), left + 5, y, 1, 1, 1, 1, UIFont.Small);
		self:drawTexture(self.SkillBarSeparator, left, y + fontHgt + 2, 1,1,1,1);
		y = y + math.max(25, fontHgt);
		-- then all the skills with their progress bar
		for ind, perk in ipairs(perkList) do
            local xpBoost = self.char:getXp():getPerkBoost(perk:getType());
            local r = 1;
            local g = 1;
            local b = 1;
            if xpBoost == 0 then
                r = 0.54;
                g = 0.54;
                b = 0.54;
            elseif xpBoost == 1 then
                r = 0.8;
                g = 0.8;
                b = 0.8;
            elseif xpBoost == 3 then
                r = 1;
                g = 0.83;
                b = 0;
            end
			self:drawText(perk:getName(), left + 20, y, r, g, b, 1, UIFont.Small);
			-- if we got a multiplier, we gonna anim that with ">, >>, >>>"
            if self.char:getXp():getMultiplier(perk:getType()) > 0 then
                self:drawTexture(self.disabledArrow, left + 20 + self.txtLen, y, 1, 1, 1, 1);
                self:drawTexture(self.disabledArrow, left + 35 + self.txtLen, y, 1, 1, 1, 1);
                self:drawTexture(self.disabledArrow, left + 50 +self.txtLen, y, 1, 1, 1, 1);

                if ISCharacterInfo.animOffset > -1 then
                    self:drawTexture(self.arrow, left + 20 + self.txtLen + ISCharacterInfo.animOffset, y, 1, 1, 1, 1);
                end
            end
			if not self.progressBarLoaded then
				local progressBar = ISSkillProgressBar:new(left + 20 + self.txtLen + 45, y + (rowHgt - progressHgt) / 2, 0, 0, self.playerNum, perk, self);
				progressBar:initialise();
				self:addChild(progressBar);
				table.insert(self.progressBars, progressBar);
			end
			y = y + rowHgt;
		end
		y = y + 10;
		maxY = math.max(maxY, y)
	end

--~ 	self:drawText("Strong : " .. getPlayer():getPerkLevel(Perks.Strength), self.x + 8, y, 1, 1, 1, 1, UIFont.Small);
	y = maxY + 10;
--~ 	for i = 0, getPlayer():getTraits():size() - 1 do
--~ 		local v = getPlayer():getTraits():get(i);
--~ 		self:drawText("Trait : " .. v, self.x + 8, y, 1, 1, 1, 1, UIFont.Small);
--~ 		y = y + 20;
--~ 	end
--~ 	self:drawText("Hauling : " .. getPlayer():getXp():getXP(Perks.Hauling), self.x + 8, y, 1, 1, 1, 1, UIFont.Small);

    self:setWidthAndParentWidth(left + self.txtLen + 380);
	self:setHeightAndParentHeight(math.min(y, maxHeight));

	self:setScrollHeight(y)

	self.progressBarLoaded = true;

	if self.joyfocus then
		if self.joypadIndex and self.joypadIndex >= 1 and self.joypadIndex <= #self.progressBars then
			local bar = self.progressBars[self.joypadIndex]
			local left = bar:getX() - (self.txtLen + 45)
			local right = bar:getX() + bar:getWidth()
			self:drawRectBorder(left-2, bar:getY()-2, (right - left) + 2, bar:getHeight() + 3, 0.4, 0.2, 1.0, 1.0);
			if bar.tooltip then
				bar.tooltip.followMouse = false
				bar.tooltip:setX(bar:getAbsoluteX())
				local tty = bar:getAbsoluteY() + bar:getHeight() + 1
				if tty + bar.tooltip:getHeight() > getCore():getScreenHeight() then
					tty = bar:getAbsoluteY() - bar.tooltip:getHeight() - 1
				end
				bar.tooltip:setY(tty)
			end
		end
	end

	self:clearStencilRect()
end

function get_rpname()
	local name = ISChat.instance.rpName or "Unknown"
	if name == "Unknown" then
		local charDesc = getPlayer():getDescriptor()
		name = charDesc:getForename();
	end
	return name;
end

function call_reset_skills()
	processSayMessage("*spiffohead*"..get_rpname().." reset their dice skills.")
	Events.OnTick.Add(reset_skills)
end

function reset_skills()
	local playerchar = getPlayer()
	rolling = false;
	local dicetotals = playerchar:getPerkLevel(Perks.DnDStrength) + 
	playerchar:getPerkLevel(Perks.DnD1hMelee) + 
	playerchar:getPerkLevel(Perks.DnD2hMelee) + 
	playerchar:getPerkLevel(Perks.DnDDefense) +
	playerchar:getPerkLevel(Perks.DnDEvasion) +
	playerchar:getPerkLevel(Perks.DnDAccuracy) +
	playerchar:getPerkLevel(Perks.DnDCharisma) +
	playerchar:getPerkLevel(Perks.DnDPersuasion) +
	playerchar:getPerkLevel(Perks.DnDDeception) +
	playerchar:getPerkLevel(Perks.DnDIntelligence) +
	playerchar:getPerkLevel(Perks.DnDWisdom) + 
	playerchar:getPerkLevel(Perks.DnDInsight) + 
	playerchar:getPerkLevel(Perks.DnDFirstAid) + 
	playerchar:getPerkLevel(Perks.DnDPerception) + 
	playerchar:getPerkLevel(Perks.DnDInitiative);
	if dicetotals > 0 then
		playerchar:LoseLevel(Perks.DnDStrength);
		playerchar:getXp():setXPToLevel(Perks.DnDStrength, playerchar:getPerkLevel(Perks.DnDStrength))
		playerchar:LoseLevel(Perks.DnD1hMelee);
		playerchar:getXp():setXPToLevel(Perks.DnD1hMelee, playerchar:getPerkLevel(Perks.DnD1hMelee))
		playerchar:LoseLevel(Perks.DnD2hMelee);
		playerchar:getXp():setXPToLevel(Perks.DnD2hMelee, playerchar:getPerkLevel(Perks.DnD2hMelee))
		playerchar:LoseLevel(Perks.DnDDefense);
		playerchar:getXp():setXPToLevel(Perks.DnDDefense, playerchar:getPerkLevel(Perks.DnDDefense))
		playerchar:LoseLevel(Perks.DnDEvasion);
		playerchar:getXp():setXPToLevel(Perks.DnDEvasion, playerchar:getPerkLevel(Perks.DnDEvasion))
		playerchar:LoseLevel(Perks.DnDAccuracy);
		playerchar:getXp():setXPToLevel(Perks.DnDAccuracy, playerchar:getPerkLevel(Perks.DnDAccuracy))
		playerchar:LoseLevel(Perks.DnDCharisma);
		playerchar:getXp():setXPToLevel(Perks.DnDCharisma, playerchar:getPerkLevel(Perks.DnDCharisma))
		playerchar:LoseLevel(Perks.DnDPersuasion);
		playerchar:getXp():setXPToLevel(Perks.DnDPersuasion, playerchar:getPerkLevel(Perks.DnDPersuasion))
		playerchar:LoseLevel(Perks.DnDDeception);
		playerchar:getXp():setXPToLevel(Perks.DnDDeception, playerchar:getPerkLevel(Perks.DnDDeception))
		playerchar:LoseLevel(Perks.DnDIntelligence);
		playerchar:getXp():setXPToLevel(Perks.DnDIntelligence, playerchar:getPerkLevel(Perks.DnDIntelligence))
		playerchar:LoseLevel(Perks.DnDWisdom);
		playerchar:getXp():setXPToLevel(Perks.DnDWisdom, playerchar:getPerkLevel(Perks.DnDWisdom))
		playerchar:LoseLevel(Perks.DnDInsight);
		playerchar:getXp():setXPToLevel(Perks.DnDInsight, playerchar:getPerkLevel(Perks.DnDInsight))
		playerchar:LoseLevel(Perks.DnDFirstAid);
		playerchar:getXp():setXPToLevel(Perks.DnDStrength, playerchar:getPerkLevel(Perks.DnDFirstAid))
		playerchar:LoseLevel(Perks.DnDInitiative);
		playerchar:getXp():setXPToLevel(Perks.DnDInitiative, playerchar:getPerkLevel(Perks.DnDInitiative))
		playerchar:LoseLevel(Perks.DnDPerception);
		playerchar:getXp():setXPToLevel(Perks.DnDPerception, playerchar:getPerkLevel(Perks.DnDPerception))
		SyncXp(playerchar)
		dicetotals = playerchar:getPerkLevel(Perks.DnDStrength) + 
		playerchar:getPerkLevel(Perks.DnD1hMelee) + 
		playerchar:getPerkLevel(Perks.DnD2hMelee) + 
		playerchar:getPerkLevel(Perks.DnDDefense) +
		playerchar:getPerkLevel(Perks.DnDEvasion) +
		playerchar:getPerkLevel(Perks.DnDAccuracy) +
		playerchar:getPerkLevel(Perks.DnDCharisma) +
		playerchar:getPerkLevel(Perks.DnDPersuasion) +
		playerchar:getPerkLevel(Perks.DnDDeception) +
		playerchar:getPerkLevel(Perks.DnDIntelligence) +
		playerchar:getPerkLevel(Perks.DnDWisdom) + 
		playerchar:getPerkLevel(Perks.DnDInsight) + 
		playerchar:getPerkLevel(Perks.DnDFirstAid) + 
		playerchar:getPerkLevel(Perks.DnDPerception) + 
		playerchar:getPerkLevel(Perks.DnDInitiative);
		print("Removed 1 level")
	elseif dicetotals <= 0 then
		Events.OnTick.Remove(reset_skills)
		print("Removal complete")
	end
	if rolling and dicetotals <= 0 then
		getPlayer():addLineChatElement("Skills reset.", 0, 0, 1);
		rolling = false;
	end
end


Events.EveryTenMinutes.Add(DnDRules.setLocalSandboxVars) --check if these values have changed
