--Dreaming Painter
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon
	--local params = {nil,Fusion.IsMonsterFilter,nil,nil,nil,s.stage2}
	local params={aux.FilterBoolFunction(Card.IsLevelBelow,6)}
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.cost)
	e3:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e3:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e3)
end
--fusion time
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	Duel.PayLPCost(tp,500)
end
--function s.stage2(e,tc,tp,sg,chk)
   -- if chk==1 then
		--local e1=Effect.CreateEffect(e:GetHandler())
	  --  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	   -- e1:SetRange(LOCATION_MZONE)
	 --   e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	--	e1:SetCountLimit(1)
	--	e1:SetCondition(s.damcon)
	--	e1:SetOperation(s.damop)
	--	e1:SetReset(RESET_EVENT+0x3fe0000)
   --	 tc:RegisterEffect(e1)
   -- end
--end
--function s.damcon(e,tp,eg,ep,ev,re,r,rp)
--	return Duel.GetTurnPlayer()==tp
--end
--function s.damop(e,tp,eg,ep,ev,re,r,rp)
   -- Duel.Hint(HINT_CARD,0,id)
   -- Duel.Damage(tp,500,REASON_EFFECT)
--end