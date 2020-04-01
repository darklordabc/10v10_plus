function OnSpellStart( event )
    local caster = event.caster
    local abilityname = event.Ability
    --local psets = Patreons:GetPlayerSettings(caster:GetPlayerID())
    --if psets.level > 0 then
        local pa1 = caster:AddAbility(abilityname)
        pa1:SetLevel(1)
        pa1:CastAbility()
        Timers:CreateTimer(1, function()
            caster:RemoveAbility(abilityname)
        end)
    --else
    --    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(caster:GetPlayerID()), "display_custom_error", { message = "#nopatreonerror" })
    --end
end

function OnSpellStartBundle( event )
    local caster = event.caster
    local ability = event.ability
    local item1 = event.Item1
    local item2 = event.Item2
    local item3 = event.Item3
    local item4 = event.Item4
    if caster:IsRealHero() then
        local psets = Patreons:GetPlayerSettings(caster:GetPlayerID())
        if psets.level > 0 then
            ability:RemoveSelf()
            caster:AddItemByName(item1)
            caster:AddItemByName(item2)
            caster:AddItemByName(item3)
            caster:AddItemByName(item4)
        else
            CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(caster:GetPlayerID()), "display_custom_error", { message = "#nopatreonerror" })
        end
    end
end
_G.alertsKickForPlayer = {}
function OnSpellStartBanHammer( event )
    local target = event.target
    local caster = event.caster
    local ability = event.ability
    if caster:IsRealHero() then
        local psets = Patreons:GetPlayerSettings(caster:GetPlayerID())
        if psets.level > 1 then
            if target:IsRealHero() then
                local ptsets = Patreons:GetPlayerSettings(target:GetPlayerID())
                if ptsets.level == 0 then
                    local uniqueKey = caster:GetEntityIndex() .. "_" .. target:GetEntityIndex()
                    if not _G.alertsKickForPlayer[uniqueKey] then
                        _G.alertsKickForPlayer[uniqueKey] = true

                        GameRules:SendCustomMessage("#alert_for_ban_message_1", caster:GetPlayerID(), 0)
                        GameRules:SendCustomMessage("#alert_for_ban_message_2", target:GetPlayerID(), 0)

                        local all_heroes = HeroList:GetAllHeroes()
                        for _, hero in pairs(all_heroes) do
                            if hero:IsRealHero() and hero:IsControllableByAnyPlayer() then
                                EmitSoundOn("Hero_Chen.HandOfGodHealHero" , hero)
                            end
                        end

                        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(target:GetPlayerID()), "display_custom_error", { message = "#alertforban" })
                        ability:ApplyDataDrivenModifier(caster, target, "modifier_alert_before_kick", { duration = 30 })
                    else
                        if target:HasModifier("modifier_alert_before_kick") then
                            CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(caster:GetPlayerID()), "display_custom_error", { message = "#playerhasalertforban" })
                        else
                            if ability:GetCurrentCharges() > 1 then
                                ability:SetCurrentCharges(ability:GetCurrentCharges()-1)
                            else
                                ability:RemoveSelf()
                            end
                            _G.kicks[target:GetPlayerID()+1] = true
                            CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(target:GetPlayerID()), "setkicks", {kicks = _G.kicks})
                        end
                    end
                else
                    CustomGameEventManager:Send_ServerToPlayer(caster:GetPlayerID(), "display_custom_error", { message = "#cannotkickotherpatreons" })
                end
            else
                CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(caster:GetPlayerID()), "display_custom_error", { message = "#nopatreonerror2" })
            end
        end
    end
end

function OnSpellStartCustomMango( event )
    local ability = event.ability
    local caster = event.caster

    local particleAgi = ParticleManager:CreateParticle("particles/items3_fx/mango_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(particleAgi, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)

    caster:GiveMana(event.mana)
    if ability:GetCurrentCharges() > 1 then
        ability:SetCurrentCharges(ability:GetCurrentCharges()-1)
    else
        ability:RemoveSelf()
    end
end