--Diving Equus Scarvasiliok
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	 Pendulum.AddProcedure(c)
	--cannot special summon monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.statcon)
	e2:SetTarget(s.efilter)
	e2:SetValue(700)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end

--sp limit
function s.splimit(e,c)
	return not (c:IsRace(RACE_BEASTWARRIOR) and c:IsAttribute(ATTRIBUTE_WATER))
end

s.listed_names={233000827}

--stat boost
function s.scfilter(c)
	return c:IsFaceup() and c:IsCode(233000827)
end
function s.statcon(e)
	return Duel.IsExistingMatchingCard(s.scfilter,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,e:GetHandler())
end

function s.efilter(e,c)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsAttribute(ATTRIBUTE_WATER)
end