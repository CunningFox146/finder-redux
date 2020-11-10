-- Idk why regular unpack doesn't work
local function UnpackColour(clr)
	return clr[1] or 1, clr[2] or 1, clr[3] or 1, clr[4] or 1
end

local function ApplyColour(inst, colour)
	if not inst:IsValid() or not inst.AnimState then
		return
	end

	if not inst._add_colour then
		inst._add_colour = {inst.AnimState:GetAddColour()}
	end

	inst.AnimState:SetAddColour(UnpackColour(colour))
end

local function ClearColour(inst)
	if not inst:IsValid() or not inst.AnimState then
		return
	end
	
	if inst._add_colour then
		inst.AnimState:SetAddColour(UnpackColour(inst._add_colour))
		inst._add_colour = nil
	else
		inst.AnimState:SetAddColour(0, 0, 0, 0)
	end
end

local ColourManager = Class(function(self, colour)
    self.colour = colour

    self.ents = {}
end)

function ColourManager:PushColour(ent, reason)
    if not self.ents[ent] then
        self.ents[ent] = {}
    end

    self.ents[ent][reason] = true

    if not ent._colour_listener then
        ent._colour_listener = function(ent) self.ents[ent] = nil end
        ent:ListenForEvent("onremove", ent._colour_listener)
    end

    ApplyColour(ent, self.colour)
end

function ColourManager:PopColour(ent, reason)
    if not self.ents[ent] then
        return
    end
    self.ents[ent][reason] = nil
    if not next(self.ents[ent]) then
        ClearColour(ent)
        self.ents[ent] = nil

        if ent._colour_listener then
            ent:RemoveEventCallback("onremove", ent._colour_listener)
            ent._colour_listener = nil
        end
    end
end

return ColourManager