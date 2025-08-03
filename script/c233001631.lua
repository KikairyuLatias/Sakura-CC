--Dream★Star Accel Emblem
local s,id=GetID()
function s.initial_effect(c)
	--Activate (add 1 "dreamstar Deer")
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--add 2 "Dream★Star" monsters with different names
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)
	--Special Summon 1 "Dream★Star" Synchro Monster from the Extra Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetCost(s.cost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.activate)
	c:RegisterEffect(e3)
end
-- --- Helper filter for "Dream★Star" cards (Archetype code 0x7ae) ---
function s.filter_dreamstar(c)
	return c:IsSetCard(0x5f6)
end

-- Helper filter for "Dream★Star" monsters
function s.filter_dreamstar_monster(c)
	return s.filter_dreamstar(c) and c:IsMonster()
end

--add stuff (singular)
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter_dreamstar_monster,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter_dreamstar_monster,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
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
		local g=Duel.GetMatchingGroup(s.filter_dreamstar_monster,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
		return g:GetClassCount(Card.GetCode)>=2
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter_dreamstar_monster,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)>=2 then
		local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetCode),1,tp,HINTMSG_ATOHAND)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

--synchro time
function s.tdfilter(c)
	return c:IsSetCard(0x5F6) and c:HasLevel() and c:IsFaceup() and c:IsAbleToDeckOrExtraAsCost()
end
function s.spfilter(c,e,tp,lv)
	return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsType(TYPE_SYNCHRO)
		and (c:IsSetCard(0x5F6) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false))
end
function s.rescon(sg,e,tp,mg)
	return #sg==2 and sg:FilterCount(Card.IsType,nil,TYPE_TUNER)==1
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg:GetSum(Card.GetLevel))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(2)
	return true
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_SYNCHRO)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED|LOCATION_GRAVE,0,nil)
	if chk==0 then return #pg<=0 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local dg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TODECK)
	e:SetLabel(dg:GetSum(Card.GetLevel))
	Duel.ConfirmCards(1-tp,dg)
	Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,e:GetLabel())
	if #g>0 and Duel.SpecialSummon(g,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
		g:GetFirst():CompleteProcedure()
	end
end