name =						"Finder Redux"
version = 					"1.1"
description =				"Version: "..version
author =					"Cunning fox"

forumthread = 				""

dst_compatible 				= true
priority 					= -1001.67825
api_version 				= 10

all_clients_require_mod     = true

server_filter_tags = {
	"finder",
	"finder redux",
}

icon_atlas = "modicon.xml"
icon       = "modicon.tex"

local bool_opts = {
	{description = "Enabled", data = true},
	{description = "Disabled", data = false},
}
local empty_opts = {{description = "", data = 0}}
local function Title(title, hover)
	return {
		name = title,
		hover = hover,
		options = empty_opts,
		default = 0,
	}
end

configuration_options =
{
	Title("Client and server options", "You can change those settings even if you're not the server host (owner)"),
	{
		name = "TINT",
		label = "Tint colour",
		hover = "Which colour you want the tint to be?",
		options = {
			{description = "White", data = 1},
			{description = "Yellow", data = 2},
			{description = "Orange", data = 3},
			{description = "Red", data = 4},
			{description = "Green", data = 5},
			{description = "Blue", data = 6},
			{description = "Ligh blue", data = 7},
			{description = "Pink", data = 8},
		},
		default = 1,
	},

	{
		name = "INGREDIENT",
		label = "Ingredient highlighting",
		hover = "Highlight chests that contain selected ingredient?",
		options = bool_opts,
		default = true,
	},

	{
		name = "ACTIVEITEM",
		label = "Active item highlighting",
		hover = "Highlight chests that containt item under your cursor?",
		options = bool_opts,
		default = true,
	},
}
