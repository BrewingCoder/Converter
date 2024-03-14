local actionList = {}
local buff
local casting
local cd
local charges
local chi
local debuff
local enemies
local energy
local equiped
local module
local talent
local ui
local unit
local use
local var



-- Action List - Precombat
actionList.Precombat = function()
    -- Module - Phial Up
    -- flask
    module.PhialUp()

    -- Module - Imbue Up
    -- augmentation
    module.ImbueUp()

    -- Variable - Sync Serenity,Default=0
    -- variable,name=sync_serenity,default=0,value=1,if=(equipped.neltharions_call_to_dominance|equipped.ashes_of_the_embersoul|equipped.mirror_of_fractured_tomorrows|equipped.witherbarks_branch)&!(fight_style.dungeonslice|fight_style.dungeonroute)
    if (((equiped.neltharionsCallToDominance() or equiped.ashesOfTheEmbersoul() or equiped.mirrorOfFracturedTomorrows() or equiped.witherbarksBranch()) and not (unit.instance("party") or unit.instance("dungeonroute")))) then
        var.syncSerenity,Default=0 = 1
    end

    -- Summon White Tiger Statue
    -- summon_white_tiger_statue
    if cast.able.summonWhiteTigerStatue() then
        if cast.summonWhiteTigerStatue() then ui.debug("Casting Summon White Tiger Statue [Precombat]") return true end
    end

    -- Expel Harm
    -- expel_harm,if=chi<chi.max
    if cast.able.expelHarm() and chi()<chi.max() then
        if cast.expelHarm() then ui.debug("Casting Expel Harm [Precombat]") return true end
    end

    -- Chi Burst
    -- chi_burst,if=!talent.jadefire_stomp
    if cast.able.chiBurst() and not talent.jadefireStomp then
        if cast.chiBurst() then ui.debug("Casting Chi Burst [Precombat]") return true end
    end

    -- Chi Wave
    -- chi_wave
    if cast.able.chiWave() then
        if cast.chiWave() then ui.debug("Casting Chi Wave [Precombat]") return true end
    end

end -- End Action List - Precombat

