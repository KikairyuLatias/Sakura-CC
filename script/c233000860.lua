--Diver Dragon Commodore Asagao
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.ffilter,2)
	--cannot activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetCode(EFFECT_CANNOT_ACTIVATE)
	e0:SetRange(LOCATION_SZONE)
	e0:SetTargetRange(0,1)
	e0:SetCondition(s.accon)
	e0:SetValue(s.aclimit)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SSET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetOperation(s.aclimset)
	c:RegisterEffect(e1)
	--inherit stuff
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.descon)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end

s.material_setcode=0x64af
function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsSetCard(0x64af,fc,sumtype,tp) and c:IsLevelBelow(6) and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,sumtype,tp),fc,sumtype,tp))
end
function s.fusfilter(c,code,fc,sumtype,tp)
	return c:IsSummonCode(fc,sumtype,tp,code) and not c:IsHasEffect(511002961)
end

--anti-spell for opponent
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFusionSummoned()
end
function s.aclimit(e,re,tp)
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsSpellEffect() then return false end
	local c=re:GetHandler()
	return not c:IsLocation(LOCATION_SZONE) or c:GetFlagEffect(id)>0
end
function s.aclimset(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	for tc in aux.Next(eg) do
		tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END|RESET_OPPO_TURN,0,1)
	end
end

--i'm gonna remove the obstacles in front of me called "your top 2 cards in Deck"
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return ep~=tp and tc:IsControler(tp) and tc:IsSetCard(0x64af)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(1-tp,2)
		if g:GetCount()>0 then
			Duel.DisableShuffleCheck()
			Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		end
end