-- Majespecter Unicorn - Black Kirin
-- Scripted with Google Gemini assistance
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--pendulum summon
	 Pendulum.AddProcedure(c)
	-- Cannot be targeted by opponent's card effects
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e0:SetValue(aux.opponent_field_target)
	c:RegisterEffect(e0)
	-- Cannot be destroyed by opponent's card effects
	local e0a=e0:Clone()
	e0a:SetCode(EFFECT_IMMUNE_EFFECT)
	e0a:SetValue(aux.opponent_effect)
	c:RegisterEffect(e0a)
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
	-- Return own monster to hand, shuffle opponent's card to Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1}) -- Once per turn, distinct from SS effect
	e2:SetTarget(s.retarget)
	e2:SetOperation(s.reoperation)
	c:RegisterEffect(e2)
end

--special
function s.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0xd0)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- Quick Effect: Return and Shuffle (e2)
function s.retgfilter1(c)
	-- Target 1 "Majespecter" monster you control
	return c:IsFaceup() and c:IsSetCard(0xd0)
end

function s.retgfilter2(c)
	-- Target 1 face-up card your opponent controls
	return c:IsFaceup()
end

function s.retarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		-- Check the first target: your Majespecter monster
		if chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.retgfilter1(chkc) then return true end
		-- Check the second target: opponent's face-up card
		if chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and s.retgfilter2(chkc) then return true end
		return false
	end

	if chk==0 then
		-- Must be able to target both your Majespecter and opponent's face-up card
		return Duel.IsExistingTarget(s.retgfilter1,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingTarget(s.retgfilter2,tp,0,LOCATION_ONFIELD,1,nil)
	end

	-- Select your Majespecter monster
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g1=Duel.SelectTarget(tp,s.retgfilter1,tp,LOCATION_MZONE,0,1,1,nil)

	-- Select opponent's face-up card
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g2=Duel.SelectTarget(tp,s.retgfilter2,tp,0,LOCATION_ONFIELD,1,1,nil)

	g1:Merge(g2) -- Merge selected targets into a single group for operation
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,1,0,0) -- Category set for both actions
end

function s.reoperation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc1=g:Filter(Card.IsControler,nil,tp):GetFirst() -- Your monster
	local tc2=g:Filter(Card.IsControler,nil,1-tp):GetFirst() -- Opponent's card

	if tc1 and tc1:IsRelateToEffect(e) and tc1:IsAbleToHand() then
		Duel.SendtoHand(tc1,nil,REASON_EFFECT)
	end

	if tc2 and tc2:IsRelateToEffect(e) and tc2:IsAbleToDeck() then
		Duel.SendtoDeck(tc2,nil,2,REASON_EFFECT) -- 2 means shuffle
	end
end