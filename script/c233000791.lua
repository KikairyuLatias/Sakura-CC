-- Animastral Fading World
-- Scripted with Google Gemini assistance
local s,id=GetID()
function s.initial_effect(c)
		-- Make it activatable as a Field Spell
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- Effect 1 Part 1: "Animastral" monsters you control gain 400 ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atkdef_filter)
	e1:SetValue(400)
	c:RegisterEffect(e1)

	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)

	-- Effect 1 Part 2: Opponent cannot activate cards or effects in response to "Animastral" monster effect activations
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1) -- Applies to the opponent
	e3:SetValue(s.immval)
	c:RegisterEffect(e3)

	-- Effect 2: During your Main Phase: You can Special Summon 1 "Animastral" monster from your hand or GY.
	-- This effect has a conditional activation protection.
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id) -- Once per turn
	e4:SetTarget(s.spsum_tg)
	e4:SetOperation(s.spsum_op)
	c:RegisterEffect(e4)
end

-- Archetype filter
function s.filter_animastral(c)
	return c:IsSetCard(0x7e9)
end

function s.filter_animastral_monster(c)
	return s.filter_animastral(c) and c:IsMonster()
end

-- --- Effect 1 Logic (ATK/DEF Boost & Response Immunity) ---

-- Filter for "Animastral" monsters on the field for ATK/DEF boost
function s.atkdef_filter(e,c)
	return s.filter_animastral_monster(c) and c:IsFaceup()
end

-- Value function for opponent's response immunity to "Animastral" monster effects
function s.immval(e,re,tp)
	-- 're' is the effect attempting to activate
	-- Checks if 're' is a monster effect, its handler is an "Animastral" monster, and it's controlled by 'tp' (our player)
	return re:IsMonsterEffect() and s.filter_animastral_monster(re:GetHandler()) and re:GetOwnerPlayer()==tp
end

-- --- Effect 2 Logic (Special Summon & Conditional Protection) ---

-- Filter for Special Summon target (Animastral monster from hand/GY)
function s.spsum_filter(c,e,tp)
	return s.filter_animastral_monster(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Target for Special Summon
function s.spsum_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spsum_filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)

	-- Store the condition check result in a label for the operation to use
	e:SetLabel(0) -- Default: no protection
	if s.check_extra_deck_animastral_summoned(tp) then
		e:SetLabel(1) -- Mark for protection if an Extra Deck "Animastral" monster is controlled
	end
end

-- Operation for Special Summon
function s.spsum_op(e,tp,eg,ep,ev,re,r,rp)
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

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spsum_filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- Helper: Check if controlling an "Animastral" monster Special Summoned from the Extra Deck
function s.check_extra_deck_animastral_summoned(tp)
	local g=Duel.GetMatchingGroup(s.filter_animastral_monster,tp,LOCATION_MZONE,0,nil)
	return g:IsExists(function(c)
		-- Check if the monster was Special Summoned from the Extra Deck (Fusion, Synchro, Xyz, Link)
		return c:IsType(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK) and c:IsSummonType(SUMMON_TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
	end,1,nil)
end

-- Value function for the temporary chain block effect
function s.cannot_activate_chain_value(e,re,tp)
	-- 're' is the effect attempting to activate by the opponent in response to the current chain
	return re:IsChain() and re:GetOwnerPlayer()==1-tp
end