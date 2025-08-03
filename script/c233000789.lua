--Animastral Avatar Kirin
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsSetCard,0x7e9),1,99,s.exmatfilter)
	--Neither monster can be destroyed by battle
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e0:SetTarget(s.indestg)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--tohand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- revive from GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END) -- Triggers when this card is sent to the GY
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,1})
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(function(e) local c=e:GetHandler() return c:GetTurnID()==Duel.GetTurnCount() and not c:IsReason(REASON_RETURN) end)
	e3:SetCost(s.self_revive_cost)
	e3:SetTarget(s.self_revive_tg)
	e3:SetOperation(s.self_revive_op)
	c:RegisterEffect(e3)
end

	--extra tuner
function s.exmatfilter(c,scard,sumtype,tp)
	return c:IsSetCard(0x7e9,scard,sumtype,tp)
end

	--generic Illusion battle thing
function s.indestg(e,c)
	local handler=e:GetHandler()
	return c==handler or c==handler:GetBattleTarget()
end

	--kirin things
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x7e9) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g1=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g2=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.BreakEffect()
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
end

-- --- Effect 3: Self-Revive from GY Logic ---

-- Condition for Self-Revive
function s.self_revive_con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Check if this card was sent to the GY this turn and it's the End Phase
	return c:IsReason(REASON_) and Duel.GetCurrentPhase()==PHASE_END
end

-- Cost for Self-Revive
function s.self_revive_cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Banish 2 other "Animastral" cards from GY
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter_animastral,tp,LOCATION_GRAVE,0,2,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.filter_animastral,tp,LOCATION_GRAVE,0,2,2,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

-- Target for Self-Revive
function s.self_revive_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

-- Operation for Self-Revive
function s.self_revive_op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end