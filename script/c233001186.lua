--Ruka the Starry Snowstorm Rabbit
local s,id=GetID()
function s.initial_effect(c)
	--fusion summon
	Fusion.AddProcMixN(c,true,true,s.ffilter,2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	--drop
		--atk
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetValue(s.val)
		c:RegisterEffect(e1)
		--def
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	--act limit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(s.chainop)
	c:RegisterEffect(e3)
end

-- constraints
function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsSetCard(0x7e7,fc,sumtype,tp) and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,sumtype,tp),fc,sumtype,tp))
end
function s.fusfilter(c,code,fc,sumtype,tp)
	return c:IsSummonCode(fc,sumtype,tp,code) and not c:IsHasEffect(511002961)
end
function s.contactfil(tp)
	return Duel.GetReleaseGroup(tp)
end
function s.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function s.contactop(g)
	Duel.Release(g,REASON_COST+REASON_MATERIAL)
end

--stat drop
function s.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0x7e7)
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(s.filter2,c:GetControler(),0,LOCATION_MZONE,nil)*-200
end

--don`t bother chaining
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsSetCard(0x7e7) then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,rp,tp)
	return tp==rp
end