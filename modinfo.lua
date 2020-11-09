name =						"Finder Redux"
version = 					"1.0.1"
description =				"Version: "..version
author =					"Cunning fox"

forumthread = 				""

dst_compatible 				= true
priority 					= -1001.67825
api_version 				= 10

all_clients_require_mod     = true

server_filter_tags = {}

icon_atlas = "modicon.xml"
icon       = "modicon.tex"

configuration_options =
{
	{
		name = "TINT",
		label = "Tint colour",
		hover = "Which colour you want the tint to be? You can change it even if you're not the server host (owner)",
		options =	{
                        {description = "Red", data = 1}, 
						{description = "Green", data = 2},
						{description = "Blue", data = 3}, 
					},
		default = 1,
	},
}
