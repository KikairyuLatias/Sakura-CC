--Sakura, Imperial Radiant Dragon Reindeer of Cherry Storm
local s,id=GetID()
function s.initial_effect(c)
	--protection while ritual summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(s.unaffectcon)
	e1:SetValue(s.unaffectval)
	c:RegisterEffect(e1)
	--cannot release
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2:SetCondition(s.unaffectcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e3)
	--no opponent
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetTargetRange(0,1)
	e4:SetValue(s.aclimit2)
	c:RegisterEffect(e4)
	--banish
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,0))
	e7:SetCategory(CATEGORY_REMOVE)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1)
	e7:SetTarget(s.kamuitg)
	e7:SetOperation(s.kamui)
	c:RegisterEffect(e7)
end

--I transcend your common sense (when ritual summoned)
function s.unaffectcon(e,tp,eg,ep,ev,re,r,rp,chk)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.unaffectval(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

--anyone who plays maxx "c", handtraps or whatever deserves a slap in the face
function s.aclimit2(e,re,tp)
	local rc=re:GetHandler()
	return rc and rc:IsLocation(LOCATION_HAND+LOCATION_GRAVE)
end

--gonna punish some bad kids who abuse their hand and grave privileges
function s.kamuitg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE,1,1) end 
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.kamui(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE,1,1,nil)
	Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	Duel.BreakEffect()
	local lp=Duel.GetLP(1-tp)
	Duel.SetLP(1-tp,lp-800)
end