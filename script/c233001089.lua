-- Scarlet Village of the Rocketblossom Deer
-- Scripted with Google Gemini assistance
local s,id=GetID()
function s.initial_effect(c)
	-- Make it activatable as a Field Spell
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- Continuous Effect: "Rocketblossom Deer" monsters you control gain 300 ATK/DEF
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetRange(LOCATION_FZONE)
	e1a:SetCode(EFFECT_UPDATE_ATTACK)
	e1a:SetTargetRange(LOCATION_MZONE,0) -- Affects monsters in your MZone
	e1a:SetTarget(s.atkdef_tg)
	e1a:SetValue(300)
	c:RegisterEffect(e1a)

	local e1b=e1a:Clone() -- Clone for DEF boost
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1b)

	-- Continuous Effect: Your opponent cannot activate cards or effects in response to their effect activations.
	local e1c=Effect.CreateEffect(c)
	e1c:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1c:SetCode(EVENT_CHAINING)
	e1c:SetRange(LOCATION_FZONE)
	e1c:SetOperation(s.chainop)
	c:RegisterEffect(e1c)

	--added normal summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x7ae))
	c:RegisterEffect(e2)

	-- Ignition Effect: Target 5 of your "Rocketblossom Deer" cards in GY/banishment; shuffle all 5 into Deck, then draw 2.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_FZONE) -- Applies from the Field Spell Zone
	e3:SetCountLimit(1,id) -- Hard once per turn for this specific card name
	e3:SetTarget(s.recycle_tg)
	e3:SetOperation(s.recycle_op)
	c:RegisterEffect(e3)
end

-- --- Helper filter for "Rocketblossom Deer" cards (Archetype code 0x7ae) ---
function s.filter_rocketblossom(c)
	return c:IsSetCard(0x7ae)
end

-- --- Effect 1: ATK/DEF Boost ---
-- Target filter for Rocketblossom Deer monsters you control
function s.atkdef_tg(e,c)
	return s.filter_rocketblossom(c) and c:IsFaceup() and c:IsControler(e:GetOwnerPlayer())
end

-- --- Effect 1: Effect Activation Protection ---
-- Value function for EFFECT_CANNOT_CHAIN: prevents opponent from chaining
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsSetCard(0x7ae) then
		Duel.SetChainLimit(function(e,rp,tp) return tp==rp end)
	end
end

-- --- Effect 2: Additional Normal Summon ---
-- Target filter for Normal Summoning Rocketblossom Deer monsters
function s.sum_tg(e,c)
	-- This effect allows 1 additional Normal Summon for "Rocketblossom Deer" monsters
	return s.filter_rocketblossom(c)
end

-- --- Effect 3: Recycle 5, Draw 2 ---
-- Filter for "Rocketblossom Deer" cards in GY or banished
function s.recycle_filter(c)
	return s.filter_rocketblossom(c) and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
end

-- Recycle Target
function s.recycle_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.recycle_filter(chkc) and chkc:IsControler(tp) end
	-- Must target exactly 5 "Rocketblossom Deer" cards in GY or banished
	if chk==0 then return Duel.IsExistingTarget(s.recycle_filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,5,nil) end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.recycle_filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,5,5,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,5,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end

-- Recycle Operation
function s.recycle_op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	-- Ensure exactly 5 cards are still valid targets and are related to this effect
	g=g:Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()~=5 then return end

	-- Shuffle selected cards into the Deck
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) then
		Duel.ShuffleDeck(tp)
		-- Draw 2 cards
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end