-- Action List - Combat
actionList.Combat = function()
    -- Auto Attack
    -- auto_attack
    if cast.able.autoAttack() then
        if cast.autoAttack() then ui.debug("Casting Auto Attack [Combat]") return true end
    end

    -- Roll
    -- roll,if=movement.distance>5
    if cast.able.roll() and unit.distance()>5 then
        if cast.roll() then ui.debug("Casting Roll [Combat]") return true end
    end

    -- Chi Torpedo
    -- chi_torpedo,if=movement.distance>5
    if cast.able.chiTorpedo() and unit.distance()>5 then
        if cast.chiTorpedo() then ui.debug("Casting Chi Torpedo [Combat]") return true end
    end

    -- Flying Serpent Kick
    -- flying_serpent_kick,if=movement.distance>5
    if cast.able.flyingSerpentKick() and unit.distance()>5 then
        if cast.flyingSerpentKick() then ui.debug("Casting Flying Serpent Kick [Combat]") return true end
    end

    -- Spear Hand Strike
    -- spear_hand_strike,if=target.debuff.casting.react
    -- TODO: The following conditions were not converted:
    -- target.debuff.casting.react
    if cast.able.spearHandStrike() and casting then
        if cast.spearHandStrike() then ui.debug("Casting Spear Hand Strike [Combat]") return true end
    end

    -- Variable - Hold Xuen,Op=Set
    -- variable,name=hold_xuen,op=set,value=!talent.invoke_xuen_the_white_tiger|cooldown.invoke_xuen_the_white_tiger.duration>fight_remains
    var.holdXuen,Op=Set = (not talent.invokeXuenTheWhiteTiger or cd.invokeXuenTheWhiteTiger.duration()>unit.ttdGroup(40))

    -- Variable - Hold Tp Rsk,Op=Set
    -- variable,name=hold_tp_rsk,op=set,value=!debuff.skyreach_exhaustion.remains<1&cooldown.rising_sun_kick.remains<1&(set_bonus.tier30_2pc|active_enemies<5)
    var.holdTpRsk,Op=Set = (not debuff.skyreachExhaustion.remains(PLACEHOLDER)<1 and cd.risingSunKick.remains()<1 and (equiped.tier(30)>=2 or #enemies.yards0<5))

    -- Variable - Hold Tp Bdb,Op=Set
    -- variable,name=hold_tp_bdb,op=set,value=!debuff.skyreach_exhaustion.remains<1&cooldown.bonedust_brew.remains<1&active_enemies=1
    var.holdTpBdb,Op=Set = not debuff.skyreachExhaustion.remains(PLACEHOLDER)<1 and cd.bonedustBrew.remains()<1 and #enemies.yards0==1

    -- Module - Combatpotion Up
    -- potion,if=buff.serenity.up|buff.storm_earth_and_fire.up&pet.xuen_the_white_tiger.active|fight_remains<=30
    module.CombatpotionUp()

    -- Call Action List - Opener
    -- call_action_list,name=opener,if=time<4&chi<5&!pet.xuen_the_white_tiger.active&!talent.serenity
    if unit.combatTime()<4 and chi()<5 and not pet.xuen_the_white_tiger.active and not talent.serenity then
        if actionList.Opener() then return true end
    end

    -- Call Action List - Trinkets
    -- call_action_list,name=trinkets
    if actionList.Trinkets() then return true end

    -- Jadefire Stomp
    -- jadefire_stomp,target_if=min:debuff.jadefire_brand_damage.remains,if=combo_strike&talent.jadefire_harmony&debuff.jadefire_brand_damage.remains<1
    -- Jadefire Stomp
    -- jadefire_stomp,target_if=min:debuff.jadefire_brand_damage.remains,if=combo_strike&talent.jadefire_harmony&debuff.jadefire_brand_damage.remains<1
    if cast.able.jadefireStomp() and combo_strike and talent.jadefireHarmony and debuff.jadefireBrandDamage.remains(PLACEHOLDER)<1 then
        if cast.jadefireStomp() then ui.debug("Casting Jadefire Stomp [Combat]") return true end
    end

    -- Bonedust Brew
    -- bonedust_brew,if=active_enemies=1&!debuff.skyreach_exhaustion.remains&(pet.xuen_the_white_tiger.active|cooldown.xuen_the_white_tiger.remains)
    if cast.able.bonedustBrew() and ((#enemies.yards0==1 and not debuff.skyreachExhaustion.remains(PLACEHOLDER) and (pet.xuen_the_white_tiger.active or cd.xuenTheWhiteTiger.remains()))) then
        if cast.bonedustBrew() then ui.debug("Casting Bonedust Brew [Combat]") return true end
    end

    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains+(debuff.skyreach_exhaustion.up*20),if=!buff.serenity.up&energy>50&buff.teachings_of_the_monastery.stack<3&combo_strike&chi.max-chi>=(2+buff.power_strikes.up)&(!talent.invoke_xuen_the_white_tiger&!talent.serenity|((!talent.skyreach&!talent.skytouch)|time>5|pet.xuen_the_white_tiger.active))&!variable.hold_tp_rsk&(active_enemies>1|!talent.bonedust_brew|talent.bonedust_brew&active_enemies=1&cooldown.bonedust_brew.remains)
    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains+(debuff.skyreach_exhaustion.up*20),if=!buff.serenity.up&energy>50&buff.teachings_of_the_monastery.stack<3&combo_strike&chi.max-chi>=(2+buff.power_strikes.up)&(!talent.invoke_xuen_the_white_tiger&!talent.serenity|((!talent.skyreach&!talent.skytouch)|time>5|pet.xuen_the_white_tiger.active))&!variable.hold_tp_rsk&(active_enemies>1|!talent.bonedust_brew|talent.bonedust_brew&active_enemies=1&cooldown.bonedust_brew.remains)
    if cast.able.tigerPalm() and ((not buff.serenity.exists() and energy()>50 and buff.teachingsOfTheMonastery.stack()<3 and combo_strike and chi.max()-chi()>=(2+buff.powerStrikes.exists()) and (not talent.invokeXuenTheWhiteTiger and not talent.serenity or ((not talent.skyreach and not talent.skytouch) or unit.combatTime()>5 or pet.xuen_the_white_tiger.active)) and not var.holdTpRsk and (#enemies.yards0>1 or not talent.bonedustBrew or talent.bonedustBrew and #enemies.yards0==1 and cd.bonedustBrew.remains()))) then
        if cast.tigerPalm() then ui.debug("Casting Tiger Palm [Combat]") return true end
    end

    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains+(debuff.skyreach_exhaustion.up*20),if=!buff.serenity.up&buff.teachings_of_the_monastery.stack<3&combo_strike&chi.max-chi>=(2+buff.power_strikes.up)&(!talent.invoke_xuen_the_white_tiger&!talent.serenity|((!talent.skyreach&!talent.skytouch)|time>5|pet.xuen_the_white_tiger.active))&!variable.hold_tp_rsk&(active_enemies>1|!talent.bonedust_brew|talent.bonedust_brew&active_enemies=1&cooldown.bonedust_brew.remains)
    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains+(debuff.skyreach_exhaustion.up*20),if=!buff.serenity.up&buff.teachings_of_the_monastery.stack<3&combo_strike&chi.max-chi>=(2+buff.power_strikes.up)&(!talent.invoke_xuen_the_white_tiger&!talent.serenity|((!talent.skyreach&!talent.skytouch)|time>5|pet.xuen_the_white_tiger.active))&!variable.hold_tp_rsk&(active_enemies>1|!talent.bonedust_brew|talent.bonedust_brew&active_enemies=1&cooldown.bonedust_brew.remains)
    if cast.able.tigerPalm() and ((not buff.serenity.exists() and buff.teachingsOfTheMonastery.stack()<3 and combo_strike and chi.max()-chi()>=(2+buff.powerStrikes.exists()) and (not talent.invokeXuenTheWhiteTiger and not talent.serenity or ((not talent.skyreach and not talent.skytouch) or unit.combatTime()>5 or pet.xuen_the_white_tiger.active)) and not var.holdTpRsk and (#enemies.yards0>1 or not talent.bonedustBrew or talent.bonedustBrew and #enemies.yards0==1 and cd.bonedustBrew.remains()))) then
        if cast.tigerPalm() then ui.debug("Casting Tiger Palm [Combat]") return true end
    end

    -- Chi Burst
    -- chi_burst,if=talent.jadefire_stomp&cooldown.jadefire_stomp.remains&(chi.max-chi>=1&active_enemies=1|chi.max-chi>=2&active_enemies>=2)&!talent.jadefire_harmony
    if cast.able.chiBurst() and ((talent.jadefireStomp and cd.jadefireStomp.remains() and (chi.max()-chi()>=1 and #enemies.yards0==1 or chi.max()-chi()>=2 and #enemies.yards0>=2) and not talent.jadefireHarmony)) then
        if cast.chiBurst() then ui.debug("Casting Chi Burst [Combat]") return true end
    end

    -- Call Action List - Cd Sef
    -- call_action_list,name=cd_sef,if=!talent.serenity
    if not talent.serenity then
        if actionList.CdSef() then return true end
    end

    -- Call Action List - Cd Serenity
    -- call_action_list,name=cd_serenity,if=talent.serenity
    if talent.serenity then
        if actionList.CdSerenity() then return true end
    end

    -- Call Action List - Serenity Aoelust
    -- call_action_list,name=serenity_aoelust,if=buff.serenity.up&((buff.bloodlust.up&(buff.invokers_delight.up|buff.power_infusion.up))|buff.invokers_delight.up&buff.power_infusion.up)&active_enemies>4
    if (buff.serenity.exists() and ((buff.bloodlust.exists() and (buff.invokersDelight.exists() or buff.powerInfusion.exists())) or buff.invokersDelight.exists() and buff.powerInfusion.exists()) and #enemies.yards0>4) then
        if actionList.SerenityAoelust() then return true end
    end

    -- Call Action List - Serenity Lust
    -- call_action_list,name=serenity_lust,if=buff.serenity.up&((buff.bloodlust.up&(buff.invokers_delight.up|buff.power_infusion.up))|buff.invokers_delight.up&buff.power_infusion.up)&active_enemies<4
    if (buff.serenity.exists() and ((buff.bloodlust.exists() and (buff.invokersDelight.exists() or buff.powerInfusion.exists())) or buff.invokersDelight.exists() and buff.powerInfusion.exists()) and #enemies.yards0<4) then
        if actionList.SerenityLust() then return true end
    end

    -- Call Action List - Serenity Aoe
    -- call_action_list,name=serenity_aoe,if=buff.serenity.up&active_enemies>4
    if buff.serenity.exists() and #enemies.yards0>4 then
        if actionList.SerenityAoe() then return true end
    end

    -- Call Action List - Serenity 4T
    -- call_action_list,name=serenity_4t,if=buff.serenity.up&active_enemies=4
    if buff.serenity.exists() and #enemies.yards0==4 then
        if actionList.Serenity4T() then return true end
    end

    -- Call Action List - Serenity 3T
    -- call_action_list,name=serenity_3t,if=buff.serenity.up&active_enemies=3
    if buff.serenity.exists() and #enemies.yards0==3 then
        if actionList.Serenity3T() then return true end
    end

    -- Call Action List - Serenity 2T
    -- call_action_list,name=serenity_2t,if=buff.serenity.up&active_enemies=2
    if buff.serenity.exists() and #enemies.yards0==2 then
        if actionList.Serenity2T() then return true end
    end

    -- Call Action List - Serenity St
    -- call_action_list,name=serenity_st,if=buff.serenity.up&active_enemies=1
    if buff.serenity.exists() and #enemies.yards0==1 then
        if actionList.SerenitySt() then return true end
    end

    -- Call Action List - Default Aoe
    -- call_action_list,name=default_aoe,if=active_enemies>4
    if #enemies.yards0>4 then
        if actionList.DefaultAoe() then return true end
    end

    -- Call Action List - Default 4T
    -- call_action_list,name=default_4t,if=active_enemies=4
    if #enemies.yards0==4 then
        if actionList.Default4T() then return true end
    end

    -- Call Action List - Default 3T
    -- call_action_list,name=default_3t,if=active_enemies=3
    if #enemies.yards0==3 then
        if actionList.Default3T() then return true end
    end

    -- Call Action List - Default 2T
    -- call_action_list,name=default_2t,if=active_enemies=2
    if #enemies.yards0==2 then
        if actionList.Default2T() then return true end
    end

    -- Call Action List - Default St
    -- call_action_list,name=default_st,if=active_enemies=1
    if #enemies.yards0==1 then
        if actionList.DefaultSt() then return true end
    end

    -- Summon White Tiger Statue
    -- summon_white_tiger_statue
    if cast.able.summonWhiteTigerStatue() then
        if cast.summonWhiteTigerStatue() then ui.debug("Casting Summon White Tiger Statue [Combat]") return true end
    end

    -- Call Action List - Fallthru
    -- call_action_list,name=fallthru
    if actionList.Fallthru() then return true end

end -- End Action List - Combat

-- Action List - BdbSetup
actionList.BdbSetup = function()
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist&active_enemies>3
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist&active_enemies>3
    if cast.able.strikeOfTheWindlord() and talent.thunderfist and #enemies.yards0>3 then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Bdb Setup]") return true end
    end

    -- Bonedust Brew
    -- bonedust_brew,if=spinning_crane_kick.max&chi>=4
    if cast.able.bonedustBrew() and spinning_crane_kick.max and chi()>=4 then
        if cast.bonedustBrew() then ui.debug("Casting Bonedust Brew [Bdb Setup]") return true end
    end

    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains+(debuff.skyreach_exhaustion.up*20),if=combo_strike&chi.max-chi>=2&buff.storm_earth_and_fire.up
    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains+(debuff.skyreach_exhaustion.up*20),if=combo_strike&chi.max-chi>=2&buff.storm_earth_and_fire.up
    if cast.able.tigerPalm() and combo_strike and chi.max()-chi()>=2 and buff.stormEarthAndFire.exists() then
        if cast.tigerPalm() then ui.debug("Casting Tiger Palm [Bdb Setup]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&!talent.whirling_dragon_punch&!spinning_crane_kick.max
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&!talent.whirling_dragon_punch&!spinning_crane_kick.max
    if cast.able.blackoutKick() and combo_strike and not talent.whirlingDragonPunch and not spinning_crane_kick.max then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Bdb Setup]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&chi>=5&talent.whirling_dragon_punch
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&chi>=5&talent.whirling_dragon_punch
    if cast.able.risingSunKick() and combo_strike and chi()>=5 and talent.whirlingDragonPunch then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Bdb Setup]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&active_enemies>=2&talent.whirling_dragon_punch
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&active_enemies>=2&talent.whirling_dragon_punch
    if cast.able.risingSunKick() and combo_strike and #enemies.yards0>=2 and talent.whirlingDragonPunch then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Bdb Setup]") return true end
    end

end -- End Action List - BdbSetup

-- Action List - CdSef
actionList.CdSef = function()

    -- Invoke Xuen The White Tiger
    -- invoke_xuen_the_white_tiger,if=!variable.hold_xuen&target.time_to_die>25&talent.bonedust_brew&cooldown.bonedust_brew.remains<=5&(active_enemies<3&chi>=3|active_enemies>=3&chi>=2)|fight_remains<25
    if cast.able.invokeXuenTheWhiteTiger() and ((not var.holdXuen and unit.timeToDie(PLACEHOLDER)>25 and talent.bonedustBrew and cd.bonedustBrew.remains()<=5 and (#enemies.yards0<3 and chi()>=3 or #enemies.yards0>=3 and chi()>=2) or unit.ttdGroup(40)<25)) then
        if cast.invokeXuenTheWhiteTiger() then ui.debug("Casting Invoke Xuen The White Tiger [Cd Sef]") return true end
    end

    -- Invoke Xuen The White Tiger
    -- invoke_xuen_the_white_tiger,if=target.time_to_die>25&fight_remains>120&(!trinket.1.is.ashes_of_the_embersoul&!trinket.1.is.witherbarks_branch&!trinket.2.is.ashes_of_the_embersoul&!trinket.2.is.witherbarks_branch|(trinket.1.is.ashes_of_the_embersoul|trinket.1.is.witherbarks_branch)&!trinket.1.cooldown.remains|(trinket.2.is.ashes_of_the_embersoul|trinket.2.is.witherbarks_branch)&!trinket.2.cooldown.remains)
    -- TODO: The following conditions were not converted:
    -- trinket.1.is.ashes_of_the_embersoul
    -- trinket.1.is.witherbarks_branch
    -- trinket.2.is.ashes_of_the_embersoul
    -- trinket.2.is.witherbarks_branch
    -- trinket.1.is.ashes_of_the_embersoul
    -- trinket.1.is.witherbarks_branch
    -- trinket.2.is.ashes_of_the_embersoul
    -- trinket.2.is.witherbarks_branch
    if cast.able.invokeXuenTheWhiteTiger() and ((unit.timeToDie(PLACEHOLDER)>25 and unit.ttdGroup(40)>120 and (not  and not  and not  and not  or ( or ) and not cd.slot.remains(13) or ( or ) and not cd.slot.remains(14)))) then
        if cast.invokeXuenTheWhiteTiger() then ui.debug("Casting Invoke Xuen The White Tiger [Cd Sef]") return true end
    end

    -- Invoke Xuen The White Tiger
    -- invoke_xuen_the_white_tiger,if=fight_remains<60&(debuff.skyreach_exhaustion.remains<2|debuff.skyreach_exhaustion.remains>55)&!cooldown.serenity.remains&active_enemies<3
    if cast.able.invokeXuenTheWhiteTiger() and ((unit.ttdGroup(40)<60 and (debuff.skyreachExhaustion.remains(PLACEHOLDER)<2 or debuff.skyreachExhaustion.remains(PLACEHOLDER)>55) and not cd.serenity.remains() and #enemies.yards0<3)) then
        if cast.invokeXuenTheWhiteTiger() then ui.debug("Casting Invoke Xuen The White Tiger [Cd Sef]") return true end
    end

    -- Storm Earth And Fire
    -- storm_earth_and_fire,if=talent.bonedust_brew&(fight_remains<30&cooldown.bonedust_brew.remains<4&chi>=4|buff.bonedust_brew.up|!spinning_crane_kick.max&active_enemies>=3&cooldown.bonedust_brew.remains<=2&chi>=2)&(pet.xuen_the_white_tiger.active|cooldown.invoke_xuen_the_white_tiger.remains>cooldown.storm_earth_and_fire.full_recharge_time)
    if cast.able.stormEarthAndFire() and ((talent.bonedustBrew and (unit.ttdGroup(40)<30 and cd.bonedustBrew.remains()<4 and chi()>=4 or buff.bonedustBrew.exists() or not spinning_crane_kick.max and #enemies.yards0>=3 and cd.bonedustBrew.remains()<=2 and chi()>=2) and (pet.xuen_the_white_tiger.active or cd.invokeXuenTheWhiteTiger.remains()>charges.stormEarthAndFire.timeTillFull()))) then
        if cast.stormEarthAndFire() then ui.debug("Casting Storm Earth And Fire [Cd Sef]") return true end
    end

    -- Storm Earth And Fire
    -- storm_earth_and_fire,if=!talent.bonedust_brew&(pet.xuen_the_white_tiger.active|target.time_to_die>15&cooldown.storm_earth_and_fire.full_recharge_time<cooldown.invoke_xuen_the_white_tiger.remains)
    if cast.able.stormEarthAndFire() and ((not talent.bonedustBrew and (pet.xuen_the_white_tiger.active or unit.timeToDie(PLACEHOLDER)>15 and charges.stormEarthAndFire.timeTillFull()<cd.invokeXuenTheWhiteTiger.remains()))) then
        if cast.stormEarthAndFire() then ui.debug("Casting Storm Earth And Fire [Cd Sef]") return true end
    end

    -- Bonedust Brew
    -- bonedust_brew,if=(!buff.bonedust_brew.up&buff.storm_earth_and_fire.up&buff.storm_earth_and_fire.remains<11&spinning_crane_kick.max)|(!buff.bonedust_brew.up&fight_remains<30&fight_remains>10&spinning_crane_kick.max&chi>=4)|fight_remains<10|(!debuff.skyreach_exhaustion.up&active_enemies>=4&spinning_crane_kick.modifier>=2)|(pet.xuen_the_white_tiger.active&spinning_crane_kick.max&active_enemies>=4)
    if cast.able.bonedustBrew() and (((not buff.bonedustBrew.exists() and buff.stormEarthAndFire.exists() and buff.stormEarthAndFire.remains()<11 and spinning_crane_kick.max) or (not buff.bonedustBrew.exists() and unit.ttdGroup(40)<30 and unit.ttdGroup(40)>10 and spinning_crane_kick.max and chi()>=4) or unit.ttdGroup(40)<10 or (not debuff.skyreachExhaustion.exists(PLACEHOLDER) and #enemies.yards0>=4 and spinning_crane_kick.modifier>=2) or (pet.xuen_the_white_tiger.active and spinning_crane_kick.max and #enemies.yards0>=4))) then
        if cast.bonedustBrew() then ui.debug("Casting Bonedust Brew [Cd Sef]") return true end
    end

    -- Call Action List - Bdb Setup
    -- call_action_list,name=bdb_setup,if=!buff.bonedust_brew.up&talent.bonedust_brew&cooldown.bonedust_brew.remains<=2&(fight_remains>60&(cooldown.storm_earth_and_fire.charges>0|cooldown.storm_earth_and_fire.remains>10)&(pet.xuen_the_white_tiger.active|cooldown.invoke_xuen_the_white_tiger.remains>10|variable.hold_xuen)|((pet.xuen_the_white_tiger.active|cooldown.invoke_xuen_the_white_tiger.remains>13)&(cooldown.storm_earth_and_fire.charges>0|cooldown.storm_earth_and_fire.remains>13|buff.storm_earth_and_fire.up)))
    if (not buff.bonedustBrew.exists() and talent.bonedustBrew and cd.bonedustBrew.remains()<=2 and (unit.ttdGroup(40)>60 and (charges.stormEarthAndFire.count()>0 or cd.stormEarthAndFire.remains()>10) and (pet.xuen_the_white_tiger.active or cd.invokeXuenTheWhiteTiger.remains()>10 or var.holdXuen) or ((pet.xuen_the_white_tiger.active or cd.invokeXuenTheWhiteTiger.remains()>13) and (charges.stormEarthAndFire.count()>0 or cd.stormEarthAndFire.remains()>13 or buff.stormEarthAndFire.exists())))) then
        if actionList.BdbSetup() then return true end
    end

    -- Storm Earth And Fire
    -- storm_earth_and_fire,if=fight_remains<20|(cooldown.storm_earth_and_fire.charges=2&cooldown.invoke_xuen_the_white_tiger.remains>cooldown.storm_earth_and_fire.full_recharge_time)&cooldown.fists_of_fury.remains<=9&chi>=2&cooldown.whirling_dragon_punch.remains<=12
    if cast.able.stormEarthAndFire() and ((unit.ttdGroup(40)<20 or (charges.stormEarthAndFire.count()==2 and cd.invokeXuenTheWhiteTiger.remains()>charges.stormEarthAndFire.timeTillFull()) and cd.fistsOfFury.remains()<=9 and chi()>=2 and cd.whirlingDragonPunch.remains()<=12)) then
        if cast.stormEarthAndFire() then ui.debug("Casting Storm Earth And Fire [Cd Sef]") return true end
    end

    -- Touch Of Death
    -- touch_of_death,target_if=max:target.health,if=fight_style.dungeonroute&!buff.serenity.up&(combo_strike&target.health<health)|(buff.hidden_masters_forbidden_touch.remains<2)|(buff.hidden_masters_forbidden_touch.remains>target.time_to_die)
    -- Touch Of Death
    -- touch_of_death,target_if=max:target.health,if=fight_style.dungeonroute&!buff.serenity.up&(combo_strike&target.health<health)|(buff.hidden_masters_forbidden_touch.remains<2)|(buff.hidden_masters_forbidden_touch.remains>target.time_to_die)
    if cast.able.touchOfDeath() and ((unit.instance("dungeonroute") and not buff.serenity.exists() and (combo_strike and unit.health(PLACEHOLDER)<health) or (buff.hiddenMastersForbiddenTouch.remains()<2) or (buff.hiddenMastersForbiddenTouch.remains()>unit.timeToDie(PLACEHOLDER)))) then
        if cast.touchOfDeath() then ui.debug("Casting Touch Of Death [Cd Sef]") return true end
    end

    -- Touch Of Death
    -- touch_of_death,cycle_targets=1,if=fight_style.dungeonroute&combo_strike&(target.time_to_die>60|debuff.bonedust_brew_debuff.up|fight_remains<10)
    if cast.able.touchOfDeath() and ((unit.instance("dungeonroute") and combo_strike and (unit.timeToDie(PLACEHOLDER)>60 or debuff.bonedustBrewDebuff.exists(PLACEHOLDER) or unit.ttdGroup(40)<10))) then
        if cast.touchOfDeath() then ui.debug("Casting Touch Of Death [Cd Sef]") return true end
    end

    -- Touch Of Death
    -- touch_of_death,cycle_targets=1,if=!fight_style.dungeonroute&combo_strike
    if cast.able.touchOfDeath() and not unit.instance("dungeonroute") and combo_strike then
        if cast.touchOfDeath() then ui.debug("Casting Touch Of Death [Cd Sef]") return true end
    end

    -- Touch Of Karma
    -- touch_of_karma,target_if=max:target.time_to_die,if=fight_remains>90|pet.xuen_the_white_tiger.active|variable.hold_xuen|fight_remains<16
    -- Touch Of Karma
    -- touch_of_karma,target_if=max:target.time_to_die,if=fight_remains>90|pet.xuen_the_white_tiger.active|variable.hold_xuen|fight_remains<16
    if cast.able.touchOfKarma() and ((unit.ttdGroup(40)>90 or pet.xuen_the_white_tiger.active or var.holdXuen or unit.ttdGroup(40)<16)) then
        if cast.touchOfKarma() then ui.debug("Casting Touch Of Karma [Cd Sef]") return true end
    end

    -- Blood Fury
    -- blood_fury,if=cooldown.invoke_xuen_the_white_tiger.remains>30|variable.hold_xuen|fight_remains<20
    if cast.able.bloodFury() and ((cd.invokeXuenTheWhiteTiger.remains()>30 or var.holdXuen or unit.ttdGroup(40)<20)) then
        if cast.bloodFury() then ui.debug("Casting Blood Fury [Cd Sef]") return true end
    end

    -- Berserking
    -- berserking,if=cooldown.invoke_xuen_the_white_tiger.remains>30|variable.hold_xuen|fight_remains<15
    if cast.able.berserking() and ((cd.invokeXuenTheWhiteTiger.remains()>30 or var.holdXuen or unit.ttdGroup(40)<15)) then
        if cast.berserking() then ui.debug("Casting Berserking [Cd Sef]") return true end
    end

    -- Lights Judgment
    -- lights_judgment
    if cast.able.lightsJudgment() then
        if cast.lightsJudgment() then ui.debug("Casting Lights Judgment [Cd Sef]") return true end
    end

    -- Fireblood
    -- fireblood,if=cooldown.invoke_xuen_the_white_tiger.remains>30|variable.hold_xuen|fight_remains<10
    if cast.able.fireblood() and ((cd.invokeXuenTheWhiteTiger.remains()>30 or var.holdXuen or unit.ttdGroup(40)<10)) then
        if cast.fireblood() then ui.debug("Casting Fireblood [Cd Sef]") return true end
    end

    -- Ancestral Call
    -- ancestral_call,if=cooldown.invoke_xuen_the_white_tiger.remains>30|variable.hold_xuen|fight_remains<20
    if cast.able.ancestralCall() and ((cd.invokeXuenTheWhiteTiger.remains()>30 or var.holdXuen or unit.ttdGroup(40)<20)) then
        if cast.ancestralCall() then ui.debug("Casting Ancestral Call [Cd Sef]") return true end
    end

    -- Bag Of Tricks
    -- bag_of_tricks,if=buff.storm_earth_and_fire.down
    if cast.able.bagOfTricks() and not buff.stormEarthAndFire.exists() then
        if cast.bagOfTricks() then ui.debug("Casting Bag Of Tricks [Cd Sef]") return true end
    end

end -- End Action List - CdSef

-- Action List - CdSerenity
actionList.CdSerenity = function()

    -- Invoke Xuen The White Tiger
    -- invoke_xuen_the_white_tiger,if=target.time_to_die>16&!variable.hold_xuen&talent.bonedust_brew&cooldown.bonedust_brew.remains<=1|buff.bloodlust.up|fight_remains<25
    if cast.able.invokeXuenTheWhiteTiger() and ((unit.timeToDie(PLACEHOLDER)>16 and not var.holdXuen and talent.bonedustBrew and cd.bonedustBrew.remains()<=1 or buff.bloodlust.exists() or unit.ttdGroup(40)<25)) then
        if cast.invokeXuenTheWhiteTiger() then ui.debug("Casting Invoke Xuen The White Tiger [Cd Serenity]") return true end
    end

    -- Invoke Xuen The White Tiger
    -- invoke_xuen_the_white_tiger,if=(target.time_to_die>16|(fight_style.dungeonslice|fight_style.dungeonroute)&cooldown.serenity.remains<2)&fight_remains>120&(!trinket.1.is.ashes_of_the_embersoul&!trinket.1.is.witherbarks_branch&!trinket.2.is.ashes_of_the_embersoul&!trinket.2.is.witherbarks_branch|(trinket.1.is.ashes_of_the_embersoul|trinket.1.is.witherbarks_branch)&!trinket.1.cooldown.remains|(trinket.2.is.ashes_of_the_embersoul|trinket.2.is.witherbarks_branch)&!trinket.2.cooldown.remains)
    -- TODO: The following conditions were not converted:
    -- trinket.1.is.ashes_of_the_embersoul
    -- trinket.1.is.witherbarks_branch
    -- trinket.2.is.ashes_of_the_embersoul
    -- trinket.2.is.witherbarks_branch
    -- trinket.1.is.ashes_of_the_embersoul
    -- trinket.1.is.witherbarks_branch
    -- trinket.2.is.ashes_of_the_embersoul
    -- trinket.2.is.witherbarks_branch
    if cast.able.invokeXuenTheWhiteTiger() and (((unit.timeToDie(PLACEHOLDER)>16 or (unit.instance("party") or unit.instance("dungeonroute")) and cd.serenity.remains()<2) and unit.ttdGroup(40)>120 and (not  and not  and not  and not  or ( or ) and not cd.slot.remains(13) or ( or ) and not cd.slot.remains(14)))) then
        if cast.invokeXuenTheWhiteTiger() then ui.debug("Casting Invoke Xuen The White Tiger [Cd Serenity]") return true end
    end

    -- Invoke Xuen The White Tiger
    -- invoke_xuen_the_white_tiger,if=target.time_to_die>16&fight_remains<60&(debuff.skyreach_exhaustion.remains<2|debuff.skyreach_exhaustion.remains>55)&!cooldown.serenity.remains&active_enemies<3
    if cast.able.invokeXuenTheWhiteTiger() and ((unit.timeToDie(PLACEHOLDER)>16 and unit.ttdGroup(40)<60 and (debuff.skyreachExhaustion.remains(PLACEHOLDER)<2 or debuff.skyreachExhaustion.remains(PLACEHOLDER)>55) and not cd.serenity.remains() and #enemies.yards0<3)) then
        if cast.invokeXuenTheWhiteTiger() then ui.debug("Casting Invoke Xuen The White Tiger [Cd Serenity]") return true end
    end

    -- Invoke Xuen The White Tiger
    -- invoke_xuen_the_white_tiger,if=fight_style.dungeonslice&talent.bonedust_brew&target.time_to_die>16&!cooldown.serenity.remains&cooldown.bonedust_brew.remains<2
    if cast.able.invokeXuenTheWhiteTiger() and unit.instance("party") and talent.bonedustBrew and unit.timeToDie(PLACEHOLDER)>16 and not cd.serenity.remains() and cd.bonedustBrew.remains()<2 then
        if cast.invokeXuenTheWhiteTiger() then ui.debug("Casting Invoke Xuen The White Tiger [Cd Serenity]") return true end
    end

    -- Bonedust Brew
    -- bonedust_brew,if=buff.invokers_delight.up|!buff.bonedust_brew.up&cooldown.xuen_the_white_tiger.remains&!pet.xuen_the_white_tiger.active|cooldown.serenity.remains>15|fight_remains<30&fight_remains>10|fight_remains<10
    if cast.able.bonedustBrew() and ((buff.invokersDelight.exists() or not buff.bonedustBrew.exists() and cd.xuenTheWhiteTiger.remains() and not pet.xuen_the_white_tiger.active or cd.serenity.remains()>15 or unit.ttdGroup(40)<30 and unit.ttdGroup(40)>10 or unit.ttdGroup(40)<10)) then
        if cast.bonedustBrew() then ui.debug("Casting Bonedust Brew [Cd Serenity]") return true end
    end

    -- Serenity
    -- serenity,if=variable.sync_serenity&(buff.invokers_delight.up|variable.hold_xuen&(talent.drinking_horn_cover&fight_remains>110|!talent.drinking_horn_cover&fight_remains>105))|!talent.invoke_xuen_the_white_tiger|fight_remains<15
    if cast.able.serenity() and ((var.syncSerenity and (buff.invokersDelight.exists() or var.holdXuen and (talent.drinkingHornCover and unit.ttdGroup(40)>110 or not talent.drinkingHornCover and unit.ttdGroup(40)>105)) or not talent.invokeXuenTheWhiteTiger or unit.ttdGroup(40)<15)) then
        if cast.serenity() then ui.debug("Casting Serenity [Cd Serenity]") return true end
    end

    -- Serenity
    -- serenity,if=!variable.sync_serenity&(buff.invokers_delight.up|cooldown.invoke_xuen_the_white_tiger.remains>fight_remains|fight_remains>(cooldown.invoke_xuen_the_white_tiger.remains+10)&fight_remains>90)
    if cast.able.serenity() and ((not var.syncSerenity and (buff.invokersDelight.exists() or cd.invokeXuenTheWhiteTiger.remains()>unit.ttdGroup(40) or unit.ttdGroup(40)>(cd.invokeXuenTheWhiteTiger.remains()+10) and unit.ttdGroup(40)>90))) then
        if cast.serenity() then ui.debug("Casting Serenity [Cd Serenity]") return true end
    end

    -- Touch Of Death
    -- touch_of_death,target_if=max:target.health,if=fight_style.dungeonroute&!buff.serenity.up&(combo_strike&target.health<health)|(buff.hidden_masters_forbidden_touch.remains<2)|(buff.hidden_masters_forbidden_touch.remains>target.time_to_die)
    -- Touch Of Death
    -- touch_of_death,target_if=max:target.health,if=fight_style.dungeonroute&!buff.serenity.up&(combo_strike&target.health<health)|(buff.hidden_masters_forbidden_touch.remains<2)|(buff.hidden_masters_forbidden_touch.remains>target.time_to_die)
    if cast.able.touchOfDeath() and ((unit.instance("dungeonroute") and not buff.serenity.exists() and (combo_strike and unit.health(PLACEHOLDER)<health) or (buff.hiddenMastersForbiddenTouch.remains()<2) or (buff.hiddenMastersForbiddenTouch.remains()>unit.timeToDie(PLACEHOLDER)))) then
        if cast.touchOfDeath() then ui.debug("Casting Touch Of Death [Cd Serenity]") return true end
    end

    -- Touch Of Death
    -- touch_of_death,cycle_targets=1,if=fight_style.dungeonroute&combo_strike&(target.time_to_die>60|debuff.bonedust_brew_debuff.up|fight_remains<10)&!buff.serenity.up
    if cast.able.touchOfDeath() and ((unit.instance("dungeonroute") and combo_strike and (unit.timeToDie(PLACEHOLDER)>60 or debuff.bonedustBrewDebuff.exists(PLACEHOLDER) or unit.ttdGroup(40)<10) and not buff.serenity.exists())) then
        if cast.touchOfDeath() then ui.debug("Casting Touch Of Death [Cd Serenity]") return true end
    end

    -- Touch Of Death
    -- touch_of_death,cycle_targets=1,if=!fight_style.dungeonroute&combo_strike&!buff.serenity.up
    if cast.able.touchOfDeath() and not unit.instance("dungeonroute") and combo_strike and not buff.serenity.exists() then
        if cast.touchOfDeath() then ui.debug("Casting Touch Of Death [Cd Serenity]") return true end
    end

    -- Touch Of Karma
    -- touch_of_karma,if=fight_remains>90|fight_remains<10
    if cast.able.touchOfKarma() and ((unit.ttdGroup(40)>90 or unit.ttdGroup(40)<10)) then
        if cast.touchOfKarma() then ui.debug("Casting Touch Of Karma [Cd Serenity]") return true end
    end

    -- Blood Fury
    -- blood_fury,if=buff.serenity.up|fight_remains<20
    if cast.able.bloodFury() and ((buff.serenity.exists() or unit.ttdGroup(40)<20)) then
        if cast.bloodFury() then ui.debug("Casting Blood Fury [Cd Serenity]") return true end
    end

    -- Berserking
    -- berserking,if=!buff.serenity.up|fight_remains<20
    if cast.able.berserking() and ((not buff.serenity.exists() or unit.ttdGroup(40)<20)) then
        if cast.berserking() then ui.debug("Casting Berserking [Cd Serenity]") return true end
    end

    -- Lights Judgment
    -- lights_judgment
    if cast.able.lightsJudgment() then
        if cast.lightsJudgment() then ui.debug("Casting Lights Judgment [Cd Serenity]") return true end
    end

    -- Fireblood
    -- fireblood,if=buff.serenity.up|fight_remains<20
    if cast.able.fireblood() and ((buff.serenity.exists() or unit.ttdGroup(40)<20)) then
        if cast.fireblood() then ui.debug("Casting Fireblood [Cd Serenity]") return true end
    end

    -- Ancestral Call
    -- ancestral_call,if=buff.serenity.up|fight_remains<20
    if cast.able.ancestralCall() and ((buff.serenity.exists() or unit.ttdGroup(40)<20)) then
        if cast.ancestralCall() then ui.debug("Casting Ancestral Call [Cd Serenity]") return true end
    end

    -- Bag Of Tricks
    -- bag_of_tricks,if=buff.serenity.up|fight_remains<20
    if cast.able.bagOfTricks() and ((buff.serenity.exists() or unit.ttdGroup(40)<20)) then
        if cast.bagOfTricks() then ui.debug("Casting Bag Of Tricks [Cd Serenity]") return true end
    end

end -- End Action List - CdSerenity

-- Action List - Default2T
actionList.Default2T = function()
    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains+(debuff.skyreach_exhaustion.up*20),if=combo_strike&chi<2&(cooldown.rising_sun_kick.remains<1|cooldown.fists_of_fury.remains<1|cooldown.strike_of_the_windlord.remains<1)&buff.teachings_of_the_monastery.stack<3
    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains+(debuff.skyreach_exhaustion.up*20),if=combo_strike&chi<2&(cooldown.rising_sun_kick.remains<1|cooldown.fists_of_fury.remains<1|cooldown.strike_of_the_windlord.remains<1)&buff.teachings_of_the_monastery.stack<3
    if cast.able.tigerPalm() and ((combo_strike and chi()<2 and (cd.risingSunKick.remains()<1 or cd.fistsOfFury.remains()<1 or cd.strikeOfTheWindlord.remains()<1) and buff.teachingsOfTheMonastery.stack()<3)) then
        if cast.tigerPalm() then ui.debug("Casting Tiger Palm [Default 2T]") return true end
    end

    -- Expel Harm
    -- expel_harm,if=chi=1&(!cooldown.rising_sun_kick.remains|!cooldown.strike_of_the_windlord.remains)|chi=2&!cooldown.fists_of_fury.remains
    if cast.able.expelHarm() and ((chi()==1 and (not cd.risingSunKick.remains() or not cd.strikeOfTheWindlord.remains()) or chi()==2 and not cd.fistsOfFury.remains())) then
        if cast.expelHarm() then ui.debug("Casting Expel Harm [Default 2T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.teachings_of_the_monastery.stack=3&talent.shadowboxing_treads
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.teachings_of_the_monastery.stack=3&talent.shadowboxing_treads
    if cast.able.blackoutKick() and buff.teachingsOfTheMonastery.stack()==3 and talent.shadowboxingTreads then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default 2T]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist&set_bonus.tier31_4pc
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist&set_bonus.tier31_4pc
    if cast.able.strikeOfTheWindlord() and talent.thunderfist and equiped.tier(31)>=4 then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Default 2T]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist&(cooldown.invoke_xuen_the_white_tiger.remains>20|fight_remains<5)
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist&(cooldown.invoke_xuen_the_white_tiger.remains>20|fight_remains<5)
    if cast.able.strikeOfTheWindlord() and ((talent.thunderfist and (cd.invokeXuenTheWhiteTiger.remains()>20 or unit.ttdGroup(40)<5))) then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Default 2T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up&set_bonus.tier31_2pc
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up&set_bonus.tier31_2pc
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() and not buff.blackoutReinforcement.exists() and equiped.tier(31)>=2 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Default 2T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=talent.shadowboxing_treads&combo_strike&buff.blackout_reinforcement.up
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=talent.shadowboxing_treads&combo_strike&buff.blackout_reinforcement.up
    if cast.able.blackoutKick() and talent.shadowboxingTreads and combo_strike and buff.blackoutReinforcement.exists() then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default 2T]") return true end
    end

    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=!set_bonus.tier30_2pc
    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=!set_bonus.tier30_2pc
    if cast.able.fistsOfFury() and not equiped.tier(30)>=2 then
        if cast.fistsOfFury() then ui.debug("Casting Fists Of Fury [Default 2T]") return true end
    end

    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains
    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains
    if cast.able.fistsOfFury() then
        if cast.fistsOfFury() then ui.debug("Casting Fists Of Fury [Default 2T]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,if=!cooldown.fists_of_fury.remains
    if cast.able.risingSunKick() and not cd.fistsOfFury.remains() then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Default 2T]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier30_2pc
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier30_2pc
    if cast.able.risingSunKick() and equiped.tier(30)>=2 then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Default 2T]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.kicks_of_flowing_momentum.up|buff.pressure_point.up|debuff.skyreach_exhaustion.remains>55
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.kicks_of_flowing_momentum.up|buff.pressure_point.up|debuff.skyreach_exhaustion.remains>55
    if cast.able.risingSunKick() and ((buff.kicksOfFlowingMomentum.exists() or buff.pressurePoint.exists() or debuff.skyreachExhaustion.remains(PLACEHOLDER)>55)) then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Default 2T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() and not buff.blackoutReinforcement.exists() then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Default 2T]") return true end
    end

    -- Chi Burst
    -- chi_burst,if=buff.bloodlust.up&chi<5
    if cast.able.chiBurst() and buff.bloodlust.exists() and chi()<5 then
        if cast.chiBurst() then ui.debug("Casting Chi Burst [Default 2T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.teachings_of_the_monastery.stack=2
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.teachings_of_the_monastery.stack=2
    if cast.able.blackoutKick() and buff.teachingsOfTheMonastery.stack()==2 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default 2T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.pressure_point.remains&chi>2&prev.rising_sun_kick
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.pressure_point.remains&chi>2&prev.rising_sun_kick
    if cast.able.blackoutKick() and buff.pressurePoint.remains() and chi()>2 and prev.rising_sun_kick then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default 2T]") return true end
    end

    -- Chi Burst
    -- chi_burst,if=chi<5&energy<50
    if cast.able.chiBurst() and chi()<5 and energy()<50 then
        if cast.chiBurst() then ui.debug("Casting Chi Burst [Default 2T]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains
    if cast.able.strikeOfTheWindlord() then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Default 2T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.teachings_of_the_monastery.up&(talent.shadowboxing_treads|cooldown.rising_sun_kick.remains>1)
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.teachings_of_the_monastery.up&(talent.shadowboxing_treads|cooldown.rising_sun_kick.remains>1)
    if cast.able.blackoutKick() and ((buff.teachingsOfTheMonastery.exists() and (talent.shadowboxingTreads or cd.risingSunKick.remains()>1))) then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default 2T]") return true end
    end

    -- Whirling Dragon Punch
    -- whirling_dragon_punch
    if cast.able.whirlingDragonPunch() then
        if cast.whirlingDragonPunch() then ui.debug("Casting Whirling Dragon Punch [Default 2T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.teachings_of_the_monastery.stack=3
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.teachings_of_the_monastery.stack=3
    if cast.able.blackoutKick() and buff.teachingsOfTheMonastery.stack()==3 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default 2T]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=!talent.shadowboxing_treads&cooldown.fists_of_fury.remains>4&talent.xuens_battlegear
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=!talent.shadowboxing_treads&cooldown.fists_of_fury.remains>4&talent.xuens_battlegear
    if cast.able.risingSunKick() and not talent.shadowboxingTreads and cd.fistsOfFury.remains()>4 and talent.xuensBattlegear then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Default 2T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&cooldown.rising_sun_kick.remains&cooldown.fists_of_fury.remains&(!buff.bonedust_brew.up|spinning_crane_kick.modifier<1.5)
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&cooldown.rising_sun_kick.remains&cooldown.fists_of_fury.remains&(!buff.bonedust_brew.up|spinning_crane_kick.modifier<1.5)
    if cast.able.blackoutKick() and ((combo_strike and cd.risingSunKick.remains() and cd.fistsOfFury.remains() and (not buff.bonedustBrew.exists() or spinning_crane_kick.modifier<1.5))) then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default 2T]") return true end
    end

    -- Rushing Jade Wind
    -- rushing_jade_wind,if=!buff.rushing_jade_wind.up
    if cast.able.rushingJadeWind() and not buff.rushingJadeWind.exists() then
        if cast.rushingJadeWind() then ui.debug("Casting Rushing Jade Wind [Default 2T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&buff.bonedust_brew.up&combo_strike&spinning_crane_kick.modifier>=2.7
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&buff.bonedust_brew.up&combo_strike&spinning_crane_kick.modifier>=2.7
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and buff.bonedustBrew.exists() and combo_strike and spinning_crane_kick.modifier>=2.7 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Default 2T]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains
    if cast.able.risingSunKick() then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Default 2T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike
    if cast.able.blackoutKick() and combo_strike then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default 2T]") return true end
    end

    -- Jadefire Stomp
    -- jadefire_stomp,if=combo_strike
    if cast.able.jadefireStomp() and combo_strike then
        if cast.jadefireStomp() then ui.debug("Casting Jadefire Stomp [Default 2T]") return true end
    end

end -- End Action List - Default2T

-- Action List - Default3T
actionList.Default3T = function()
    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains+(debuff.skyreach_exhaustion.up*20),if=combo_strike&chi<2&(cooldown.rising_sun_kick.remains<1|cooldown.fists_of_fury.remains<1|cooldown.strike_of_the_windlord.remains<1)&buff.teachings_of_the_monastery.stack<3
    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains+(debuff.skyreach_exhaustion.up*20),if=combo_strike&chi<2&(cooldown.rising_sun_kick.remains<1|cooldown.fists_of_fury.remains<1|cooldown.strike_of_the_windlord.remains<1)&buff.teachings_of_the_monastery.stack<3
    if cast.able.tigerPalm() and ((combo_strike and chi()<2 and (cd.risingSunKick.remains()<1 or cd.fistsOfFury.remains()<1 or cd.strikeOfTheWindlord.remains()<1) and buff.teachingsOfTheMonastery.stack()<3)) then
        if cast.tigerPalm() then ui.debug("Casting Tiger Palm [Default 3T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() and not buff.blackoutReinforcement.exists() then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Default 3T]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist&set_bonus.tier31_4pc
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist&set_bonus.tier31_4pc
    if cast.able.strikeOfTheWindlord() and talent.thunderfist and equiped.tier(31)>=4 then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Default 3T]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist&(cooldown.invoke_xuen_the_white_tiger.remains>20|fight_remains<5)
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist&(cooldown.invoke_xuen_the_white_tiger.remains>20|fight_remains<5)
    if cast.able.strikeOfTheWindlord() and ((talent.thunderfist and (cd.invokeXuenTheWhiteTiger.remains()>20 or unit.ttdGroup(40)<5))) then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Default 3T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.teachings_of_the_monastery.stack=3&talent.shadowboxing_treads
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.teachings_of_the_monastery.stack=3&talent.shadowboxing_treads
    if cast.able.blackoutKick() and buff.teachingsOfTheMonastery.stack()==3 and talent.shadowboxingTreads then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default 3T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=talent.shadowboxing_treads&combo_strike&buff.blackout_reinforcement.up
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=talent.shadowboxing_treads&combo_strike&buff.blackout_reinforcement.up
    if cast.able.blackoutKick() and talent.shadowboxingTreads and combo_strike and buff.blackoutReinforcement.exists() then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default 3T]") return true end
    end

    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains
    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains
    if cast.able.fistsOfFury() then
        if cast.fistsOfFury() then ui.debug("Casting Fists Of Fury [Default 3T]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.bonedust_brew.up&buff.pressure_point.up&set_bonus.tier30_2pc
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.bonedust_brew.up&buff.pressure_point.up&set_bonus.tier30_2pc
    if cast.able.risingSunKick() and buff.bonedustBrew.exists() and buff.pressurePoint.exists() and equiped.tier(30)>=2 then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Default 3T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&buff.bonedust_brew.up&combo_strike
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&buff.bonedust_brew.up&combo_strike
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and buff.bonedustBrew.exists() and combo_strike then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Default 3T]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=!buff.bonedust_brew.up&buff.pressure_point.up
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=!buff.bonedust_brew.up&buff.pressure_point.up
    if cast.able.risingSunKick() and not buff.bonedustBrew.exists() and buff.pressurePoint.exists() then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Default 3T]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier30_2pc
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier30_2pc
    if cast.able.risingSunKick() and equiped.tier(30)>=2 then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Default 3T]") return true end
    end

    -- Expel Harm
    -- expel_harm,if=chi=1&(!cooldown.rising_sun_kick.remains|!cooldown.strike_of_the_windlord.remains)|chi=2&!cooldown.fists_of_fury.remains
    if cast.able.expelHarm() and ((chi()==1 and (not cd.risingSunKick.remains() or not cd.strikeOfTheWindlord.remains()) or chi()==2 and not cd.fistsOfFury.remains())) then
        if cast.expelHarm() then ui.debug("Casting Expel Harm [Default 3T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.teachings_of_the_monastery.stack=2
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.teachings_of_the_monastery.stack=2
    if cast.able.blackoutKick() and buff.teachingsOfTheMonastery.stack()==2 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default 3T]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains
    if cast.able.strikeOfTheWindlord() then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Default 3T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.teachings_of_the_monastery.up&(talent.shadowboxing_treads|cooldown.rising_sun_kick.remains>1)
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.teachings_of_the_monastery.up&(talent.shadowboxing_treads|cooldown.rising_sun_kick.remains>1)
    if cast.able.blackoutKick() and ((buff.teachingsOfTheMonastery.exists() and (talent.shadowboxingTreads or cd.risingSunKick.remains()>1))) then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default 3T]") return true end
    end

    -- Whirling Dragon Punch
    -- whirling_dragon_punch
    if cast.able.whirlingDragonPunch() then
        if cast.whirlingDragonPunch() then ui.debug("Casting Whirling Dragon Punch [Default 3T]") return true end
    end

    -- Chi Burst
    -- chi_burst,if=buff.bloodlust.up&chi<5
    if cast.able.chiBurst() and buff.bloodlust.exists() and chi()<5 then
        if cast.chiBurst() then ui.debug("Casting Chi Burst [Default 3T]") return true end
    end

    -- Chi Burst
    -- chi_burst,if=chi<5&energy<50
    if cast.able.chiBurst() and chi()<5 and energy()<50 then
        if cast.chiBurst() then ui.debug("Casting Chi Burst [Default 3T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.teachings_of_the_monastery.stack=3
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.teachings_of_the_monastery.stack=3
    if cast.able.blackoutKick() and buff.teachingsOfTheMonastery.stack()==3 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default 3T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&cooldown.fists_of_fury.remains<3&buff.chi_energy.stack>15
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&cooldown.fists_of_fury.remains<3&buff.chi_energy.stack>15
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and cd.fistsOfFury.remains()<3 and buff.chiEnergy.stack()>15 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Default 3T]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=cooldown.fists_of_fury.remains>4&chi>3
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=cooldown.fists_of_fury.remains>4&chi>3
    if cast.able.risingSunKick() and cd.fistsOfFury.remains()>4 and chi()>3 then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Default 3T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&cooldown.rising_sun_kick.remains&cooldown.fists_of_fury.remains&chi>4&((talent.storm_earth_and_fire&!talent.bonedust_brew)|(talent.serenity))
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&cooldown.rising_sun_kick.remains&cooldown.fists_of_fury.remains&chi>4&((talent.storm_earth_and_fire&!talent.bonedust_brew)|(talent.serenity))
    if cast.able.spinningCraneKick() and ((unit.timeToDie(PLACEHOLDER)>duration and combo_strike and cd.risingSunKick.remains() and cd.fistsOfFury.remains() and chi()>4 and ((talent.stormEarthAndFire and not talent.bonedustBrew) or (talent.serenity)))) then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Default 3T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&cooldown.fists_of_fury.remains
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&cooldown.fists_of_fury.remains
    if cast.able.blackoutKick() and combo_strike and cd.fistsOfFury.remains() then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default 3T]") return true end
    end

    -- Rushing Jade Wind
    -- rushing_jade_wind,if=!buff.rushing_jade_wind.up
    if cast.able.rushingJadeWind() and not buff.rushingJadeWind.exists() then
        if cast.rushingJadeWind() then ui.debug("Casting Rushing Jade Wind [Default 3T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&talent.shadowboxing_treads&!spinning_crane_kick.max
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&talent.shadowboxing_treads&!spinning_crane_kick.max
    if cast.able.blackoutKick() and combo_strike and talent.shadowboxingTreads and not spinning_crane_kick.max then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default 3T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&(combo_strike&chi>5&talent.storm_earth_and_fire|combo_strike&chi>4&talent.serenity)
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&(combo_strike&chi>5&talent.storm_earth_and_fire|combo_strike&chi>4&talent.serenity)
    if cast.able.spinningCraneKick() and ((unit.timeToDie(PLACEHOLDER)>duration and (combo_strike and chi()>5 and talent.stormEarthAndFire or combo_strike and chi()>4 and talent.serenity))) then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Default 3T]") return true end
    end

end -- End Action List - Default3T

-- Action List - Default4T
actionList.Default4T = function()
    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains+(debuff.skyreach_exhaustion.up*20),if=combo_strike&chi<2&(cooldown.fists_of_fury.remains<1|cooldown.strike_of_the_windlord.remains<1)&buff.teachings_of_the_monastery.stack<3
    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains+(debuff.skyreach_exhaustion.up*20),if=combo_strike&chi<2&(cooldown.fists_of_fury.remains<1|cooldown.strike_of_the_windlord.remains<1)&buff.teachings_of_the_monastery.stack<3
    if cast.able.tigerPalm() and ((combo_strike and chi()<2 and (cd.fistsOfFury.remains()<1 or cd.strikeOfTheWindlord.remains()<1) and buff.teachingsOfTheMonastery.stack()<3)) then
        if cast.tigerPalm() then ui.debug("Casting Tiger Palm [Default 4T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&spinning_crane_kick.max&!buff.blackout_reinforcement.up
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&spinning_crane_kick.max&!buff.blackout_reinforcement.up
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() and spinning_crane_kick.max and not buff.blackoutReinforcement.exists() then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Default 4T]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist
    if cast.able.strikeOfTheWindlord() and talent.thunderfist then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Default 4T]") return true end
    end

    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains
    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains
    if cast.able.fistsOfFury() then
        if cast.fistsOfFury() then ui.debug("Casting Fists Of Fury [Default 4T]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.bonedust_brew.up&buff.pressure_point.up&set_bonus.tier30_2pc
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.bonedust_brew.up&buff.pressure_point.up&set_bonus.tier30_2pc
    if cast.able.risingSunKick() and buff.bonedustBrew.exists() and buff.pressurePoint.exists() and equiped.tier(30)>=2 then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Default 4T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=talent.shadowboxing_treads&combo_strike&buff.blackout_reinforcement.up
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=talent.shadowboxing_treads&combo_strike&buff.blackout_reinforcement.up
    if cast.able.blackoutKick() and talent.shadowboxingTreads and combo_strike and buff.blackoutReinforcement.exists() then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default 4T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&buff.bonedust_brew.up&combo_strike&spinning_crane_kick.max
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&buff.bonedust_brew.up&combo_strike&spinning_crane_kick.max
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and buff.bonedustBrew.exists() and combo_strike and spinning_crane_kick.max then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Default 4T]") return true end
    end

    -- Whirling Dragon Punch
    -- whirling_dragon_punch
    if cast.able.whirlingDragonPunch() then
        if cast.whirlingDragonPunch() then ui.debug("Casting Whirling Dragon Punch [Default 4T]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=!buff.bonedust_brew.up&buff.pressure_point.up&cooldown.fists_of_fury.remains>5
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=!buff.bonedust_brew.up&buff.pressure_point.up&cooldown.fists_of_fury.remains>5
    if cast.able.risingSunKick() and not buff.bonedustBrew.exists() and buff.pressurePoint.exists() and cd.fistsOfFury.remains()>5 then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Default 4T]") return true end
    end

    -- Rushing Jade Wind
    -- rushing_jade_wind,if=!buff.rushing_jade_wind.up
    if cast.able.rushingJadeWind() and not buff.rushingJadeWind.exists() then
        if cast.rushingJadeWind() then ui.debug("Casting Rushing Jade Wind [Default 4T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.teachings_of_the_monastery.stack=3&talent.shadowboxing_treads
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.teachings_of_the_monastery.stack=3&talent.shadowboxing_treads
    if cast.able.blackoutKick() and buff.teachingsOfTheMonastery.stack()==3 and talent.shadowboxingTreads then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default 4T]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier30_2pc
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier30_2pc
    if cast.able.risingSunKick() and equiped.tier(30)>=2 then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Default 4T]") return true end
    end

    -- Expel Harm
    -- expel_harm,if=chi=1&(!cooldown.rising_sun_kick.remains|!cooldown.strike_of_the_windlord.remains)|chi=2&!cooldown.fists_of_fury.remains
    if cast.able.expelHarm() and ((chi()==1 and (not cd.risingSunKick.remains() or not cd.strikeOfTheWindlord.remains()) or chi()==2 and not cd.fistsOfFury.remains())) then
        if cast.expelHarm() then ui.debug("Casting Expel Harm [Default 4T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&cooldown.fists_of_fury.remains>3&buff.chi_energy.stack>10
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&cooldown.fists_of_fury.remains>3&buff.chi_energy.stack>10
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and cd.fistsOfFury.remains()>3 and buff.chiEnergy.stack()>10 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Default 4T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&set_bonus.tier30_2pc
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&set_bonus.tier30_2pc
    if cast.able.blackoutKick() and combo_strike and equiped.tier(30)>=2 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default 4T]") return true end
    end

    -- Chi Burst
    -- chi_burst,if=buff.bloodlust.up&chi<5
    if cast.able.chiBurst() and buff.bloodlust.exists() and chi()<5 then
        if cast.chiBurst() then ui.debug("Casting Chi Burst [Default 4T]") return true end
    end

    -- Chi Burst
    -- chi_burst,if=chi<5&energy<50
    if cast.able.chiBurst() and chi()<5 and energy()<50 then
        if cast.chiBurst() then ui.debug("Casting Chi Burst [Default 4T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&(cooldown.fists_of_fury.remains>3|chi>4)&spinning_crane_kick.max
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&(cooldown.fists_of_fury.remains>3|chi>4)&spinning_crane_kick.max
    if cast.able.spinningCraneKick() and ((unit.timeToDie(PLACEHOLDER)>duration and combo_strike and (cd.fistsOfFury.remains()>3 or chi()>4) and spinning_crane_kick.max)) then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Default 4T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.teachings_of_the_monastery.stack=3
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.teachings_of_the_monastery.stack=3
    if cast.able.blackoutKick() and buff.teachingsOfTheMonastery.stack()==3 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default 4T]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains
    if cast.able.strikeOfTheWindlord() then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Default 4T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&(cooldown.fists_of_fury.remains>3|chi>4)
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&(cooldown.fists_of_fury.remains>3|chi>4)
    if cast.able.spinningCraneKick() and ((unit.timeToDie(PLACEHOLDER)>duration and combo_strike and (cd.fistsOfFury.remains()>3 or chi()>4))) then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Default 4T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike
    if cast.able.blackoutKick() and combo_strike then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default 4T]") return true end
    end

end -- End Action List - Default4T

-- Action List - DefaultAoe
actionList.DefaultAoe = function()
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&spinning_crane_kick.max&!buff.blackout_reinforcement.up
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&spinning_crane_kick.max&!buff.blackout_reinforcement.up
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() and spinning_crane_kick.max and not buff.blackoutReinforcement.exists() then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Default Aoe]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&!talent.hit_combo&spinning_crane_kick.max&buff.bonedust_brew.up
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&!talent.hit_combo&spinning_crane_kick.max&buff.bonedust_brew.up
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and not talent.hitCombo and spinning_crane_kick.max and buff.bonedustBrew.exists() then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Default Aoe]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist
    if cast.able.strikeOfTheWindlord() and talent.thunderfist then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Default Aoe]") return true end
    end

    -- Whirling Dragon Punch
    -- whirling_dragon_punch,if=active_enemies>8
    if cast.able.whirlingDragonPunch() and #enemies.yards0>8 then
        if cast.whirlingDragonPunch() then ui.debug("Casting Whirling Dragon Punch [Default Aoe]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&buff.bonedust_brew.up&combo_strike&spinning_crane_kick.max
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&buff.bonedust_brew.up&combo_strike&spinning_crane_kick.max
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and buff.bonedustBrew.exists() and combo_strike and spinning_crane_kick.max then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Default Aoe]") return true end
    end

    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains
    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains
    if cast.able.fistsOfFury() then
        if cast.fistsOfFury() then ui.debug("Casting Fists Of Fury [Default Aoe]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.bonedust_brew.up&buff.pressure_point.up&set_bonus.tier30_2pc
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.bonedust_brew.up&buff.pressure_point.up&set_bonus.tier30_2pc
    if cast.able.risingSunKick() and buff.bonedustBrew.exists() and buff.pressurePoint.exists() and equiped.tier(30)>=2 then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Default Aoe]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.teachings_of_the_monastery.stack=3&talent.shadowboxing_treads
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.teachings_of_the_monastery.stack=3&talent.shadowboxing_treads
    if cast.able.blackoutKick() and buff.teachingsOfTheMonastery.stack()==3 and talent.shadowboxingTreads then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default Aoe]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=talent.shadowboxing_treads&combo_strike&buff.blackout_reinforcement.up
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=talent.shadowboxing_treads&combo_strike&buff.blackout_reinforcement.up
    if cast.able.blackoutKick() and talent.shadowboxingTreads and combo_strike and buff.blackoutReinforcement.exists() then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default Aoe]") return true end
    end

    -- Whirling Dragon Punch
    -- whirling_dragon_punch,if=active_enemies>=5
    if cast.able.whirlingDragonPunch() and #enemies.yards0>=5 then
        if cast.whirlingDragonPunch() then ui.debug("Casting Whirling Dragon Punch [Default Aoe]") return true end
    end

    -- Rushing Jade Wind
    -- rushing_jade_wind,if=!buff.rushing_jade_wind.up
    if cast.able.rushingJadeWind() and not buff.rushingJadeWind.exists() then
        if cast.rushingJadeWind() then ui.debug("Casting Rushing Jade Wind [Default Aoe]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.pressure_point.up&set_bonus.tier30_2pc
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.pressure_point.up&set_bonus.tier30_2pc
    if cast.able.risingSunKick() and buff.pressurePoint.exists() and equiped.tier(30)>=2 then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Default Aoe]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier30_2pc
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier30_2pc
    if cast.able.risingSunKick() and equiped.tier(30)>=2 then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Default Aoe]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=talent.whirling_dragon_punch&cooldown.whirling_dragon_punch.remains<3&cooldown.fists_of_fury.remains>3&!buff.kicks_of_flowing_momentum.up
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=talent.whirling_dragon_punch&cooldown.whirling_dragon_punch.remains<3&cooldown.fists_of_fury.remains>3&!buff.kicks_of_flowing_momentum.up
    if cast.able.risingSunKick() and talent.whirlingDragonPunch and cd.whirlingDragonPunch.remains()<3 and cd.fistsOfFury.remains()>3 and not buff.kicksOfFlowingMomentum.exists() then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Default Aoe]") return true end
    end

    -- Expel Harm
    -- expel_harm,if=chi=1&(!cooldown.rising_sun_kick.remains|!cooldown.strike_of_the_windlord.remains)|chi=2&!cooldown.fists_of_fury.remains
    if cast.able.expelHarm() and ((chi()==1 and (not cd.risingSunKick.remains() or not cd.strikeOfTheWindlord.remains()) or chi()==2 and not cd.fistsOfFury.remains())) then
        if cast.expelHarm() then ui.debug("Casting Expel Harm [Default Aoe]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&cooldown.fists_of_fury.remains<5&buff.chi_energy.stack>10
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&cooldown.fists_of_fury.remains<5&buff.chi_energy.stack>10
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and cd.fistsOfFury.remains()<5 and buff.chiEnergy.stack()>10 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Default Aoe]") return true end
    end

    -- Chi Burst
    -- chi_burst,if=buff.bloodlust.up&chi<5
    if cast.able.chiBurst() and buff.bloodlust.exists() and chi()<5 then
        if cast.chiBurst() then ui.debug("Casting Chi Burst [Default Aoe]") return true end
    end

    -- Chi Burst
    -- chi_burst,if=chi<5&energy<50
    if cast.able.chiBurst() and chi()<5 and energy()<50 then
        if cast.chiBurst() then ui.debug("Casting Chi Burst [Default Aoe]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&(cooldown.fists_of_fury.remains>3|chi>2)&spinning_crane_kick.max&buff.bloodlust.up&!buff.blackout_reinforcement.up
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&(cooldown.fists_of_fury.remains>3|chi>2)&spinning_crane_kick.max&buff.bloodlust.up&!buff.blackout_reinforcement.up
    if cast.able.spinningCraneKick() and ((unit.timeToDie(PLACEHOLDER)>duration and combo_strike and (cd.fistsOfFury.remains()>3 or chi()>2) and spinning_crane_kick.max and buff.bloodlust.exists() and not buff.blackoutReinforcement.exists())) then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Default Aoe]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&(cooldown.fists_of_fury.remains>3|chi>2)&spinning_crane_kick.max&buff.invokers_delight.up&!buff.blackout_reinforcement.up
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&(cooldown.fists_of_fury.remains>3|chi>2)&spinning_crane_kick.max&buff.invokers_delight.up&!buff.blackout_reinforcement.up
    if cast.able.spinningCraneKick() and ((unit.timeToDie(PLACEHOLDER)>duration and combo_strike and (cd.fistsOfFury.remains()>3 or chi()>2) and spinning_crane_kick.max and buff.invokersDelight.exists() and not buff.blackoutReinforcement.exists())) then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Default Aoe]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=talent.shadowboxing_treads&combo_strike&set_bonus.tier30_2pc&!buff.bonedust_brew.up&active_enemies<15&!talent.crane_vortex
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=talent.shadowboxing_treads&combo_strike&set_bonus.tier30_2pc&!buff.bonedust_brew.up&active_enemies<15&!talent.crane_vortex
    if cast.able.blackoutKick() and talent.shadowboxingTreads and combo_strike and equiped.tier(30)>=2 and not buff.bonedustBrew.exists() and #enemies.yards0<15 and not talent.craneVortex then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default Aoe]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=talent.shadowboxing_treads&combo_strike&set_bonus.tier30_2pc&!buff.bonedust_brew.up&active_enemies<8
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=talent.shadowboxing_treads&combo_strike&set_bonus.tier30_2pc&!buff.bonedust_brew.up&active_enemies<8
    if cast.able.blackoutKick() and talent.shadowboxingTreads and combo_strike and equiped.tier(30)>=2 and not buff.bonedustBrew.exists() and #enemies.yards0<8 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default Aoe]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&(cooldown.fists_of_fury.remains>3|chi>4)&spinning_crane_kick.max
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&(cooldown.fists_of_fury.remains>3|chi>4)&spinning_crane_kick.max
    if cast.able.spinningCraneKick() and ((unit.timeToDie(PLACEHOLDER)>duration and combo_strike and (cd.fistsOfFury.remains()>3 or chi()>4) and spinning_crane_kick.max)) then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Default Aoe]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.teachings_of_the_monastery.stack=3
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.teachings_of_the_monastery.stack=3
    if cast.able.blackoutKick() and buff.teachingsOfTheMonastery.stack()==3 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default Aoe]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains
    if cast.able.strikeOfTheWindlord() then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Default Aoe]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=talent.shadowboxing_treads&combo_strike&!spinning_crane_kick.max
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=talent.shadowboxing_treads&combo_strike&!spinning_crane_kick.max
    if cast.able.blackoutKick() and talent.shadowboxingTreads and combo_strike and not spinning_crane_kick.max then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default Aoe]") return true end
    end

    -- Chi Burst
    -- chi_burst,if=chi.max-chi>=1&active_enemies=1&raid_event.adds.in>20|chi.max-chi>=2
    if cast.able.chiBurst() and ((chi.max()-chi()>=1 and #enemies.yards0==1 and notConvertable>20 or chi.max()-chi()>=2)) then
        if cast.chiBurst() then ui.debug("Casting Chi Burst [Default Aoe]") return true end
    end

end -- End Action List - DefaultAoe

-- Action List - DefaultSt
actionList.DefaultSt = function()
    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains+(debuff.skyreach_exhaustion.up*20),if=combo_strike&chi<2&(cooldown.rising_sun_kick.remains<1|cooldown.fists_of_fury.remains<1|cooldown.strike_of_the_windlord.remains<1)&buff.teachings_of_the_monastery.stack<3
    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains+(debuff.skyreach_exhaustion.up*20),if=combo_strike&chi<2&(cooldown.rising_sun_kick.remains<1|cooldown.fists_of_fury.remains<1|cooldown.strike_of_the_windlord.remains<1)&buff.teachings_of_the_monastery.stack<3
    if cast.able.tigerPalm() and ((combo_strike and chi()<2 and (cd.risingSunKick.remains()<1 or cd.fistsOfFury.remains()<1 or cd.strikeOfTheWindlord.remains()<1) and buff.teachingsOfTheMonastery.stack()<3)) then
        if cast.tigerPalm() then ui.debug("Casting Tiger Palm [Default St]") return true end
    end

    -- Expel Harm
    -- expel_harm,if=chi=1&(!cooldown.rising_sun_kick.remains|!cooldown.strike_of_the_windlord.remains)|chi=2&!cooldown.fists_of_fury.remains&cooldown.rising_sun_kick.remains
    if cast.able.expelHarm() and ((chi()==1 and (not cd.risingSunKick.remains() or not cd.strikeOfTheWindlord.remains()) or chi()==2 and not cd.fistsOfFury.remains() and cd.risingSunKick.remains())) then
        if cast.expelHarm() then ui.debug("Casting Expel Harm [Default St]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,if=buff.domineering_arrogance.up&talent.thunderfist&talent.serenity&cooldown.invoke_xuen_the_white_tiger.remains>20|fight_remains<5|talent.thunderfist&debuff.skyreach_exhaustion.remains>10&!buff.domineering_arrogance.up|talent.thunderfist&debuff.skyreach_exhaustion.remains>35&!talent.serenity
    if cast.able.strikeOfTheWindlord() and ((buff.domineeringArrogance.exists() and talent.thunderfist and talent.serenity and cd.invokeXuenTheWhiteTiger.remains()>20 or unit.ttdGroup(40)<5 or talent.thunderfist and debuff.skyreachExhaustion.remains(PLACEHOLDER)>10 and not buff.domineeringArrogance.exists() or talent.thunderfist and debuff.skyreachExhaustion.remains(PLACEHOLDER)>35 and not talent.serenity)) then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Default St]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&set_bonus.tier31_2pc&!buff.blackout_reinforcement.up
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&set_bonus.tier31_2pc&!buff.blackout_reinforcement.up
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() and equiped.tier(31)>=2 and not buff.blackoutReinforcement.exists() then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Default St]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,if=!cooldown.fists_of_fury.remains
    if cast.able.risingSunKick() and not cd.fistsOfFury.remains() then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Default St]") return true end
    end

    -- Fists Of Fury
    -- fists_of_fury,if=!buff.pressure_point.up&debuff.skyreach_exhaustion.remains<55&(debuff.jadefire_brand_damage.remains>2|cooldown.jadefire_stomp.remains)
    if cast.able.fistsOfFury() and ((not buff.pressurePoint.exists() and debuff.skyreachExhaustion.remains(PLACEHOLDER)<55 and (debuff.jadefireBrandDamage.remains(PLACEHOLDER)>2 or cd.jadefireStomp.remains()))) then
        if cast.fistsOfFury() then ui.debug("Casting Fists Of Fury [Default St]") return true end
    end

    -- Jadefire Stomp
    -- jadefire_stomp,if=debuff.skyreach_exhaustion.remains<1&debuff.jadefire_brand_damage.remains<3
    if cast.able.jadefireStomp() and debuff.skyreachExhaustion.remains(PLACEHOLDER)<1 and debuff.jadefireBrandDamage.remains(PLACEHOLDER)<3 then
        if cast.jadefireStomp() then ui.debug("Casting Jadefire Stomp [Default St]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,if=buff.pressure_point.up|debuff.skyreach_exhaustion.remains>55
    if cast.able.risingSunKick() and ((buff.pressurePoint.exists() or debuff.skyreachExhaustion.remains(PLACEHOLDER)>55)) then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Default St]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,if=buff.pressure_point.remains&chi>2&prev.rising_sun_kick
    if cast.able.blackoutKick() and buff.pressurePoint.remains() and chi()>2 and prev.rising_sun_kick then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default St]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,if=buff.teachings_of_the_monastery.stack=3
    if cast.able.blackoutKick() and buff.teachingsOfTheMonastery.stack()==3 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default St]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,if=buff.blackout_reinforcement.up&cooldown.rising_sun_kick.remains&combo_strike&buff.dance_of_chiji.up
    if cast.able.blackoutKick() and buff.blackoutReinforcement.exists() and cd.risingSunKick.remains() and combo_strike and buff.danceOfChiji.exists() then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default St]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick
    if cast.able.risingSunKick() then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Default St]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,if=buff.blackout_reinforcement.up&combo_strike
    if cast.able.blackoutKick() and buff.blackoutReinforcement.exists() and combo_strike then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default St]") return true end
    end

    -- Fists Of Fury
    -- fists_of_fury
    if cast.able.fistsOfFury() then
        if cast.fistsOfFury() then ui.debug("Casting Fists Of Fury [Default St]") return true end
    end

    -- Whirling Dragon Punch
    -- whirling_dragon_punch,if=!buff.pressure_point.up
    if cast.able.whirlingDragonPunch() and not buff.pressurePoint.exists() then
        if cast.whirlingDragonPunch() then ui.debug("Casting Whirling Dragon Punch [Default St]") return true end
    end

    -- Chi Burst
    -- chi_burst,if=buff.bloodlust.up&chi<5
    if cast.able.chiBurst() and buff.bloodlust.exists() and chi()<5 then
        if cast.chiBurst() then ui.debug("Casting Chi Burst [Default St]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,if=buff.teachings_of_the_monastery.stack=2&debuff.skyreach_exhaustion.remains>1
    if cast.able.blackoutKick() and buff.teachingsOfTheMonastery.stack()==2 and debuff.skyreachExhaustion.remains(PLACEHOLDER)>1 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default St]") return true end
    end

    -- Chi Burst
    -- chi_burst,if=chi<5&energy<50
    if cast.able.chiBurst() and chi()<5 and energy()<50 then
        if cast.chiBurst() then ui.debug("Casting Chi Burst [Default St]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,if=debuff.skyreach_exhaustion.remains>30|fight_remains<5
    if cast.able.strikeOfTheWindlord() and ((debuff.skyreachExhaustion.remains(PLACEHOLDER)>30 or unit.ttdGroup(40)<5)) then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Default St]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!set_bonus.tier31_2pc
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!set_bonus.tier31_2pc
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() and not equiped.tier(31)>=2 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Default St]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,if=buff.teachings_of_the_monastery.up&cooldown.rising_sun_kick.remains>1
    if cast.able.blackoutKick() and buff.teachingsOfTheMonastery.exists() and cd.risingSunKick.remains()>1 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default St]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&buff.bonedust_brew.up&combo_strike&spinning_crane_kick.modifier>=2.7
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&buff.bonedust_brew.up&combo_strike&spinning_crane_kick.modifier>=2.7
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and buff.bonedustBrew.exists() and combo_strike and spinning_crane_kick.modifier>=2.7 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Default St]") return true end
    end

    -- Whirling Dragon Punch
    -- whirling_dragon_punch
    if cast.able.whirlingDragonPunch() then
        if cast.whirlingDragonPunch() then ui.debug("Casting Whirling Dragon Punch [Default St]") return true end
    end

    -- Rushing Jade Wind
    -- rushing_jade_wind,if=!buff.rushing_jade_wind.up
    if cast.able.rushingJadeWind() and not buff.rushingJadeWind.exists() then
        if cast.rushingJadeWind() then ui.debug("Casting Rushing Jade Wind [Default St]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,if=combo_strike
    if cast.able.blackoutKick() and combo_strike then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Default St]") return true end
    end

