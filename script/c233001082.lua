-- Prancer the Rocketblossom Deer
-- scripted with Google Gemini assistance
local s,id=GetID()
function s.initial_effect(c)
	-- During your Main Phase: You can excavate the top 3 cards of your Deck, and if you do, you can add 1 excavated “Rocketblossom Deer” card to your hand, also send the rest to the GY.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id) -- Each effect of this card once per turn
	e1:SetTarget(s.excav_tg)
	e1:SetOperation(s.excav_op)
	c:RegisterEffect(e1)
	-- During your Main Phase: You can banish 1 "Rocketblossom Deer" card from your GY, then target 1 face-up Spell/Trap your opponent controls; destroy it.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1}) -- Each effect of this card once per turn (different index to track separately)
	e2:SetCost(s.banish_cost)
	e2:SetTarget(s.banish_tg)
	e2:SetOperation(s.banish_op)
	c:RegisterEffect(e2)
end

-- --- Effect 1: Excavate and Add ---

-- Filter for "Rocketblossom Deer" cards (Archetype code 0x7ae)
function s.filter_rocketblossom(c)
	return c:IsSetCard(0x7ae)
end

-- Excavate Target
function s.excav_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Check if there are at least 3 cards in the Deck to excavate
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 end
	-- Set operation information for adding to hand and sending to GY
	Duel.SetOperationInfo(0,CATEGORY_TOHAND+CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
end

-- Excavate Operation
function s.excav_op(e,tp,eg,ep,ev,re,r,rp)
	-- Get the top 3 cards of the Deck
	local g=Duel.GetDecktopGroup(tp,3)
	if #g>0 then
		-- Filter for "Rocketblossom Deer" cards among the excavated cards
		local s_g=g:Filter(s.filter_rocketblossom,nil)
		local to_hand_card=nil
		if #s_g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			-- Allow player to choose to add 0 or 1 card to hand
			to_hand_card=s_g:Select(tp,0,1,nil):GetFirst()
		end

		if to_hand_card then
			-- Add the selected card to hand
			Duel.SendtoHand(to_hand_card,nil,REASON_EFFECT)
			g:RemoveCard(to_hand_card) -- Remove it from the group to be sent to GY
		end
		-- Send the remaining excavated cards to the GY
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end

-- --- Effect 2: Banish & Destroy ---

-- Banish Cost
function s.banish_cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Check if there's a "Rocketblossom Deer" card in the GY to banish
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter_rocketblossom,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- Select 1 "Rocketblossom Deer" card from GY to banish (face-up)
	local g=Duel.SelectMatchingCard(tp,s.filter_rocketblossom,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

-- Target filter for opponent's face-up Spell/Trap
function s.banish_tg_filter(c)
	return c:IsFaceup() and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP))
end

-- Banish & Destroy Target
function s.banish_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- Check if the target is valid (face-up Spell/Trap controlled by opponent)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.banish_tg_filter(chkc) end
	-- Check if there's a valid target on the opponent's field
	if chk==0 then return Duel.IsExistingTarget(s.banish_tg_filter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- Select 1 face-up Spell/Trap your opponent controls
	local g=Duel.SelectTarget(tp,s.banish_tg_filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

-- Banish & Destroy Operation
function s.banish_op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	-- If the target is still valid and related to the effect, destroy it
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end