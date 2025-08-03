--Dream★Star Rider Hokulani
local s,id=GetID()
function s.initial_effect(c)

	--pendulum summon
	Pendulum.AddProcedure(c)

	--Pendulum Effect 1: Recover LP from "Dream★Star" battles
	local pe1=Effect.CreateEffect(c)
	pe1:SetDescription(aux.Stringid(id,1))
	pe1:SetCategory(CATEGORY_RECOVER)
	pe1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	pe1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	pe1:SetCode(EVENT_BATTLE_DESTROYING)
	pe1:SetRange(LOCATION_PZONE)
	pe1:SetCountLimit(1,id)
	pe1:SetCondition(s.reccon)
	pe1:SetTarget(s.rectg)
	pe1:SetOperation(s.recop)
	c:RegisterEffect(pe1)
	--Pendulum Effect 2: Special Summon this card
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

	--tohand
	local me1=Effect.CreateEffect(c)
	me1:SetDescription(aux.Stringid(id,2))
	me1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	me1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	me1:SetCode(EVENT_SUMMON_SUCCESS)
	me1:SetProperty(EFFECT_FLAG_DELAY)
	me1:SetCountLimit(1,{id,1})
	me1:SetTarget(s.thtg)
	me1:SetOperation(s.thop)
	c:RegisterEffect(me1)
	local me1a=me1:Clone()
	me1a:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(me1a)
	local me1b=me1:Clone()
	me1b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(me1b)

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
function s.filter_dreamstar_beast(c)
	return s.filter_dreamstar(c) and c:IsRace(RACE_BEAST) and c:IsMonster()
end

--lp restoration
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return eg:GetCount()==1 and tc:IsControler(tp) and tc:IsSetCard(0x5f6)
		and bc:IsReason(REASON_BATTLE)
end

function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	local atk=eg:GetFirst():GetBattleTarget():GetAttack()
	if atk<0 then atk=0 end
	Duel.SetTargetParam(atk)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,atk)
end

function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end

-- --- Pendulum Effect 2: Special Summon this card ---
-- Condition for Pendulum Effect 2: Control a "Dream★Star" Beast monster
function s.pscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter_dreamstar_beast,tp,LOCATION_MZONE,0,1,nil)
end

-- Target for Pendulum Effect 2
function s.pstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

-- Operation for Pendulum Effect 2
function s.psop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

	--searcher
function s.filter(c)
	return c:IsSetCard(0x5f6) and c:IsAbleToHand() and c:IsMonster()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- --- Monster Effect 2: Add to hand or Place in Pendulum Zone ---

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