-- Rocketblossom Deer Conscription
local s,id=GetID()
function s.initial_effect(c)
	-- Effect 1: Special Summon 1 "Rocketblossom Deer" monster from hand/Deck/banishment.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE) -- Assuming it's a Normal Spell Card that activates from the hand
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.spsum_tg)
	e1:SetOperation(s.spsum_op)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH) -- "You can only use 1 effect of 'Rocketblossom Deer Conscription' per turn, and only once that turn."
	c:RegisterEffect(e1)

	-- Effect 2: Control Transfer when banished
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE) -- Triggers when this card is banished
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_REMOVED) -- Activates from the banished zone
	e2:SetCondition(s.control_con)
	e2:SetTarget(s.control_tg)
	e2:SetOperation(s.control_op)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH) -- Common OPT restriction
	c:RegisterEffect(e2)
end

-- Archetype Filter
function s.filter_rocketblossom(c)
	-- Added nil check
	if not c then return false end
	return c:IsSetCard(0x7ae)
end

function s.filter_rocketblossom_monster(c)
	-- Added nil check
	if not c then return false end
	return s.filter_rocketblossom(c) and c:IsMonster()
end

-- --- Effect 1: Special Summon Logic ---

-- Filter for "Rocketblossom Deer" monsters that can be Special Summoned
function s.spsum_filter(c,e,tp)
	return s.filter_rocketblossom_monster(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Target function for the Special Summon effect
function s.spsum_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetMatchingGroup(s.spsum_filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_REMOVED,0,nil,e,tp)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and mg:GetCount()>0
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_REMOVED)
end

-- Operation function for the Special Summon effect
function s.spsum_op(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spsum_filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.splimit(e,c)
	return not c:IsSetCard(0x7ae)
end

-- --- Effect 2: Control Transfer Logic (when banished) ---

-- Condition function for the Control Transfer effect
function s.control_con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- This card must be banished to activate a "Rocketblossom Deer" monster effect
	return c:IsReason(REASON_REMOVE) and re:IsActiveType(TYPE_MONSTER) and s.filter_rocketblossom(re:GetHandler())
end

-- Target function for the Control Transfer effect
function s.control_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:IsControler(1-tp) end
	if chk==0 then
		return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end

-- Operation function for the Control Transfer effect
function s.control_op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsControler(1-tp) and tc:IsRelateToEffect(e) then
		-- Apply control change: until the end of the next turn
		-- The `RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END` with `RESETS_STANDARD` attempts to last for two turns.
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_CONTROL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1-tp) -- Transfer control to the opponent
		tc:RegisterEffect(e1)
	end
end