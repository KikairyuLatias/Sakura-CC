--Diving Cervine Romashka
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--opponent plays with hand revealed
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(0,LOCATION_HAND)
	e1:SetCondition(s.handcon)
	c:RegisterEffect(e1)
	--banish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.descon)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end

--condition
s.listed_names={233000828}

function s.scfilter(c)
	return c:IsFaceup() and c:IsCode(233000828)
end
function s.handcon(e)
	return Duel.IsExistingMatchingCard(s.scfilter,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,e:GetHandler())
end

--banish
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return ep~=tp and tc:IsControler(tp) and tc:IsRace(RACE_BEASTWARRIOR) and tc:IsAttribute(ATTRIBUTE_WATER)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(1-tp,3)
		if g:GetCount()>0 then
			Duel.DisableShuffleCheck()
			Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		end
end