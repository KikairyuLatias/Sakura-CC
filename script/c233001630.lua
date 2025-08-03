--Dream★Star Performance Arena
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x5f6)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--atk boost
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x5f6))
	e1:SetValue(500)
	c:RegisterEffect(e1)
	--def boost
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1a)
	--counter
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.ctcon)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
	--counter
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAIN_SOLVING)
	e5:SetRange(LOCATION_FZONE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(s.ctcon2)
	e5:SetOperation(s.ctop2)
	c:RegisterEffect(e5)
	--opponent can't trigger
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetCode(EFFECT_CANNOT_ACTIVATE)
	e7:SetRange(LOCATION_FZONE)
	e7:SetTargetRange(0,1)
	e7:SetValue(1)
	e7:SetCondition(s.actcon)
	c:RegisterEffect(e7)
	--disable anything in the way of spreading joy to the world
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_ATTACK_ANNOUNCE)
	e8:SetRange(LOCATION_FZONE)
	e8:SetCondition(s.actcon2)
	e8:SetOperation(s.actop)
	c:RegisterEffect(e8)
	--disable the opponent from triggering anything
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetCode(EFFECT_DISABLE)
	e9:SetRange(LOCATION_FZONE)
	e9:SetTargetRange(0,LOCATION_MZONE)
	e9:SetCondition(s.actcon3)
	e9:SetTarget(s.locktg)
	c:RegisterEffect(e9)
	--remove counter
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e10:SetRange(LOCATION_FZONE)
	e10:SetCode(EVENT_PHASE+PHASE_END)
	e10:SetCountLimit(1)
	e10:SetCondition(s.rccon)
	e10:SetOperation(s.rcop)
	c:RegisterEffect(e10)
end

--counter addition for summoning
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(aux.FaceupFilter(Card.IsSetCard,0x5f6),1,nil)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x5f6,1)
end

--counter addition 2
function s.ctcon2(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0x5f6) and re:IsActiveType(TYPE_MONSTER) and not re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.ctop2(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x5f6,1)
end

--forget about triggering
s.listed_series={0x5f6}
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x5f6) and c:IsControler(tp)
end
function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return (a and s.cfilter(a,tp)) or (d and s.cfilter(d,tp)) and e:GetHandler():GetCounter(0x5f6)>=10
end

function s.actcon2(e)
	return e:GetHandler():GetCounter(0x5f6)>=10
end

--negate stuff when battling
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local p=e:GetHandler():GetControler()
	if d==nil then return end
	local tc=nil
	if a:GetControler()==p and a:IsSetCard(0x5f6) and e:GetHandler():GetCounter(0x5f6)>=10 then tc=d
	elseif d:GetControler()==p and d:IsSetCard(0x5f6) and e:GetHandler():GetCounter(0x5f6)>=10 then tc=a end
	if not tc then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+0x17a0000)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+0x17a0000)
	tc:RegisterEffect(e2)
end

--lock down
function s.actcon3(e)
	return e:GetHandler():GetCounter(0x5f6)>=15
end

function s.locktg(e,c)
	return c:IsStatus(STATUS_SUMMON_TURN+STATUS_FLIP_SUMMON_TURN+STATUS_SPSUMMON_TURN)
end

--momentum drop
function s.rccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.rcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local ct=math.min(5,c:GetCounter(0x5f6))
		c:RemoveCounter(tp,0x5f6,ct,REASON_EFFECT)
	end
end