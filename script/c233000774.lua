--A.G.M. Guest Winged Lion - LHK
local s,id=GetID()
function s.initial_effect(c)
	--atk up
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_UPDATE_ATTACK)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetTarget(s.tg)
	e0:SetValue(s.atkval)
	c:RegisterEffect(e0)
	--def up
	local e1=e0:Clone()
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1)
	--shuffle 5, draw 2
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
end

--boost
function s.tg(e,c)
	return c:IsSetCard(0x7df) and c:IsType(TYPE_MONSTER) and c~=e:GetHandler()
end
function s.filter(c)
	return c:IsSetCard(0x7df) and c:IsFaceup()
end
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(s.filter,c:GetControler(),LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return ct*100
end

--recycle draw
function s.tdfilter(c)
	return c:IsSetCard(0x7df) and (c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) or c:IsFaceup()) and c:IsAbleToDeck()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,5,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,5,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if #g<5 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:Select(tp,5,5,nil)
	Duel.SendtoDeck(sg,nil,0,REASON_EFFECT)
	local og=Duel.GetOperatedGroup()
	if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==5 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end