--Diver Deer SEAL Admiral Khmala
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x14af),1,1,Synchro.NonTunerEx(Card.IsSetCard,0x14af),1,99,nil,nil,nil,s.matfilter)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e2)
	--immune
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	--register effect (and can do all the nasty things)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(s.regcon)
	e5:SetOperation(s.regop)
	c:RegisterEffect(e5)
	--material count check
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_MATERIAL_CHECK)
	e6:SetValue(s.valcheck)
	e6:SetLabelObject(e5)
	c:RegisterEffect(e6)
	--Special Summon
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,1))
	e9:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e9:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e9:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e9:SetCode(EVENT_LEAVE_FIELD)
	e9:SetCondition(s.sumcon)
	e9:SetTarget(s.sumtg)
	e9:SetOperation(s.sumop)
	c:RegisterEffect(e9)
end

--you need a synchro to make me
function s.cfilter(c,sc,tp)
	return c:IsType(TYPE_SYNCHRO,sc,SUMMON_TYPE_SYNCHRO,tp)
end
function s.matfilter(g,sc,tp)
	return g:IsExists(s.cfilter,1,nil,sc,tp)
end

--triggers
function s.valcheckmat(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

--georgian tochi power
function s.mfilter(c)
	return not c:IsType(TYPE_TUNER)
end

function s.valcheck(e,c)
	local g=c:GetMaterial()
	local ct=g:FilterCount(s.mfilter,nil)
	e:GetLabelObject():SetLabel(ct)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()>0
end
function s.chkfilter(c,label)
	return c:GetFlagEffect(label)>0
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	local e7=Effect.CreateEffect(c)
	e7:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e7:SetDescription(aux.Stringid(id,0))
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_MZONE)
	e7:SetReset(RESET_EVENT+(RESETS_STANDARD&~RESET_TURN_SET))
	e7:SetCountLimit(ct,id)
	e7:SetTarget(s.bantg)
	e7:SetOperation(s.banop)
	c:RegisterEffect(e7)
end

--conditions
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_HAND,1,nil) end 
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_HAND,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_HAND,1,1,nil)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+0x1fe0000,0,1)
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	Duel.Damage(1-tp,800,REASON_EFFECT)
end

--special
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.filter(c,e,tp)
	return c:IsSetCard(0x14af) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,true)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetFirstMatchingCard(s.filter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,nil,e,tp)
	if tg then
		Duel.SpecialSummon(tg,0,tp,tp,false,true,POS_FACEUP)
	end
end