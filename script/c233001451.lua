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
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
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
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7dc) and c:IsType(TYPE_MONSTER)
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsAbleToDeck()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
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
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)
	if ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	if g:GetCount()>0 then
		local ct2=Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	end
end

--condition 2
function s.remcon(e)
	return Duel.GetMatchingGroupCount(s.cfilter2,e:GetHandler():GetControler(),LOCATION_MZONE,0,nil)>=1
end
function s.cfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x7dc) and c:IsType(TYPE_RITUAL)
end
function s.banfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
function s.remtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.banfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(s.banfilter,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	--opponent cannot chain (or least they should not be, as this condition is already satisfied)
	Duel.SetChainLimit(s.chainlm)
end

function s.remop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)
	if ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.banfilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	if g:GetCount()>0 then
		local ct2=Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end