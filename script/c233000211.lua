-- Psychic Dragon Takeshi
local s,id=GetID()
function s.initial_effect(c)
	--opt, cannot die by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(s.valcon)
	c:RegisterEffect(e1)
	--cannot be battle target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.atktg)
	c:RegisterEffect(e2)
end

--protect
function s.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end

--attack target
function s.atktg(e,c)
	return c:IsFaceup() and c~=e:GetHandler() and c:IsSetCard(0x5f1)
end