end -- End Action List - DefaultSt

-- Action List - Fallthru
actionList.Fallthru = function()
    -- Crackling Jade Lightning
    -- crackling_jade_lightning,if=buff.the_emperors_capacitor.stack>19&energy.time_to_max>execute_time-1&cooldown.rising_sun_kick.remains>execute_time|buff.the_emperors_capacitor.stack>14&(cooldown.serenity.remains<5&talent.serenity|fight_remains<5)
    if cast.able.cracklingJadeLightning() and ((buff.theEmperorsCapacitor.stack()>19 and energy.timeToMax()>execute_time-1 and cd.risingSunKick.remains()>execute_time or buff.theEmperorsCapacitor.stack()>14 and (cd.serenity.remains()<5 and talent.serenity or unit.ttdGroup(40)<5))) then
        if cast.cracklingJadeLightning() then ui.debug("Casting Crackling Jade Lightning [Fallthru]") return true end
    end

    -- Jadefire Stomp
    -- jadefire_stomp,if=combo_strike
    if cast.able.jadefireStomp() and combo_strike then
        if cast.jadefireStomp() then ui.debug("Casting Jadefire Stomp [Fallthru]") return true end
    end

    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains+(debuff.skyreach_exhaustion.up*20),if=combo_strike&chi.max-chi>=(2+buff.power_strikes.up)
    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains+(debuff.skyreach_exhaustion.up*20),if=combo_strike&chi.max-chi>=(2+buff.power_strikes.up)
    if cast.able.tigerPalm() and combo_strike and chi.max()-chi()>=(2+buff.powerStrikes.exists()) then
        if cast.tigerPalm() then ui.debug("Casting Tiger Palm [Fallthru]") return true end
    end

    -- Expel Harm
    -- expel_harm,if=chi.max-chi>=1&active_enemies>2
    if cast.able.expelHarm() and chi.max()-chi()>=1 and #enemies.yards0>2 then
        if cast.expelHarm() then ui.debug("Casting Expel Harm [Fallthru]") return true end
    end

    -- Chi Burst
    -- chi_burst,if=chi.max-chi>=1&active_enemies=1&raid_event.adds.in>20|chi.max-chi>=2&active_enemies>=2
    if cast.able.chiBurst() and ((chi.max()-chi()>=1 and #enemies.yards0==1 and notConvertable>20 or chi.max()-chi()>=2 and #enemies.yards0>=2)) then
        if cast.chiBurst() then ui.debug("Casting Chi Burst [Fallthru]") return true end
    end

    -- Chi Wave
    -- chi_wave
    if cast.able.chiWave() then
        if cast.chiWave() then ui.debug("Casting Chi Wave [Fallthru]") return true end
    end

    -- Expel Harm
    -- expel_harm,if=chi.max-chi>=1
    if cast.able.expelHarm() and chi.max()-chi()>=1 then
        if cast.expelHarm() then ui.debug("Casting Expel Harm [Fallthru]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&active_enemies>=5
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&active_enemies>=5
    if cast.able.blackoutKick() and combo_strike and #enemies.yards0>=5 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Fallthru]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.chi_energy.stack>30-5*active_enemies&buff.storm_earth_and_fire.down&(cooldown.rising_sun_kick.remains>2&cooldown.fists_of_fury.remains>2|cooldown.rising_sun_kick.remains<3&cooldown.fists_of_fury.remains>3&chi>3|cooldown.rising_sun_kick.remains>3&cooldown.fists_of_fury.remains<3&chi>4|chi.max-chi<=1&energy.time_to_max<2)|buff.chi_energy.stack>10&fight_remains<7
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.chi_energy.stack>30-5*active_enemies&buff.storm_earth_and_fire.down&(cooldown.rising_sun_kick.remains>2&cooldown.fists_of_fury.remains>2|cooldown.rising_sun_kick.remains<3&cooldown.fists_of_fury.remains>3&chi>3|cooldown.rising_sun_kick.remains>3&cooldown.fists_of_fury.remains<3&chi>4|chi.max-chi<=1&energy.time_to_max<2)|buff.chi_energy.stack>10&fight_remains<7
    if cast.able.spinningCraneKick() and ((unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.chiEnergy.stack()>30-5*#enemies.yards0 and not buff.stormEarthAndFire.exists() and (cd.risingSunKick.remains()>2 and cd.fistsOfFury.remains()>2 or cd.risingSunKick.remains()<3 and cd.fistsOfFury.remains()>3 and chi()>3 or cd.risingSunKick.remains()>3 and cd.fistsOfFury.remains()<3 and chi()>4 or chi.max()-chi()<=1 and energy.timeToMax()<2) or buff.chiEnergy.stack()>10 and unit.ttdGroup(40)<7)) then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Fallthru]") return true end
    end

    -- Arcane Torrent
    -- arcane_torrent,if=chi.max-chi>=1
    if cast.able.arcaneTorrent() and chi.max()-chi()>=1 then
        if cast.arcaneTorrent() then ui.debug("Casting Arcane Torrent [Fallthru]") return true end
    end

    -- Flying Serpent Kick
    -- flying_serpent_kick,interrupt=1
    if cast.able.flyingSerpentKick() then
        if cast.flyingSerpentKick() then ui.debug("Casting Flying Serpent Kick [Fallthru]") return true end
    end

    -- Tiger Palm
    -- tiger_palm
    if cast.able.tigerPalm() then
        if cast.tigerPalm() then ui.debug("Casting Tiger Palm [Fallthru]") return true end
    end

end -- End Action List - Fallthru

-- Action List - Opener
actionList.Opener = function()
    -- Summon White Tiger Statue
    -- summon_white_tiger_statue
    if cast.able.summonWhiteTigerStatue() then
        if cast.summonWhiteTigerStatue() then ui.debug("Casting Summon White Tiger Statue [Opener]") return true end
    end

    -- Expel Harm
    -- expel_harm,if=talent.chi_burst.enabled&chi.max-chi>=3
    if cast.able.expelHarm() and talent.chiBurst and chi.max()-chi()>=3 then
        if cast.expelHarm() then ui.debug("Casting Expel Harm [Opener]") return true end
    end

    -- Jadefire Stomp
    -- jadefire_stomp,if=debuff.jadefire_brand_damage.remains<2&!debuff.skyreach_exhaustion.remains<2&!debuff.skyreach_exhaustion.remains
    if cast.able.jadefireStomp() and debuff.jadefireBrandDamage.remains(PLACEHOLDER)<2 and not debuff.skyreachExhaustion.remains(PLACEHOLDER)<2 and not debuff.skyreachExhaustion.remains(PLACEHOLDER) then
        if cast.jadefireStomp() then ui.debug("Casting Jadefire Stomp [Opener]") return true end
    end

    -- Expel Harm
    -- expel_harm,if=talent.chi_burst.enabled&chi=3
    if cast.able.expelHarm() and talent.chiBurst and chi()==3 then
        if cast.expelHarm() then ui.debug("Casting Expel Harm [Opener]") return true end
    end

    -- Chi Wave
    -- chi_wave,if=chi.max-chi=2
    if cast.able.chiWave() and chi.max()-chi()==2 then
        if cast.chiWave() then ui.debug("Casting Chi Wave [Opener]") return true end
    end

    -- Expel Harm
    -- expel_harm
    if cast.able.expelHarm() then
        if cast.expelHarm() then ui.debug("Casting Expel Harm [Opener]") return true end
    end

    -- Chi Burst
    -- chi_burst,if=chi>1&chi.max-chi>=2
    if cast.able.chiBurst() and chi()>1 and chi.max()-chi()>=2 then
        if cast.chiBurst() then ui.debug("Casting Chi Burst [Opener]") return true end
    end

end -- End Action List - Opener

-- Action List - Serenity2T
actionList.Serenity2T = function()
    -- Jadefire Stomp
    -- jadefire_stomp,if=debuff.jadefire_brand_damage.remains<2&!debuff.skyreach_exhaustion.remains<2&!debuff.skyreach_exhaustion.remains
    if cast.able.jadefireStomp() and debuff.jadefireBrandDamage.remains(PLACEHOLDER)<2 and not debuff.skyreachExhaustion.remains(PLACEHOLDER)<2 and not debuff.skyreachExhaustion.remains(PLACEHOLDER) then
        if cast.jadefireStomp() then ui.debug("Casting Jadefire Stomp [Serenity 2T]") return true end
    end

    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!debuff.skyreach_exhaustion.up*20&combo_strike
    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!debuff.skyreach_exhaustion.up*20&combo_strike
    if cast.able.tigerPalm() and not debuff.skyreachExhaustion.exists(PLACEHOLDER)*20 and combo_strike then
        if cast.tigerPalm() then ui.debug("Casting Tiger Palm [Serenity 2T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&buff.teachings_of_the_monastery.stack=3&buff.teachings_of_the_monastery.remains<1
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&buff.teachings_of_the_monastery.stack=3&buff.teachings_of_the_monastery.remains<1
    if cast.able.blackoutKick() and combo_strike and buff.teachingsOfTheMonastery.stack()==3 and buff.teachingsOfTheMonastery.remains()<1 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity 2T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up&prev.fists_of_fury&set_bonus.tier31_2pc
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up&prev.fists_of_fury&set_bonus.tier31_2pc
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() and not buff.blackoutReinforcement.exists() and prev.fists_of_fury and equiped.tier(31)>=2 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity 2T]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.pressure_point.up|debuff.skyreach_exhaustion.remains>55
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.pressure_point.up|debuff.skyreach_exhaustion.remains>55
    if cast.able.risingSunKick() and ((buff.pressurePoint.exists() or debuff.skyreachExhaustion.remains(PLACEHOLDER)>55)) then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Serenity 2T]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.pressure_point.up&set_bonus.tier30_2pc
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.pressure_point.up&set_bonus.tier30_2pc
    if cast.able.risingSunKick() and buff.pressurePoint.exists() and equiped.tier(30)>=2 then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Serenity 2T]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier30_2pc
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier30_2pc
    if cast.able.risingSunKick() and equiped.tier(30)>=2 then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Serenity 2T]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist&buff.call_to_dominance.up&debuff.skyreach_exhaustion.remains>buff.call_to_dominance.remains
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist&buff.call_to_dominance.up&debuff.skyreach_exhaustion.remains>buff.call_to_dominance.remains
    if cast.able.strikeOfTheWindlord() and talent.thunderfist and buff.callToDominance.exists() and debuff.skyreachExhaustion.remains(PLACEHOLDER)>buff.callToDominance.remains() then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Serenity 2T]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist&debuff.skyreach_exhaustion.remains>55
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist&debuff.skyreach_exhaustion.remains>55
    if cast.able.strikeOfTheWindlord() and talent.thunderfist and debuff.skyreachExhaustion.remains(PLACEHOLDER)>55 then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Serenity 2T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&buff.blackout_reinforcement.up
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&buff.blackout_reinforcement.up
    if cast.able.blackoutKick() and combo_strike and buff.blackoutReinforcement.exists() then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity 2T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up&set_bonus.tier31_2pc
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up&set_bonus.tier31_2pc
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() and not buff.blackoutReinforcement.exists() and equiped.tier(31)>=2 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity 2T]") return true end
    end

    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=buff.invokers_delight.up,interrupt=1
    -- TODO: The following conditions were not converted:
    -- buff.invokers_delight.up,interrupt
    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=buff.invokers_delight.up,interrupt=1
    -- TODO: The following conditions were not converted:
    -- buff.invokers_delight.up,interrupt
    if cast.able.fistsOfFury() and ==1 then
        if cast.fistsOfFury() then ui.debug("Casting Fists Of Fury [Serenity 2T]") return true end
    end

    -- Fists Of Fury Cancel
    -- fists_of_fury_cancel,target_if=max:debuff.keefers_skyreach.remains
    -- Fists Of Fury Cancel
    -- fists_of_fury_cancel,target_if=max:debuff.keefers_skyreach.remains
    if cast.able.fistsOfFuryCancel() then
        if cast.fistsOfFuryCancel() then ui.debug("Casting Fists Of Fury Cancel [Serenity 2T]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist
    if cast.able.strikeOfTheWindlord() and talent.thunderfist then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Serenity 2T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up&set_bonus.tier31_2pc
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up&set_bonus.tier31_2pc
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() and not buff.blackoutReinforcement.exists() and equiped.tier(31)>=2 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity 2T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&!buff.blackout_reinforcement.up&set_bonus.tier31_2pc
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&!buff.blackout_reinforcement.up&set_bonus.tier31_2pc
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and not buff.blackoutReinforcement.exists() and equiped.tier(31)>=2 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity 2T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&set_bonus.tier30_2pc
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&set_bonus.tier30_2pc
    if cast.able.blackoutKick() and combo_strike and equiped.tier(30)>=2 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity 2T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&buff.teachings_of_the_monastery.stack=2
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&buff.teachings_of_the_monastery.stack=2
    if cast.able.blackoutKick() and combo_strike and buff.teachingsOfTheMonastery.stack()==2 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity 2T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=cooldown.fists_of_fury.remains>5&talent.shadowboxing_treads&buff.teachings_of_the_monastery.stack=1&combo_strike
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=cooldown.fists_of_fury.remains>5&talent.shadowboxing_treads&buff.teachings_of_the_monastery.stack=1&combo_strike
    if cast.able.blackoutKick() and cd.fistsOfFury.remains()>5 and talent.shadowboxingTreads and buff.teachingsOfTheMonastery.stack()==1 and combo_strike then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity 2T]") return true end
    end

    -- Whirling Dragon Punch
    -- whirling_dragon_punch
    if cast.able.whirlingDragonPunch() then
        if cast.whirlingDragonPunch() then ui.debug("Casting Whirling Dragon Punch [Serenity 2T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=max:debuff.keefers_skyreach.remains,if=combo_strike
    -- Blackout Kick
    -- blackout_kick,target_if=max:debuff.keefers_skyreach.remains,if=combo_strike
    if cast.able.blackoutKick() and combo_strike then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity 2T]") return true end
    end

    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=talent.teachings_of_the_monastery&buff.teachings_of_the_monastery.stack<3
    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=talent.teachings_of_the_monastery&buff.teachings_of_the_monastery.stack<3
    if cast.able.tigerPalm() and talent.teachingsOfTheMonastery and buff.teachingsOfTheMonastery.stack()<3 then
        if cast.tigerPalm() then ui.debug("Casting Tiger Palm [Serenity 2T]") return true end
    end

