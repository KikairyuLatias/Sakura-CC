-- Ignition of the Rocketblossom Deer
-- Scripted with Google Gemini assistance
local s,id=GetID()
function s.initial_effect(c)
	-- Effect 1: Send cards from Deck to GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.deck_send_cost)
	e1:SetTarget(s.deck_send_tg)
	e1:SetOperation(s.deck_send_op)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH) -- Common OPT restriction
	c:RegisterEffect(e1)

	-- Effect 2: Banished burn damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE) -- Triggers when this card is banished
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_REMOVED) -- Activates from the banished zone
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsMonsterEffect() and s.filter_rocketblossom(re:GetHandler()) end)
	e2:SetTarget(s.banished_burn_tg)
	e2:SetOperation(s.banished_burn_op)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH) -- Common OPT restriction
	c:RegisterEffect(e2)
end

-- Archetype Filter
function s.filter_rocketblossom(c)
	return c:IsSetCard(0x7ae)
end

function s.filter_rocketblossom_monster(c)
	return s.filter_rocketblossom(c) and c:IsMonster()
end

-- --- Effect 1: Deck Send Logic ---

-- Cost for Deck Send
function s.deck_send_cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter_rocketblossom,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,s.filter_rocketblossom,1,1,REASON_COST+REASON_DISCARD)
end

-- Actual mill
function s.deck_send_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter_rocketblossom,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.deck_send_op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_TOGRAVE)
	if #sg>0 then
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end

-- --- Effect 2: Banished Burn Logic ---

-- Target for Banished Burn
function s.banished_burn_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- Check if there's at least one "Rocketblossom Deer" monster controlled by the player to inflict damage
		local g=Duel.GetMatchingGroup(s.filter_rocketblossom_monster,tp,LOCATION_MZONE,0,nil)
		return g:GetCount() > 0
	end
	Duel.SetTargetPlayer(1-tp) -- Target the opponent
	-- The damage value will be calculated in the operation, so set to 0 here.
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end

-- Operation for Banished Burn
function s.banished_burn_op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter_rocketblossom_monster,tp,LOCATION_MZONE,0,nil)
	-- Get the count of "Rocketblossom Deer" monsters with different names controlled by the player
	local diff_name_count = g:GetClassCount(Card.GetCode)
	
	if diff_name_count > 0 then
		Duel.Damage(1-tp, diff_name_count * 200, REASON_EFFECT)
	end
end