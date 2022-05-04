-- Snow Flyer - Donner
local s,id=GetID()
function s.initial_effect(c)
	--pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.target)
	c:RegisterEffect(e2)
end
function s.target(e,c)
	return c:IsSetCard(0x14c9)
end