end -- End Action List - Serenity2T

-- Action List - Serenity3T
actionList.Serenity3T = function()
    -- Jadefire Stomp
    -- jadefire_stomp,if=debuff.jadefire_brand_damage.remains<1
    if cast.able.jadefireStomp() and debuff.jadefireBrandDamage.remains(PLACEHOLDER)<1 then
        if cast.jadefireStomp() then ui.debug("Casting Jadefire Stomp [Serenity 3T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier31_2pc&combo_strike&buff.blackout_reinforcement.up
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier31_2pc&combo_strike&buff.blackout_reinforcement.up
    if cast.able.blackoutKick() and equiped.tier(31)>=2 and combo_strike and buff.blackoutReinforcement.exists() then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity 3T]") return true end
    end

    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!debuff.skyreach_exhaustion.up*20&combo_strike
    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!debuff.skyreach_exhaustion.up*20&combo_strike
    if cast.able.tigerPalm() and not debuff.skyreachExhaustion.exists(PLACEHOLDER)*20 and combo_strike then
        if cast.tigerPalm() then ui.debug("Casting Tiger Palm [Serenity 3T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&spinning_crane_kick.max&!buff.blackout_reinforcement.up&set_bonus.tier31_2pc
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&spinning_crane_kick.max&!buff.blackout_reinforcement.up&set_bonus.tier31_2pc
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() and spinning_crane_kick.max and not buff.blackoutReinforcement.exists() and equiped.tier(31)>=2 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity 3T]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist&buff.call_to_dominance.up&debuff.skyreach_exhaustion.remains>buff.call_to_dominance.remains
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist&buff.call_to_dominance.up&debuff.skyreach_exhaustion.remains>buff.call_to_dominance.remains
    if cast.able.strikeOfTheWindlord() and talent.thunderfist and buff.callToDominance.exists() and debuff.skyreachExhaustion.remains(PLACEHOLDER)>buff.callToDominance.remains() then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Serenity 3T]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist&debuff.skyreach_exhaustion.remains>55
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist&debuff.skyreach_exhaustion.remains>55
    if cast.able.strikeOfTheWindlord() and talent.thunderfist and debuff.skyreachExhaustion.remains(PLACEHOLDER)>55 then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Serenity 3T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&buff.blackout_reinforcement.up
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&buff.blackout_reinforcement.up
    if cast.able.blackoutKick() and combo_strike and buff.blackoutReinforcement.exists() then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity 3T]") return true end
    end

    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=buff.invokers_delight.up&!set_bonus.tier31_2pc,interrupt=1
    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=buff.invokers_delight.up&!set_bonus.tier31_2pc,interrupt=1
    if cast.able.fistsOfFury() and buff.invokersDelight.exists() and not equiped.tier(31)>=2==1 then
        if cast.fistsOfFury() then ui.debug("Casting Fists Of Fury [Serenity 3T]") return true end
    end

    -- Fists Of Fury Cancel
    -- fists_of_fury_cancel,target_if=max:debuff.keefers_skyreach.remains,if=!set_bonus.tier31_2pc|buff.fury_of_xuen_stacks.stack>90
    -- Fists Of Fury Cancel
    -- fists_of_fury_cancel,target_if=max:debuff.keefers_skyreach.remains,if=!set_bonus.tier31_2pc|buff.fury_of_xuen_stacks.stack>90
    if cast.able.fistsOfFuryCancel() and ((not equiped.tier(31)>=2 or buff.furyOfXuenStacks.stack()>90)) then
        if cast.fistsOfFuryCancel() then ui.debug("Casting Fists Of Fury Cancel [Serenity 3T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&spinning_crane_kick.max&!buff.blackout_reinforcement.up&set_bonus.tier31_2pc
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&spinning_crane_kick.max&!buff.blackout_reinforcement.up&set_bonus.tier31_2pc
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and spinning_crane_kick.max and not buff.blackoutReinforcement.exists() and equiped.tier(31)>=2 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity 3T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&spinning_crane_kick.max&buff.blackout_reinforcement.up&set_bonus.tier31_2pc&prev.blackout_kick&talent.crane_vortex
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&spinning_crane_kick.max&buff.blackout_reinforcement.up&set_bonus.tier31_2pc&prev.blackout_kick&talent.crane_vortex
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and spinning_crane_kick.max and buff.blackoutReinforcement.exists() and equiped.tier(31)>=2 and prev.blackout_kick and talent.craneVortex then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity 3T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&!buff.pressure_point.up
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&!buff.pressure_point.up
    if cast.able.blackoutKick() and combo_strike and not buff.pressurePoint.exists() then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity 3T]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.pressure_point.up
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.pressure_point.up
    if cast.able.risingSunKick() and buff.pressurePoint.exists() then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Serenity 3T]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.pressure_point.up&set_bonus.tier30_2pc
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.pressure_point.up&set_bonus.tier30_2pc
    if cast.able.risingSunKick() and buff.pressurePoint.exists() and equiped.tier(30)>=2 then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Serenity 3T]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier30_2pc
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier30_2pc
    if cast.able.risingSunKick() and equiped.tier(30)>=2 then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Serenity 3T]") return true end
    end

    -- Jadefire Stomp
    -- jadefire_stomp,if=debuff.jadefire_brand_damage.remains<2
    if cast.able.jadefireStomp() and debuff.jadefireBrandDamage.remains(PLACEHOLDER)<2 then
        if cast.jadefireStomp() then ui.debug("Casting Jadefire Stomp [Serenity 3T]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist
    if cast.able.strikeOfTheWindlord() and talent.thunderfist then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Serenity 3T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&spinning_crane_kick.max&!buff.blackout_reinforcement.up
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&spinning_crane_kick.max&!buff.blackout_reinforcement.up
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() and spinning_crane_kick.max and not buff.blackoutReinforcement.exists() then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity 3T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&set_bonus.tier30_2pc
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&set_bonus.tier30_2pc
    if cast.able.blackoutKick() and combo_strike and equiped.tier(30)>=2 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity 3T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&!buff.blackout_reinforcement.up
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&!buff.blackout_reinforcement.up
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and not buff.blackoutReinforcement.exists() then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity 3T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&buff.teachings_of_the_monastery.stack=2
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&buff.teachings_of_the_monastery.stack=2
    if cast.able.blackoutKick() and combo_strike and buff.teachingsOfTheMonastery.stack()==2 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity 3T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=talent.shadowboxing_treads&combo_strike
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=talent.shadowboxing_treads&combo_strike
    if cast.able.blackoutKick() and talent.shadowboxingTreads and combo_strike then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity 3T]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains
    if cast.able.strikeOfTheWindlord() then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Serenity 3T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity 3T]") return true end
    end

    -- Whirling Dragon Punch
    -- whirling_dragon_punch
    if cast.able.whirlingDragonPunch() then
        if cast.whirlingDragonPunch() then ui.debug("Casting Whirling Dragon Punch [Serenity 3T]") return true end
    end

    -- Rushing Jade Wind
    -- rushing_jade_wind,if=!buff.rushing_jade_wind.up
    if cast.able.rushingJadeWind() and not buff.rushingJadeWind.exists() then
        if cast.rushingJadeWind() then ui.debug("Casting Rushing Jade Wind [Serenity 3T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=max:debuff.keefers_skyreach.remains,if=combo_strike
    -- Blackout Kick
    -- blackout_kick,target_if=max:debuff.keefers_skyreach.remains,if=combo_strike
    if cast.able.blackoutKick() and combo_strike then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity 3T]") return true end
    end

    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=talent.teachings_of_the_monastery&buff.teachings_of_the_monastery.stack<3
    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=talent.teachings_of_the_monastery&buff.teachings_of_the_monastery.stack<3
    if cast.able.tigerPalm() and talent.teachingsOfTheMonastery and buff.teachingsOfTheMonastery.stack()<3 then
        if cast.tigerPalm() then ui.debug("Casting Tiger Palm [Serenity 3T]") return true end
    end

