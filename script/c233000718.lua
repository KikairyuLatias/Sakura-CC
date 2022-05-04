--Skateboard Dragon Hyakunichisou
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON),3,2)
	c:EnableReviveLimit()
	--stat drop
	--usual bouncing
	--kill the ED
end
