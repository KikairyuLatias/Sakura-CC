-- Diver Deer Vanguard Paskuas
-- Scripted with Google Gemini assistance
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.matfilter,2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)

	-- ATK Modification (Quick Effect)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,PHASE_MAIN1+PHASE_MAIN2+PHASE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)

	-- Link Summon Material Modification (Main Phase Effect)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end

-- Contact Fusion Material Filter
function s.matfilter(c)
	-- 2 "Diver Deer" monsters with 2300 or lower original ATK, except "Diver Deer Vanguard Paskuas"
	return c:IsSetCard(0x14af) and c:GetBaseAttack()<=2300 and not c:IsCode(id) and c:IsAbleToDeckOrExtraAsCost()
end

function s.contactfil(tp)
	return Duel.GetMatchingGroup(function(c) return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost() end,tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST|REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end

-- ATK Modification Target
function s.filter1(c,tp)
	return c:IsMonster() and Duel.IsExistingTarget(s.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c:GetAttack())
end
function s.filter2(c,atk)
	return c:IsFaceup() and c:IsSetCard(0x14af) and c:GetAttack()~=atk
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)
	local g1=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	e:SetLabelObject(g1:GetFirst())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g1:GetFirst():GetAttack())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local gc=e:GetLabelObject()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==gc then tc=g:GetNext() end
	if gc:IsFaceup() and gc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		--Change ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(gc:GetAttack())
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end

-- Link Material Modification Operation (Code of Soul's style)
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Reincarnation Link Summon effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.reinclinkcon)
	e1:SetTarget(s.reinclinktg)
	e1:SetOperation(s.reinclinkop)
	e1:SetValue(SUMMON_TYPE_LINK)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e2:SetTargetRange(LOCATION_EXTRA,0)
	e2:SetTarget(function(e,c) return c:IsSetCard(0x14af) and c:IsLinkMonster() end)
	e2:SetLabelObject(e1)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,1))
end
function s.reincmatfilter(c,lc,tp)
	return c:IsFaceup() and c:IsLinkMonster()
		and c:IsSummonCode(lc,SUMMON_TYPE_LINK,tp,lc:GetCode()) and c:IsCanBeLinkMaterial(lc,tp)
		and Duel.GetLocationCountFromEx(tp,tp,c,lc)>0
end
function s.reinclinkcon(e,c,must,g,min,max)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.reincmatfilter,tp,LOCATION_MZONE,0,nil,c,tp)
	local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,g,REASON_LINK)
	if must then mustg:Merge(must) end
	return ((#mustg==1 and s.reincmatfilter(mustg:GetFirst(),c,tp)) or (#mustg==0 and #g>0))
		and not Duel.HasFlagEffect(tp,id)
end
function s.reinclinktg(e,tp,eg,ep,ev,re,r,rp,chk,c,must,g,min,max)
	local g=Duel.GetMatchingGroup(s.reincmatfilter,tp,LOCATION_MZONE,0,nil,c,tp)
	local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,g,REASON_LINK)
	if must then mustg:Merge(must) end
	if #mustg>0 then
		if #mustg>1 then
			return false
		end
		mustg:KeepAlive()
		e:SetLabelObject(mustg)
		return true
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
	local tc=g:SelectUnselect(Group.CreateGroup(),tp,false,true)
	if tc then
		local sg=Group.FromCards(tc)
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function s.reinclinkop(e,tp,eg,ep,ev,re,r,rp,c,must,g,min,max)
	Duel.Hint(HINT_CARD,0,id)
	local mg=e:GetLabelObject()
	c:SetMaterial(mg)
	Duel.SendtoGrave(mg,REASON_MATERIAL|REASON_LINK)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
end