local TINT_CLR = GetModConfigData("TINT") or 1
local INGREDIENT_ENABLED = GetModConfigData("INGREDIENT") or true
local ACTIVEITEM_ENABLED = GetModConfigData("ACTIVEITEM") or true

local env = env
GLOBAL.setfenv(1, GLOBAL)

local function Print(...) end
if not env.MODROOT:find("workshop-") then
	CHEATS_ENABLED = true
	Print = function(...) print(...) end
end

local CHEST_COLOURS = {
	{1, 0, 0, 1},
	{0, 1, 0, 1},
	{0, 0, 1, 1},
}

-- Mini-module that works like colouradder component
local ColourManager = require("colour_manager")(CHEST_COLOURS[TINT_CLR])

-- Server calls this on clients
local HIGHLITED_ENTS = {}
AddClientModRPCHandler("FINDER_REDUX", "HIGHLIGHT", function(chest)
	if not INGREDIENT_ENABLED then
		return
	end
	Print("got client rpc", chest)
	-- Probably a bug? The last argument is allways some random function :|
	chest = (chest and type(chest) ~= "function") and chest or nil
	if chest then
		ColourManager:PushColour(chest, "highlight")
		table.insert(HIGHLITED_ENTS, chest)
	elseif next(HIGHLITED_ENTS) then
		for i, ent in ipairs(HIGHLITED_ENTS) do
			ColourManager:PopColour(ent, "highlight")
		end
		HIGHLITED_ENTS = {}
	end
end)

-- Custom RPC for active items since we can hover over
-- Ingredients with active item selected
local HIGHLITED_ACTIVEITEM_ENTS = {}
AddClientModRPCHandler("FINDER_REDUX", "HIGHLIGHT_ACTIVEITEM", function(chest)
	if not ACTIVEITEM_ENABLED then
		return
	end
	Print("got client rpc (activeitem)", chest)
	chest = (chest and type(chest) ~= "function") and chest or nil
	if chest then
		ColourManager:PushColour(chest, "activeitem")
		table.insert(HIGHLITED_ACTIVEITEM_ENTS, chest)
	elseif next(HIGHLITED_ACTIVEITEM_ENTS) then
		for i, ent in ipairs(HIGHLITED_ACTIVEITEM_ENTS) do
			ColourManager:PopColour(ent, "activeitem")
		end
		HIGHLITED_ACTIVEITEM_ENTS = {}
	end
end)

local function FindItem(inst, item, active_item)
	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 20, {"_container"}, {"player", "DECOR", "FX", "NOCLICK", "INLIMBO", "outofreach"})
	for _, ent in ipairs(ents) do
		if ent and ent:IsValid() and ent.entity:IsVisible() and
		ent.components.container and ent.components.container:Has(item, 1) then
			-- Send our chest to client
			-- Not sure if we call it more then once per tick. Needs to be checked
			Print("Sending client rpc")
			SendModRPCToClient(GetClientModRPC("FINDER_REDUX", active_item and "HIGHLIGHT_ACTIVEITEM" or "HIGHLIGHT"), inst, ent)
		end
	end
end

local ingredients = require("cooking").ingredients
local function FindFoodTag(inst, searchtag)
	-- Look through cooking and find all foods with the tag we need
	-- Then iterate through all food and run FindItem for every item
	local prefabs = {}
	for prefab, data in pairs(ingredients) do
		for tag, num in pairs(data.tags) do
			if tag == searchtag then
				FindItem(inst, prefab)
				break
			end
		end
	end
end

-- Client calls this on its side and it runs on server
-- Item is a prefab string, not an instance
AddModRPCHandler("FINDER_REDUX", "FIND", function(inst, item, isfoodtag)
	Print("Got server RPC", item)
	if item then
		if isfoodtag then
			FindFoodTag(inst, item)
		else
			FindItem(inst, item)
		end
	else
		SendModRPCToClient(GetClientModRPC("FINDER_REDUX", "HIGHLIGHT"), inst, nil)
	end
end)

-- Update hover colour to highlight active item
-- (the item in cursor)
env.AddComponentPostInit("inventory", function(self)
	if not self.inst:HasTag("player") then
		return
	end
	
	local _SetActiveItem = self.SetActiveItem
	function self:SetActiveItem(item, ...)
		if item then
			FindItem(self.inst, item.prefab or nil, true)
		else
			SendModRPCToClient(GetClientModRPC("FINDER_REDUX", "HIGHLIGHT_ACTIVEITEM"), self.inst, nil)
		end
		return _SetActiveItem(self, item, ...)
	end
end)

------------------------------------------------------------
-------Patching widgets to send out items to server---------
------------------------------------------------------------
-- We don't need to run this on dedicated server.
-- Clients only (self-hosted servers too)
if TheNet:IsDedicated() then
	return
end

local AddClassPostConstruct = env.AddClassPostConstruct
local pass = function() return true end

local function FindItem(item)
	Print("Sending RPC...", item)
	SendModRPCToServer(GetModRPC("FINDER_REDUX", "FIND"), item)
end

-- When ingredient in recipepopup is hovered
AddClassPostConstruct("widgets/ingredientui", function(self, atlas, image, quantity, on_hand, has_enough, name, owner, recipe_type)
	-- Save our recipe_type
	self.product = recipe_type
	
    local _OnGainFocus = self.OnGainFocus or pass
    local _OnLoseFocus = self.OnLoseFocus or pass

	function self:OnGainFocus(...)
		if self.product then
			FindItem(self.product)
		end
		return _OnGainFocus(self, ...)
    end

	function self:OnLoseFocus(...)
		FindItem(nil)
		return _OnLoseFocus(self, ...)
    end
end)

AddClassPostConstruct("widgets/tabgroup", function(self)
    local _DeselectAll = self.DeselectAll
	function self:DeselectAll(...)
		FindItem(nil)
		return _DeselectAll(self, ...)
    end
end)

-- Compatibility with Craft Pot Mod
-- Looking for food with matching tags
if pcall(require, "widgets/foodingredientui") then
	local function FindTag(tag)
		Print("Sending RPC (tag)...", tag)
		SendModRPCToServer(GetModRPC("FINDER_REDUX", "FIND"), tag, true)
	end

    AddClassPostConstruct("widgets/foodingredientui", function(self)
		local _OnGainFocus = self.OnGainFocus or pass
		local _OnLoseFocus = self.OnLoseFocus or pass
		
        function self:OnGainFocus(...)
            local searchtag = self.prefab -- tag or name
            local isname = self.is_name
			
			-- Clear old highlights
			FindItem(nil)
            if isname then
				FindItem(PREFABDEFINITIONS[searchtag] and PREFABDEFINITIONS[searchtag].name or searchtag)
            else
				FindTag(searchtag)
			end
			
            return _OnGainFocus(self, ...)
		end

		function self:OnLoseFocus(...)
			FindTag(nil)
			return _OnLoseFocus(self, ...)
		end
    end)

    AddClassPostConstruct("widgets/foodcrafting", function(self)
        local _OnLoseFocus = self.OnLoseFocus or pass
        function self:OnLoseFocus(...)
            FindItem(nil)
			return _OnLoseFocus(self, ...) 
        end
        
		local _Close = self.Close or pass
		function self:Close(...)
			FindItem(nil)
			return _Close(self, ...) 
		end
    end)
end

