--Bunny Reflection Mirror
local s,id=GetID()
function s.initial_effect(c)
	 --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==1-tp end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--act in hand
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e4:SetCondition(s.actcon)
	c:RegisterEffect(e4)
end

--trigger
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7d0)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	return g:GetClassCount(Card.GetCode)>=2
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SendtoDeck(eg,nil,2,REASON_EFFECT)
	end
end

--handtrap cond
function s.actfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7d0) and c:IsType(TYPE_SYNCHRO)
end
function s.actcon(e)
	return Duel.IsExistingMatchingCard(s.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end