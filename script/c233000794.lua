--Animastral Judgment
local s,id=GetID()
function s.initial_effect(c)
	--Activate(summon)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH) -- Common OPT restriction for both effects
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negate_tg)
	e1:SetOperation(s.negate_op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
	--Activate(effect)
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.negcon2)
	e4:SetTarget(s.negate_tg2)
	e4:SetOperation(s.negate_op2)
	c:RegisterEffect(e4)   
	--act in hand
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e5:SetCondition(s.actcon)
	c:RegisterEffect(e5)
end

--negation

function s.neg_con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain(true)==0
end

function s.negate_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end
function s.negate_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end

function s.negcon2(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
		return ep~=tp and Duel.IsChainNegatable(ev) and ph>PHASE_MAIN1 and ph<PHASE_MAIN2
			and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x7e9),tp,LOCATION_MZONE,0,2,nil)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain(true)==0 and eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x7e9),tp,LOCATION_MZONE,0,2,nil)
end
function s.negate_tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(Card.IsControler,nil,1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,g,#g,0,0)
	local g2=g:Filter(Card.IsPreviousLocation,nil,LOCATION_EXTRA)
	if #g2>0 then
		Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g2,#g2,0,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.negate_op2(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsSummonPlayer,nil,1-tp)
	Duel.NegateSummon(g)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end

--handtrap cond
function s.actfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7e9) and c:IsSummonLocation(LOCATION_EXTRA) and c:IsFaceup()
end
function s.actcon(e)
	return Duel.IsExistingMatchingCard(s.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
