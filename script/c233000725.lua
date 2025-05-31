-- Sunbeast Kia
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetCountLimit(1,id) -- "You can only Special Summon 'Sunbeast Kia' once per turn this way."
	c:RegisterEffect(e1)
	--spsummon count limit
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SPSUMMON_COUNT_LIMIT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(0,0) -- Applies only to opponent (0)
	e4:SetValue(1) -- Limit to 1 Special Summon
	e4:SetReset(RESET_PHASE+PHASE_END) -- Added explicit reset for the counter
	c:RegisterEffect(e4)
end

--special summon
function s.filter(c)
	-- "Level 5 'Sunbeast' monster, except 'Sunbeast Kia'"
	return c:IsFaceup() and c:IsSetCard(0x640) and c:GetLevel()==5 and c:GetCode()~=id
end
function s.spcon(e,c)
	if c==nil then return true end
	-- Original condition for "Sunbeast Kia"
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		Duel.IsExistingMatchingCard(s.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end