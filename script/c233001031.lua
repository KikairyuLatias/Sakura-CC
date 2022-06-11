--Dreamlight Scarlet Flyer
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--opponent can't trigger
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetCondition(s.actcon)
	c:RegisterEffect(e1)
	--freeze zones
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.zcon)
	e4:SetTarget(s.ztg)
	e4:SetOperation(s.zop)
	c:RegisterEffect(e4)
end

--forget about triggering
s.listed_series={0x5f7}
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp)
end
function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return (a and s.cfilter(a,tp)) or (d and s.cfilter(d,tp))
end

--no more zones for you
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x5f7) or c:IsSetCard(0x5f8)
end
function s.zcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function s.ztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE+LOCATION_SZONE,PLAYER_NONE,0) end
	local dis=Duel.SelectDisableField(tp,1,0,LOCATION_ONFIELD,0)
	Duel.Hint(HINT_ZONE,tp,dis)
	e:SetLabel(dis)
end
function s.zop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetOperation(s.disop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	e1:SetLabel(e:GetLabel())
	e:GetHandler():RegisterEffect(e1)
end
function s.disop(e,tp)
	return e:GetLabel()
end