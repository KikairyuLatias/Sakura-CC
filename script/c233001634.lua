--Dream★Star Lineup
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x5f6)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Dream★Star Spell/Trap Cards you control cannot be destroyed by your opponent's card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetCondition(s.indocon)
	e1:SetTarget(function(e,c) return c:IsSetCard(0x5f6) and c:IsType(TYPE_SPELL+TYPE_TRAP) end)
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	--Place up to 2 "Dream★Star" Pendulum Monsters with different Scales from Deck or face-up Extra Deck in Pendulum Zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0)) -- Reverted to original description ID
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN) -- Re-added: Important for effect to appear
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1}) -- Correct: Independent count limit
	e2:SetTarget(s.pltg)
	e2:SetOperation(s.plop)
	c:RegisterEffect(e2)
	--moving
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1)) -- Reverted to original description ID
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,2}) -- Correct: Independent count limit
	e3:SetTarget(s.seqtg)
	e3:SetOperation(s.seqop)
	c:RegisterEffect(e3)
end

function s.dreamstar_filter(c)
	return c:IsFaceup() and c:IsSetCard(0x5f6) and c:IsType(TYPE_MONSTER)
end

--protection for backrow
function s.indocon(e)
	return Duel.IsExistingMatchingCard(s.dreamstar_filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

--placing
function s.plfilter(c)
	return c:IsSetCard(0x5f6) and c:IsType(TYPE_PENDULUM) and (c:IsLocation(LOCATION_EXTRA|LOCATION_DECK) or c:IsFaceup())
end

-- Target check for the Pendulum Zone placement effect
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_PZONE)>0
	and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK,0,1,nil) end
end

-- Operation for the Pendulum Zone placement effect
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_PZONE)
	if ft<=0 then return end

	-- Get all valid "Dream★Star" Pendulum Monsters from Hand, Deck, or face-up Extra Deck
	local g=Duel.GetMatchingGroup(s.plfilter,tp,LOCATION_DECK,0,nil)
	if #g==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	-- CHANGED: Now selects up to 2 cards with different Pendulum Scales using aux.dpcheck
	local sg=aux.SelectUnselectGroup(g,e,tp,1,math.min(ft,2),aux.dpcheck(Card.GetScale),1,tp,HINTMSG_TOFIELD)
	if #sg==0 then return end

	for tc in aux.Next(sg) do
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end

--moving
function s.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.seqfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.dreamstar_filter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	Duel.SelectTarget(tp,s.seqfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.seqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or not (Duel.GetLocationCount(tp,LOCATION_MZONE)>0)then return end
	local seq=tc:GetSequence()
	Duel.Hint(HINT_SELECTMSG,tp,571)
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	local nseq=math.log(s,2)
	Duel.MoveSequence(tc,nseq)
end