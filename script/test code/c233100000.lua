-- Inside function s326.initial_effect(c)
    -- Protection effect
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_BE_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e1:SetCondition(s326.protection_condition)
    e1:SetTargetRange(1, 0)
    e1:SetTarget(s326.cannot_be_targeted_destroyed_effect_target) -- Function to check if target is this card
    c:RegisterEffect(e1)

    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e2:SetCondition(s326.protection_condition)
    e2:SetTargetRange(1, 0)
    e2:SetTarget(s326.cannot_be_targeted_destroyed_effect_target) -- Function to check if target is this card
    c:RegisterEffect(e2)

    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_ACTIVATE) -- This might be a more specific code like EFFECT_FORBIDDEN_ACTIVATE
    e3:SetRange(LOCATION_MZONE)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_SET_AVAILABLE)
    e3:SetCondition(s326.protection_condition)
    e3:SetTargetRange(0, 1) -- Affects opponent
    e3:SetTarget(s326.no_activation_during_battle_phase_target) -- Specific target check for Battle Phase
    c:RegisterEffect(e3)

    -- Quick Effect
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetHintTiming(0, TIMING_MAIN_END + TIMING_BATTLE_START + TIMING_BATTLE_END + TIMING_END_PHASE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCost(s326.detach_cost)
    e4:SetTarget(s326.destroy_target)
    e4:SetOperation(s326.destroy_operation)
    c:RegisterEffect(e4)

    -- End Phase Effect
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e5:SetCode(EVENT_PHASE + PHASE_END)
    e5:SetCountLimit(1)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCondition(s326.reattach_condition)
    e5:SetTarget(s326.reattach_target)
    e5:SetOperation(s326.reattach_operation)
    c:RegisterEffect(e5)
end
-- Protection effect (continuous)
function s326.protection_condition(e)
    local c = e:GetHandler()
    local materials = c:GetOverlayGroup()
    local has_water_material = materials:IsExists(Card.IsAttribute, 1, nil, ATTRIBUTE_WATER)
    local has_dragon_material = materials:IsExists(Card.IsRace, 1, nil, RACE_DRAGON)
    return has_water_material or has_dragon_material
end

-- Cannot be targeted/destroyed
function s326.cannot_be_targeted_destroyed_effect(e, te)
    -- This is a "Target" filter, applied to opponent's effects
    -- Also a "Destroy" filter
    -- This effect would be a continuous effect applied via "AddContinuousEffect"
end

-- Opponent cannot activate during Battle Phase
function s326.no_activation_during_battle_phase_effect(e, rp)
    -- This would be a "MustProhibitActivation" or similar effect
    -- Triggered at the start of the Battle Phase and lasts for its duration
    -- Also a continuous effect
end

-- In initial_effect, add these continuous effects, linked to s326.protection_condition
-- Quick Effect: Detach 1 material to destroy
function s326.destroy_effect(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:CheckRemoveOverlay(tp, 1, REASON_COST) then
        c:RemoveOverlay(tp, 1, REASON_COST)
        local num_monsters = Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0)
        if num_monsters > 0 then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
            local g = Duel.SelectMatchingCard(tp, Card.IsDestructable, tp, 0, LOCATION_ONFIELD, num_monsters, num_monsters, nil)
            if g:GetCount() > 0 then
                Duel.Destroy(g, REASON_EFFECT)
            end
        end
    end
end

-- Register this as a Quick Effect in initial_effect, once per turn
-- e:SetCategory(CATEGORY_DESTROY)
-- e:SetProperty(EFFECT_FLAG_CARD_TARGET) -- If you want to target, otherwise it's mass destruction
-- e:SetCountLimit(1)
-- e:SetCost(s326.detach_cost)
-- e:SetTarget(s326.destroy_target)
-- e:SetOperation(s326.destroy_operation)
-- e:SetLabelObject(e)
-- End Phase effect: Reattach material
function s326.reattach_condition(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:GetOverlayCount() == 0 and Duel.GetTurnPlayer() == tp
end

function s326.reattach_target(e, tp, eg, ep, ev, re, r, rp, chk, chkbyf)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(Card.IsMonster, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, nil)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATTACH)
    Duel.SelectTarget(tp, Card.IsMonster, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, 1, nil)
end

function s326.reattach_operation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and c:IsFaceup() then
        Duel.Overlay(c, Group.FromCards(tc))
    end
end

-- Register this as a trigger effect (EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F) in initial_effect
-- Trigger at EVENT_PHASE + PHASE_END
-- e:SetCondition(s326.reattach_condition)
-- e:SetTarget(s326.reattach_target)
-- e:SetOperation(s326.reattach_operation)
-- e:SetCountLimit(1)