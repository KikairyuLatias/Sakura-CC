-- Dasher the Rocketblossom Deer
-- Scripted with Google Gemini assistance
local s,id=GetID()
function s.initial_effect(c)
	-- During your Main Phase: You can Special Summon 1 “Rocketblossom Deer” monster from your Deck, but it cannot activate its effects this turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,1}) -- Each effect of this card once per turn (index 1)
	e1:SetTarget(s.spsum_tg)
	e1:SetOperation(s.spsum_op)
	c:RegisterEffect(e1)
	-- During your Main Phase: You can banish 1 "Rocketblossom Deer" card from your GY, then target 1 face-up monster your opponent controls; destroy it.
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

-- --- Effect 1: Special Summon from Deck ---

-- Special Summon Filter
function s.spsum_filter(c,e,tp)
	-- "Rocketblossom Deer" monster that can be Special Summoned
	return s.filter_rocketblossom(c) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Special Summon Target
function s.spsum_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Check if there's an available Monster Zone and a "Rocketblossom Deer" monster in Deck
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spsum_filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

-- Special Summon Operation
function s.spsum_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- Select 1 "Rocketblossom Deer" monster from Deck
	local g=Duel.SelectMatchingCard(tp,s.spsum_filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		-- Special Summon the selected monster
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		-- Apply effect: "it cannot activate its effects this turn"
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3302)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end

-- --- Effect 2: Banish from GY & Destroy Opponent's Monster ---

-- Banish Cost
function s.banish_cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Check if there's a "Rocketblossom Deer" card in the GY to banish
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter_rocketblossom,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- Select 1 "Rocketblossom Deer" card from GY to banish (face-up)
	local g=Duel.SelectMatchingCard(tp,s.filter_rocketblossom,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

-- Target filter for opponent's face-up monster
function s.destroy_tg_filter(c)
	return c:IsFaceup() and c:IsMonster()
end

-- Destroy Target
function s.destroy_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- Check if the target is valid (face-up monster controlled by opponent)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.destroy_tg_filter(chkc) end
	-- Check if there's a valid target on the opponent's field
	if chk==0 then return Duel.IsExistingTarget(s.destroy_tg_filter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- Select 1 face-up monster your opponent controls
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