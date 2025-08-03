-- Emblem of the Rocketblossom Deer
-- Scripted with Google Gemini assistance
local s,id=GetID()
function s.initial_effect(c)
	--Activate (add 1 "Rocketblossom Deer")
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--add 2 "Rocketblossom Deer" monsters with different names
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)

	-- Trigger effect: If this card is banished to activate a "Rocketblossom Deer" monster effect, Special Summon 1 "Rocketblossom Deer" monster from GY/banishment.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2)) -- Description changed to id,2 as requested
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O) -- Optional trigger effect
	e3:SetCode(EVENT_REMOVE) -- Triggers when this card is banished
	e3:SetProperty(EFFECT_FLAG_DELAY) -- Delayable trigger
	e3:SetRange(LOCATION_REMOVED) -- Must be in banished zone to activate
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsMonsterEffect() and s.filter_rocketblossom(re:GetHandler()) end)
	e3:SetTarget(s.spsum_tg)
	e3:SetOperation(s.spsum_op)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH) -- Covered by the card's overall OPT
	c:RegisterEffect(e3)
end

-- --- Helper filter for "Rocketblossom Deer" cards (Archetype code 0x7ae) ---
function s.filter_rocketblossom(c)
	return c:IsSetCard(0x7ae)
end

-- Helper filter for "Rocketblossom Deer" monsters
function s.filter_rocketblossom_monster(c)
	return s.filter_rocketblossom(c) and c:IsMonster()
end

--add stuff (singular)
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter_rocketblossom_monster,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter_rocketblossom_monster,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--add stuff (plural)
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.filter_rocketblossom_monster,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
		return g:GetClassCount(Card.GetCode)>=2
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter_rocketblossom_monster,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)>=2 then
		local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetCode),1,tp,HINTMSG_ATOHAND)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

-- --- Effect 2: Special Summon from GY/Banishment ---

-- Filter for "Rocketblossom Deer" monsters that can be Special Summoned
function s.filter_spsum(c,e,tp)
	return s.filter_rocketblossom_monster(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Target for Special Summon
function s.spsum_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.filter_spsum,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

-- Operation for Special Summon
function s.spsum_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter_spsum,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end