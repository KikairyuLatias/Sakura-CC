--Snow Blossom Triservice Academy
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atk boost
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xa34))
	e2:SetValue(500)
	c:RegisterEffect(e2)	
	--def boost
	local e2a=e2:Clone()
	e2a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2a)
	--act limit
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
	--Draw
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetTarget(s.drtg)
	e5:SetOperation(s.drop)
	c:RegisterEffect(e5)
end

--don`t bother chaining
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if ep==tp and re:IsMonsterEffect() and rc:IsSetCard(0xa34) then
		Duel.SetChainLimit(function(_e,_rp,_tp) return _tp==_rp end)
	end
end

--protection
function s.limfilter(c,sp)
	return c:IsSetCard(0xa34) and c:IsFaceup() and c:IsSummonPlayer(sp)
end
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.limfilter,1,nil,tp) then
		Duel.SetChainLimitTillChainEnd(function(e,_rp,_tp) return _tp==_rp end)
	end
end

-- spsummon
function s.filter2(c)
	return c:IsSetCard(0xa34) and c:IsType(TYPE_MONSTER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--return
function s.filter(c)
	return c:IsSetCard(0xa34) and c:IsAbleToDeck()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,5,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,5,5,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,5,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=5 then return end
	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==5 then
		Duel.BreakEffect()
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end