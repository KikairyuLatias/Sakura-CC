--Navalfur Fleet Admiral - Huashu
local s,id=GetID()
function s.initial_effect(c)
	--Skill Drain
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e1)
	--act limit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetTargetRange(0,1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.negcon2)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end

--you do not mess with the fleet admiral
function s.condfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7bd) and c:IsLevelAbove(7)
end
function s.negcon(e)
	return Duel.IsExistingMatchingCard(s.condfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.negtg(e,c)
	return c:IsType(TYPE_EFFECT) or bit.band(c:GetOriginalType(),TYPE_EFFECT)==TYPE_EFFECT
end

--seriously, don't mess with the navalfurs
function s.negcon2(e)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer() and Duel.IsExistingMatchingCard(s.condfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end