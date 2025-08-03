-- Akane the Rocketblossom Deer
-- Scripted with Google Gemini assistance
local s,id=GetID()
function s.initial_effect(c)
	-- During your Main Phase: You can have all face-up monsters your opponent controls lose 200 ATK/DEF for each "Rocketblossom Deer" monster you control with different names until the end of the next turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,1}) -- Each effect of this card once per turn (index 1)
	e1:SetTarget(s.atkdef_loss_tg)
	e1:SetOperation(s.atkdef_loss_op)
	c:RegisterEffect(e1)

	-- During your Main Phase: You can banish 1 "Rocketblossom Deer" card from your GY, then target 1 face-up monster your opponent controls; gain LP equal to its ATK.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,2}) -- Each effect of this card once per turn (index 2)
	e2:SetCost(s.banish_cost)
	e2:SetTarget(s.lpgain_tg)
	e2:SetOperation(s.lpgain_op)
	c:RegisterEffect(e2)
end

-- --- Helper filter for "Rocketblossom Deer" cards (Archetype code 0x7ae) ---
function s.filter_rocketblossom(c)
	return c:IsSetCard(0x7ae)
end

-- --- Effect 1: Opponent's Monster ATK/DEF Loss ---

-- ATK/DEF Loss Target
function s.atkdef_loss_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Check if there's at least one "Rocketblossom Deer" monster you control
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter_rocketblossom,tp,LOCATION_MZONE,0,1,nil)
		-- And at least one face-up monster your opponent controls
		and Duel.IsExistingMatchingCard(Card.IsFaceup,1-tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE,nil,0,1-tp,LOCATION_MZONE)
end

-- ATK/DEF Loss Operation
function s.atkdef_loss_op(e,tp,eg,ep,ev,re,r,rp)
	-- Get all "Rocketblossom Deer" monsters controlled by the player
	local my_rocketblossom_monsters=Duel.GetMatchingGroup(s.filter_rocketblossom,tp,LOCATION_MZONE,0,nil)
	if #my_rocketblossom_monsters==0 then return end

	-- Calculate the number of "Rocketblossom Deer" monsters you control with different names
	local unique_codes={}
	local diff_names_count=0
	for tc in aux.Next(my_rocketblossom_monsters) do
		local code=tc:GetCode()
		if not unique_codes[code] then
			unique_codes[code]=true
			diff_names_count=diff_names_count+1
		end
	end

	local loss_value = diff_names_count * -200 -- Negative value for loss

	-- Get all face-up monsters your opponent controls
	local opponent_monsters=Duel.GetMatchingGroup(Card.IsFaceup,1-tp,LOCATION_MZONE,0,nil)
	if #opponent_monsters==0 then return end

	-- Apply the ATK/DEF loss to all opponent's face-up monsters
	for tc in aux.Next(opponent_monsters) do
		local e_atk=Effect.CreateEffect(e:GetHandler())
		e_atk:SetType(EFFECT_TYPE_SINGLE)
		e_atk:SetCode(EFFECT_UPDATE_ATTACK)
		e_atk:SetValue(loss_value)
		e_atk:SetReset(RESET_PHASE|PHASE_END,2) -- Lasts until the end of the next turn
		tc:RegisterEffect(e_atk)

		local e_def=e_atk:Clone() -- Clone the ATK effect for DEF
		e_def:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e_def)
	end
end

-- --- Effect 2: Banish from GY & LP Gain ---

-- Banish Cost
function s.banish_cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Check if there's a "Rocketblossom Deer" card in the GY to banish
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter_rocketblossom,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- Select 1 "Rocketblossom Deer" card from GY to banish (face-up)
	local g=Duel.SelectMatchingCard(tp,s.filter_rocketblossom,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

-- Target filter for opponent's face-up monster
function s.lpgain_tg_filter(c)
	return c:IsFaceup() and c:IsMonster()
end

-- LP Gain Target
function s.lpgain_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- Check if the target is valid (face-up monster controlled by opponent)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.lpgain_tg_filter(chkc) end
	-- Check if there's a valid target on the opponent's field
	if chk==0 then return Duel.IsExistingTarget(s.lpgain_tg_filter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- Select 1 face-up monster your opponent controls
	local g=Duel.SelectTarget(tp,s.lpgain_tg_filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0) -- Set recover category information
end

-- LP Gain Operation
function s.lpgain_op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	-- If the target is still valid and related to the effect, gain LP
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local gain_lp = tc:GetAttack()
		Duel.Recover(tp, gain_lp, REASON_EFFECT)
	end
end