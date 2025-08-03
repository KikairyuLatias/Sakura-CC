-- Rocketblossom Deer Roaring Skies
-- Scripted with Google Gemini assistance
local s,id=GetID()
function s.initial_effect(c)

	--Activate(summon)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH) -- Common OPT restriction for both effects
	e1:SetCondition(s.condition1)
	e1:SetCost(s.negate_cost)
	e1:SetTarget(s.negate_tg)
	e1:SetOperation(s.negate_op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
	--Activate(effect)
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==1-tp end)
	e4:SetCost(s.negate_cost)
	e4:SetTarget(s.negate_tg2)
	e4:SetOperation(s.negate_op2)
	c:RegisterEffect(e4)

	-- Effect 2: Self-Set from banished
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE) -- Triggers when this card is banished
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_REMOVED) -- Activates from the banished zone
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsMonsterEffect() and s.filter_rocketblossom(re:GetHandler()) end)
	e2:SetTarget(s.set_tg)
	e2:SetOperation(s.set_op)
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

-- --- Effect 1: Negation and Burn Logic ---

-- Cost for Negation
function s.negate_cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.filter_rocketblossom_monster,1,false,nil,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,s.filter_rocketblossom_monster,1,1,false,nil,nil)
	Duel.Release(g,REASON_COST)
end

function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain(true)==0
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
function s.negate_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
function s.negate_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
	Duel.BreakEffect()
	Duel.Damage(1-tp,500,REASON_EFFECT)
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
function s.negate_tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
	end
end
function s.negate_op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
		Duel.BreakEffect()
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
end


-- --- Effect 2: Self-Set from Banished Logic ---

	--Activation legality
function s.set_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
	--Set itself back to S/T zone, banish it if it leaves the field
function s.set_op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end