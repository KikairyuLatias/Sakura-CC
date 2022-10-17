--Resistance★Dragon Pacific Storm
local s,id=GetID()
function s.initial_effect(c)
	--Shuffle into the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.desttg)
	e1:SetOperation(s.destop)
	c:RegisterEffect(e1)
	--Banish them face-down
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.remcon)
	e2:SetTarget(s.remtg)
	e2:SetOperation(s.remop)
	c:RegisterEffect(e2)
end

--condition
function s.destfilter(c)
	return c:IsSetCard(0x7dc) and c:IsType(TYPE_MONSTER)
end
function s.desttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.destfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=Duel.GetMatchingGroup(s.destfilter,tp,LOCATION_MZONE,0,nil):GetClassCount(Card.GetCode)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local tg=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,#tg,1,0,0)
	--if you got a ritual monster (and still want to just shuffle into deck)
	if Duel.IsExistingMatchingCard(s.lmfilter,tp,LOCATION_MZONE,0,1,nil) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.lmfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7dc) and c:IsType(TYPE_RITUAL+TYPE_MONSTER)
end
function s.chainlm(e,rp,tp)
	return tp==rp
end
function s.destop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then Duel.SendtoDeck(g,nil,2,REASON_EFFECT) end
end

--condition 2
function s.remcon(e)
	return Duel.GetMatchingGroupCount(s.cfilter,e:GetHandler():GetControler(),LOCATION_MZONE,0,nil)>=1
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7dc) and c:IsType(TYPE_RITUAL)
end
function s.remtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.destfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=Duel.GetMatchingGroup(s.destfilter,tp,LOCATION_MZONE,0,nil):GetClassCount(Card.GetCode)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tg=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,#tg,1,0,0)
	--opponent cannot chain (or least they should not be, as this condition is already satisfied)
	Duel.SetChainLimit(s.chainlm)
end

function s.remop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT) end
end