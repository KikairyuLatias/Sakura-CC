--Diver Vulpine Commodore Kaʻūmana
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,s.mfilter,6,2,nil,nil,Xyz.InfiniteMaterial)
	c:EnableReviveLimit()
	--cannot be targeted while has material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e0:SetCondition(s.dscon)
	e0:SetValue(aux.tgoval)
	c:RegisterEffect(e0)
	--banish opponent's field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(Cost.DetachFromSelf(1,1,nil))
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--banish opponent's deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.DetachFromSelf(1,1,nil))
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end

--material filter
function s.mfilter(c,xyz,sumtype,tp)
	return c:IsRace(RACE_BEASTWARRIOR,xyz,sumtype,tp) and c:IsAttribute(ATTRIBUTE_WATER,xyz,sumtype,tp)
end

--protection from targeting effects
function s.dscon(e)
	return e:GetHandler():GetOverlayCount()~=0
end

-- lock and fire
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end 
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+0x1fe0000,0,1)
	Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	Duel.BreakEffect()
	Duel.Damage(1-tp,800,REASON_EFFECT)
end

--bye bye deck
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(1-tp,3)
		if g:GetCount()>0 then
			Duel.DisableShuffleCheck()
			Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
			Duel.BreakEffect()
			Duel.Damage(1-tp,800,REASON_EFFECT)
		end
end