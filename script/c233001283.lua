--Madara the Ten-Tailed Snowstorm Reindeer Ninja
local s,id=GetID()
function s.initial_effect(c)
	--can revive
	c:EnableReviveLimit()
	--effect immunity
		--cannot target
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetValue(aux.tgoval)
		e1:SetCondition(s.immcon)
		c:RegisterEffect(e1)
		--indes
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCondition(s.immcon)
		e2:SetValue(s.indval)
		c:RegisterEffect(e2)
	--you gotta do better than that to kill madara
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetCountLimit(1)
	e3:SetValue(s.valcon)
	c:RegisterEffect(e3)
	--banish opponent's extra deck
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.extdtg)
	e4:SetOperation(s.extdop)
	c:RegisterEffect(e4)
	--WINTER IS COMING!
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DISABLE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetTarget(s.distg)
	e5:SetOperation(s.disop)
	c:RegisterEffect(e5)
end

--immunity
function s.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end
function s.immcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end

--battle proc
function s.valcon(e,re,r,rp)
	return (r&REASON_BATTLE)~=0 and e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end

--you sure that madara didn't steal eyes to do kamui?
function s.extdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)>0 end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,1-tp,LOCATION_EXTRA)
end

function s.extdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if #g>0 then
		Duel.ConfirmCards(tp,g)
		local sg=g:FilterSelect(tp,Card.IsType,1,1,nil,TYPE_MONSTER)
		Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
		Duel.ShuffleExtra(1-tp)
	end
		Duel.BreakEffect()
		Duel.Damage(1-tp,1000,REASON_EFFECT)
end

--negate
function s.dfilter(c)
	return c:IsFaceup()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.dfilter,tp,0,LOCATION_ONFIELD,1,nil) end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.dfilter,tp,0,LOCATION_ONFIELD,nil)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end