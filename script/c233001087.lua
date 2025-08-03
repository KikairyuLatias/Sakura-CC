-- Raika the Honor Rocketblossom Deer
-- Scripted with Google Gemini assistance
local s,id=GetID()
function s.initial_effect(c)
	-- Synchro Summon: 1 Tuner + 1+ non-Tuner "Rocketblossom Deer" monsters
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(s.filter_rocketblossom),1,99)
	c:EnableReviveLimit()

	-- Your opponent cannot activate cards or effects when you Summon a “Rocketblossom Deer” monster.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS+EVENT_SPSUMMON_SUCCESS+EVENT_FLIP_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY) -- Activates after the summon, in the response window
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.summon_block_con)
	e1:SetOperation(s.summon_block_op)
	c:RegisterEffect(e1)

	-- During your Main Phase: You can banish 1 "Rocketblossom Deer" card from your GY; destroy up to 2 cards your opponent controls.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1}) -- Shares "once per turn" with effect 3
	e2:SetCost(s.banish_cost)
	e2:SetTarget(s.destroy_tg)
	e2:SetOperation(s.destroy_op)
	c:RegisterEffect(e2)

	-- If a "Rocketblossom Deer" monster you control, except "Raika the Honor Rocketblossom Deer", is destroyed: You can Special Summon this card that is either banished or from your GY.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,2}) -- Shares "once per turn" with effect 2
	e3:SetCondition(s.spsum_con)
	e3:SetTarget(s.spsum_tg)
	e3:SetOperation(s.spsum_op)
	c:RegisterEffect(e3)
end

-- --- Helper filter for "Rocketblossom Deer" cards (Archetype code 0x7ae) ---
function s.filter_rocketblossom(c)
	return c:IsSetCard(0x7ae)
end

-- --- Effect 1: Opponent Cannot Activate on "Rocketblossom Deer" Summon ---

-- Condition for triggering the anti-activation effect
function s.summon_block_con(e,tp,eg,ep,ev,re,r,rp)
	-- Check if a "Rocketblossom Deer" monster was summoned by the player
	local c=e:GetHandler()
	return eg:IsExists(s.filter_rocketblossom_summoned,1,nil,tp)
end

-- Filter for summoned "Rocketblossom Deer" monsters
function s.filter_rocketblossom_summoned(c,tp)
	return s.filter_rocketblossom(c) and c:IsSummonPlayer(tp)
end

-- Operation to apply the temporary anti-activation effect
function s.summon_block_op(e,tp,eg,ep,ev,re,r,rp)
	local e_temp=Effect.CreateEffect(e:GetHandler())
	e_temp:SetType(EFFECT_TYPE_FIELD)
	e_temp:SetCode(EFFECT_CANNOT_ACTIVATE)
	e_temp:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e_temp:SetTargetRange(0,1) -- Affects opponent (player 1-tp)
	e_temp:SetValue(s.cannot_act_filter) -- Prevents any activation
	-- Resets at the end of the current chain (response window) or end of phase
	e_temp:SetReset(RESET_PHASE+PHASE_END+RESET_CHAIN)
	Duel.RegisterEffect(e_temp,tp)
end

-- Value function for EFFECT_CANNOT_ACTIVATE: prevents all activations
function s.cannot_act_filter(e,re,r,rp)
	return true
end

-- --- Effect 2: Banish from GY & Destroy up to 2 cards opponent controls ---

-- Banish Cost
function s.banish_cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Check if there's a "Rocketblossom Deer" card in the GY to banish
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter_rocketblossom,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- Select 1 "Rocketblossom Deer" card from GY to banish (face-up)
	local g=Duel.SelectMatchingCard(tp,s.filter_rocketblossom,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

-- Destroy Target Filter (any card on opponent's field)
function s.destroy_tg_filter(c)
	return true
end

-- Destroy Target
function s.destroy_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- Check if target is valid
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.destroy_tg_filter(chkc) end
	-- Check if there's at least 1 destroyable card on opponent's field
	if chk==0 then return Duel.IsExistingTarget(s.destroy_tg_filter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- Select up to 2 cards on opponent's field
	local g=Duel.SelectTarget(tp,s.destroy_tg_filter,tp,0,LOCATION_ONFIELD,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0) -- Set operation info for the selected number of cards
end

-- Destroy Operation
function s.destroy_op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

-- --- Effect 3: Special Summon from Banished/GY on Destruction ---

-- Condition for Special Summon
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSetCard(0x7ae) and not c:IsCode(id)
end
function s.spsum_con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.spsum_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spsum_op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end