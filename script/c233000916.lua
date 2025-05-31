--Serena the Performer Trainer
--Scripted with Google Gemini assistance
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	--protection
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e0:SetTarget(s.indtg)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--gain LP (1 monster pointing)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.reccon)
	e1:SetTarget(s.rectg)
	e1:SetOperation(s.recop)
	c:RegisterEffect(e1)
	--stat boosting (2 monsters pointing)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
end

--protection
function s.indtg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end

--lp bonus
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetLinkedGroupCount()>=1
end
function s.recfilter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.recfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.recfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.recfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetAttack())
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetAttack()>0 then
		Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)
	end
end

--stat boost
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	-- Serena must point to 2 monsters
	if c:GetLinkedGroupCount() ~= 2 then return false end

	-- Must be in Damage Step, before damage calculation
	local phase = Duel.GetCurrentPhase()
	if phase ~= PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end

	local a = Duel.GetAttacker()
	local d = Duel.GetAttackTarget()

	-- Ensure valid battling monsters are present and related to battle
	if not a or not d or not a:IsRelateToBattle() or not d:IsRelateToBattle() then return false end

	local serena_linked_group = c:GetLinkedGroup()

	-- Check if your monster that Serena points to is battling an opponent's monster
	local your_monster_is_attacker = (a:GetControler() == tp and serena_linked_group:IsContains(a) and d:GetControler() ~= tp)
	local your_monster_is_defender = (d:GetControler() == tp and serena_linked_group:IsContains(d) and a:GetControler() ~= tp)

	return your_monster_is_attacker or your_monster_is_defender
end

function s.operation2(e,tp,eg,ep,ev,re,r,rp) -- Removed 'chk' parameter as it's not used here
	local a = Duel.GetAttacker()
	local d = Duel.GetAttackTarget()
	local c = e:GetHandler() -- Serena, the effect's handler

	local serena_linked_group = c:GetLinkedGroup()

	local your_monster = nil
	local opp_monster = nil

	-- Determine which is your monster (pointed to by Serena) and which is the opponent's monster
	if a and a:GetControler() == tp and serena_linked_group:IsContains(a) and d and d:GetControler() ~= tp then
		your_monster = a
		opp_monster = d
	elseif d and d:GetControler() == tp and serena_linked_group:IsContains(d) and a and a:GetControler() ~= tp then
		your_monster = d
		opp_monster = a
	end

	if your_monster and opp_monster then
		local e_atk = Effect.CreateEffect(c) -- Serena owns this effect
		e_atk:SetType(EFFECT_TYPE_SINGLE)
		e_atk:SetCode(EFFECT_UPDATE_ATTACK)
		e_atk:SetValue(opp_monster:GetAttack()) -- Gain ATK equal to opponent's monster's ATK
		e_atk:SetReset(RESET_PHASE+PHASE_DAMAGE) -- Reset until the end of the Damage Step
		your_monster:RegisterEffect(e_atk)
	end
end