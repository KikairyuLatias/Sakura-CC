-- Dimensionstar Hazmat Diver Equine Enríque
-- Scripted with Google Gemini assistance

local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,s.mfilter,10,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c,false)

	-- Pendulum Effect: Tribute 2 "Diver Equine" monsters; Special Summon this card from your Pendulum Zone.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(id,1)
	e1:SetCost(s.pzspcost)
	e1:SetTarget(s.pzsptg)
	e1:SetOperation(s.pzspop)
	c:RegisterEffect(e1)

	-- Monster Effect: Unaffected by opponent's activated effects (if Xyz Summoned)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetCondition(s.xyzimmunecon)
	e3:SetValue(s.xyzimmuneval)
	c:RegisterEffect(e3)

	-- Monster Effect: If destroyed, place in Pendulum Zone
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_POSITION)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(s.pendplacecon)
	e4:SetTarget(s.pendplacetg)
	e4:SetOperation(s.pendplaceop)
	c:RegisterEffect(e4)

	-- Monster Effect: Detach 2 materials; banish top 7 cards face-down, 1000 damage
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetCost(s.banishcost)
	e5:SetTarget(s.banishtg)
	e5:SetOperation(s.banishop)
	c:RegisterEffect(e5)

	-- Monster Effect: Target 1 monster in GYs; attach as material
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,3))
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,{id,2})
	e6:SetTarget(s.target)
	e6:SetOperation(s.operation)
	c:RegisterEffect(e6)
end

-- Helper: Check if a card is a "Diver Equine" monster
function s.IsDiverEquine(c)
	return c:IsSetCard(0x24af)
end

--alt condition
function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsRace(RACE_BEASTWARRIOR) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ,xyzc,SUMMON_TYPE_XYZ,tp) and c:GetRank()>=6

end
function s.xyzop(e,tp,chk,mc)
	if chk==0 then return mc:CheckRemoveOverlayCard(tp,3,REASON_COST) end
	mc:RemoveOverlayCard(tp,3,3,REASON_COST)
	return true
end

-- Pendulum Effect: Special Summon from P-Zone
function s.pzspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckTribute(tp,aux.FilterBoolFunction(s.IsDiverEquine),2) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TRIBUTE)
	local g=Duel.SelectTribute(tp,aux.FilterBoolFunction(s.IsDiverEquine),2,2)
	e:SetLabelObject(g)
	Duel.Tribute(g,0,REASON_COST)
end
function s.pzsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,tp,POS_FACEUP,1) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.pzspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,POS_FACEUP,1)
	end
end

-- Monster Effect: Unaffected by opponent's activated effects (if Xyz Summoned)
function s.xyzimmunecon(e)
	return e:GetHandler():IsSummonType(SUMMONTYPE_XYZ)
end
function s.xyzimmuneval(e,re)
	return re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) and re:GetOwnerPlayer()~=e:GetOwnerPlayer()
end

-- Monster Effect: If destroyed, place in Pendulum Zone
function s.pendplacecon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_MZONE) and Duel.CheckPendulumZones(tp)
end
function s.pendplacetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.pendplaceop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.CheckPendulumZones(tp) and c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end

-- Monster Effect: Detach 2 materials; banish top 7 cards face-down, 1000 damage
function s.banishcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetOverlayCount()>=2 end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
function s.banishtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(1-tp, LOCATION_DECK, 0)>=7 end
	Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 0, 1-tp, 7)
	Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1-tp, 1000)
end
function s.banishop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RemoveExtPC(1-tp, 7, REASON_EFFECT) -- Banish top 7 cards face-down
	Duel.Damage(1-tp, 1000, REASON_EFFECT)
end

--refuel materials
function s.xyfilter(c,tp)
	return c:IsMonster() and not c:IsType(TYPE_TOKEN) and c:IsLocation(LOCATION_GRAVE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and s.xyfilter(chkc,tp) and chkc~=e:GetHandler() end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingTarget(s.xyfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,e:GetHandler(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.xyfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,e:GetHandler(),tp)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(c,tc,true)
	end
end