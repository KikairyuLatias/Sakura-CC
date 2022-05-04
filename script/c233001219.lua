--馴鹿霊天使
local s,id=GetID()
function s.initial_effect(c)
	--activation
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetOperation(s.activate)
	c:RegisterEffect(e0)
	--indes (general Flyer)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x4c9))
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--indes (Snow Flyer)
	local e2=e1:Clone()
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x14c9))
	c:RegisterEffect(e2)
	--indes (Flash Flyer)
	local e3=e1:Clone()
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x24c9))
	c:RegisterEffect(e2)
	--atk/def down (field)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetValue(s.val)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
	--atk/def down (graveyard)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTargetRange(0,LOCATION_MZONE)
	e6:SetValue(s.val2)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e7)
end

--control
function s.filter(c)
	return c:IsFaceup() and (c:IsSetCard(0x4c9) or c:IsSetCard(0x14c9) or c:IsSetCard(0x24c9)) and c:IsType(TYPE_MONSTER)
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(s.filter,c:GetControler(),0,LOCATION_MZONE,nil)*-200
end

--grave
function s.filter2(c)
	return c:IsFaceup() and (c:IsSetCard(0x4c9) or c:IsSetCard(0x14c9) or c:IsSetCard(0x24c9)) and c:IsType(TYPE_MONSTER)
end
function s.val2(e,c)
	return Duel.GetMatchingGroupCount(s.filter2,c:GetControler(),0,LOCATION_GRAVE,nil)*-200
end