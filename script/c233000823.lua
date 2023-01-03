--Diver Equine Support Blaze
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--to hand or activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e1a)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--lv change
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetCondition(s.lvcon)
	e5:SetTarget(s.lvtg)
	e5:SetOperation(s.lvop)
	c:RegisterEffect(e5)
end

--activate the Field Spell
function s.thfilter(c,tp)
	return c:IsType(TYPE_FIELD) and c:IsSetCard(0x24af)
		and (c:IsAbleToHand() or c:GetActivateEffect():IsActivatable(tp,true,true))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	aux.ToHandOrElse(tc,tp,function(c)
					local te=tc:GetActivateEffect()
					return te:IsActivatable(tp,true,true) end,
					function(c)
						Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
						local te=tc:GetActivateEffect()
						local tep=tc:GetControler()
						local cost=te:GetCost()
						if cost
							then cost(te,tep,eg,ep,ev,re,r,rp,1)
						end
					end,
					aux.Stringid(id,0))
end

--ritual lowering
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x24af),tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function s.filter(c)
	return c:IsSetCard(0x24af) and c:IsType(TYPE_RITUAL) and c:IsMonster()
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) end
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		g:GetFirst():RegisterEffect(e1)
	end
end