end -- End Action List - Serenity3T

-- Action List - Serenity4T
actionList.Serenity4T = function()
    -- Jadefire Stomp
    -- jadefire_stomp,if=debuff.jadefire_brand_damage.remains<1
    if cast.able.jadefireStomp() and debuff.jadefireBrandDamage.remains(PLACEHOLDER)<1 then
        if cast.jadefireStomp() then ui.debug("Casting Jadefire Stomp [Serenity 4T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&buff.serenity.remains<1.5&combo_strike&!buff.blackout_reinforcement.remains&set_bonus.tier31_2pc
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&buff.serenity.remains<1.5&combo_strike&!buff.blackout_reinforcement.remains&set_bonus.tier31_2pc
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and buff.serenity.remains()<1.5 and combo_strike and not buff.blackoutReinforcement.remains() and equiped.tier(31)>=2 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity 4T]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,if=set_bonus.tier31_4pc&talent.thunderfist
    if cast.able.strikeOfTheWindlord() and equiped.tier(31)>=4 and talent.thunderfist then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Serenity 4T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up&set_bonus.tier31_2pc
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up&set_bonus.tier31_2pc
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() and not buff.blackoutReinforcement.exists() and equiped.tier(31)>=2 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity 4T]") return true end
    end

    -- Fists Of Fury Cancel
    -- fists_of_fury_cancel,target_if=max:debuff.keefers_skyreach.remains,if=!set_bonus.tier30_2pc&buff.fury_of_xuen_stacks.stack>90
    -- Fists Of Fury Cancel
    -- fists_of_fury_cancel,target_if=max:debuff.keefers_skyreach.remains,if=!set_bonus.tier30_2pc&buff.fury_of_xuen_stacks.stack>90
    if cast.able.fistsOfFuryCancel() and not equiped.tier(30)>=2 and buff.furyOfXuenStacks.stack()>90 then
        if cast.fistsOfFuryCancel() then ui.debug("Casting Fists Of Fury Cancel [Serenity 4T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&set_bonus.tier31_2pc&!buff.blackout_reinforcement.up
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&set_bonus.tier31_2pc&!buff.blackout_reinforcement.up
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() and equiped.tier(31)>=2 and not buff.blackoutReinforcement.exists() then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity 4T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&buff.teachings_of_the_monastery.stack=3&buff.teachings_of_the_monastery.remains<1
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&buff.teachings_of_the_monastery.stack=3&buff.teachings_of_the_monastery.remains<1
    if cast.able.blackoutKick() and combo_strike and buff.teachingsOfTheMonastery.stack()==3 and buff.teachingsOfTheMonastery.remains()<1 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity 4T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier31_2pc&combo_strike&buff.blackout_reinforcement.up
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier31_2pc&combo_strike&buff.blackout_reinforcement.up
    if cast.able.blackoutKick() and equiped.tier(31)>=2 and combo_strike and buff.blackoutReinforcement.exists() then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity 4T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&set_bonus.tier31_2pc&combo_strike&!buff.blackout_reinforcement.up&talent.crane_vortex
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&set_bonus.tier31_2pc&combo_strike&!buff.blackout_reinforcement.up&talent.crane_vortex
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and equiped.tier(31)>=2 and combo_strike and not buff.blackoutReinforcement.exists() and talent.craneVortex then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity 4T]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.pressure_point.up&!talent.bonedust_brew
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.pressure_point.up&!talent.bonedust_brew
    if cast.able.risingSunKick() and buff.pressurePoint.exists() and not talent.bonedustBrew then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Serenity 4T]") return true end
    end

    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=buff.invokers_delight.up&set_bonus.tier31_2pc&buff.transfer_the_power.stack>5&!talent.crane_vortex&buff.bloodlust.up,interrupt=1
    -- TODO: The following conditions were not converted:
    -- buff.bloodlust.up,interrupt
    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=buff.invokers_delight.up&set_bonus.tier31_2pc&buff.transfer_the_power.stack>5&!talent.crane_vortex&buff.bloodlust.up,interrupt=1
    -- TODO: The following conditions were not converted:
    -- buff.bloodlust.up,interrupt
    if cast.able.fistsOfFury() and buff.invokersDelight.exists() and equiped.tier(31)>=2 and buff.transferThePower.stack()>5 and not talent.craneVortex and ==1 then
        if cast.fistsOfFury() then ui.debug("Casting Fists Of Fury [Serenity 4T]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.pressure_point.up&set_bonus.tier30_2pc
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.pressure_point.up&set_bonus.tier30_2pc
    if cast.able.risingSunKick() and buff.pressurePoint.exists() and equiped.tier(30)>=2 then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Serenity 4T]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier30_2pc
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier30_2pc
    if cast.able.risingSunKick() and equiped.tier(30)>=2 then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Serenity 4T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&set_bonus.tier31_2pc&combo_strike&!buff.blackout_reinforcement.up
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&set_bonus.tier31_2pc&combo_strike&!buff.blackout_reinforcement.up
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and equiped.tier(31)>=2 and combo_strike and not buff.blackoutReinforcement.exists() then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity 4T]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist&buff.call_to_dominance.up&debuff.skyreach_exhaustion.remains>buff.call_to_dominance.remains
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist&buff.call_to_dominance.up&debuff.skyreach_exhaustion.remains>buff.call_to_dominance.remains
    if cast.able.strikeOfTheWindlord() and talent.thunderfist and buff.callToDominance.exists() and debuff.skyreachExhaustion.remains(PLACEHOLDER)>buff.callToDominance.remains() then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Serenity 4T]") return true end
    end

    -- Jadefire Stomp
    -- jadefire_stomp,if=debuff.jadefire_brand_damage.remains<2
    if cast.able.jadefireStomp() and debuff.jadefireBrandDamage.remains(PLACEHOLDER)<2 then
        if cast.jadefireStomp() then ui.debug("Casting Jadefire Stomp [Serenity 4T]") return true end
    end

    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=buff.invokers_delight.up,interrupt=1
    -- TODO: The following conditions were not converted:
    -- buff.invokers_delight.up,interrupt
    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=buff.invokers_delight.up,interrupt=1
    -- TODO: The following conditions were not converted:
    -- buff.invokers_delight.up,interrupt
    if cast.able.fistsOfFury() and ==1 then
        if cast.fistsOfFury() then ui.debug("Casting Fists Of Fury [Serenity 4T]") return true end
    end

    -- Fists Of Fury Cancel
    -- fists_of_fury_cancel,target_if=max:debuff.keefers_skyreach.remains
    -- Fists Of Fury Cancel
    -- fists_of_fury_cancel,target_if=max:debuff.keefers_skyreach.remains
    if cast.able.fistsOfFuryCancel() then
        if cast.fistsOfFuryCancel() then ui.debug("Casting Fists Of Fury Cancel [Serenity 4T]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist
    if cast.able.strikeOfTheWindlord() and talent.thunderfist then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Serenity 4T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() and not buff.blackoutReinforcement.exists() then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity 4T]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.pressure_point.up
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.pressure_point.up
    if cast.able.risingSunKick() and buff.pressurePoint.exists() then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Serenity 4T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&set_bonus.tier30_2pc
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&set_bonus.tier30_2pc
    if cast.able.blackoutKick() and combo_strike and equiped.tier(30)>=2 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity 4T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&spinning_crane_kick.max
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&spinning_crane_kick.max
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and spinning_crane_kick.max then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity 4T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=talent.shadowboxing_treads&combo_strike
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=talent.shadowboxing_treads&combo_strike
    if cast.able.blackoutKick() and talent.shadowboxingTreads and combo_strike then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity 4T]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains
    if cast.able.strikeOfTheWindlord() then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Serenity 4T]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&!buff.blackout_reinforcement.up
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&!buff.blackout_reinforcement.up
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and not buff.blackoutReinforcement.exists() then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity 4T]") return true end
    end

    -- Whirling Dragon Punch
    -- whirling_dragon_punch
    if cast.able.whirlingDragonPunch() then
        if cast.whirlingDragonPunch() then ui.debug("Casting Whirling Dragon Punch [Serenity 4T]") return true end
    end

    -- Rushing Jade Wind
    -- rushing_jade_wind,if=!buff.rushing_jade_wind.up
    if cast.able.rushingJadeWind() and not buff.rushingJadeWind.exists() then
        if cast.rushingJadeWind() then ui.debug("Casting Rushing Jade Wind [Serenity 4T]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=max:debuff.keefers_skyreach.remains,if=combo_strike
    -- Blackout Kick
    -- blackout_kick,target_if=max:debuff.keefers_skyreach.remains,if=combo_strike
    if cast.able.blackoutKick() and combo_strike then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity 4T]") return true end
    end

    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=talent.teachings_of_the_monastery&buff.teachings_of_the_monastery.stack<3
    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=talent.teachings_of_the_monastery&buff.teachings_of_the_monastery.stack<3
    if cast.able.tigerPalm() and talent.teachingsOfTheMonastery and buff.teachingsOfTheMonastery.stack()<3 then
        if cast.tigerPalm() then ui.debug("Casting Tiger Palm [Serenity 4T]") return true end
    end

