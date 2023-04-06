--Bunny Storm Cross
local s,id=GetID()
function s.initial_effect(c)
	--Destroy all of opponent's monsters that has ATK <= than the targeted monster's ATK
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

--the filters
function s.filter(c,tp)
	return c:IsFaceup() and c:IsLevelAbove(6) and c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x7d0)
		and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
function s.desfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()<=atk
end
function s.filter2(c,tp)
	return c:IsFaceup() and (c:IsCode(233001111) or c:IsCode(233001112) or ((c:ListsCode(233001111) or c:ListsCode(233001112) and c:IsType(TYPE_SYNCHRO))))
end
--what you are blasting away
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tg=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local atk=tg:GetFirst():GetAttack()
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,atk)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)

	--if posie, cinnamon or their evolved forms exist, opponent can't do anything
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(s.filter2),tp,LOCATION_MZONE,0,1,nil) then
		Duel.SetChainLimit(s.chlimit)
	end
end

function s.chlimit(e,ep,tp)
	return tp==ep
end

--blow up things
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,tc:GetAttack())
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end