--Psychic Dragon Twin Strike
local s,id=GetID()
function s.initial_effect(c)
	--Activate (borrow from chaos alliance)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

--stuff
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x5f1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,2,nil)
end
function s.cfilter2(c,atk)
	return c:IsSetCard(0x5f1) and c:IsFaceup() and c:GetAttack()<atk
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil):GetMaxGroup(Card.GetAttack)
	if chkc then return g and #g>0 and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter2(chkc,g:GetFirst():GetAttack()) end
	if chk==0 then return g and #g>0 and Duel.IsExistingTarget(s.cfilter2,tp,LOCATION_MZONE,0,1,nil,g:GetFirst():GetAttack()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,g:GetFirst():GetAttack())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil):GetMaxGroup(Card.GetAttack)
	if #g==0 then return end
	local atk=g:GetFirst():GetAttack()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetAttack()<atk then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
