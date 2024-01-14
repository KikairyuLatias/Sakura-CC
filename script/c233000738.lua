--Sunbeast Heiau
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=s.ritualfil,extrafil=s.extrafil,extraop=s.extraop})
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	--WINTER IS COMING!
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.negcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end

--ritual
function s.ritualfil(c)
	return c:IsCode(233000737)
end
function s.exfilter0(c)
	return c:IsReleasable()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.IsExistingMatchingCard(Card.IsSummonLocation,tp,0,LOCATION_MZONE,1,1,LOCATION_EXTRA) then
		return Duel.GetMatchingGroup(s.exfilter0,tp,0,LOCATION_MZONE,1,c)
	end
end
function s.extraop(mg,e,tp,eg,ep,ev,re,r,rp)
	local mat2=mg:Filter(Card.IsLocation,0,LOCATION_MZONE)
	mg:Sub(mat2)
	Duel.ReleaseRitualMaterial(mg)
	Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end

--negate
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.exccon(e) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x640),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.dfilter(c)
	return c:IsFaceup()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.dfilter,tp,0,LOCATION_ONFIELD,1,nil) end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.dfilter,tp,0,LOCATION_ONFIELD,nil)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end