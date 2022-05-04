--Hazmat Animal Fusion
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,s.ffilter,Fusion.OnFieldMat,s.fextra,Fusion.BanishMaterial)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	if not AshBlossomTable then AshBlossomTable={} end
	table.insert(AshBlossomTable,e1)
end

function s.ffilter(c)
	return c:IsSetCard(0x43a)
end

function s.fextra(e,tp,mg)
	--if you have Instigator Sheep
		if Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,233000588),tp,LOCATION_MZONE,0,1,nil) then
			local sg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE,0,nil)
			if #sg>0 then
				return sg,s.fcheck
		end
	--if you do not have Instigator Sheep
		else
			if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
			return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
		end
	end

	return nil
end

function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)<=1
end