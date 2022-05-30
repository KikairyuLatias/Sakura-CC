--A.G.M. Eon Champion Commander - Azure Sakura
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsSetCard,0x7df),1,99,nil,nil,nil,s.matfilter)
	c:EnableReviveLimit()
	--synchro summoned me is harder to take down
	--cannot target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetValue(aux.tgoval)
	e1:SetCondition(s.procon)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.procon)
	e2:SetValue(s.indval)
	c:RegisterEffect(e2)
	--no one`s causing drama while I`m here
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1,id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	--this is what happens to spambots
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_SUMMON)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.discon2)
	e4:SetTarget(s.distg2)
	e4:SetOperation(s.disop2)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e6)
	--come back
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,2))
	e7:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e7:SetCode(EVENT_DESTROYED)
	e7:SetCountLimit(1,{id,1})
	e7:SetCondition(s.sumcon)
	e7:SetTarget(s.sumtg)
	e7:SetOperation(s.sumop)
	c:RegisterEffect(e7)
end

--you need a level 5 or higher to make me
function s.cfilter(c,sc,tp)
	return c:IsLevelAbove(5)
end
function s.matfilter(g,sc,tp)
	return g:IsExists(s.cfilter,1,nil,sc,tp)
end

--protection clause
function s.procon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end

--needed to have done this when certain members were spilling gas on everything!
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			Duel.SetChainLimit(s.chainlm)
		end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEDOWN,REASON_EFFECT)
	end
end

--time to ban spambots before they show up
function s.discon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and ep~=tp
end
function s.distg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,eg:GetCount(),0,0)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			Duel.SetChainLimit(s.chainlm)
		end
end
function s.disop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	Duel.NegateSummon(eg)
	Duel.Remove(eg,POS_FACEDOWN,REASON_EFFECT)
end

--revive
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end