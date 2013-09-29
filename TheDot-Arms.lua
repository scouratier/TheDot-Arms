arms = LibStub("AceAddon-3.0"):NewAddon("arms", "AceConsole-3.0", "AceEvent-3.0")

function MakeCode( r , g , b)
    return r/255 , g/255 , b/255
end

function arms:OnInitialize()
    -- Called when the addon is loaded
    self:Print("DOT LOADED: Arms-1.0")

    spells = {  }
    spells["Avatar"] =              {r = 0}, {g = 0}, {b = 0}  
    spells["Battle Shout"] =        {r = 0}, {g = 0}, {b = 0}
    spells["Battle Stance"] =       {r = 0}, {g = 0}, {b = 0}
    spells["Berserker Rage"] =      {r = 0}, {g = 0}, {b = 0}
    spells["Berserker Stance"] =    {r = 0}, {g = 0}, {b = 0}
    spells["Bladestorm"] =          {r = 0}, {g = 0}, {b = 0}
    spells["Charge"] =              {r = 0}, {g = 0}, {b = 0}
    spells["Cleave"] =              {r = 0}, {g = 0}, {b = 0}
    spells["Colossus Smash"] =      {r = 0}, {g = 0}, {b = 0}
    spells["Commanding Shout"] =    {r = 0}, {g = 0}, {b = 0} 
    spells["Defensive Stance"] =    {r = 0}, {g = 0}, {b = 0}
    spells["Die by the Sword"] =    {r = 0}, {g = 0}, {b = 0}
    spells["Disarm"] =              {r = 0}, {g = 0}, {b = 0}
    spells["Disrupting Shout"] =    {r = 0}, {g = 0}, {b = 0}
    spells["Execute"] =             {r = 0}, {g = 0}, {b = 0}
    spells["Hamstring"] =           {r = 0}, {g = 0}, {b = 0}
    spells["Heroic Strike"] =       {r = 0}, {g = 0}, {b = 0}
    spells["Heroic Throw"] =        {r = 0}, {g = 0}, {b = 0}
    spells["Intervene"] =           {r = 0}, {g = 0}, {b = 0}
    spells["Intimidating Shout"] =  {r = 0}, {g = 0}, {b = 0}
    spells["Mass Spell Reflection"] = {r = 0}, {g = 0}, {b = 0}
    spells["Mortal Strike"] =       {r = 0}, {g = 0}, {b = 0}
    spells["Overpower"] =           {r = 0}, {g = 0}, {b = 0}
    spells["Pummel "]=              {r = 0}, {g = 0}, {b = 0}
    spells["Rallying Cry"] =        {r = 0}, {g = 0}, {b = 0}
    spells["Recklessness"] =        {r = 0}, {g = 0}, {b = 0}
    spells["Shield Wall"] =         {r = 0}, {g = 0}, {b = 0}
    spells["Slam"] =                {r = 0}, {g = 0}, {b = 0}
    spells["Spell Reflection"] =    {r = 0}, {g = 0}, {b = 0}
    spells["Sweeping Strikes"] =    {r = 0}, {g = 0}, {b = 0}
    spells["Taunt"] =               {r = 0}, {g = 0}, {b = 0}
    spells["Thunder Clap"] =        {r = 0}, {g = 0}, {b = 0}
    spells["Victory Rush"] =        {r = 0}, {g = 0}, {b = 0}
    spells["Skull Banner"] =        {r = 0}, {g = 0}, {b = 0}
    spells["Whirlwind"] =           {r = 0}, {g = 0}, {b = 0}
          
    self:Print( spells["Avatar"]["r"], spells["Avatar"]["g"], spells["Avatar"]["b"])

end

