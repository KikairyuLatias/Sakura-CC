-- Skateboard Dragon Flare Rampage
local s,id=GetID()
function s.initial_effect(c)
	Ritual.AddProcEqual(c,s.ritualfil,nil,nil,nil,nil,nil,nil,LOCATION_HAND|LOCATION_DECK):SetCountLimit(1,id)
	--destroy cards on the field
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.destg)
	e3:SetCondition(aux.exccon)
	e3:SetCost(aux.bfgcost)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end

--ritual summon
function s.ritualfil(c)
	return c:IsSetCard(0x5f0) and c:IsRitualMonster()
end

--blow stuff up
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,1,2)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,0,1,2)
	local tc=g:GetFirst()
	if #g>0 then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end