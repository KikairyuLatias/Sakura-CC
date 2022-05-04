--SG-U Freaky Monkey Pink
local s,id=GetID()
function s.initial_effect(c)
	--steal a monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetValue(s.ctatk)
	e3:SetTarget(s.ctltg)
	e3:SetOperation(s.ctlop)
	c:RegisterEffect(e3)
end
--steal shit
function s.ctfilter(c,atk)
	return c:IsFaceup() and c:IsSetCard(0x7d5) and c:GetAttack()>atk
end
function s.ctatk(e,c)
	return c:IsFaceup() and c:IsSetCard(0x7d5) and Duel.IsExistingMatchingCard(s.ctfilter,c:GetControler(),LOCATION_MZONE,0,1,nil,c:GetAttack())
end
function s.filter(c)
	return c:IsFaceup() and c:IsDefenseBelow(0) and c:IsControlerCanBeChanged()
end
function s.ctltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.ctlop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsDefenseBelow(0) then
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end