-- ZPD Carrot Pen Recorder
-- Scripted with Google Gemini assistance
local s,id=GetID()
local ZPD_SETCODE = 0x4b0 -- ZPD Setcode

-- Define a custom flag for cards revealed by this effect
local CUSTOM_FLAG_REVEALED_BY_RECORDER = 0x10000000

function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- Effect 1: Negate S/T activation and add to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.negate_condition)
	e1:SetTarget(s.negate_target)
	e1:SetOperation(s.negate_operation)
	e1:SetCountLimit(1, id) -- Once per turn by card ID for this effect
	c:RegisterEffect(e1)

	-- Effect 2: Send revealed card from hand to GY to activate its effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(s.apply_condition)
	e2:SetCost(s.apply_cost)
	e2:SetTarget(s.apply_target) -- Added target for the activated S/T
	e2:SetOperation(s.apply_operation)
	e2:SetCountLimit(1, id+1) -- Separate once per turn for the second effect
	c:RegisterEffect(e2)
end

-- ZPD Monster Control Check
function s.zpd_check(tp)
	return Duel.IsExistingMatchingCard(Card.IsSetCard, tp, LOCATION_MZONE, 0, 1, nil, ZPD_SETCODE)
end

---
--Effect 1: Negate S/T Activation
---
function s.negate_condition(e,tp,eg,ep,ev,re,r,rp)
	if not s.zpd_check(tp) then return false end
	local rc=re:GetHandler()
	return rc:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end

function s.negate_target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
	Duel.SetOperationInfo(0, CATEGORY_ADD, eg, 1, 0, 0)
end

function s.negate_operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if Duel.NegateActivation(ev) then
		if tc:IsRelateToEffect(re) then
			if Duel.SendtoHand(tc, tp, REASON_EFFECT) then
				-- Apply effects to the card in hand
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_PUBLIC) -- Keep revealed in hand
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)

				local e2=e1:Clone()
				e2:SetCode(EFFECT_CANNOT_SET) -- Cannot be Set from hand (e.g., as a monster)
				tc:RegisterEffect(e2)

				local e3=e1:Clone()
				e3:SetCode(EFFECT_CANNOT_SSET) -- Cannot be Set to S/T Zone
				tc:RegisterEffect(e3)

				-- Mark with custom flag for the second effect
				local e4=e1:Clone()
				e4:SetCode(EFFECT_ADD_CARD_CUSTOM_FLAG)
				e4:SetValue(CUSTOM_FLAG_REVEALED_BY_RECORDER)
				tc:RegisterEffect(e4)
			end
		end
	end
end

---
--Effect 2: Activate Revealed Spell/Trap from GY
---
function s.apply_condition(e,tp,eg,ep,ev,re,r,rp)
	if not s.zpd_check(tp) then return false end
	return Duel.IsExistingMatchingCard(s.revealed_st_filter, tp, LOCATION_HAND, 0, 1, nil)
end

-- Filter for Spell/Trap cards in hand that have the custom flag
function s.revealed_st_filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:HasFlag(CUSTOM_FLAG_REVEALED_BY_RECORDER)
end

function s.apply_cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.revealed_st_filter, tp, LOCATION_HAND, 0, 1, nil)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp, s.revealed_st_filter, tp, LOCATION_HAND, 0, 1, 1, nil)
	Duel.SendtoGrave(g, REASON_COST)
	e:SetLabelObject(g:GetFirst()) -- Store the sent card for the operation
end

function s.apply_target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject() -- The card sent as cost
	if chk==0 then
		-- Check if the sent card can activate its original effect from the GY
		-- We'll assume the original card must have an effect that can be activated from GY.
		-- This is a strong assumption and might need adjustment based on specific S/T cards.
		return tc and tc:IsAbleToGraveAsCost() and tc:IsCanBeEffectTarget(e) and tc:IsType(TYPE_SPELL+TYPE_TRAP)
	end
	Duel.SetTargetCard(tc) -- Set the sent card as the target for its own activation
	-- Any categories of the activated S/T should be set here
	-- For generic S/T, it's hard to know the category without parsing its script.
	-- If you want this to work specifically for S/T that e.g., destroy a card, you'd add CATEGORY_DESTROY here.
end

function s.apply_operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject() -- The card sent as cost
	if not tc or tc:IsLocation(LOCATION_HAND) then return end -- Ensure it's in GY after cost

	-- This part attempts to activate the effect of the sent S/T card.
	-- The wording "apply its effect as this card's effect" means ZPD Carrot Pen Recorder is the source.
	-- This means the S/T's own costs and conditions might be bypassed if not included in the 'apply_cost' and 'apply_condition' of Recorder.
	-- Here, we're trying to activate it from the GY.

	-- Get the main effect of the sent Spell/Trap
	local se = tc:GetFirstEffect() -- This gets *an* effect, often the primary one
	if se and se:IsActivatable(tp) and se:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.GetLocationCount(tp, LOCATION_SZONE)>0 then -- Check if activatable and S/T type
		Duel.Hint(HINT_CARD, tp, tc:GetCode())
		-- Perform the activation of the sent card's effect.
		-- The 'e' (ZPD Carrot Pen Recorder's effect) acts as the parent effect,
		-- so 'tc's effect will resolve under the context of 'ZPD Carrot Pen Recorder'.
		Duel.BreakEffect() -- Break current chain to activate new effect
		Duel.ActivateEffect(tp, tc, se)
	else
		-- If the sent card's effect couldn't be activated for some reason
		-- (e.g., no valid targets, specific conditions not met for its own effect, etc.),
		-- you might want to return it to hand or do something else.
		-- For now, it just remains in GY if not activated.
	end
end