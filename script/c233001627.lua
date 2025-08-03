--Dream★Star Signer Rider Dreamlight
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Pendulum Summon procedure
	Pendulum.AddProcedure(c,false)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsSetCard,0x5f6),1,99)
	c:EnableReviveLimit()
	--Your opponent cannot activate cards or effects in response to "Dream★Star" monsters being Summoned.
	local pe1=Effect.CreateEffect(c)
	pe1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	pe1:SetCode(EVENT_SUMMON_SUCCESS)
	pe1:SetRange(LOCATION_MZONE)
	pe1:SetOperation(s.limop)
	c:RegisterEffect(pe1)
	local pe1a=pe1:Clone()
	pe1a:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(pe1a)
	local pe1b=pe1:Clone()
	pe1b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(pe1b)
	--Your opponent cannot activate cards or effects in response to the activation of "Dream★Star" monster effects
	local pe2=Effect.CreateEffect(c)
	pe2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	pe2:SetCode(EVENT_CHAINING)
	pe2:SetRange(LOCATION_PZONE)
	pe2:SetOperation(s.chainop)
	c:RegisterEffect(pe2)
	--Special Summon this card from your Pendulum Zone
	local pe3=Effect.CreateEffect(c)
	pe3:SetDescription(aux.Stringid(id,0))
	pe3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	pe3:SetType(EFFECT_TYPE_IGNITION)
	pe3:SetRange(LOCATION_PZONE)
	pe3:SetCountLimit(1,id)
	pe3:SetCondition(s.dreamstarcon)
	pe3:SetTarget(s.dreamstartg)
	pe3:SetOperation(s.dreamstarop)
	c:RegisterEffect(pe3)
	--multi attack
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCountLimit(1,{id,1})
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.mtcon)
	e4:SetOperation(s.mtop)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_MATERIAL_CHECK)
	e5:SetValue(s.valcheck)
	c:RegisterEffect(e5)
	--negate
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,2))
	e7:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e7:SetCode(EVENT_CHAINING)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1,{id,2})
	e7:SetCondition(s.negcon)
	e7:SetTarget(s.negtg)
	e7:SetOperation(s.negop)
	c:RegisterEffect(e7)
	--go to P-Zone
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,3))
	e8:SetCategory(CATEGORY_DESTROY)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_DESTROYED)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCondition(s.pencon)
	e8:SetTarget(s.pentg)
	e8:SetOperation(s.penop)
	c:RegisterEffect(e8)
end

s.listed_series={0x5f6}

--protection
function s.limfilter(c,sp)
	return c:IsSetCard(0x5f6) and c:IsFaceup() and c:IsSummonPlayer(sp)
end
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.limfilter,1,nil,tp) then
		Duel.SetChainLimitTillChainEnd(function(e,_rp,_tp) return _tp==_rp end)
	end
end
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if ep==tp and re:IsMonsterEffect() and rc:IsSetCard(0x5F6) then
		Duel.SetChainLimit(function(_e,_rp,_tp) return _tp==_rp end)
	end
end

--special summon self
function s.dreamstarcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x5F6),tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
function s.dreamstartg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.dreamstarop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--multi-attack
function s.mtfilter(c)
	return c:IsSetCard(0x5f6)
end
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP() and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.ConfirmDecktop(tp,3)
	local g=Duel.GetDecktopGroup(tp,3):Filter(s.mtfilter,nil,e,tp)
	local ct=g:FilterCount(Card.IsType,nil,TYPE_MONSTER)
	Duel.ShuffleDeck(tp)
	if ct>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		e1:SetValue(ct)
		c:RegisterEffect(e1)
	end
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0x5f6) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD&~(RESET_TOFIELD)|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e1)
	end
end

--negation
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsAbleToRemove() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
		Duel.BreakEffect()
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
end

--pendulum scale
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return false end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end