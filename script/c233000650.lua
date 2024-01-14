--Pony Apprentice
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--ss lock
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e2:SetValue(s.matlimit)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetValue(s.matlimit)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetValue(s.matlimit)
	c:RegisterEffect(e4)
	--Can be treated as a Level 4 or 5 monster for the Synchro Summon of a "Pony" Synchro monster
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e5:SetRange(LOCATION_MZONE)
	e5:SetOperation(s.synop)
	c:RegisterEffect(e5)
end

--level mod
function s.synop(e,tg,ntg,sg,lv,sc,tp)
	local c=e:GetHandler()
	local sum=(sg-c):GetSum(Card.GetSynchroLevel,sc)
	if sum+c:GetSynchroLevel(sc)==lv then return true,true end
	return sc:IsSetCard(0x439) and ((sum+4==lv) or (sum+5==lv)),true
end

--material
function s.matlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x439)
end