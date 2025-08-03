--Dream★Star Blossom Rider Sakura
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Pendulum Summon procedure
	Pendulum.AddProcedure(c,false)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsSetCard,0x5f6),1,99)
	c:EnableReviveLimit()
	--Special Summon this card from your Pendulum Zone
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCountLimit(1,{id,1})
	e0:SetCondition(s.dreamstarcon)
	e0:SetTarget(s.dreamstartg)
	e0:SetOperation(s.dreamstarop)
	c:RegisterEffect(e0)
	--Your "Dream★Star" monsters cannot be destroyed by battle, nor destroyed or targeted by opponent's card effects
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e1:SetRange(LOCATION_PZONE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetValue(s.atlimit)
		c:RegisterEffect(e1)
		local e1a=Effect.CreateEffect(c)
		e1a:SetType(EFFECT_TYPE_FIELD)
		e1a:SetRange(LOCATION_MZONE)
		e1a:SetTargetRange(LOCATION_MZONE,0)
		e1a:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1a:SetTarget(s.tgtg)
		e1a:SetValue(1)
		c:RegisterEffect(e1a)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e2:SetRange(LOCATION_PZONE)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetTarget(s.atlimit)
		e2:SetValue(aux.tgoval)
		c:RegisterEffect(e2)
		local e2a=Effect.CreateEffect(c)
		e2a:SetType(EFFECT_TYPE_FIELD)
		e2a:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2a:SetRange(LOCATION_PZONE)
		e2a:SetTargetRange(LOCATION_ONFIELD,0)
		e2a:SetTarget(s.tgtg)
		e2a:SetValue(aux.indoval)
		c:RegisterEffect(e2a)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.target)
	e3:SetOperation(s.activate)
	c:RegisterEffect(e3)
	--negate monster summons
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_SUMMON)
	e4:SetCountLimit(1,{id,1})
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
	--go to P-Zone
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,3))
	e8:SetCategory(CATEGORY_DESTROY)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_DESTROYED)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCondition(s.pencon)
	e8:SetTarget(s.pentg)
	e8:SetOperation(s.penop)
	c:RegisterEffect(e8)
end

s.listed_series={0x5F6}
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if ep==tp and re:IsMonsterEffect() and rc:IsSetCard(0x5F6) then
		Duel.SetChainLimit(function(_e,_rp,_tp) return _tp==_rp end)
	end
end

--protection
function s.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x5F6) and c~=e:GetHandler()
end
--protect
function s.tgtg(e,c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x5F6) and c~=e:GetHandler()
end

--special summon self
function s.dreamstarcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x5F6),tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
function s.dreamstartg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.dreamstarop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--special summon
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x5F6) 
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_REMOVED)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--negate summons
function s.discon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and ep~=tp
end

function s.distg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,eg:GetCount(),0,0)
end

function s.disop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	Duel.NegateSummon(eg)
	Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	Duel.BreakEffect()
	Duel.Damage(1-tp,800,REASON_EFFECT)
end

--pendulum scale
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