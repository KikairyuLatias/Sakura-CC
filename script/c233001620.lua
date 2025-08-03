--Dream★Star Rider Akane
--Scripted with Google Gemini assistance
local s,id=GetID()
function s.initial_effect(c)

	--pendulum summon
	Pendulum.AddProcedure(c)

	--Pendulum Effect 1: Add/Activate "Dream★Star Performance Arena"
	local pe1=Effect.CreateEffect(c)
	pe1:SetDescription(aux.Stringid(id,0)) -- Add/Activate Arena
	pe1:SetCategory(CATEGORY_TOHAND)
	pe1:SetType(EFFECT_TYPE_IGNITION)
	pe1:SetRange(LOCATION_PZONE)
	pe1:SetCountLimit(1,{id,1}) -- Pendulum effect once
	pe1:SetTarget(s.patg1)
	pe1:SetOperation(s.paop1)
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

	--Monster Effect 1: Special Summon "Dream★Star" Beast
	local me1=Effect.CreateEffect(c)
	me1:SetDescription(aux.Stringid(id,2)) -- SS Beast
	me1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	me1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	me1:SetCode(EVENT_SUMMON_SUCCESS) -- On Normal/Flip Summon
	me1:SetProperty(EFFECT_FLAG_DELAY)
	me1:SetCountLimit(1,{id,3}) -- Monster effect once
	me1:SetTarget(s.ms1tg)
	me1:SetOperation(s.ms1op)
	c:RegisterEffect(me1)
	local me1b=me1:Clone()
	me1b:SetCode(EVENT_SPSUMMON_SUCCESS) -- On Special Summon
	c:RegisterEffect(me1b)
	local me1c=me1:Clone()
	me1c:SetCode(EVENT_FLIP_SUMMON_SUCCESS) -- On Flip Summon
	c:RegisterEffect(me1c)

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

-- --- Pendulum Effect 1: Add/Activate "Dream★Star Performance Arena" ---
function s.thfilter(c,tp)
	return c:IsCode(233001630)
		and (c:IsAbleToHand() or c:GetActivateEffect():IsActivatable(tp,true,true))
end
function s.patg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.paop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	aux.ToHandOrElse(tc,tp,function(c)
					local te=tc:GetActivateEffect()
					return te:IsActivatable(tp,true,true) end,
					function(c)
						Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
						local te=tc:GetActivateEffect()
						local tep=tc:GetControler()
					end,
					aux.Stringid(id,0))
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

-- --- Monster Effect 1: Special Summon "Dream★Star" Beast ---
-- Filter for "Dream★Star" Beast monster from hand or Deck
function s.ms1filter(c,e,tp)
	return s.filter_dreamstar_beast(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Target for Monster Effect 1
function s.ms1tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.ms1filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

-- Operation for Monster Effect 1
function s.ms1op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.ms1filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
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