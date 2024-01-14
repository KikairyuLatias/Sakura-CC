--Vee☆Vee Ribbon Strawberry Blast
local s,id=GetID()
function s.initial_effect(c)
	--Destroy them
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
	--act in hand
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetCondition(s.handcon)
	c:RegisterEffect(e3)
end

--condition
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7d2) and c:IsRace(RACE_BEASTWARRIOR) and c:IsType(TYPE_MONSTER)
end
function s.desfilter(c)
	return c:IsDestructable() and c:IsFaceup()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
	local ct=g:GetClassCount(Card.GetCode)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)
	if ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	if g:GetCount()>0 then
		local ct=Duel.Destroy(g,REASON_EFFECT)
	end
end

--condition 2 (if ichigo exists)
function s.remcon(e)
	return Duel.GetMatchingGroupCount(s.cfilter2,e:GetHandler():GetControler(),LOCATION_MZONE,0,nil)>=1
end
function s.cfilter2(c)
	return c:IsFaceup() and c:IsCode(233000280)
end
function s.banfilter(c)
	return c:IsAbleToRemove()
end
function s.remtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.banfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(s.banfilter,tp,0,LOCATION_ONFIELD,nil)
	local ct=g:GetClassCount(Card.GetCode)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

function s.remop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)
	if ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.banfilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	if g:GetCount()>0 then
		local ct2=Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end

--QP handcon
function s.handcon(e)
	return Duel.IsExistingMatchingCard(s.cfilter2,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end