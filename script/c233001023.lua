-- Dreamlight Valkyria
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon procedure
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--counter
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(s.addct)
	e2:SetOperation(s.addc)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--immunity to opponent's effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.etarget)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
end

--special summon
function s.spfilter(c,ft)
	return c:IsFaceup() and c:IsSetCard(0x5f7) and (c:IsAbleToHandAsCost() or c:IsAbleToExtraAsCost())
		and (ft>0 or c:GetSequence()<5)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil,ft)
	return ft>-1 and #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,nil,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=nil
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil,ft)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,nil,1,tp,HINTMSG_RTOHAND,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoHand(g,nil,REASON_COST)
	g:DeleteGroup()
end

--put counter on monster
s.counter_list={0x5f7}
function s.filter(c)
	return c:IsFaceup() --and c:IsCanAddCounter(0x5f7,1)
end
function s.addct(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.filter(chkc) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x5f7)
end
function s.addc(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x5f7,1)
	end
end

--protection
function s.etarget(e,c)
	return c:GetCounter(0x5f7)>0
end
function s.efilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end