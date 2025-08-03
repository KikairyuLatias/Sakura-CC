--Diver Dragon Lieutenant Kiku
--Scripted with Google Gemini assistance

local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--special summon up to 2 level 4 or lower "diver dragon" from hand or GY
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY)
	e2a:SetCode(EVENT_SUMMON_SUCCESS)
	e2a:SetCountLimit(1,{id,2})
	e2a:SetTarget(s.sptg2)
	e2a:SetOperation(s.spop2)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2b)
	local e2c=e2a:Clone()
	e2c:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2c)

	--Fusion Summon 1 "Diver Dragon" Fusion Monster
	local params={function(c) return c:IsSetCard(0x64af) end}
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e3:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e3:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e3)

	--Synchro Summon
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,3))
	e3a:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3a:SetType(EFFECT_TYPE_QUICK_O)
	e3a:SetCode(EVENT_FREE_CHAIN)
	e3a:SetRange(LOCATION_MZONE)
	e3a:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e3a:SetCountLimit(1,{id,1})
	e3a:SetCondition(function(_,tp)return Duel.IsTurnPlayer(1-tp)end)
	e3a:SetTarget(s.sctg)
	e3a:SetOperation(s.scop)
	c:RegisterEffect(e3a)
end

--synchro summon condition
function s.scfilter(c)
	return c:IsSetCard(0x64af) and c:IsSynchroSummonable(nil)
end
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.scfilter,tp,LOCATION_EXTRA,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SynchroSummon(tp,sg:GetFirst(),nil)
	end
end
-- Helper: Check if a card is a "Diver Dragon" monster
function s.IsDiverDragon(c)
	return c:IsSetCard(0x64af)
end

--self special summon
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x64af)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return #g>0 and g:FilterCount(s.cfilter,nil)==#g
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end

-- other special summon
function s.filter(c,e,tp)
	return c:IsSetCard(0x64af) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return false end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return false end
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil,e,tp)
		return g:GetClassCount(Card.GetCode)>=2
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end