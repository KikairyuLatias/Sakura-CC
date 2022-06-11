--Dark Magical Girl Mascot
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,1))
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e0:SetRange(LOCATION_GRAVE)
	e0:SetCode(EVENT_LEAVE_FIELD)
	e0:SetCountLimit(1,id)
	e0:SetCondition(s.revcon)
	e0:SetTarget(s.revtg)
	e0:SetOperation(s.revdop)
	c:RegisterEffect(e0)
	--send to grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end

--condition to trigger
function s.revfilter(c,tp)
	return c:IsSetCard(0x5f3) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousControler()==tp
end
function s.revcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.revfilter,1,nil,tp)
end

--Activation legality
function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
	--Special Summon from GY, banish it if it leaves the field
function s.revop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		--Banish it when it leaves the field
		local e0=Effect.CreateEffect(c)
		e0:SetDescription(3300)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e0:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e0:SetValue(LOCATION_REMOVED)
		e0:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e0,true)
	end
end

--time to mill
function s.tgfilter(c)
	return c:IsSetCard(0x5f3) and c:IsAbleToGrave() and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end