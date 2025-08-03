-- Independence Blossom, the Stars and Stripes Hazmat Equine
-- Scripted with Google Gemini assistance

local s,id=GetID()
function s.initial_effect(c)
	-- Synchro Summon Condition: 1+ Tuners + 1 non-Tuner monster
	c:EnableReviveLimit()
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)

	-- While you control this Synchro Summoned card, your opponent cannot target or destroy other monsters you control with card effects.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CODE_CANNOT_BE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(cm.protcon)
	e1:SetTarget(cm.protfilter)
	e1:SetValue(aux.tgovalfromfield)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CODE_CANNOT_BE_DESTROYED)
	c:RegisterEffect(e2)

	-- (Quick Effect): You can excavate the top 3 cards of your Deck; shuffle them back in, also destroy cards your opponent controls up to the number of monsters excavated with different names.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(m,0))
	e3:SetCategory(CATEGORY_DECKDES+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(cm.excavatetg)
	e3:SetOperation(cm.excavateop)
	c:RegisterEffect(e3)

	-- During the End Phase, if this card is in the GY because it was sent there this turn: You can banish 2 other monsters; Special Summon it.
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(m,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCondition(cm.regravcon)
	e4:SetTarget(cm.regravtg)
	e4:SetOperation(cm.regravop)
	c:RegisterEffect(e4)
end

-- Protection Effect
function cm.protcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsSummonType(SUMMONTYPE_SYNCHRO)
end

function cm.protfilter(e,c)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(e:GetOwnerPlayer()) and c~=e:GetHandler()
end

-- Excavate & Destroy Effect
function cm.excavatetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0)>=3 end
	Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, tp, 3)
	Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 0, 1-tp, 0)
end

function cm.excavateop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(tp, 3)
	if #g==0 then return end

	local unique_monsters_count=0
	local names={}
	for tc in aux.Next(g) do
		if tc:IsMonster() and not names[tc:GetCode()] then
			names[tc:GetCode()]=true
			unique_monsters_count=unique_monsters_count+1
		end
	end

	Duel.SendtoDeck(g, nil, 2, REASON_EFFECT) -- Shuffle back
	Duel.ShuffleDeck(tp)

	if unique_monsters_count>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local tg=Duel.SelectTarget(tp, 0, tp, 0, LOCATION_ONFIELD, 1, unique_monsters_count, nil)
		if #tg>0 then
			Duel.Destroy(tg, REASON_EFFECT)
		end
	end
end

-- End Phase Special Summon
function cm.regravcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_GRAVE) and Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_END
end

function cm.regravtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,tp,POS_FACEUP_ATTACK,1)
			and Duel.IsExistingMatchingCard(Card.IsMonster, tp, LOCATION_GRAVE, 0, 2, c)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
	Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 0, 0, 0)
end

function cm.regravop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp, LOCATION_MZONE)<=0 then return end
	if not c:IsCanBeSpecialSummoned(e,0,tp,tp,POS_FACEUP_ATTACK,1) then return end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp, Card.IsMonster, tp, LOCATION_GRAVE, 0, 2, 2, c)
	if #g<2 then return end

	Duel.Remove(g, POS_FACEUP_BANISHED, REASON_EFFECT)
	Duel.SpecialSummon(c,0,tp,tp,POS_FACEUP_ATTACK,1)
end
