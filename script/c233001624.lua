--Dream★Star Racer
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--destroy replace
	local pe1=Effect.CreateEffect(c)
	pe1:SetDescription(aux.Stringid(id,0))
	pe1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	pe1:SetCode(EFFECT_DESTROY_REPLACE)
	pe1:SetRange(LOCATION_PZONE)
	pe1:SetCountLimit(1,id)
	pe1:SetTarget(s.reptg)
	pe1:SetValue(s.repval)
	pe1:SetOperation(s.repop)
	c:RegisterEffect(pe1)
	--Special Summon this card
	local pe2=Effect.CreateEffect(c)
	pe2:SetDescription(aux.Stringid(id,1)) -- SS this card
	pe2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	pe2:SetType(EFFECT_TYPE_IGNITION)
	pe2:SetRange(LOCATION_PZONE)
	pe2:SetCountLimit(1,{id,2}) -- Pendulum effect once
	pe2:SetCondition(s.pscon)
	pe2:SetTarget(s.pstg)
	pe2:SetOperation(s.psop)
	c:RegisterEffect(pe2)
	--attack directly
	local me1=Effect.CreateEffect(c)
	me1:SetDescription(aux.Stringid(id,1))
	me1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	me1:SetType(EFFECT_TYPE_IGNITION)
	me1:SetRange(LOCATION_MZONE)
	me1:SetCountLimit(1,{id,1})
	me1:SetCondition(s.dacon)
	me1:SetTarget(s.datg)
	me1:SetOperation(s.daop)
	c:RegisterEffect(me1,false,1)
	--Place this card in the Pendulum Zone (or go to hand)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,{id,4})
	e3:SetCondition(s.pencon)
	e3:SetTarget(s.pentg)
	e3:SetOperation(s.penop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetDescription(aux.Stringid(id,4))
	e4:SetTarget(s.pentg2)
	e4:SetOperation(s.penop2)
	c:RegisterEffect(e4)
end

-- --- Helper filters ---
-- "Dream★Star" SetCode
function s.filter_dreamstar(c)
	return c:IsSetCard(0x5f6)
end
-- "Dream★Star" Beast monster
function s.filter_dreamstar_notbeast(c)
	return s.filter_dreamstar(c) and c:IsMonster() and not c:IsRace(RACE_BEAST)
end

--destroy replace
function s.filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and c:IsSetCard(0x5f6)
		and not c:IsReason(REASON_REPLACE) and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()~=tp))
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.filter,1,c,tp)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repval(e,c)
	return s.filter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT|REASON_REPLACE)
end

-- Special Summon from Pendulum Zone
function s.pscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter_dreamstar_nobeast,tp,LOCATION_MZONE,0,1,nil)
end

function s.pstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.psop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--attack
function s.dacon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP()
end
function s.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0x5f6)
end
function s.datg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter2(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter2,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,nil)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.ftarget)
	e1:SetLabel(g:GetFirst():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.daop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+0x1fe1000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end

-- Add to hand or Place in Pendulum Zone
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r&REASON_SYNCHRO==REASON_SYNCHRO and c:IsFaceup() and c:IsLocation(LOCATION_EXTRA)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end

function s.pentg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.penop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end