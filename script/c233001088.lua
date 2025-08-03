-- Ruka the Honor Rocketblossom Deer
-- Scripted with Google Gemini assistance
local s,id=GetID()
function s.initial_effect(c)
	-- Synchro Summon: 1 Tuner + 1+ non-Tuner "Rocketblossom Deer" monsters
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(s.filter_rocketblossom),1,99)
	c:EnableReviveLimit()

	-- Continuous Effect: If your "Rocketblossom Deer" monsters attack, your opponent cannot activate cards or effects until the end of the Damage Step.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1) -- Affects opponent (player 1-tp)
	e1:SetCondition(s.atk_pro_con)
	e1:SetValue(s.atk_pro_val) -- Prevents any activation
	c:RegisterEffect(e1)

	-- During your Main Phase: You can banish 1 "Rocketblossom Deer" card from your GY; destroy up to 2 cards your opponent controls, then if you destroyed a monster(s) with this effect, inflict damage to them equal to half the combined ATK of the destroyed monsters.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id) -- Hard once per turn for this specific card name
	e2:SetCost(s.banish_cost)
	e2:SetTarget(s.destroy_burn_tg)
	e2:SetOperation(s.destroy_burn_op)
	c:RegisterEffect(e2)

	-- If a "Rocketblossom Deer" monster you control, except "Ruka the Honor Rocketblossom Deer", is destroyed: You can Special Summon this card that is either banished or from your GY.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_GRAVE+LOCATION_REMOVED) -- This card needs to be in GY/banished for this effect to trigger
	e3:SetCountLimit(1,{id,1}) -- Hard once per turn for this specific card name
	e3:SetCondition(s.spsum_con)
	e3:SetTarget(s.spsum_tg)
	e3:SetOperation(s.spsum_op)
	c:RegisterEffect(e3)
end

-- --- Helper filter for "Rocketblossom Deer" cards (Archetype code 0x7ae) ---
function s.filter_rocketblossom(c)
	return c:IsSetCard(0x7ae)
end

-- --- Effect 1: Attack Protection (Continuous) ---

-- Condition for the continuous "cannot activate" effect
function s.atk_pro_con(e,tp,eg,ep,ev,re,r,rp)
	-- The effect is active if it's the Battle Phase and a "Rocketblossom Deer" monster controlled by the player is attacking.
	local attacker = Duel.GetAttacker()
	return Duel.GetCurrentPhase()==PHASE_BATTLE and attacker and s.filter_rocketblossom(attacker) and attacker:IsControler(tp)
end

-- Value function for EFFECT_CANNOT_ACTIVATE: prevents all activations
function s.atk_pro_val(e,re,r,rp)
	return true
end

-- --- Effect 2: Banish from GY, Destroy & Burn ---

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
function s.destroy_filter(c)
	return true
end

-- Destroy & Burn Target
function s.destroy_burn_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- Check if target is valid
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.destroy_filter(chkc) end
	-- Check if there's at least 1 destroyable card on opponent's field
	if chk==0 then return Duel.IsExistingTarget(s.destroy_filter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- Select up to 2 cards on opponent's field
	local g=Duel.SelectTarget(tp,s.destroy_filter,tp,0,LOCATION_ONFIELD,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0) -- Set operation info for the selected cards to be destroyed
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0) -- Set damage category (damage is conditional)
end

-- Destroy & Burn Operation
function s.destroy_burn_op(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if tg then
		local total_atk=0
		-- Filter for monsters among the targeted cards to calculate combined ATK before destruction
		local monsters_to_destroy = tg:Filter(Card.IsMonster, nil):Filter(Card.IsRelateToEffect,nil,e)
		for tm in aux.Next(monsters_to_destroy) do
			total_atk = total_atk + tm:GetAttack() -- Get current ATK on field
		end
		-- Destroy the selected cards
		Duel.Destroy(tg,REASON_EFFECT)
		-- If monsters were destroyed, inflict damage
		if monsters_to_destroy:GetCount() > 0 then
			Duel.Damage(1-tp, total_atk/2, REASON_EFFECT)
		end
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