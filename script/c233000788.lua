-- Animastral Avatar Dragon
-- Scripted with Google Gemini assistance
local s,id=GetID()
function s.initial_effect(c)
	-- Semi-Nomi monster: Must first be Special Summoned by its own procedure.
	c:EnableReviveLimit()
	--Fusion Materials: 3 "Animastral" monsters with different names
	Fusion.AddProcMixN(c,true,true,s.ffilter,3)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)

	--Neither monster can be destroyed by battle
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e0:SetTarget(s.indestg)
	e0:SetValue(1)
	c:RegisterEffect(e0)

	-- Effect 2: Quick Effect Banish + Burn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O) -- Quick Effect
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.banish_burn_tg)
	e2:SetOperation(s.banish_burn_op)
	c:RegisterEffect(e2)

	-- Effect 3: Self-Revive from GY
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

-- Archetype filter
function s.filter_animastral(c)
	return c:IsSetCard(0x7e9)
end

function s.filter_animastral_monster(c)
	return s.filter_animastral(c) and c:IsMonster()
end

-- --- Summoning Condition Logic ---
function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsSetCard(0x7e9,fc,sumtype,tp) and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,sumtype,tp),fc,sumtype,tp))
end
function s.fusfilter(c,code,fc,sumtype,tp)
	return c:IsSummonCode(fc,sumtype,tp,code) and not c:IsHasEffect(511002961)
end
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
function s.matfil(c,tp)
	return c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_MZONE) or aux.SpElimFilter(c,false,true)) and c:IsType(TYPE_MONSTER)
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(s.matfil,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,tp)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST+REASON_MATERIAL)
end

	--generic Illusion battle thing
function s.indestg(e,c)
	local handler=e:GetHandler()
	return c==handler or c==handler:GetBattleTarget()
end

-- --- Effect 2: Quick Effect Banish + Burn Logic ---

-- Helper: Get count of "Animastral" monsters with different names controlled by player
function s.get_animastral_diff_name_count(tp)
	local g=Duel.GetMatchingGroup(s.filter_animastral_monster,tp,LOCATION_MZONE,0,nil)
	local t={}
	local count=0
	for tc in aux.Next(g) do
		local code=tc:GetCode()
		if not t[code] then
			t[code]=true
			count=count+1
		end
	end
	return count
end

-- Target for Banish + Burn
function s.banish_burn_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local count=s.get_animastral_diff_name_count(tp)
	if count==0 then return false end -- Cannot activate if no Animastral monsters with different names
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,count,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*200)
end

-- Operation for Banish + Burn
function s.banish_burn_op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if g:GetCount()>0 then
		local bc = Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT) -- Banish cards face-down
		if bc>0 then
			Duel.Damage(1-tp,bc*200,REASON_EFFECT)
		end
	end
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