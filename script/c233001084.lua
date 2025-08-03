-- Dancer the Rocketblossom Deer
-- Scripted with Google Gemini assistance
local s,id=GetID()
function s.initial_effect(c)
	-- During your Main Phase: You can Set 1 “Rocketblossom Deer” Spell/Trap directly from your Deck.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,1}) -- Each effect of this card once per turn (index 1)
	e1:SetTarget(s.set_tg)
	e1:SetOperation(s.set_op)
	c:RegisterEffect(e1)

	-- During your Main Phase: You can banish 1 "Rocketblossom Deer" card from your GY, then target 1 face-down card your opponent controls; destroy it.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,2}) -- Each effect of this card once per turn (index 2)
	e2:SetCost(s.banish_cost)
	e2:SetTarget(s.destroy_tg)
	e2:SetOperation(s.destroy_op)
	c:RegisterEffect(e2)
end

-- --- Helper filter for "Rocketblossom Deer" cards (Archetype code 0x7ae) ---
function s.filter_rocketblossom(c)
	return c:IsSetCard(0x7ae)
end

-- --- Effect 1: Set Spell/Trap from Deck ---

-- Filter for "Rocketblossom Deer" Spell/Trap cards in Deck
function s.set_filter(c)
	return s.filter_rocketblossom(c) and c:IsSpellTrap()
end

-- Set Target
function s.set_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.set_filter,tp,LOCATION_DECK,0,1,nil) end
end

-- Set Operation
function s.set_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,s.set_filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		Duel.SSet(tp,tc)
	end
end

-- --- Effect 2: Banish from GY & Destroy Opponent's Face-down Card ---

-- Banish Cost
function s.banish_cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Check if there's a "Rocketblossom Deer" card in the GY to banish
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter_rocketblossom,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- Select 1 "Rocketblossom Deer" card from GY to banish (face-up)
	local g=Duel.SelectMatchingCard(tp,s.filter_rocketblossom,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

-- Target filter for opponent's face-down card
function s.destroy_tg_filter(c)
	return c:IsFacedown()
end

-- Destroy Target
function s.destroy_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- Check if the target is valid (face-down card controlled by opponent)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.destroy_tg_filter(chkc) end
	-- Check if there's a valid target on the opponent's field
	if chk==0 then return Duel.IsExistingTarget(s.destroy_tg_filter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- Select 1 face-down card your opponent controls
	local g=Duel.SelectTarget(tp,s.destroy_tg_filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

-- Destroy Operation
function s.destroy_op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	-- If the target is still valid and related to the effect, destroy it
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end