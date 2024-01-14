--ＺＰＤ逮捕状
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