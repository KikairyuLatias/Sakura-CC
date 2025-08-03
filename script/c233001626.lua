--Dream★Star Reserve Rider Kiryuko
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c,false)
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(s.ffilter),2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	--Special Summon this card from your Pendulum Zone
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCountLimit(1,{id,1})
	e0:SetCondition(s.dreamstarcon)
	e0:SetTarget(s.dreamstartg)
	e0:SetOperation(s.dreamstarop)
	c:RegisterEffect(e0)
	--opponent can't trigger
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetCondition(s.actcon)
	c:RegisterEffect(e1)
	--Disable[iffy]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	--Add 2 "Dream★Star" Pendulum Monsters to the hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_TOEXTRA)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
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

--summon conditioning
function s.ffilter(c,fc,sumtype,tp)
	return c:IsSetCard(0x5f6,fc,sumtype,tp) and c:IsLevelBelow(5)
end
function s.contactfil(tp)
	return Duel.GetReleaseGroup(tp)
end
function s.contactop(g)
	Duel.Release(g,REASON_COST|REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	local c=e:GetHandler()
	return not (c:IsLocation(LOCATION_EXTRA) and c:IsFacedown())
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
	return (a and s.cfilter(a,tp)) or (d and s.cfilter(d,tp))
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

--negate stuff when battling [iffy]
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local p=e:GetHandler():GetControler()
	if d==nil then return end
	local tc=nil
	if a:GetControler()==p and a:IsSetCard(0x5f6) then tc=d
	elseif d:GetControler()==p and d:IsSetCard(0x5f6) then tc=a end
	if not tc then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_LEAVE-RESET_TOGRAVE)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_LEAVE-RESET_TOGRAVE)
	tc:RegisterEffect(e2)
end

--I totally never rip this off Majespecter Orthrus
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0x5F6,lc,sumtype,tp)
end
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x5F6) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
function s.tefilter(c)
	return c:IsSetCard(0x5F6) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Cannot Special Summon from the Extra Deck, except Xyz Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return not c:IsSetCard(0x5F6) and c:IsLocation(LOCATION_EXTRA) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(c,tp,function(_,c) return not c:IsOriginalSetCard(0x5F6) end)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_EXTRA,0,1,2,nil)
	if #g==0 or Duel.SendtoHand(g,tp,REASON_EFFECT)==0 or #g:Match(Card.IsLocation,nil,LOCATION_HAND)==0 then return end
	Duel.ConfirmCards(1-tp,g)
	local dg=Duel.GetMatchingGroup(s.tefilter,tp,LOCATION_DECK,0,nil)
	if #dg==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	local teg=aux.SelectUnselectGroup(dg,e,tp,1,2,aux.dncheck,1,tp,HINTMSG_CONFIRM)
	if #teg>0 then
		Duel.BreakEffect()
		Duel.SendtoExtraP(teg,tp,REASON_EFFECT)
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