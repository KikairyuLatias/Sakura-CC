--Hazmat Diver Bioterritory
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x84af)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--counter
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
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
	local e3a=e2:Clone()
	e3a:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3a)
	--stat bonus
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetValue(s.val)
	e4:SetTarget(s.hztg)
	c:RegisterEffect(e4)
	--def down
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
	--cannot target
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(LOCATION_MZONE,0)
	e6:SetTarget(s.hztg)
	e6:SetValue(aux.tgoval)
	c:RegisterEffect(e6)
	--Pop on attack
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))
	e7:SetCategory(CATEGORY_DESTROY)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_DAMAGE_CALCULATING)
	e7:SetRange(LOCATION_FZONE)
	e7:SetCountLimit(1,id)
	e7:SetCondition(s.descon)
	e7:SetTarget(s.destg)
	e7:SetOperation(s.desop)
	c:RegisterEffect(e7)
	--leave
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,2))
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e8:SetCode(EVENT_LEAVE_FIELD)
	e8:SetOperation(s.lpop)
	c:RegisterEffect(e8)
end

--counter addition for summoning
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x84af)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x84af,1)
end

--boost
function s.val(e)
	return e:GetHandler():GetCounter(0x84af)*100
end

function s.hztg(e,c)
	return c:IsSetCard(0x4af) and c:IsType(TYPE_RITUAL) and c:IsRace(RACE_BEASTWARRIOR)
end

--pop
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local a,at=Duel.GetAttacker(),Duel.GetAttackTarget()
	if a:IsControler(1-tp) then a,at=at,a end
	return a and at and (a:IsSetCard(0x4af) and a:IsType(TYPE_RITUAL) and a:IsRace(RACE_BEASTWARRIOR)) and a:IsFaceup() and at:IsControler(1-tp)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local a,at=Duel.GetAttacker(),Duel.GetAttackTarget()
	if a:IsControler(1-tp) then a,at=at,a end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,at,1,1-tp,LOCATION_MZONE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local a,at=Duel.GetAttacker(),Duel.GetAttackTarget()
	if a:IsControler(1-tp) then a,at=at,a end
	if at and at:IsRelateToBattle() and at:IsControler(1-tp) then
		Duel.Destroy(at,REASON_EFFECT)
	end
end

--protect this, or lose lp
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetLP(tp,Duel.GetLP(tp)-3000)
end