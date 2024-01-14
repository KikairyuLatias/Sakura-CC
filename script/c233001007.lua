--Dreamlight Speedstar
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--synchro level
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.synop)
	c:RegisterEffect(e2)
end

--ss
function s.filter(c)
	return c:IsFaceup() and (c:IsSetCard(0x5f7) or c:IsSetCard(0x5f8)) and c:GetCode()~=id
end

function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		Duel.IsExistingMatchingCard(s.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end

--change level to 2 or 4
function s.synop(e,tg,ntg,sg,lv,sc,tp)
	local c=e:GetHandler()
	local sum=(sg-c):GetSum(Card.GetSynchroLevel,sc)
	if sum+c:GetSynchroLevel(sc)==lv then return true,true end
	return (sc:IsSetCard(0x5f7) or sc:IsSetCard(0x5f8)) and ((sum+2==lv) or (sum+4==lv)),true
end