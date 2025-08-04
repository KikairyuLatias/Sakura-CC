--Diver Dragon Aoi
--Scripted with Google Gemini assistance

local s,id=GetID()
function s.initial_effect(c)
	--send "diver dragon" to GY
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_TOGRAVE)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetCountLimit(1,id)
	e1a:SetTarget(s.tgtg)
	e1a:SetOperation(s.tgop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	local e1c=e1a:Clone()
	e1c:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1c)

	--Fusion Summon 1 "Diver Dragon" Fusion Monster
	local params={aux.FilterBoolFunction(Card.IsSetCard,0x64af),Fusion.OnFieldMat}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e2:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e2:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e2)

	--Synchro Summon
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,2))
	e2a:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2a:SetType(EFFECT_TYPE_QUICK_O)
	e2a:SetCode(EVENT_FREE_CHAIN)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e2a:SetCountLimit(1,{id,1})
	e2a:SetCondition(function(_,tp)return Duel.IsTurnPlayer(1-tp)end)
	e2a:SetTarget(s.sctg)
	e2a:SetOperation(s.scop)
	c:RegisterEffect(e2a)
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

-- to grave
function s.tgfilter(c)
	return c:IsSetCard(0x64af) and not c:IsCode(id) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end