end -- End Action List - Serenity4T

-- Action List - SerenityAoe
actionList.SerenityAoe = function()
    -- Jadefire Stomp
    -- jadefire_stomp,if=debuff.jadefire_brand_damage.remains<1
    if cast.able.jadefireStomp() and debuff.jadefireBrandDamage.remains(PLACEHOLDER)<1 then
        if cast.jadefireStomp() then ui.debug("Casting Jadefire Stomp [Serenity Aoe]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,if=set_bonus.tier31_4pc&talent.thunderfist
    if cast.able.strikeOfTheWindlord() and equiped.tier(31)>=4 and talent.thunderfist then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Serenity Aoe]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&set_bonus.tier31_2pc
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&set_bonus.tier31_2pc
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() and equiped.tier(31)>=2 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Aoe]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&!buff.blackout_reinforcement.up&set_bonus.tier31_2pc&buff.bonedust_brew.up&active_enemies>4
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&!buff.blackout_reinforcement.up&set_bonus.tier31_2pc&buff.bonedust_brew.up&active_enemies>4
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and not buff.blackoutReinforcement.exists() and equiped.tier(31)>=2 and buff.bonedustBrew.exists() and #enemies.yards0>4 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Aoe]") return true end
    end

    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=talent.jade_ignition,interrupt_if=buff.chi_energy.stack=30
    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=talent.jade_ignition,interrupt_if=buff.chi_energy.stack=30
    if cast.able.fistsOfFury() and talent.jadeIgnition,InterruptIf==buff.chiEnergy.stack()==30 then
        if cast.fistsOfFury() then ui.debug("Casting Fists Of Fury [Serenity Aoe]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&set_bonus.tier31_2pc&combo_strike&!buff.blackout_reinforcement.up
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&set_bonus.tier31_2pc&combo_strike&!buff.blackout_reinforcement.up
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and equiped.tier(31)>=2 and combo_strike and not buff.blackoutReinforcement.exists() then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Aoe]") return true end
    end

    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=buff.invokers_delight.up&set_bonus.tier31_2pc&(!buff.bonedust_brew.up|active_enemies>10)&(buff.transfer_the_power.stack=10&!talent.crane_vortex|active_enemies>5&talent.crane_vortex&buff.transfer_the_power.stack=10|active_enemies>14|active_enemies>12&!talent.crane_vortex),interrupt=1
    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=buff.invokers_delight.up&set_bonus.tier31_2pc&(!buff.bonedust_brew.up|active_enemies>10)&(buff.transfer_the_power.stack=10&!talent.crane_vortex|active_enemies>5&talent.crane_vortex&buff.transfer_the_power.stack=10|active_enemies>14|active_enemies>12&!talent.crane_vortex),interrupt=1
    if cast.able.fistsOfFury() and ((buff.invokersDelight.exists() and equiped.tier(31)>=2 and (not buff.bonedustBrew.exists() or #enemies.yards0>10) and (buff.transferThePower.stack()==10 and not talent.craneVortex or #enemies.yards0>5 and talent.craneVortex and buff.transferThePower.stack()==10 or #enemies.yards0>14 or #enemies.yards0>12 and not talent.craneVortex),interrupt==1)) then
        if cast.fistsOfFury() then ui.debug("Casting Fists Of Fury [Serenity Aoe]") return true end
    end

    -- Fists Of Fury Cancel
    -- fists_of_fury_cancel,target_if=max:debuff.keefers_skyreach.remains,if=!set_bonus.tier30_2pc&set_bonus.tier31_2pc&(!buff.bonedust_brew.up|active_enemies>10)&(buff.transfer_the_power.stack=10&!talent.crane_vortex|active_enemies>5&talent.crane_vortex&buff.transfer_the_power.stack=10|active_enemies>14|active_enemies>12&!talent.crane_vortex)&!buff.bonedust_brew.up|buff.fury_of_xuen_stacks.stack>90
    -- Fists Of Fury Cancel
    -- fists_of_fury_cancel,target_if=max:debuff.keefers_skyreach.remains,if=!set_bonus.tier30_2pc&set_bonus.tier31_2pc&(!buff.bonedust_brew.up|active_enemies>10)&(buff.transfer_the_power.stack=10&!talent.crane_vortex|active_enemies>5&talent.crane_vortex&buff.transfer_the_power.stack=10|active_enemies>14|active_enemies>12&!talent.crane_vortex)&!buff.bonedust_brew.up|buff.fury_of_xuen_stacks.stack>90
    if cast.able.fistsOfFuryCancel() and ((not equiped.tier(30)>=2 and equiped.tier(31)>=2 and (not buff.bonedustBrew.exists() or #enemies.yards0>10) and (buff.transferThePower.stack()==10 and not talent.craneVortex or #enemies.yards0>5 and talent.craneVortex and buff.transferThePower.stack()==10 or #enemies.yards0>14 or #enemies.yards0>12 and not talent.craneVortex) and not buff.bonedustBrew.exists() or buff.furyOfXuenStacks.stack()>90)) then
        if cast.fistsOfFuryCancel() then ui.debug("Casting Fists Of Fury Cancel [Serenity Aoe]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&!spinning_crane_kick.max&talent.shadowboxing_treads
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&!spinning_crane_kick.max&talent.shadowboxing_treads
    if cast.able.blackoutKick() and combo_strike and not spinning_crane_kick.max and talent.shadowboxingTreads then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity Aoe]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&buff.teachings_of_the_monastery.stack=3&buff.teachings_of_the_monastery.remains<1
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&buff.teachings_of_the_monastery.stack=3&buff.teachings_of_the_monastery.remains<1
    if cast.able.blackoutKick() and combo_strike and buff.teachingsOfTheMonastery.stack()==3 and buff.teachingsOfTheMonastery.remains()<1 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity Aoe]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() and not buff.blackoutReinforcement.exists() then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Aoe]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&set_bonus.tier31_2pc&combo_strike&buff.blackout_reinforcement.up&prev.blackout_kick&buff.dance_of_chiji.up
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&set_bonus.tier31_2pc&combo_strike&buff.blackout_reinforcement.up&prev.blackout_kick&buff.dance_of_chiji.up
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and equiped.tier(31)>=2 and combo_strike and buff.blackoutReinforcement.exists() and prev.blackout_kick and buff.danceOfChiji.exists() then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Aoe]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier31_2pc&combo_strike&buff.blackout_reinforcement.up
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier31_2pc&combo_strike&buff.blackout_reinforcement.up
    if cast.able.blackoutKick() and equiped.tier(31)>=2 and combo_strike and buff.blackoutReinforcement.exists() then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity Aoe]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&set_bonus.tier31_2pc&combo_strike&buff.blackout_reinforcement.up&prev.blackout_kick
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&set_bonus.tier31_2pc&combo_strike&buff.blackout_reinforcement.up&prev.blackout_kick
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and equiped.tier(31)>=2 and combo_strike and buff.blackoutReinforcement.exists() and prev.blackout_kick then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Aoe]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.pressure_point.up&set_bonus.tier30_2pc
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.pressure_point.up&set_bonus.tier30_2pc
    if cast.able.risingSunKick() and buff.pressurePoint.exists() and equiped.tier(30)>=2 then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Serenity Aoe]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier30_2pc
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier30_2pc
    if cast.able.risingSunKick() and equiped.tier(30)>=2 then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Serenity Aoe]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist&buff.call_to_dominance.up&debuff.skyreach_exhaustion.remains>buff.call_to_dominance.remains&active_enemies<10
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist&buff.call_to_dominance.up&debuff.skyreach_exhaustion.remains>buff.call_to_dominance.remains&active_enemies<10
    if cast.able.strikeOfTheWindlord() and talent.thunderfist and buff.callToDominance.exists() and debuff.skyreachExhaustion.remains(PLACEHOLDER)>buff.callToDominance.remains() and #enemies.yards0<10 then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Serenity Aoe]") return true end
    end

    -- Jadefire Stomp
    -- jadefire_stomp,if=debuff.jadefire_brand_damage.remains<2
    if cast.able.jadefireStomp() and debuff.jadefireBrandDamage.remains(PLACEHOLDER)<2 then
        if cast.jadefireStomp() then ui.debug("Casting Jadefire Stomp [Serenity Aoe]") return true end
    end

    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=buff.invokers_delight.up,interrupt=1
    -- TODO: The following conditions were not converted:
    -- buff.invokers_delight.up,interrupt
    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=buff.invokers_delight.up,interrupt=1
    -- TODO: The following conditions were not converted:
    -- buff.invokers_delight.up,interrupt
    if cast.able.fistsOfFury() and ==1 then
        if cast.fistsOfFury() then ui.debug("Casting Fists Of Fury [Serenity Aoe]") return true end
    end

    -- Fists Of Fury Cancel
    -- fists_of_fury_cancel,target_if=max:debuff.keefers_skyreach.remains
    -- Fists Of Fury Cancel
    -- fists_of_fury_cancel,target_if=max:debuff.keefers_skyreach.remains
    if cast.able.fistsOfFuryCancel() then
        if cast.fistsOfFuryCancel() then ui.debug("Casting Fists Of Fury Cancel [Serenity Aoe]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist
    if cast.able.strikeOfTheWindlord() and talent.thunderfist then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Serenity Aoe]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Aoe]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=active_enemies<6&combo_strike&set_bonus.tier30_2pc
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=active_enemies<6&combo_strike&set_bonus.tier30_2pc
    if cast.able.blackoutKick() and #enemies.yards0<6 and combo_strike and equiped.tier(30)>=2 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity Aoe]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&spinning_crane_kick.max
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&spinning_crane_kick.max
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and spinning_crane_kick.max then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Aoe]") return true end
    end

    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!debuff.skyreach_exhaustion.up*20&combo_strike&active_enemies=5
    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!debuff.skyreach_exhaustion.up*20&combo_strike&active_enemies=5
    if cast.able.tigerPalm() and not debuff.skyreachExhaustion.exists(PLACEHOLDER)*20 and combo_strike and #enemies.yards0==5 then
        if cast.tigerPalm() then ui.debug("Casting Tiger Palm [Serenity Aoe]") return true end
    end

    -- Rushing Jade Wind
    -- rushing_jade_wind,if=!buff.rushing_jade_wind.up
    if cast.able.rushingJadeWind() and not buff.rushingJadeWind.exists() then
        if cast.rushingJadeWind() then ui.debug("Casting Rushing Jade Wind [Serenity Aoe]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=talent.shadowboxing_treads&active_enemies>=3&combo_strike
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=talent.shadowboxing_treads&active_enemies>=3&combo_strike
    if cast.able.blackoutKick() and talent.shadowboxingTreads and #enemies.yards0>=3 and combo_strike then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity Aoe]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains
    if cast.able.strikeOfTheWindlord() then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Serenity Aoe]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Aoe]") return true end
    end

    -- Whirling Dragon Punch
    -- whirling_dragon_punch
    if cast.able.whirlingDragonPunch() then
        if cast.whirlingDragonPunch() then ui.debug("Casting Whirling Dragon Punch [Serenity Aoe]") return true end
    end

    -- Rushing Jade Wind
    -- rushing_jade_wind,if=!buff.rushing_jade_wind.up
    if cast.able.rushingJadeWind() and not buff.rushingJadeWind.exists() then
        if cast.rushingJadeWind() then ui.debug("Casting Rushing Jade Wind [Serenity Aoe]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=max:debuff.keefers_skyreach.remains,if=combo_strike
    -- Blackout Kick
    -- blackout_kick,target_if=max:debuff.keefers_skyreach.remains,if=combo_strike
    if cast.able.blackoutKick() and combo_strike then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity Aoe]") return true end
    end

    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=talent.teachings_of_the_monastery&buff.teachings_of_the_monastery.stack<3
    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=talent.teachings_of_the_monastery&buff.teachings_of_the_monastery.stack<3
    if cast.able.tigerPalm() and talent.teachingsOfTheMonastery and buff.teachingsOfTheMonastery.stack()<3 then
        if cast.tigerPalm() then ui.debug("Casting Tiger Palm [Serenity Aoe]") return true end
    end

