--Pony Assistant Rider
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	 Pendulum.AddProcedure(c)
	--Ritual Summon
	local e2=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,aux.FilterBoolFunction(Card.IsSetCard,0x439),desc=aux.Stringid(id,1),forcedselection=function(e,tp,g,sc)return g:IsContains(e:GetHandler()) end})
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.ritcon)
	c:RegisterEffect(e2)
end

function s.ritcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end