--Diver Deer Giglio
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	 Pendulum.AddProcedure(c)
	--cannot special summon monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
	--burn damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
	--rank burn damage
	local e3=e2:Clone()
	e3:SetCondition(s.condition2)
	e3:SetTarget(s.target2)
	c:RegisterEffect(e3)
	--attack directly
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.dacon)
	e4:SetTarget(s.datg)
	e4:SetOperation(s.daop)
	c:RegisterEffect(e4,false,1)
	--Add to hand
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_EXTRA)
	e5:SetCountLimit(1,{id,1})
	e5:SetCost(s.rthcost)
	e5:SetTarget(s.rthtg)
	e5:SetOperation(s.rthop)
	c:RegisterEffect(e5)
end

--sp limit
function s.splimit(e,c)
	return not (c:IsSetCard(0x4af) and c:IsAttribute(ATTRIBUTE_WATER))
end

--burn damage
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return eg:GetCount()==1 and tc:IsControler(tp) and tc:IsSetCard(0x14af)
		and bc:IsReason(REASON_BATTLE) and not bc:IsType(TYPE_XYZ) and not bc:IsType(TYPE_LINK)
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return eg:GetCount()==1 and tc:IsControler(tp) and tc:IsSetCard(0x14af)
		and bc:IsReason(REASON_BATTLE) and bc:IsType(TYPE_XYZ)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	local lv=eg:GetFirst():GetBattleTarget():GetLevel()
	if lv<0 then lv=0 end
	Duel.SetTargetParam(lv*200)
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	local rk=eg:GetFirst():GetBattleTarget():GetRank()
	if rk<0 then rk=0 end
	Duel.SetTargetParam(rk*200)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end

--attack
function s.dacon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP()
end
function s.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0x14af)
end
function s.datg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter2(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter2,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,nil)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.ftarget)
	e1:SetLabel(g:GetFirst():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.daop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+0x1fe1000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end

--return to hand
function s.rthcostfilter(c)
	return c:IsDiscardable() and c:IsSetCard(0x14af)
end
function s.rthcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rthcostfilter,tp,LOCATION_HAND,0,2,nil) end
	Duel.DiscardHand(tp,s.rthcostfilter,2,2,REASON_COST+REASON_DISCARD)
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.rthfilter(c)
	return c:IsSetCard(0x14af) and c:IsAbleToHand()
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0
		and c:IsLocation(LOCATION_HAND)
		and Duel.IsExistingMatchingCard(s.rthfilter,tp,LOCATION_PZONE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local rg=Duel.SelectMatchingCard(tp,s.rthfilter,tp,LOCATION_PZONE,0,1,1,nil)
		if #rg>0 then
			Duel.BreakEffect()
			Duel.HintSelection(rg,true)
			Duel.SendtoHand(rg,nil,REASON_EFFECT)
		end
	end
end