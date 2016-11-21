Destruction = LibStub("AceAddon-3.0"):NewAddon("Destruction", "AceConsole-3.0", "AceEvent-3.0")

lastUpdated = 0
updateInterval = 0.1

function MakeCode( r , g , b)
    return r/255 , g/255 , b/255
end

function Destruction:OnInitialize()
    -- Called when the addon is loaded
    self:Print("DOT LOADED: Destruction-3.0.0")

    self.spells = {  }
    -- Get all the bound keys
    self.spells = GetBindings()
    self.Print( self.spells )

end

function Destruction:OnEnable()
    square_size = 15
    local f = CreateFrame( "Frame" , "one" , UIParent )
    f:SetFrameStrata( "HIGH" )
    f:SetScript("OnUpdate", onUpdate)
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
    
end

function Destruction:OnDisable()
    -- Called when the addon is disabled
end

function Destruction:Update()
    -- Start by reseting the dot state:
    self.two:SetStatusBarColor(0, 0, 0);
    self.three:SetStatusBarColor(0, 0, 0);

    nextCast = 0     

    local rank = 0
    local mana = 0
    local spellName
    local red = 0
    local green = 0
    local blue = 0


    -- are we in combat
    if InCombatLockdown() == true or UnitAffectingCombat("focus") == true then
        mana = UnitMana("player")

        nextCast = ifPossible("Drain Life",nextCast)

        local ua, uarank, uaicon, uacount, uadebuffType, uaduration, uaexpirationTime, uaisMine, uaisStealable  = UnitDebuff("target","Unstable Affliction");
        if ua ~= nil and uaisMine == "player" then
            if uaexpirationTime then
                uaexpirein = uaexpirationTime - GetTime();
            end
            if uaexpirein > 0 and uaexpirein < 1 then
                nextCast = ifPossible("Unstable Affliction",nextCast)
            end
        else
            nextCast = ifPossible("Unstable Affliction",nextCast)
        end 
        
        local cr, crrank, cricon, crcount, crdebuffType, crduration, crexpirationTime, crisMine, crisStealable  = UnitDebuff("target","Corruption");
        if cr ~= nil and crisMine == "player" then
            if crexpirationTime then
                crexpirein = crexpirationTime - GetTime();
            end
            if crexpirein > 0 and crexpirein < 1 then
                nextCast = ifPossible("Corruption",nextCast)
            end
        else
            nextCast = ifPossible("Corruption",nextCast)
        end

        local ag, agrank, agicon, agcount, agdebuffType, agduration, agexpirationTime, agisMine, agisStealable  = UnitDebuff("target","Agony");
        if ag ~= nil and agisMine == "player" then
            if agexpirationTime then
                agexpirein = agexpirationTime - GetTime();
            end
            if agexpirein > 0 and agexpirein < 1 then
                nextCast = ifPossible("Agony",nextCast)
            end
        else
            nextCast = ifPossible("Agony",nextCast)
        end 

        



        sb, sbcooldown = canCastNow( "Shadow Bolt" )
        if sb == true then
            nextCast = spells["Shadow Bolt"]
        end
        
        inc, inccooldown = canCastNow( "Incinerate" )
        if inc == true then
            nextCast = spells["Incinerate"]
        end  

        conf, confcooldown = canCastNow( "Conflagrate" )
        if conf == true then
            nextCast = spells["Conflagrate"]
        end

        cb, cbcooldown = canCastNow( "Chaos Bolt" )
        if cb == true then
            nextCast = spells["Chaos Bolt"]
        end
        
        Corruption, crcooldown = canCastNow( "Immolate" )
        if cr ~= nil and crisMine == "player" then
            if crexpirationTime then
                crexpirein = crexpirationTime - GetTime();
            end
            if crexpirein > 0 and crexpirein < 1 then
                if Corruption == true then
                    nextCast = spells["Immolate"]
                end
            end
        else
            if Corruption == true then
                nextCast = spells["Immolate"]
            end
        end  
    end
    

    if nextCast == nil then
        nextCast = spells["Incinerate"]
    end
    self.two:SetStatusBarColor(nextCast/255, green/255, blue/255)
    red = 0
    green = 0
    blue = 0
    self.three:SetStatusBarColor( red/255, 127/255, blue/255 );
end

function onUpdate(self, elapsed)
    --self.lastUpdated = self.lastUpdated + elapsed
    lastUpdated = lastUpdated + elapsed
    --if (self.lastUpdated > self.update_interval) then
    if (lastUpdated > updateInterval) then
        Destruction:Update()
        lastUpdated = 0
    end
end