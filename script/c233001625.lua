--Dream★Star Huaxing
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--destroy replace
	local me1=Effect.CreateEffect(c)
	me1:SetDescription(aux.Stringid(id,0))
	me1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	me1:SetCode(EFFECT_DESTROY_REPLACE)
	me1:SetRange(LOCATION_PZONE)
	me1:SetCountLimit(1,id)
	me1:SetTarget(s.reptg)
	me1:SetValue(s.repval)
	me1:SetOperation(s.repop)
	c:RegisterEffect(me1)
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
	--double
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetCondition(s.dcon)
	e1:SetOperation(s.dop)
	c:RegisterEffect(e1)
	--spsummon
	local me2=Effect.CreateEffect(c)
	me2:SetDescription(aux.Stringid(id,2)) -- Using ID 3 for this effect's description (as per previous suggestion)
	me2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	me2:SetType(EFFECT_TYPE_IGNITION)
	me2:SetRange(LOCATION_HAND) -- This is the crucial part: it activates from the hand
	me2:SetCountLimit(1,{id,4}) -- Once per turn limit for this specific effect (using ID 4 for the count limit)
	me2:SetCost(s.cost)
	me2:SetTarget(s.tg)
	me2:SetOperation(s.op)
	c:RegisterEffect(me2)
	--Place this card in the Pendulum Zone (or go to hand)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,{id,3})
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

--functions
function s.dcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return ep~=tp and tc:IsSetCard(0x5f6) and tc:GetBattleTarget()~=nil
end
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(ep,ev*2)
end

--ss condition
function s.costfilter(c)
	return c:IsSetCard(0x5f6) and c:IsFaceup() and c:IsLocation(LOCATION_EXTRA)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
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