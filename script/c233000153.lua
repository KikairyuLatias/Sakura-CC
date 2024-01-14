--Ultimate Magical Girl of Dreams
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x5f3),1,1,Synchro.NonTunerEx(Card.IsSetCard,0x5f3),2,99)
	c:EnableReviveLimit()
	--pendulum summon
	Pendulum.AddProcedure(c)
	--protection
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x5f3))
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--special summon from P-Zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--move
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.seqtg)
	e3:SetOperation(s.seqop)
	c:RegisterEffect(e3)
	--protection 2
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x5f3))
	e4:SetValue(s.efilter)
	e4:SetTarget(s.eftg)
	c:RegisterEffect(e4)
	--pendulum
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(s.pencon)
	e5:SetTarget(s.pentg)
	e5:SetOperation(s.penop)
	c:RegisterEffect(e5)
end

--protection
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

--special summon myself
function s.cfilter(c)
	return c:IsSetCard(0x5f3) and c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost() and aux.SpElimFilter(c,true)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--move
function s.seqcon(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer()
end
function s.banfilter(c,g)
	return c:IsAbleToRemove() and g:IsContains(c)
end
function s.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local cg=e:GetHandler():GetColumnGroup()
	if chk==0 then return Duel.IsExistingMatchingCard(s.banfilter,tp,0,LOCATION_ONFIELD,1,nil,cg) end
	local g=Duel.GetMatchingGroup(s.banfilter,tp,0,LOCATION_ONFIELD,nil,cg)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.seqop(e,tp,eg,ep,ev,re,r,rp)
	Duel.MoveSequence(e:GetHandler(),math.log(Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0),2))
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	cg:AddCard(c)
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local g=Duel.GetMatchingGroup(s.banfilter,tp,0,LOCATION_ONFIELD,nil,cg)
		if #g>0 then
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end

--more protection for column
function s.eftg(e,c)
	local g=e:GetHandler():GetColumnGroup(1,1)
	return c:IsSetCard(0x109) and c:GetSequence()<5 and g:IsContains(c)
end

--to pendulumZ
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return false end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end