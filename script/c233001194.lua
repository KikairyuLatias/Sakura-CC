--Snowstorm Rabbit Skycross
local s,id=GetID()
function s.initial_effect(c)
	--Negate and summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e3)
	--act in hand
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e4:SetCondition(s.actcon)
	c:RegisterEffect(e4)
	--to hand
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCondition(s.thcon)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	e5:SetCountLimit(1,{id,1})
	c:RegisterEffect(e5)
end

--negation
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain(true)==0 and eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x7e7),tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,#eg,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsSummonPlayer,nil,1-tp)
	Duel.NegateSummon(g)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end

--handtrap cond
function s.actfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7e7) and c:IsType(TYPE_SYNCHRO)
end
function s.actcon(e)
	return Duel.IsExistingMatchingCard(s.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

--retrieval from gy to hand
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_END and Duel.IsTurnPlayer(tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end