function arms:OnEnable()
    local f = CreateFrame( "Frame" , "one" , UIParent )
    f:SetFrameStrata( "HIGH" )
    f:SetWidth( 30 )
    f:SetHeight( 15 )
    f:SetPoint( "TOPLEFT" , 15 , 0 )
    
    self.two = CreateFrame( "StatusBar" , nil , f )
    self.two:SetPoint( "TOPLEFT" )
    self.two:SetWidth( 15 )
    self.two:SetHeight( 15 )
    self.two:SetStatusBarTexture("Interface\\AddOns\\thedot\\Images\\Gloss")
    self.two:SetStatusBarColor( 1 , 1 , 1 )
    
    self.three = CreateFrame( "StatusBar" , nil , f )
    self.three:SetPoint( "TOPLEFT" , 15 , 0)
    self.three:SetWidth( 15 )
    self.three:SetHeight( 15 )
    self.three:SetStatusBarTexture("Interface\\AddOns\\thedot\\Images\\Gloss")
    self.three:SetStatusBarColor( 1 , 1 , 1 )
    
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    --self:RegisterEvent("CHAT_MSG_WHISPER")
end

function arms:OnDisable()
    -- Called when the addon is disabled
end

function canCastNow(inSpell)
    local start, duration, enable
    local usable, noRage = IsUsableSpell( inSpell )
        if usable == 1 then
            start, duration, enable = GetSpellCooldown( inSpell )
            if start == 0 then
                return true , 0
            end
        else
            return false , 0
        end
    return false , (start+duration - GetTime())
end

function arms:ACTIONBAR_UPDATE_COOLDOWN()
end

function arms:COMBAT_LOG_EVENT_UNFILTERED()
    -- Start by reseting the dot state:
    self.two:SetStatusBarColor(0, 0, 0);
    self.three:SetStatusBarColor(0, 0, 0);      

    local battleShout = 0
    local rank = 0
    local rage = 0
    local sunders = 0
    local rend = 0
    local inRange = 1
    local spellName
    local red = 0
    local green = 0
    local blue = 0
    local shade = 0
    local nextCast = "none"
    local HSCast = false
    local ZERKCast = false
    local AVACast = false
    local RECKCast = false
    local SKULLCast = false
    local Trinket = false
		
    -- are we in combat
    if InCombatLockdown() == 1 or UnitAffectingCombat("focus") == 1 then
        rage = UnitMana("player")

		local cs, csrank, csicon, cscount, csdebuffType, csduration, csexpirationTime, csisMine, csisStealable  = UnitDebuff("target","Colossus Smash");

        bs, bscooldown = canCastNow( "Battle Shout" )
        if bs == true then
            if rage < 100 then
                nextCast = "Battle Shout"
            end
        end

        slam, slamcooldown = canCastNow("Slam")
        if slam == true and rage > 40 then
            nextCast = "Slam"
        end
        
        tfbbuff, tfbrank, tfbicon, tfbcount = UnitBuff( "player" , "Taste for Blood")
        if tfbbuff ~= nil then
            --op, opcooldown = canCastNow("Overpower")
            if tfbcount > 0 then
                nextCast = "Overpower"
            end
        end

        dr, drcooldown = canCastNow( "Dragon Roar")
        if dr == true then
            nextCast = "Dragon Roar"
        end

        if cs ~= nil then
            if csexpirationTime then
                csexpirein = csexpirationTime - GetTime();
            end
            if csexpirein > 0 and csexpirein < 1 then
                Colossus, ColossusCooldown = canCastNow("Colossus Smash")
                if Colossus == true then
                    nextCast = "Colossus Smash"
                end
            end
        end

        if cs == nil  then
            Colossus, ColossusCooldown = canCastNow("Colossus Smash")
            if Colossus == true then
                nextCast = "Colossus Smash"
            end
        end
            
        hs, hscooldown = canCastNow( "Heroic Strike")
        if rage > 105 and hs == true then
            HSCast = true
        end
            
        ms, mscoodown = canCastNow( "Mortal Strike" )
        if ms == true then
            nextCast = "Mortal Strike"
        end

        if ColossusCooldown ~= nil then
            if ColossusCooldown < 3 and ColossusCooldown > 0 then
                enragebuff = UnitBuff( "player" , "Enrage")
                if enragebuff == nil then
                    ZERKCast, zerkercooldown = canCastNow( "Berserker Rage")
                end
                AVACast, AVAcooldown = canCastNow( "Avatar" )
                RECKCast, reckcooldown = canCastNow( "Recklessness" )
                SKULLCast, skullcooldown = canCastNow( "Skull Banner")
            end
        end
            
        execute, executecooldown = canCastNow( "Execute" )
        if execute == true then
            nextCast = "Execute"
        end

        --if UnitExists( "target" ) then 
        local c, ccooldown = canCastNow( "Charge" )
        local crange = IsSpellInRange( "Charge" , "target" )
        if c == true and crange == 1 then
            nextCast = "Charge"
        else
            --self:Print("Not in range")
        end
	

        if HSCast == true then
            r, g, b = GetColorCode( "Heroic Strike")
            red = red + r
            green = green + g
            blue = blue + b
        end
        if ZERKCast == true then
            r, g, b = GetColorCode( "Berserker Rage" )
            red = red + r
            green = green + g
            blue = blue + b
        end
        if AVACast == true then
            r, g, b = GetColorCode( "Avatar" )
            red = red + r
            green = green + g
            blue = blue + b
        end
        if RECKCast == true then
            r, g, b = GetColorCode( "Recklessness" )
            red = red + r
            green = green + g
            blue = blue + b
        end
        if SKULLCast == true then
            r, g, b = GetColorCode( "Skull Banner" )
            red = red + r
            green = green + g
            blue = blue + b
        end
    else
        --if UnitExists( "target" ) then 
        --local intervene, intercooldown = canCastNow( "Intervene" )
        --local interrange = IsSpellInRange( "Intervene" , "Party1" )
        --if intervene == true and irange == 1 then
        --    self:Print("Unit is in range, trying to intervene")
        --    nextCast = "Intervene"
        --else
        --    self:Print("Not in range")
        --end
    end

    if nextCast ~= "none" then
        --;,dw;,self:Print( nextCast )
    end

    r , g , b = GetColorCode( nextCast )                                               
    red = red + r
    green = green + g
    blue = blue + b 
    --self:Print( red , green , blue )
    self.two:SetStatusBarColor(red/255, green/255, blue/255)
    red = 0
    green = 0
    blue = 0
    self.three:SetStatusBarColor( red/255, green/255, blue/255 );
