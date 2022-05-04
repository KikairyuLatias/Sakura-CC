--Flyer Victory Mountain - Lanakila
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--snow flyer
		--atk up
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetRange(LOCATION_FZONE)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetTarget(s.tg)
		e2:SetValue(s.val)
		c:RegisterEffect(e2)
		--def up (snow flyer)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		e3:SetRange(LOCATION_FZONE)
		e3:SetTargetRange(LOCATION_MZONE,0)
		e3:SetValue(s.val)
		e3:SetTarget(s.tg)
		c:RegisterEffect(e3)
	--special summoning
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.target)
	e4:SetOperation(s.activate)
	c:RegisterEffect(e4)
	--remove
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
	e5:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(0,0xff)
	e5:SetValue(LOCATION_REMOVED)
	e5:SetTarget(s.rmtg)
	e5:SetCondition(s.bancon)
	c:RegisterEffect(e5)
end

--boost
function s.tg(e,c)
	return c:IsSetCard(0x4c9) or c:IsCode(233001215) and c:IsType(TYPE_MONSTER)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x4c9)
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(s.filter,c:GetControler(),LOCATION_MZONE,0,nil)*200
end

--ss condition
function s.filter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x4c9) or c:IsCode(233001215)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- banishing
function s.banfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x4c9) or c:IsCode(233001215) and c:IsType(TYPE_MONSTER)
end
function s.bancon(e)
	return Duel.IsExistingMatchingCard(s.banfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.rmtg(e,c)
	return c:GetOwner()~=e:GetHandlerPlayer()
end