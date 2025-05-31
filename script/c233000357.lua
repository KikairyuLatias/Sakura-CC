--Erpeta Metensar Anaconda
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--scale
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CHANGE_LSCALE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCondition(s.sccon)
	e0:SetValue(8)
	c:RegisterEffect(e0)
	local e0a=e0:Clone()
	e0a:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(e0a)
	--equip this card from p-zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.eqtga)
	e1:SetOperation(s.eqopa)
	c:RegisterEffect(e1)
	--special summon condition
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1}) -- Changed to a different count limit key for monster effect
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--stat up
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.stattg)
	e4:SetValue(s.statval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
	--negate opponent's hand/GY monster effects while equipped
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS) -- Continuous effect while equipped
	e6:SetCode(EVENT_EQUIP) -- Trigger when equipped
	e6:SetOperation(s.negop)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EVENT_REMOVE) -- Trigger when unequipped/removed
	e7:SetOperation(s.negret)
	c:RegisterEffect(e7)
	local e8=e6:Clone()
	e8:SetCode(EVENT_LEAVE_FIELD) -- Also trigger when leaves field
	e8:SetOperation(s.negret)
	c:RegisterEffect(e8)
end

--scale change slightly (to summon the Synchro...)
function s.sccon(e)
	local tp=e:GetHandlerPlayer()
	-- Check if there's an "Erpeta Metensar" card in the other Pendulum Zone
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0x7c5)
end

--equip self from P-Zone or another "Erpeta Metensar" monster
function s.eqfilter(c)
	-- Filter for "Erpeta Metensar" monsters that are face-up
	return c:IsSetCard(0x7c5) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end

function s.eqtga(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() and chkc:IsRace(RACE_REPTILE) end
	-- Check for valid equip target (Reptile monster) and available S/T Zone
	-- Also check if this card can be equipped, or if another "Erpeta Metensar" monster can be equipped
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsRace,RACE_REPTILE),tp,LOCATION_MZONE,0,1,nil)
		and (c:IsLocation(LOCATION_PZONE) or Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,c)) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsRace,RACE_REPTILE),tp,LOCATION_MZONE,0,1,1,nil)
	-- Set operation info for equipping either this card or another
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_PZONE+LOCATION_GRAVE+LOCATION_EXTRA)
end

function s.eqopa(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	-- Ensure the target is still valid and there's an available S/T Zone
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0) then return end

	local c=e:GetHandler()
	local eq_card = nil
	-- If this card is in the Pendulum Zone, it can be equipped
	if c:IsLocation(LOCATION_PZONE) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then -- Prompt to equip this card
		eq_card = c
	else
		-- Otherwise, select another "Erpeta Metensar" monster from GY or Extra Deck
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g = Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
		eq_card = g:GetFirst()
	end

	if eq_card then
		Duel.Equip(tp,eq_card,tc) -- Equip the selected card
		-- Create an equip limit effect to ensure it stays equipped to the target
		local e1=Effect.CreateEffect(eq_card)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimita)
		e1:SetLabelObject(tc)
		eq_card:RegisterEffect(e1)
	end
end

function s.eqlimita(e,c)
	return c==e:GetLabelObject()
end

-- Special Summon
function s.cfilter(c)
	-- Returns true if the monster is face-down or not an "Erpeta Metensar" monster
	return c:IsFacedown() or not c:IsSetCard(0x7c5)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- Condition is true if no monsters, or all controlled monsters are "Erpeta Metensar"
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
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

-- Reptile power up
function s.stattg(e,c)
	-- Targets "Erpeta Metensar" monsters you control
	return c:IsSetCard(0x7c5) and c:IsType(TYPE_MONSTER)
end
function s.statfilter(c)
	-- Filters for face-up "Erpeta Metensar" cards
	return c:IsFaceup() and c:IsSetCard(0x7c5)
end
function s.statval(e,c)
	-- Value is 100 ATK/DEF for each "Erpeta Metensar" card controlled by the card's controller
	return Duel.GetMatchingGroupCount(s.statfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)*100
end

-- Negation effect when equipped
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local eqp=c:GetEquipTarget()
	-- Only apply if equipped to a Reptile monster
	if eqp and eqp:IsRace(RACE_REPTILE) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE_HAND)
		e1:SetTargetRange(0,1) -- Affect opponent's hand
		e1:SetLabelObject(e) -- Link to the original effect
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		Duel.RegisterEffect(e1,tp)

		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_DISABLE_GRAVE)
		e2:SetTargetRange(0,1) -- Affect opponent's GY
		e2:SetLabelObject(e) -- Link to the original effect
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		Duel.RegisterEffect(e2,tp)
		e:SetLabelObject(e1) -- Store e1 and e2 to easily disable them later
	end
end

function s.negret(e,tp,eg,ep,ev,re,r,rp)
	-- Disable the field effects when this card is no longer equipped or leaves the field
	local e1=e:GetLabelObject()
	if e1 then
		e1:Reset()
	end
end