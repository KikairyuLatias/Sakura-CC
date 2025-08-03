--Animastral Avatar Tortoise
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x7e9),4,2,nil,nil,Xyz.InfiniteMats)
	c:EnableReviveLimit()
	--Neither monster can be destroyed by battle
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e0:SetTarget(s.indestg)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	-- protection
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(Cost.Detach(1,1,nil))
	e3:SetOperation(s.immop)
	c:RegisterEffect(e3)
	-- revive from GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END) -- Triggers when this card is sent to the GY
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,1})
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(function(e) local c=e:GetHandler() return c:GetTurnID()==Duel.GetTurnCount() and not c:IsReason(REASON_RETURN) end)
	e3:SetCost(s.self_revive_cost)
	e3:SetTarget(s.self_revive_tg)
	e3:SetOperation(s.self_revive_op)
	c:RegisterEffect(e3)
end

	-- generic Illusion battle thing
function s.indestg(e,c)
	local handler=e:GetHandler()
	return c==handler or c==handler:GetBattleTarget()
end

	-- Quick Effect (Effect Immunity) Cost and Operation

function s.immop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.IsAnimastral, tp, LOCATION_MZONE, 0, nil)
	if #g>0 then
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetValue(s.immv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
function s.immv(e,re)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER) and re:GetOwnerPlayer()~=e:GetOwnerPlayer()
end

-- --- Effect 3: Self-Revive from GY Logic ---

-- Condition for Self-Revive
function s.self_revive_con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Check if this card was sent to the GY this turn and it's the End Phase
	return c:IsReason(REASON_) and Duel.GetCurrentPhase()==PHASE_END
end

-- Cost for Self-Revive
function s.self_revive_cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Banish 2 other "Animastral" cards from GY
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter_animastral,tp,LOCATION_GRAVE,0,2,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.filter_animastral,tp,LOCATION_GRAVE,0,2,2,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

-- Target for Self-Revive
function s.self_revive_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

-- Operation for Self-Revive
function s.self_revive_op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end