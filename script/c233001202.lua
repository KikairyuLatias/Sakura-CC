-- Snow Flyer - Dasher
local s,id=GetID()
function s.initial_effect(c)
	--direct attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x14c9))
	c:RegisterEffect(e3)
	--Battle damage is halved if attacking directly
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x14c9))
	e4:SetCondition(s.rdmgcond)
	e4:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e4)
end

--direct shot
function s.rdmgcond(e)
	local tp=e:GetHandlerPlayer()
	local c=Duel.GetAttacker()
	return Duel.GetAttackTarget()==nil and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 --if there are 0 monsters, it's not attacking directly using this effect
end