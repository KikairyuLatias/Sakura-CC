--Starblossom Fighting Aura
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--disable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TRIGGER)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(s.locktg)
	c:RegisterEffect(e1)
	--Soul Drain the opponent
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.accon)
	e2:SetValue(s.aclimit)
	c:RegisterEffect(e2)
	--Mind Drain the opponent
	local e3=e2:Clone()
	e3:SetValue(s.aclimit2)
	c:RegisterEffect(e3)
	--burn/recover
	local e4=Effect.CreateEffect(c)
		--e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_RECOVER+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetCondition(s.reccon)
	e4:SetOperation(s.recop)
	c:RegisterEffect(e4)
	--burn/recover for monster destruction
	local e5=e4:Clone()
		--e5:SetDescription(aux.Stringid(id,1))
	e5:SetCode(EVENT_BATTLE_DESTROYING)
	c:RegisterEffect(e5)
end

--shut off activating effects on summon turn
function s.lockcon(e,tp,eg,ep,ev,re,r,rp,chk)
	return c:IsFaceup() and c:IsSetCard(0x4cb) and c:IsType(TYPE_MONSTER) and c:IsRace(RACE_BEASTWARRIOR)
end
function s.locktg(e,c)
	return c:IsStatus(STATUS_SUMMON_TURN+STATUS_FLIP_SUMMON_TURN+STATUS_SPSUMMON_TURN+STATUS_F)
end

--requirement to shut down the opponent's activations
function s.acfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x4cb) and c:IsType(TYPE_MONSTER) and c:GetOriginalLevel()==7
end
function s.accon(e)
	return Duel.IsExistingMatchingCard(s.banfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

function s.aclimit(e,re,tp)
	local loc=re:GetActivateLocation()
	return (loc==LOCATION_GRAVE or loc==LOCATION_REMOVED) and re:IsActiveType(TYPE_MONSTER)
end
function s.aclimit2(e,re,tp)
	local loc=re:GetActivateLocation()
	return loc==LOCATION_HAND and re:IsActiveType(TYPE_MONSTER)
end

--burn opponent and gain lp
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:GetFirst():IsControler(tp) and eg:GetFirst():IsSetCard(0x4cb)
end

function s.recop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Damage(1-tp,300,REASON_EFFECT)
	Duel.Recover(tp,300,REASON_EFFECT)
end