end -- End Action List - SerenityAoe

-- Action List - SerenityAoelust
actionList.SerenityAoelust = function()
    -- Jadefire Stomp
    -- jadefire_stomp,if=debuff.jadefire_brand_damage.remains<1
    if cast.able.jadefireStomp() and debuff.jadefireBrandDamage.remains(PLACEHOLDER)<1 then
        if cast.jadefireStomp() then ui.debug("Casting Jadefire Stomp [Serenity Aoelust]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,if=set_bonus.tier31_4pc&talent.thunderfist
    if cast.able.strikeOfTheWindlord() and equiped.tier(31)>=4 and talent.thunderfist then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Serenity Aoelust]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&set_bonus.tier31_2pc
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&set_bonus.tier31_2pc
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() and equiped.tier(31)>=2 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Aoelust]") return true end
    end

    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=talent.jade_ignition,interrupt_if=buff.chi_energy.stack=30
    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=talent.jade_ignition,interrupt_if=buff.chi_energy.stack=30
    if cast.able.fistsOfFury() and talent.jadeIgnition,InterruptIf==buff.chiEnergy.stack()==30 then
        if cast.fistsOfFury() then ui.debug("Casting Fists Of Fury [Serenity Aoelust]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&!buff.blackout_reinforcement.up&set_bonus.tier31_2pc&buff.bonedust_brew.up&active_enemies>4
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&!buff.blackout_reinforcement.up&set_bonus.tier31_2pc&buff.bonedust_brew.up&active_enemies>4
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and not buff.blackoutReinforcement.exists() and equiped.tier(31)>=2 and buff.bonedustBrew.exists() and #enemies.yards0>4 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Aoelust]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&set_bonus.tier31_2pc&combo_strike&!buff.blackout_reinforcement.up
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&set_bonus.tier31_2pc&combo_strike&!buff.blackout_reinforcement.up
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and equiped.tier(31)>=2 and combo_strike and not buff.blackoutReinforcement.exists() then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Aoelust]") return true end
    end

    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=buff.invokers_delight.up&set_bonus.tier31_2pc&(active_enemies>5&buff.transfer_the_power.stack>5|active_enemies>6|active_enemies>4&!talent.crane_vortex&buff.transfer_the_power.stack>5),interrupt=1
    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=buff.invokers_delight.up&set_bonus.tier31_2pc&(active_enemies>5&buff.transfer_the_power.stack>5|active_enemies>6|active_enemies>4&!talent.crane_vortex&buff.transfer_the_power.stack>5),interrupt=1
    if cast.able.fistsOfFury() and ((buff.invokersDelight.exists() and equiped.tier(31)>=2 and (#enemies.yards0>5 and buff.transferThePower.stack()>5 or #enemies.yards0>6 or #enemies.yards0>4 and not talent.craneVortex and buff.transferThePower.stack()>5),interrupt==1)) then
        if cast.fistsOfFury() then ui.debug("Casting Fists Of Fury [Serenity Aoelust]") return true end
    end

    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=!set_bonus.tier30_2pc&!buff.invokers_delight.up&set_bonus.tier31_2pc&(!buff.bonedust_brew.up|active_enemies>10)&(buff.transfer_the_power.stack=10&!talent.crane_vortex|active_enemies>5&talent.crane_vortex&buff.transfer_the_power.stack=10|active_enemies>14|active_enemies>12&!talent.crane_vortex),interrupt=1
    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=!set_bonus.tier30_2pc&!buff.invokers_delight.up&set_bonus.tier31_2pc&(!buff.bonedust_brew.up|active_enemies>10)&(buff.transfer_the_power.stack=10&!talent.crane_vortex|active_enemies>5&talent.crane_vortex&buff.transfer_the_power.stack=10|active_enemies>14|active_enemies>12&!talent.crane_vortex),interrupt=1
    if cast.able.fistsOfFury() and ((not equiped.tier(30)>=2 and not buff.invokersDelight.exists() and equiped.tier(31)>=2 and (not buff.bonedustBrew.exists() or #enemies.yards0>10) and (buff.transferThePower.stack()==10 and not talent.craneVortex or #enemies.yards0>5 and talent.craneVortex and buff.transferThePower.stack()==10 or #enemies.yards0>14 or #enemies.yards0>12 and not talent.craneVortex),interrupt==1)) then
        if cast.fistsOfFury() then ui.debug("Casting Fists Of Fury [Serenity Aoelust]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&!spinning_crane_kick.max&talent.shadowboxing_treads
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&!spinning_crane_kick.max&talent.shadowboxing_treads
    if cast.able.blackoutKick() and combo_strike and not spinning_crane_kick.max and talent.shadowboxingTreads then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity Aoelust]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&buff.teachings_of_the_monastery.stack=3&buff.teachings_of_the_monastery.remains<1
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&buff.teachings_of_the_monastery.stack=3&buff.teachings_of_the_monastery.remains<1
    if cast.able.blackoutKick() and combo_strike and buff.teachingsOfTheMonastery.stack()==3 and buff.teachingsOfTheMonastery.remains()<1 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity Aoelust]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() and not buff.blackoutReinforcement.exists() then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Aoelust]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&set_bonus.tier31_2pc&combo_strike&buff.blackout_reinforcement.up&prev.blackout_kick&buff.dance_of_chiji.up
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&set_bonus.tier31_2pc&combo_strike&buff.blackout_reinforcement.up&prev.blackout_kick&buff.dance_of_chiji.up
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and equiped.tier(31)>=2 and combo_strike and buff.blackoutReinforcement.exists() and prev.blackout_kick and buff.danceOfChiji.exists() then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Aoelust]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier31_2pc&combo_strike&buff.blackout_reinforcement.up
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier31_2pc&combo_strike&buff.blackout_reinforcement.up
    if cast.able.blackoutKick() and equiped.tier(31)>=2 and combo_strike and buff.blackoutReinforcement.exists() then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity Aoelust]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&set_bonus.tier31_2pc&combo_strike&!buff.blackout_reinforcement.up
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&set_bonus.tier31_2pc&combo_strike&!buff.blackout_reinforcement.up
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and equiped.tier(31)>=2 and combo_strike and not buff.blackoutReinforcement.exists() then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Aoelust]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=active_enemies<6&combo_strike&set_bonus.tier31_2pc
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=active_enemies<6&combo_strike&set_bonus.tier31_2pc
    if cast.able.blackoutKick() and #enemies.yards0<6 and combo_strike and equiped.tier(31)>=2 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity Aoelust]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.pressure_point.up&set_bonus.tier30_2pc
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=buff.pressure_point.up&set_bonus.tier30_2pc
    if cast.able.risingSunKick() and buff.pressurePoint.exists() and equiped.tier(30)>=2 then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Serenity Aoelust]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier30_2pc
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=set_bonus.tier30_2pc
    if cast.able.risingSunKick() and equiped.tier(30)>=2 then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Serenity Aoelust]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist&buff.call_to_dominance.up&debuff.skyreach_exhaustion.remains>buff.call_to_dominance.remains&active_enemies<10
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist&buff.call_to_dominance.up&debuff.skyreach_exhaustion.remains>buff.call_to_dominance.remains&active_enemies<10
    if cast.able.strikeOfTheWindlord() and talent.thunderfist and buff.callToDominance.exists() and debuff.skyreachExhaustion.remains(PLACEHOLDER)>buff.callToDominance.remains() and #enemies.yards0<10 then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Serenity Aoelust]") return true end
    end

    -- Jadefire Stomp
    -- jadefire_stomp,if=debuff.jadefire_brand_damage.remains<2
    if cast.able.jadefireStomp() and debuff.jadefireBrandDamage.remains(PLACEHOLDER)<2 then
        if cast.jadefireStomp() then ui.debug("Casting Jadefire Stomp [Serenity Aoelust]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist
    if cast.able.strikeOfTheWindlord() and talent.thunderfist then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Serenity Aoelust]") return true end
    end

    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=buff.invokers_delight.up,interrupt=1
    -- TODO: The following conditions were not converted:
    -- buff.invokers_delight.up,interrupt
    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=buff.invokers_delight.up,interrupt=1
    -- TODO: The following conditions were not converted:
    -- buff.invokers_delight.up,interrupt
    if cast.able.fistsOfFury() and ==1 then
        if cast.fistsOfFury() then ui.debug("Casting Fists Of Fury [Serenity Aoelust]") return true end
    end

    -- Fists Of Fury Cancel
    -- fists_of_fury_cancel,target_if=max:debuff.keefers_skyreach.remains
    -- Fists Of Fury Cancel
    -- fists_of_fury_cancel,target_if=max:debuff.keefers_skyreach.remains
    if cast.able.fistsOfFuryCancel() then
        if cast.fistsOfFuryCancel() then ui.debug("Casting Fists Of Fury Cancel [Serenity Aoelust]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Aoelust]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=active_enemies<6&combo_strike&set_bonus.tier30_2pc
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=active_enemies<6&combo_strike&set_bonus.tier30_2pc
    if cast.able.blackoutKick() and #enemies.yards0<6 and combo_strike and equiped.tier(30)>=2 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity Aoelust]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&spinning_crane_kick.max
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&spinning_crane_kick.max
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and spinning_crane_kick.max then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Aoelust]") return true end
    end

    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!debuff.skyreach_exhaustion.up*20&combo_strike&active_enemies=5
    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!debuff.skyreach_exhaustion.up*20&combo_strike&active_enemies=5
    if cast.able.tigerPalm() and not debuff.skyreachExhaustion.exists(PLACEHOLDER)*20 and combo_strike and #enemies.yards0==5 then
        if cast.tigerPalm() then ui.debug("Casting Tiger Palm [Serenity Aoelust]") return true end
    end

    -- Rushing Jade Wind
    -- rushing_jade_wind,if=!buff.rushing_jade_wind.up
    if cast.able.rushingJadeWind() and not buff.rushingJadeWind.exists() then
        if cast.rushingJadeWind() then ui.debug("Casting Rushing Jade Wind [Serenity Aoelust]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=talent.shadowboxing_treads&active_enemies>=3&combo_strike
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=talent.shadowboxing_treads&active_enemies>=3&combo_strike
    if cast.able.blackoutKick() and talent.shadowboxingTreads and #enemies.yards0>=3 and combo_strike then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity Aoelust]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains
    if cast.able.strikeOfTheWindlord() then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Serenity Aoelust]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Aoelust]") return true end
    end

    -- Whirling Dragon Punch
    -- whirling_dragon_punch
    if cast.able.whirlingDragonPunch() then
        if cast.whirlingDragonPunch() then ui.debug("Casting Whirling Dragon Punch [Serenity Aoelust]") return true end
    end

    -- Rushing Jade Wind
    -- rushing_jade_wind,if=!buff.rushing_jade_wind.up
    if cast.able.rushingJadeWind() and not buff.rushingJadeWind.exists() then
        if cast.rushingJadeWind() then ui.debug("Casting Rushing Jade Wind [Serenity Aoelust]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=max:debuff.keefers_skyreach.remains,if=combo_strike
    -- Blackout Kick
    -- blackout_kick,target_if=max:debuff.keefers_skyreach.remains,if=combo_strike
    if cast.able.blackoutKick() and combo_strike then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity Aoelust]") return true end
    end

    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=talent.teachings_of_the_monastery&buff.teachings_of_the_monastery.stack<3
    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=talent.teachings_of_the_monastery&buff.teachings_of_the_monastery.stack<3
    if cast.able.tigerPalm() and talent.teachingsOfTheMonastery and buff.teachingsOfTheMonastery.stack()<3 then
        if cast.tigerPalm() then ui.debug("Casting Tiger Palm [Serenity Aoelust]") return true end
    end

end -- End Action List - SerenityAoelust

