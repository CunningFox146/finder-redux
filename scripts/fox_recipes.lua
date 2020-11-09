local function ChangeRecipe(name, ing_arr, tech, tab, key, cnt)
	local rec = AllRecipes[name]
	
	if not rec then
		print('ERROR: Recipe "'..tostring(name)..'" not found!')
		return
	end
	
	if ing_arr then
		local ingredients = {}
		local character_ingredients = {}
		local tech_ingredients = {}
		
		for k, v in pairs(ing_arr) do
			table.insert(
				(IsCharacterIngredient(k) and character_ingredients) or
				(IsTechIngredient(k) and tech_ingredients) or
				ingredients,
				Ingredient(k, v)
			)
		end
		
		rec.ingredients = ingredients
		rec.character_ingredients = character_ingredients
		rec.tech_ingredients = tech_ingredients
	end
	
	if tech then
		rec.level = tech
	end
	
	if tab then
		rec.tab = tab
	end
	
	if key then
		rec.sortkey = key
	end
	
	if cnt then
		rec.numtogive = cnt
	end
end

ChangeRecipe("critter_kitten_builder", {coontail = 1, meat = 1})
ChangeRecipe("critter_puppy_builder", {houndstooth = 1, monstermeat = 1})
ChangeRecipe("critter_lamb_builder", {steelwool = 1, meat = 1})
ChangeRecipe("critter_perdling_builder", {trailmix = 1, drumstick = 2})
ChangeRecipe("critter_dragonling_builder", {hotchili = 1, meat = 1})
ChangeRecipe("critter_glomling_builder", {glommerfuel = 1, monstermeat = 1})
ChangeRecipe("critter_lunarmothling_builder", {moonbutterfly = 1, butterfly = 1})
