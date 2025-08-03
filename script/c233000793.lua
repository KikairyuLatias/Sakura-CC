-- Animastral Spirit Force
-- Scripted with Google Gemini assistance
local s,id=GetID()
function s.initial_effect(c)

	-- Effect: Target and banish opponent's GY cards face-down
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE) -- Activates from hand or when set
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id) -- "You can only activate 1 'Animastral Spirit Force' per turn."
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
end

-- Archetype filter
function s.filter_animastral(c)
	return c:IsSetCard(0x7e9)
end

function s.filter_animastral_monster(c)
	return s.filter_animastral(c) and c:IsMonster()
end

-- --- Banishment Logic ---

-- Helper: Get count of "Animastral" monsters you control with different names
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

-- Filter for banish target (any card in opponent's GY)
function s.banish_filter(c)
	return true
end

-- Target for Banish effect
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local max_target=s.get_animastral_diff_name_count(tp)
	if max_target==0 then return false end -- Cannot activate if no Animastral monsters with different names

	-- Check if the target is in the opponent's GY
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) end

	if chk==0 then
		-- Check if there's at least 1 banishable target in opponent's GY
		return Duel.IsExistingTarget(s.banish_filter,tp,0,LOCATION_GRAVE,1,max_target,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- Select target cards from opponent's GY, up to max_target
	local g=Duel.SelectTarget(tp,s.banish_filter,tp,0,LOCATION_GRAVE,1,max_target,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)

	-- Store the condition check result for conditional activation protection in a label
	e:SetLabel(0) -- Default: no protection
	if s.check_extra_deck_animastral_summoned(tp) then
		e:SetLabel(1) -- Mark for protection if an Extra Deck "Animastral" monster is controlled
	end
end

-- Operation for Banish effect
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- If the condition for activation protection was met, apply a temporary chain block
	if e:GetLabel()==1 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1) -- Affects opponent
		e1:SetValue(s.cannot_activate_chain_value)
		e1:SetReset(RESET_CHAIN) -- This effect resets at the end of the current chain
		Duel.RegisterEffect(e1,tp)
	end

	local g=Duel.GetTargetCards(e)
	if g:GetCount()>0 then
		-- Banish selected cards face-down
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end

-- --- Conditional Activation Protection Logic ---

-- Helper: Check if controlling an "Animastral" monster Special Summoned from the Extra Deck
function s.check_extra_deck_animastral_summoned(tp)
	local g=Duel.GetMatchingGroup(s.filter_animastral_monster,tp,LOCATION_MZONE,0,nil)
	return g:IsExists(function(c)
		-- Check if the monster was Special Summoned from the Extra Deck (Fusion, Synchro, Xyz, Link)
		return c:IsType(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK) and c:IsSummonType(SUMMON_TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
	end,1,nil)
end

-- Value function for the temporary chain block