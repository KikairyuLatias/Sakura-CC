--Dreamlight Rage
local s,id=GetID()
function s.initial_effect(c)
	--banish the opponent's stuff
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e1:SetCondition(s.bancon)
	e1:SetTarget(s.bantg)
	e1:SetOperation(s.banop)
	c:RegisterEffect(e1)
	--and this is what happens when I blast everyone with the Spirit World Blaster Cannon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e2:SetCondition(s.bancon2)
	e2:SetTarget(s.bantg2)
	e2:SetOperation(s.banop2)
	c:RegisterEffect(e2)
end

--this banishes the spells/traps only
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.cfilter(c)
	return c:IsFaceup() and (c:IsCode(233001001) or (c:IsType(TYPE_SYNCHRO) and c:ListsCode(233001001)))
end
function s.bancon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	local sg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,#sg,0,0)
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,e:GetHandler())
	if sg:GetCount()>0 then
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end

--this banishes everything and burns
function s.cfilter2(c)
	return c:IsFaceup() and ((c:IsSetCard(0x5f7) or c:IsSetCard(0x5f8)) and c:IsLevelAbove(10) and c:IsType(TYPE_SYNCHRO))
end
function s.bancon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,2,nil)
end
function s.bantg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,#sg,0,0)
end
function s.banop2(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if sg:GetCount()>0 then
	Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
	Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end