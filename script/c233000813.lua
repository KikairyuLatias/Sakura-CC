--Diver Vulpine Bond Reflection
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)
end

--stuff
function s.spfilter(c,tp)
	return c:IsFaceup() and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,0x4000,c:GetAttack(),c:GetAttack(),4,RACE_BEASTWARRIOR,ATTRIBUTE_WATER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.spfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.spfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	local atk=tc:GetAttack()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,0x4000,atk,atk,4,RACE_BEASTWARRIOR,ATTRIBUTE_WATER) then return end
	c:AddMonsterAttribute(TYPE_EFFECT|TYPE_TRAP)
	if Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP_ATTACK) then
		c:AddMonsterAttributeComplete()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		e2:SetValue(atk)
		c:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e3:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
		e3:SetRange(LOCATION_MZONE)
		e3:SetValue(1)
		c:RegisterEffect(e3)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_CHANGE_TYPE)
		e4:SetValue(TYPE_EFFECT+TYPE_MONSTER) -- Set as Effect Monster
		e4:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e4)
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_CHANGE_LEVEL)
		e5:SetValue(4) -- Set Level to 4
		e5:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e5)
		local e6=Effect.CreateEffect(c)
		e6:SetType(EFFECT_TYPE_SINGLE)
		e6:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e6:SetValue(ATTRIBUTE_WATER) -- Set Attribute to WATER
		e6:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e6)
		local e7=Effect.CreateEffect(c)
		e7:SetType(EFFECT_TYPE_SINGLE)
		e7:SetCode(EFFECT_CHANGE_RACE)
		e7:SetValue(RACE_BEASTWARRIOR) -- Set Race to Beast-Warrior
		e7:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e7)
	end
	Duel.SpecialSummonComplete()
end

--handtrap cond
function s.actfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x44af) and c:IsType(TYPE_XYZ)
end
function s.actcon(e)
	return Duel.IsExistingMatchingCard(s.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end