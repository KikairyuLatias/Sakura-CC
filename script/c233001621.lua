--Dream★Star Rider Luna
local s,id=GetID()
function s.initial_effect(c)

	--pendulum summon
	Pendulum.AddProcedure(c)

	--Pendulum Effect 1: Shuffle and draw from "Dream★Star" cards
	local pe1=Effect.CreateEffect(c)
	pe1:SetDescription(aux.Stringid(id,0))
	pe1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	pe1:SetType(EFFECT_TYPE_IGNITION)
	pe1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	pe1:SetRange(LOCATION_PZONE)
	pe1:SetCountLimit(1,{id,1})
	pe1:SetTarget(s.drtg)
	pe1:SetOperation(s.drop)
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

--return
function s.filter(c)
	return c:IsSetCard(0x5f6) and c:IsAbleToDeck()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,5,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,5,5,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,5,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=5 then return end
	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==5 then
		Duel.BreakEffect()
		Duel.Draw(tp,2,REASON_EFFECT)
	end
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
	return c:IsSetCard(0x5f6) and c:IsAbleToHand() and c:IsSpellTrap()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
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