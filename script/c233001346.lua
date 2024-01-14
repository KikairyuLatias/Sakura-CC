--Blazefur Athlete Opening Ceremony
local s,id=GetID()
function s.initial_effect(c)
	--Ritual Summon
	local e1=Ritual.CreateProc(c,RITPROC_GREATER,aux.FilterBoolFunction(Card.IsCode,233001345),nil,nil,nil,nil,s.mfilter,nil,LOCATION_HAND+LOCATION_DECK)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	--added Normal Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetTarget(s.extg)
	c:RegisterEffect(e2)
	--protection
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(s.limcon)
	e3:SetOperation(s.limop)
	c:RegisterEffect(e1)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
--ritual
function s.mfilter(c)
	return c:IsLocation(LOCATION_HAND+LOCATION_MZONE)
end

--added summon
function s.extg(e,c)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE)
end

--protection
function s.limfilter(c,tp)
	return c:GetSummonPlayer()==tp and c:IsRace(RACE_BEASTWARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.limfilter,1,nil,tp)
end
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(Card.IsSummonPlayer,1,nil,tp) then
		Duel.SetChainLimitTillChainEnd(function(_,rp,tp) return rp==tp end)
	end
end