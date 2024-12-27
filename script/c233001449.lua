--Resistance★Dragon Imperial Battlefield
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atk boost
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.tg)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	--def boost
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--actlimit
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_FZONE)
	e5:SetOperation(s.chainop)
	c:RegisterEffect(e5)
	--extra summon
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e6:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x7dc))
	c:RegisterEffect(e6)
end

--power up
function s.tg(e,c)
	return c:IsSetCard(0x7dc)
end

--no battle damage
function s.efilter(e,c)
	return c:IsSetCard(0x7dc)
end

--time to take back our world
function s.cfilterkk(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x7dc) and c:IsControler(tp)
end
function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return (a and s.cfilterkk(a,tp)) or (d and s.cfilterkk(d,tp))
end

--forget about triggering
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if ep==tp and re:IsMonsterEffect() and rc:IsSetCard(0x7dc) then
		Duel.SetChainLimit(function(_e,_rp,_tp) return _tp==_rp end)
	end
end