end

function GetColorCode(inSpell)
    if inSpell == "Bloodthirst" or inSpell == "Mortal Strike" or inSpell == "Shield Slam" then
        return 1 , 0 , 0
    end
    if inSpell == "Whirlwind" then
        return 2 , 0 , 0
    end
    if inSpell == "Wild Strike" or inSpell == "Slam" then
        return 0 , 0 , 128
    end
    if inSpell == "Berserker Rage" then
        return 8 , 0 , 0
    end
    if inSpell == "Raging Blow" or inSpell == "Overpower" then
        return 16 , 0 , 0
    end
    if inSpell == "Execute" then
        return 32 , 0 , 0
    end
    if inSpell == "Bloodbath" or inSpell == "Avatar" then
        return 64 , 0 , 0
    end
    if inSpell == "Victory Rush" then
        return 128 , 0 , 0
    end
    if inSpell == "Colossus Smash" then
        return 0 , 1 , 0
    end
    if inSpell == "Devastate" then
        return 0 , 2 , 0
    end
    if inSpell == "Recklessness" then
        return 0 , 4 , 0
    end
    if inSpell == "Skull Banner" then
        return 0 , 8 , 0
    end
    if inSpell == "Cleave" then
        return 0 , 16 , 0
    end
    if inSpell == "Battle Shout" then
        return 0 , 32 , 0
    end
    if inSpell == "Heroic Throw" then
        return 0 , 64 , 0
    end
    if inSpell == "Shockwave" or inSpell == "Dragon Roar" then
        return 0 , 128 , 0
    end
    if inSpell == "Heroic Strike" then
        return 0 , 0 , 1
    end
    if inSpell == "Charge" then
        return 0 , 0 , 2
    end

    return 0 , 0 , 0
end