-- Action List - SerenityLust
actionList.SerenityLust = function()
    -- Jadefire Stomp
    -- jadefire_stomp,if=debuff.jadefire_brand_damage.remains<1
    if cast.able.jadefireStomp() and debuff.jadefireBrandDamage.remains(PLACEHOLDER)<1 then
        if cast.jadefireStomp() then ui.debug("Casting Jadefire Stomp [Serenity Lust]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&buff.serenity.remains<1.5&combo_strike&!buff.blackout_reinforcement.remains&set_bonus.tier31_2pc
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&buff.serenity.remains<1.5&combo_strike&!buff.blackout_reinforcement.remains&set_bonus.tier31_2pc
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and buff.serenity.remains()<1.5 and combo_strike and not buff.blackoutReinforcement.remains() and equiped.tier(31)>=2 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Lust]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&buff.teachings_of_the_monastery.stack=3&buff.teachings_of_the_monastery.remains<1
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&buff.teachings_of_the_monastery.stack=3&buff.teachings_of_the_monastery.remains<1
    if cast.able.blackoutKick() and combo_strike and buff.teachingsOfTheMonastery.stack()==3 and buff.teachingsOfTheMonastery.remains()<1 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity Lust]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up&set_bonus.tier31_2pc&active_enemies>2
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up&set_bonus.tier31_2pc&active_enemies>2
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() and not buff.blackoutReinforcement.exists() and equiped.tier(31)>=2 and #enemies.yards0>2 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Lust]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist
    -- Strike Of The Windlord
    -- strike_of_the_windlord,target_if=max:debuff.keefers_skyreach.remains,if=talent.thunderfist
    if cast.able.strikeOfTheWindlord() and talent.thunderfist then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Serenity Lust]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&buff.blackout_reinforcement.up&active_enemies>2
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&buff.blackout_reinforcement.up&active_enemies>2
    if cast.able.blackoutKick() and combo_strike and buff.blackoutReinforcement.exists() and #enemies.yards0>2 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity Lust]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,target_if=max:debuff.keefers_skyreach.remains,if=combo_strike&(active_enemies<3|!set_bonus.tier31_2pc)
    -- Rising Sun Kick
    -- rising_sun_kick,target_if=max:debuff.keefers_skyreach.remains,if=combo_strike&(active_enemies<3|!set_bonus.tier31_2pc)
    if cast.able.risingSunKick() and ((combo_strike and (#enemies.yards0<3 or not equiped.tier(31)>=2))) then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Serenity Lust]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&buff.blackout_reinforcement.up&prev.fists_of_fury&talent.shadowboxing_treads&set_bonus.tier31_2pc&!talent.dance_of_chiji
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&buff.blackout_reinforcement.up&prev.fists_of_fury&talent.shadowboxing_treads&set_bonus.tier31_2pc&!talent.dance_of_chiji
    if cast.able.blackoutKick() and combo_strike and buff.blackoutReinforcement.exists() and prev.fists_of_fury and talent.shadowboxingTreads and equiped.tier(31)>=2 and not talent.danceOfChiji then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity Lust]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up&prev.fists_of_fury&debuff.skyreach_exhaustion.remains>55&set_bonus.tier31_2pc
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up&prev.fists_of_fury&debuff.skyreach_exhaustion.remains>55&set_bonus.tier31_2pc
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() and not buff.blackoutReinforcement.exists() and prev.fists_of_fury and debuff.skyreachExhaustion.remains(PLACEHOLDER)>55 and equiped.tier(31)>=2 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Lust]") return true end
    end

    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=buff.invokers_delight.up&(active_enemies<3|!set_bonus.tier31_2pc),interrupt=1
    -- Fists Of Fury
    -- fists_of_fury,target_if=max:debuff.keefers_skyreach.remains,if=buff.invokers_delight.up&(active_enemies<3|!set_bonus.tier31_2pc),interrupt=1
    if cast.able.fistsOfFury() and ((buff.invokersDelight.exists() and (#enemies.yards0<3 or not equiped.tier(31)>=2),interrupt==1)) then
        if cast.fistsOfFury() then ui.debug("Casting Fists Of Fury [Serenity Lust]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&spinning_crane_kick.max&!buff.blackout_reinforcement.up&active_enemies>2&set_bonus.tier31_2pc
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&spinning_crane_kick.max&!buff.blackout_reinforcement.up&active_enemies>2&set_bonus.tier31_2pc
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and spinning_crane_kick.max and not buff.blackoutReinforcement.exists() and #enemies.yards0>2 and equiped.tier(31)>=2 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Lust]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&spinning_crane_kick.max&buff.blackout_reinforcement.up&active_enemies>2&prev.blackout_kick&set_bonus.tier31_2pc
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&spinning_crane_kick.max&buff.blackout_reinforcement.up&active_enemies>2&prev.blackout_kick&set_bonus.tier31_2pc
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and spinning_crane_kick.max and buff.blackoutReinforcement.exists() and #enemies.yards0>2 and prev.blackout_kick and equiped.tier(31)>=2 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Lust]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&spinning_crane_kick.max&buff.bonedust_brew.up&active_enemies>2&set_bonus.tier31_2pc
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&spinning_crane_kick.max&buff.bonedust_brew.up&active_enemies>2&set_bonus.tier31_2pc
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and spinning_crane_kick.max and buff.bonedustBrew.exists() and #enemies.yards0>2 and equiped.tier(31)>=2 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Lust]") return true end
    end

    -- Fists Of Fury Cancel
    -- fists_of_fury_cancel,target_if=max:debuff.keefers_skyreach.remains,if=active_enemies<3|!set_bonus.tier31_2pc
    -- Fists Of Fury Cancel
    -- fists_of_fury_cancel,target_if=max:debuff.keefers_skyreach.remains,if=active_enemies<3|!set_bonus.tier31_2pc
    if cast.able.fistsOfFuryCancel() and ((#enemies.yards0<3 or not equiped.tier(31)>=2)) then
        if cast.fistsOfFuryCancel() then ui.debug("Casting Fists Of Fury Cancel [Serenity Lust]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() and not buff.blackoutReinforcement.exists() then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Lust]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&!buff.blackout_reinforcement.up&buff.bonedust_brew.up&set_bonus.tier31_2pc
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&!buff.blackout_reinforcement.up&buff.bonedust_brew.up&set_bonus.tier31_2pc
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and not buff.blackoutReinforcement.exists() and buff.bonedustBrew.exists() and equiped.tier(31)>=2 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Lust]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike
    if cast.able.blackoutKick() and combo_strike then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity Lust]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Lust]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=max:debuff.keefers_skyreach.remains,if=combo_strike
    -- Blackout Kick
    -- blackout_kick,target_if=max:debuff.keefers_skyreach.remains,if=combo_strike
    if cast.able.blackoutKick() and combo_strike then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity Lust]") return true end
    end

    -- Whirling Dragon Punch
    -- whirling_dragon_punch
    if cast.able.whirlingDragonPunch() then
        if cast.whirlingDragonPunch() then ui.debug("Casting Whirling Dragon Punch [Serenity Lust]") return true end
    end

    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=talent.teachings_of_the_monastery&buff.teachings_of_the_monastery.stack<3
    -- Tiger Palm
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=talent.teachings_of_the_monastery&buff.teachings_of_the_monastery.stack<3
    if cast.able.tigerPalm() and talent.teachingsOfTheMonastery and buff.teachingsOfTheMonastery.stack()<3 then
        if cast.tigerPalm() then ui.debug("Casting Tiger Palm [Serenity Lust]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity Lust]") return true end
    end

end -- End Action List - SerenityLust

-- Action List - SerenitySt
actionList.SerenitySt = function()
    -- Jadefire Stomp
    -- jadefire_stomp,if=debuff.jadefire_brand_damage.remains<2&!debuff.skyreach_exhaustion.remains
    if cast.able.jadefireStomp() and debuff.jadefireBrandDamage.remains(PLACEHOLDER)<2 and not debuff.skyreachExhaustion.remains(PLACEHOLDER) then
        if cast.jadefireStomp() then ui.debug("Casting Jadefire Stomp [Serenity St]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&buff.serenity.remains<1.5&combo_strike&!buff.blackout_reinforcement.remains&set_bonus.tier31_4pc
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&buff.serenity.remains<1.5&combo_strike&!buff.blackout_reinforcement.remains&set_bonus.tier31_4pc
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and buff.serenity.remains()<1.5 and combo_strike and not buff.blackoutReinforcement.remains() and equiped.tier(31)>=4 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity St]") return true end
    end

    -- Tiger Palm
    -- tiger_palm,if=!debuff.skyreach_exhaustion.up*20&combo_strike
    if cast.able.tigerPalm() and not debuff.skyreachExhaustion.exists(PLACEHOLDER)*20 and combo_strike then
        if cast.tigerPalm() then ui.debug("Casting Tiger Palm [Serenity St]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,if=combo_strike&buff.teachings_of_the_monastery.stack=3&buff.teachings_of_the_monastery.remains<1
    if cast.able.blackoutKick() and combo_strike and buff.teachingsOfTheMonastery.stack()==3 and buff.teachingsOfTheMonastery.remains()<1 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity St]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,if=talent.thunderfist&set_bonus.tier31_4pc
    if cast.able.strikeOfTheWindlord() and talent.thunderfist and equiped.tier(31)>=4 then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Serenity St]") return true end
    end

    -- Rising Sun Kick
    -- rising_sun_kick,if=combo_strike
    if cast.able.risingSunKick() and combo_strike then
        if cast.risingSunKick() then ui.debug("Casting Rising Sun Kick [Serenity St]") return true end
    end

    -- Jadefire Stomp
    -- jadefire_stomp,if=debuff.jadefire_brand_damage.remains<2
    if cast.able.jadefireStomp() and debuff.jadefireBrandDamage.remains(PLACEHOLDER)<2 then
        if cast.jadefireStomp() then ui.debug("Casting Jadefire Stomp [Serenity St]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,if=talent.thunderfist&buff.call_to_dominance.up&debuff.skyreach_exhaustion.remains>buff.call_to_dominance.remains
    if cast.able.strikeOfTheWindlord() and talent.thunderfist and buff.callToDominance.exists() and debuff.skyreachExhaustion.remains(PLACEHOLDER)>buff.callToDominance.remains() then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Serenity St]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,if=talent.thunderfist&debuff.skyreach_exhaustion.remains>55
    if cast.able.strikeOfTheWindlord() and talent.thunderfist and debuff.skyreachExhaustion.remains(PLACEHOLDER)>55 then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Serenity St]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,if=combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up&prev.rising_sun_kick&set_bonus.tier31_2pc
    if cast.able.spinningCraneKick() and combo_strike and buff.danceOfChiji.exists() and not buff.blackoutReinforcement.exists() and prev.rising_sun_kick and equiped.tier(31)>=2 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity St]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,if=combo_strike&set_bonus.tier31_2pc&buff.blackout_reinforcement.up&prev.rising_sun_kick
    if cast.able.blackoutKick() and combo_strike and equiped.tier(31)>=2 and buff.blackoutReinforcement.exists() and prev.rising_sun_kick then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity St]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up&prev.fists_of_fury&set_bonus.tier31_2pc
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&buff.dance_of_chiji.up&!buff.blackout_reinforcement.up&prev.fists_of_fury&set_bonus.tier31_2pc
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and buff.danceOfChiji.exists() and not buff.blackoutReinforcement.exists() and prev.fists_of_fury and equiped.tier(31)>=2 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity St]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&buff.blackout_reinforcement.up&prev.fists_of_fury&set_bonus.tier31_2pc
    -- Blackout Kick
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20),if=combo_strike&buff.blackout_reinforcement.up&prev.fists_of_fury&set_bonus.tier31_2pc
    if cast.able.blackoutKick() and combo_strike and buff.blackoutReinforcement.exists() and prev.fists_of_fury and equiped.tier(31)>=2 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity St]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&!buff.blackout_reinforcement.up&set_bonus.tier31_2pc&prev.fists_of_fury
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&!buff.blackout_reinforcement.up&set_bonus.tier31_2pc&prev.fists_of_fury
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and not buff.blackoutReinforcement.exists() and equiped.tier(31)>=2 and prev.fists_of_fury then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity St]") return true end
    end

    -- Fists Of Fury
    -- fists_of_fury,if=buff.invokers_delight.up,interrupt=1
    -- TODO: The following conditions were not converted:
    -- buff.invokers_delight.up,interrupt
    if cast.able.fistsOfFury() and ==1 then
        if cast.fistsOfFury() then ui.debug("Casting Fists Of Fury [Serenity St]") return true end
    end

    -- Fists Of Fury Cancel
    -- fists_of_fury_cancel
    if cast.able.fistsOfFuryCancel() then
        if cast.fistsOfFuryCancel() then ui.debug("Casting Fists Of Fury Cancel [Serenity St]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&!buff.blackout_reinforcement.up&set_bonus.tier31_2pc
    -- Spinning Crane Kick
    -- spinning_crane_kick,target_if=max:target.time_to_die,if=target.time_to_die>duration&combo_strike&!buff.blackout_reinforcement.up&set_bonus.tier31_2pc
    if cast.able.spinningCraneKick() and unit.timeToDie(PLACEHOLDER)>duration and combo_strike and not buff.blackoutReinforcement.exists() and equiped.tier(31)>=2 then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity St]") return true end
    end

    -- Strike Of The Windlord
    -- strike_of_the_windlord,if=debuff.skyreach_exhaustion.remains>buff.call_to_dominance.remains
    if cast.able.strikeOfTheWindlord() and debuff.skyreachExhaustion.remains(PLACEHOLDER)>buff.callToDominance.remains() then
        if cast.strikeOfTheWindlord() then ui.debug("Casting Strike Of The Windlord [Serenity St]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,if=combo_strike&set_bonus.tier30_2pc
    if cast.able.blackoutKick() and combo_strike and equiped.tier(30)>=2 then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity St]") return true end
    end

    -- Blackout Kick
    -- blackout_kick,if=combo_strike
    if cast.able.blackoutKick() and combo_strike then
        if cast.blackoutKick() then ui.debug("Casting Blackout Kick [Serenity St]") return true end
    end

    -- Spinning Crane Kick
    -- spinning_crane_kick,if=combo_strike&buff.dance_of_chiji.up
    if cast.able.spinningCraneKick() and combo_strike and buff.danceOfChiji.exists() then
        if cast.spinningCraneKick() then ui.debug("Casting Spinning Crane Kick [Serenity St]") return true end
    end

    -- Whirling Dragon Punch
    -- whirling_dragon_punch
    if cast.able.whirlingDragonPunch() then
        if cast.whirlingDragonPunch() then ui.debug("Casting Whirling Dragon Punch [Serenity St]") return true end
    end

    -- Tiger Palm
    -- tiger_palm,if=talent.teachings_of_the_monastery&buff.teachings_of_the_monastery.stack<3
    if cast.able.tigerPalm() and talent.teachingsOfTheMonastery and buff.teachingsOfTheMonastery.stack()<3 then
        if cast.tigerPalm() then ui.debug("Casting Tiger Palm [Serenity St]") return true end
    end

end -- End Action List - SerenitySt

-- Action List - Trinkets
actionList.Trinkets = function()
    -- Use Item - Ruby Whelp Shell
    -- use_item,name=ruby_whelp_shell,if=!trinket.1.has_use_buff&!trinket.2.has_use_buff|(trinket.1.has_use_buff|trinket.2.has_use_buff)&cooldown.invoke_xuen_the_white_tiger.remains>30&cooldown.serenity.remains
    -- TODO: The following conditions were not converted:
    -- trinket.1.has_use_buff
    -- trinket.2.has_use_buff
    -- trinket.1.has_use_buff
    -- trinket.2.has_use_buff
    if use.able.rubyWhelpShell() and ((not  and not  or ( or ) and cd.invokeXuenTheWhiteTiger.remains()>30 and cd.serenity.remains())) then
        if use.rubyWhelpShell() then ui.debug("Using Ruby Whelp Shell [Trinkets]") return true end
    end


end -- End Action List - Trinkets

function br.rotations.profile()
    buff = br.player.buff
    casting = br.player.casting
    cd = br.player.cd
    charges = br.player.charges
    chi = br.player.power.chi
    debuff = br.player.debuff
    enemies = br.player.enemies
    energy = br.player.power.energy
    equiped = br.player.equiped
    module = br.player.module
    talent = br.player.talent
    ui = br.player.ui
    unit = br.player.unit
    use = br.player.use
    var = br.player.variable

    -- This is a very rough implementation, review needed and be sure to rename the var used where implemented
    -- target_if=min:debuff.jadefire_brand_damage.remains
    var.minPLACEHOLDER=99999
    var.minPLACEHOLDERUnit="target"
    for i=1,#enemies.yards0 do
        local thisUnit=enemies.yards0[i]
        local thisCondition=debuff.jadefireBrandDamage.remains(thisUnit)
        if thisCondition<var.minPLACEHOLDER then
            var.minPLACEHOLDER=thisCondition
            var.minPLACEHOLDERUnit=thisUnit
        end
    end


    -- This is a very rough implementation, review needed and be sure to rename the var used where implemented
    -- target_if=min:debuff.mark_of_the_crane.remains+(debuff.skyreach_exhaustion.up*20)
    var.minPLACEHOLDER=99999
    var.minPLACEHOLDERUnit="target"
    for i=1,#enemies.yards0 do
        local thisUnit=enemies.yards0[i]
        local thisCondition=debuff.markOfTheCrane.remains(thisUnit)+(debuff.skyreachExhaustion.exists(thisUnit)*20)
        if thisCondition<var.minPLACEHOLDER then
            var.minPLACEHOLDER=thisCondition
            var.minPLACEHOLDERUnit=thisUnit
        end
    end


    -- This is a very rough implementation, review needed and be sure to rename the var used where implemented
    -- target_if=max:debuff.keefers_skyreach.remains
    var.maxPLACEHOLDER=0
    var.maxPLACEHOLDERUnit="target"
    for i=1,#enemies.yards0 do
        local thisUnit=enemies.yards0[i]
        local thisCondition=debuff.keefersSkyreach.remains(thisUnit)
        if thisCondition>var.maxPLACEHOLDER then
            var.maxPLACEHOLDER=thisCondition
            var.maxPLACEHOLDERUnit=thisUnit
        end
    end


    -- This is a very rough implementation, review needed and be sure to rename the var used where implemented
    -- target_if=min:debuff.mark_of_the_crane.remains-spinning_crane_kick.max*(target.time_to_die+debuff.keefers_skyreach.remains*20)
    var.minPLACEHOLDER=99999
    var.minPLACEHOLDERUnit="target"
    for i=1,#enemies.yards0 do
        local thisUnit=enemies.yards0[i]
        local thisCondition=debuff.markOfTheCrane.remains(thisUnit)-spinning_crane_kick.max*(unit.timeToDie(thisUnit)+debuff.keefersSkyreach.remains(thisUnit)*20)
        if thisCondition<var.minPLACEHOLDER then
            var.minPLACEHOLDER=thisCondition
            var.minPLACEHOLDERUnit=thisUnit
        end
    end


    -- This is a very rough implementation, review needed and be sure to rename the var used where implemented
    -- target_if=max:target.health
    var.maxPLACEHOLDER=0
    var.maxPLACEHOLDERUnit="target"
    for i=1,#enemies.yards0 do
        local thisUnit=enemies.yards0[i]
        local thisCondition=unit.health(thisUnit)
        if thisCondition>var.maxPLACEHOLDER then
            var.maxPLACEHOLDER=thisCondition
            var.maxPLACEHOLDERUnit=thisUnit
        end
    end




    -------------------------
    ----- Begin Profile -----
    -------------------------
    -- Profile Stop | Pause
    if not unit.inCombat() and not unit.exists("target") and var.profileStop then
        var.profileStop = false
    elseif (unit.inCombat() and var.profileStop) or ui.pause() or ui.mode.rotation==4 then
        return true
    else
        -----------------------
        ------- Rotation ------
        -----------------------
        if actionList.Extras() then return true end
        if actionList.Defensive() then return true end
        ----------------------------------
        ----- Out of Combat Rotation -----
        ----------------------------------
        if not unit.inCombat() and not (unit.flying() or unit.mounted()) then
            if actionList.Precombat() then return true end
        end
        ------------------------------
        ----- In Combat Rotation -----
        ------------------------------
        if (unit.inCombat() or (not unit.inCombat() and unit.valid("target"))) and not var.profileStop
            and unit.exists("target") and cd.global.remain() == 0
        then
            if actionList.Combat() then return true end
        end
    end
            
end
