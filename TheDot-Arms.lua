arms = LibStub("AceAddon-3.0"):NewAddon("arms", "AceConsole-3.0", "AceEvent-3.0")

function MakeCode( r , g , b)
    return r/255 , g/255 , b/255
end

function arms:OnInitialize()
    -- Called when the addon is loaded
    self:Print("DOT LOADED: Arms-2.0.0")

    spells = {  }
    spells["Charge"] =                  {r = 1  , g = 0  , b = 0}
    spells["Mortal Strike"] =           {r = 2  , g = 0  , b = 0} 
    spells["Whirlwind"] =               {r = 4  , g = 0  , b = 0}
    spells["Rend"] =                    {r = 8  , g = 0  , b = 0}
    spells["Execute"] =                 {r = 16 , g = 0  , b = 0}
    spells["Shield Barrier"] =          {r = 32 , g = 0  , b = 0}
    spells["Bloodbath"] =               {r = 64 , g = 0  , b = 0}
    spells["Recklessness"] =            {r = 128, g = 0  , b = 0}
    spells["Blood Fury"] =              {r = 0  , g = 1  , b = 0}
    spells["Battle Shout"] =            {r = 0  , g = 2  , b = 0}
    spells["Rallying Cry"] =            {r = 0  , g = 4  , b = 0} 
    spells["Victory Rush"] =            {r = 0  , g = 8  , b = 0}

    spells["Mass Spell Reflection"] =   {r = 0  , g = 16 , b = 0}
    spells["Dragon Roar"] =             {r = 0  , g = 32 , b = 0}
    spells["Colossus Smash"] =          {r = 0  , g = 64 , b = 0}
    spells["Enraged Regeneration"] =    {r = 0  , g = 128, b = 0}
    spells["Berserker Rage"] =          {r = 0  , g = 0  , b = 1}
    spells["Heroic Leap"] =             {r = 0  , g = 0  , b = 2}
    spells["Sweaping Strikes"] =        {r = 0  , g = 0  , b = 4}
end

function arms:OnEnable()
    square_size = 15
    local f = CreateFrame( "Frame" , "one" , UIParent )
    f:SetFrameStrata( "HIGH" )
    f:SetWidth( square_size * 2 )
    f:SetHeight( square_size )
    f:SetPoint( "TOPLEFT" , square_size * 2 , 0 )
    
    self.two = CreateFrame( "StatusBar" , nil , f )
    self.two:SetPoint( "TOPLEFT" )
    self.two:SetWidth( square_size )
    self.two:SetHeight( square_size )
    self.two:SetStatusBarTexture("Interface\\AddOns\\thedot\\Images\\Gloss")
    self.two:SetStatusBarColor( 1 , 1 , 1 )
    
    self.three = CreateFrame( "StatusBar" , nil , f )
    self.three:SetPoint( "TOPLEFT" , square_size , 0)
    self.three:SetWidth( square_size )
    self.three:SetHeight( square_size )
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
        if usable == true then
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

    local nextCast = {}
    local noSpell =  { r = 0 , g = 0 , b = 0 }
    nextCast = noSpell     

    local rank = 0
    local rage = 0
    local spellName
    local red = 0
    local green = 0
    local blue = 0

    -- Just get Battle Shout up
    --local bs, bsrank, bsicon, bscount, bsdebuffType, bsduration, bsexpirationTime, bsisMine, bsisStealable  = UnitBuff("player","Battle Shout");
   
    --bscast, bsccooldown = canCastNow( "Battle Shout" )
    --if bscast == true and bs == nil then
    --    nextCast = spells["Battle Shout"]
    --end
		
    -- are we in combat
    if InCombatLockdown() == true or UnitAffectingCombat("focus") == true then
        rage = UnitMana("player")

		local cs, csrank, csicon, cscount, csdebuffType, csduration, csexpirationTime, csisMine, csisStealable  = UnitDebuff("target","Colossus Smash");
        local rend, rendrank, rendicon, rendcount, renddebuffType, rendduration, rendexpirationTime, rendisMine, rendisStealable  = UnitDebuff("target","Rend");

        if cs ~= nil and csisMine then
            ww, wwcooldown = canCastNow( "Whirlwind" )
            if ww == true and rage > 35 then
                nextCast = spells["Whirlwind"]
            end            

            ms, mscoodown = canCastNow( "Mortal Strike" )
            if ms == true then
                nextCast = spells["Mortal Strike"]
            end

            execute, executecooldown = canCastNow( "Execute" )
            if execute == true then
                nextCast = spells["Execute"]
            end
        else
            ww, wwcooldown = canCastNow( "Whirlwind" )
            if ww == true and rage > 35 then
                nextCast = spells["Whirlwind"]
            end

            ms, mscoodown = canCastNow( "Mortal Strike" )
            if ms == true then
                nextCast = spells["Mortal Strike"]
            end

            dr, drcooldown = canCastNow( "Dragon Roar")
            if dr == true then
                nextCast = spells["Dragon Roar"]
            end

            Colossus, ColossusCooldown = canCastNow("Colossus Smash")
            if Colossus == true then
                nextCast = spells["Colossus Smash"]
            end

            -- cast or refresh Rend
            rendcast , rendcastcooldown = canCastNow("Rend")
            if rend ~= nil and rendisMine == "player" then
                -- self:Print("Frost fever detected")
                if rendexpirationTime then
                    rendexpirein = rendexpirationTime - GetTime();
                end
                if rendexpirein > 0 and rendexpirein < 1.4 then
                    if rendcast == true then
                        nextCast = spells["Rend"]
                    end
                end
            else
                if rendcast == true then
                    nextCast = spells["Rend"]
                end
            end

            execute, executecooldown = canCastNow( "Execute" )
            if execute == true then
                nextCast = spells["Execute"]
            end
        end

        vr, vrcooldown = canCastNow( "Victory Rush")
        if vr == true then
            nextCast = spells["Victory Rush"]
        end

        reck, reckcooldown = canCastNow( "Recklessness")
        if reck == true then
            nextCast = spells["Recklessness"]
        end

        bb, bbcooldown = canCastNow( "Bloodbath")
        if bb == true then
            nextCast = spells["Bloodbath"]
        end

        bf, bfcooldown = canCastNow( "Blood Fury")
        if bf == true then
            nextCast = spells["Blood Fury"]
        end

    end

    red = red + nextCast["r"]
    green = green + nextCast["g"]
    blue = blue + nextCast["b"]
    --self:Print( red , green , blue )
    self.two:SetStatusBarColor(red/255, green/255, blue/255)
    red = 0
    green = 0
    blue = 0
    self.three:SetStatusBarColor( red/255, 127/255, blue/255 );
end