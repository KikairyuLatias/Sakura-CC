--Dream★Star Show Rider Liko
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Pendulum Summon procedure
	Pendulum.AddProcedure(c,false)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsSetCard,0x5f6),1,99)
	c:EnableReviveLimit()
	--Your opponent cannot activate cards or effects in response to the activation of "Dream★Star" backrow activation or effects
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
	--tohand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--go to P-Zone
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,2))
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
	if ep==tp and rc:IsSetCard(0x5F6) and (re:IsSpellTrapEffect() or re:IsSpellTrap()) then
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

	--kirin things
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x5f6) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g1=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g2=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.BreakEffect()
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