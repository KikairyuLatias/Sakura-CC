--A.G.M. Legacy - Eternal Bond
local s,id=GetID()
function s.initial_effect(c)
	--baka you can't have multiples at once!
	c:SetUniqueOnField(1,0,id)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--tribute to gain lp
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.lptg)
	e1:SetOperation(s.lpop)
	c:RegisterEffect(e1)
	--make the opponent suffer
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCost(s.cost2)
	e2:SetTarget(s.lptg2)
	e2:SetOperation(s.lpop2)
	c:RegisterEffect(e2)
	--immune effect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(s.immcon)
	e3:SetTarget(s.etarget)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	--negate for days
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(0,LOCATION_ONFIELD)
	e4:SetCondition(s.lockcon)
	e4:SetTarget(s.locktg)
	e4:SetValue(s.indval)
	c:RegisterEffect(e4)
end

--gain lp
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(0)
	if chk==0 then return true end
end
function s.lpfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7df) and c:GetAttack()>0
end
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then
		if e:GetLabel()~=0 then return false end
		e:SetLabel(0)
		return Duel.CheckReleaseGroupCost(tp,s.lpfilter,1,false,nil,nil) and Duel.GetFlagEffect(tp,id)==0 end
	local sg=Duel.SelectReleaseGroupCost(tp,s.lpfilter,1,1,false,nil,nil)
	local tc=sg:GetFirst()
	local rec=tc:GetAttack()
	Duel.Release(tc,REASON_COST)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(rec)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
end

function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end

--lose lp for opponent
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.lpfilter,1,false,nil,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,s.lpfilter,1,1,false,nil,nil)
	e:SetLabel(g:GetFirst():GetAttack())
	Duel.Release(g,REASON_COST)
end

function s.lptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end

function s.lpop2(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.SetLP(1-tp,Duel.GetLP(1-tp)-e:GetLabel())
end

--draco and sakura protecting the AGM from beyond
function s.cfilter(c)
	return c:IsSetCard(0x7df) and c:IsAttackAbove(3000)
end
function s.immcon(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
function s.etarget(e,c)
	return c:IsSetCard(0x7df)
end
function s.efilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

--sakura's spirit being felt from the great beyond and exerting his power even now
function s.cfilter2(c)
	return c:IsSetCard(0x7df) and c:GetBaseAttack()==3300
end
function s.lockcon(e)
	return Duel.IsExistingMatchingCard(s.cfilter2,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
function s.locktg(e,c)
	return c:IsFaceup()
end
function s.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end