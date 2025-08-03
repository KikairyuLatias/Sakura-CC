-- Rocketblossom Deer Bombardment
-- Scripted with Google Gemini assistance
local s,id=GetID()
function s.initial_effect(c)
	-- Make it activatable as a Continuous Spell
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- Effect 1: Continuous burn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS) -- Continuous Spell effect
	e1:SetCode(EVENT_CHAIN_SOLVING) -- Triggers immediately after an effect resolves
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.continuous_burn_con)
	e1:SetOperation(s.continuous_burn_op)
	c:RegisterEffect(e1)

	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1a:SetCode(EVENT_CHAINING)
	e1a:SetRange(LOCATION_SZONE)
	e1a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1a:SetOperation(s.regop)
	c:RegisterEffect(e1a)

	-- Effect 2: Banish and burn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_REMOVE) -- Category for damage and cost (banishing)
	e2:SetType(EFFECT_TYPE_IGNITION) -- Main Phase activation
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(s.banish_burn_cost)
	e2:SetTarget(s.banish_burn_tg)
	e2:SetOperation(s.banish_burn_op)
	e2:SetCountLimit(1,id) -- "You can only use this effect of 'Rocketblossom Deer Bombardment' once per turn."
	c:RegisterEffect(e2)
end

-- Archetype Filter
function s.filter_rocketblossom(c)
	return c:IsSetCard(0x7ae)
end

function s.filter_rocketblossom_monster(c)
	return s.filter_rocketblossom(c) and c:IsMonster()
end

-- --- Effect 1: Continuous Burn Logic ---

-- Condition for Continuous Burn
function s.continuous_burn_con(e,tp,eg,ep,ev,re,r,rp)
	-- Checks if the resolving effect (re) is a monster effect, from the "Rocketblossom Deer" archetype, and activated by the current player.
	return re and re:IsActiveType(TYPE_MONSTER) and s.filter_rocketblossom(re:GetHandler()) and rp==tp
end

-- Operation for Continuous Burn
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET)|RESET_CHAIN,0,1)
end

function s.continuous_burn_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp, 200, REASON_EFFECT)
end

-- --- Effect 2: Banish and Burn Logic ---

-- Filter for banish cost
function s.banish_cost_filter(c)
	return s.filter_rocketblossom_monster(c) and c:IsAbleToRemoveAsCost()
end

-- Cost for Banish and Burn
function s.banish_burn_cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.banish_cost_filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.banish_cost_filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- Store the banished monster's Level in the effect's label for the operation.
	e:SetLabel(g:GetFirst():GetLevel())
	return true
end

-- Target for Banish and Burn
function s.banish_burn_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end -- This effect is always possible if the cost can be paid.
	Duel.SetTargetPlayer(1-tp) -- Target the opponent for damage.
	-- The damage value will be calculated in the operation, so set to 0 here.
	Duel.SetTargetParam(0) 
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end

-- Operation for Banish and Burn
function s.banish_burn_op(e,tp,eg,ep,ev,re,r,rp)
	local level = e:GetLabel() -- Retrieve the Level of the monster banished for cost.
	local damage = level * 300
	Duel.Damage(1-tp, damage, REASON_EFFECT)
end