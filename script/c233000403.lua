--Skystorm Mecha Jet - Red Blaster
local s,id=GetID()
function s.initial_effect(c)
	--atk up
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_UPDATE_ATTACK)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetTarget(s.tg)
	e0:SetValue(s.val)
	c:RegisterEffect(e0)
	--def up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(s.val)
	e1:SetTarget(s.tg)
	c:RegisterEffect(e1)
	--burn damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end

--boost functions
function s.tg(e,c)
	return c:IsType(TYPE_MONSTER) and c~=e:GetHandler()
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x7c7)
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(s.filter,c:GetControler(),LOCATION_MZONE,0,nil)*200
end

--burn functions
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local dm = Duel.GetAttacker() -- The monster that destroyed by battle (your monster)
	local dt = Duel.GetAttackTarget() -- The monster that was destroyed by battle (opponent's monster)
	-- Check if your monster is WIND and Machine, it destroyed an opponent's monster by battle
	return dm and dt and dm:IsControler(tp) and dm:IsRace(RACE_MACHINE) and dm:IsAttribute(ATTRIBUTE_WIND)
		and dt:IsControler(1-tp) and dt:IsStatus(STATUS_BATTLE_DESTROYED)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dt = Duel.GetAttackTarget() -- The monster that was destroyed by battle (opponent's monster)
	if chk==0 then return dt and dt:GetAttack() > 0 end -- Ensure destroyed monster has ATK > 0
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dt:GetAttack()) -- Inflict damage equal to the destroyed monster's ATK
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dt:GetAttack())
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetTargetPlayer()
	local d=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end