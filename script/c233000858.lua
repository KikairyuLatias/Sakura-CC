--Diver Dragon Joint Base 326R
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Opponent cannot do anything
	local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_CHAINING)
		e3:SetRange(LOCATION_FZONE)
		e3:SetOperation(s.chainop)
		c:RegisterEffect(e3)
		--protection
		local e3a=Effect.CreateEffect(c)
		e3a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3a:SetCode(EVENT_SUMMON_SUCCESS)
		e3a:SetRange(LOCATION_FZONE)
		e3a:SetOperation(s.limop)
		c:RegisterEffect(e1)
		local e3b=e3a:Clone()
		e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
		c:RegisterEffect(e3b)
		local e3c=e3a:Clone()
		e3c:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		c:RegisterEffect(e3c)
		local e3d=Effect.CreateEffect(c)
		e3d:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3d:SetRange(LOCATION_FZONE)
		e3d:SetCode(EVENT_CHAIN_END)
		e3d:SetOperation(s.limop2)
		c:RegisterEffect(e3d)
		--spsummon
		local e4=Effect.CreateEffect(c)
		e4:SetDescription(aux.Stringid(id,0))
		e4:SetType(EFFECT_TYPE_IGNITION)
		e4:SetRange(LOCATION_FZONE)
		e4:SetCountLimit(1,id)
		e4:SetTarget(s.target)
		e4:SetOperation(s.activate)
		c:RegisterEffect(e4)
	--Reveal 3 cards
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
end

--protection
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if ep==tp and re:IsMonsterEffect() and rc:IsSetCard(0x64af) then
		Duel.SetChainLimit(function(_e,_rp,_tp) return _tp==_rp end)
	end
end

function s.limfilter(c,sp)
	return c:IsSetCard(0x64af) and c:IsFaceup() and c:IsSummonPlayer(sp)
end
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.limfilter,1,nil,tp) then
		Duel.SetChainLimitTillChainEnd(function(e,_rp,_tp) return _tp==_rp end)
	end
end

-- spsummon
function s.filter2(c)
	return c:IsSetCard(0x64af) and c:IsType(TYPE_MONSTER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--search
function s.thfilter(c)
	return c:IsSetCard(0x64af) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,3,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>=3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,3,3,nil)
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleDeck(tp)
		local tg=sg:RandomSelect(1-tp,1)
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end