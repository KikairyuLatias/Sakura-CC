--Sunbeast Iakua a ka Molehu
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--always treat as DARK-Attribute (on top of base Attribute)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e1)
	--rivalry of warlords (when you control 3 or more "Sunbeast" monsters)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.adjustcon)
	e2:SetOperation(s.adjustop)
	c:RegisterEffect(e2)
	--cannot summon,spsummon,flipsummon
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(0,1)
	e4:SetTarget(s.sumlimit)
	e4:SetValue(POS_FACEDOWN)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e6)
	--gozen match
	local e7=e2:Clone()
	e2:SetOperation(s.adjustop2)
	c:RegisterEffect(e7)
	--cannot summon,spsummon,flipsummon
	local e8=e4:Clone()
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
	e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e8:SetTargetRange(0,1)
	e8:SetTarget(s.sumlimit2)
	e8:SetValue(POS_FACEDOWN)
	c:RegisterEffect(e8)
	local e9=e8:Clone()
	e9:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e9)
	local e10=e8:Clone()
	e10:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e10)
	--special summon
	local e11=Effect.CreateEffect(c)
	e11:SetDescription(aux.Stringid(id,2))
	e11:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e11:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e11:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e11:SetCountLimit(1)
	e11:SetCode(EVENT_DESTROYED)
	e11:SetCondition(s.spcon2)
	e11:SetTarget(s.sptg2)
	e11:SetOperation(s.spop2)
	c:RegisterEffect(e11)
end

--condition
function s.actfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x640)
end
function s.adjustcon(e)
	return Duel.IsExistingMatchingCard(s.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,3,nil)
end

--stuff for locking the opponent down
s[0]=0

function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	s[0]=0
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	local rc=s.getrace(Duel.GetMatchingGroup(Card.IsFaceup,targetp or sump,LOCATION_MZONE,0,nil))
	if rc==0 then return false end
	return c:GetRace()~=rc
end
function s.getrace(g)
	local arc=0
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		arc=(arc|tc:GetRace())
	end
	return arc
end
function s.rmfilter(c,rc)
	return c:GetRace()==rc
end
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local c=e:GetHandler()
	if #g1==0 then s[tp]=0
	else
		local rac=s.getrace(g1)
		if (rac&rac-1)~=0 then
			if s[tp]==0 or (s[tp]&rac)==0 then
				Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
				rac=Duel.AnnounceRace(tp,1,rac)
			else rac=s[tp] end
		end
		g1:Remove(s.rmfilter,nil,rac)
		s[tp]=rac
	end
	
	if #g1>0 then
		Duel.SendtoGrave(g1,REASON_RULE)
		Duel.Readjust()
	end
end

--one attribute only (there has to be a more condensed version of this...)
s[1]=0

function s.acttg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	s[1]=0
end
function s.sumlimit2(e,c,sump,sumtype,sumpos,targetp)
	local at=s.getattribute(Duel.GetMatchingGroup(Card.IsFaceup,targetp or sump,LOCATION_MZONE,0,nil))
	if at==0 then return false end
	return c:GetAttribute()~=at
end
function s.getattribute(g)
	local aat=0
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		aat=(aat|tc:GetAttribute())
	end
	return aat
end
function s.rmfilter2(c,at)
	return c:GetAttribute()==at
end
function s.adjustop2(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local c=e:GetHandler()
	if #g1==0 then s[tp]=0
	else
		local att=s.getattribute(g1)
		if (att&att-1)~=0 then
			if s[tp]==0 or (s[tp]&att)==0 then
				Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
				att=Duel.AnnounceAttribute(tp,1,att)
			else att=s[tp] end
		end
		g1:Remove(s.rmfilter2,nil,att)
		s[tp]=att
	end

	if #g1>0 then
		Duel.SendtoGrave(g1,REASON_RULE)
		Duel.Readjust()
	end
end

--revival
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)))
		and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x640) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id) 
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end