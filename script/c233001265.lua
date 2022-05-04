--Snowstorm Reindeer Hidden Snow Leaf Village
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--snowstorm reindeer
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
	--trigger supports from hand
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x9d0))
	e4:SetTargetRange(LOCATION_HAND,0)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e5)
	--remove
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
	e6:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTargetRange(0,0xff)
	e6:SetValue(LOCATION_REMOVED)
	e6:SetCondition(s.bancon)
	e6:SetTarget(s.rmtg)
	c:RegisterEffect(e6)
end

--boost
function s.tg(e,c)
	return c:IsSetCard(0x9d0) and c:IsType(TYPE_MONSTER)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9d0)
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(s.filter,c:GetControler(),LOCATION_MZONE,0,nil)*200
end

-- banishing
function s.banfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9d0) and c:IsType(TYPE_MONSTER)
end
function s.bancon(e)
	return Duel.IsExistingMatchingCard(s.banfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.rmtg(e,c)
	return c:GetOwner()~=e:GetHandlerPlayer()
end