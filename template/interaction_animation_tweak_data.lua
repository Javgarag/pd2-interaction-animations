InteractionTweakData = InteractionTweakData or class()

local animations = {
	-- Offhand; remove this is if your animation is divided into parts.
	insert_gensec_keycard = { -- Descriptive name for your animation that you'll use below, in the definition.
		animation_state_machine_name = "insert_keycard", -- The name you used in all the other files.
		units = { -- If your animation uses units, add them here. If not, remove this section.
			{
				unit_path = "units/payday2/pickups/gen_pku_keycard/gen_pku_keycard", -- Path to the unit.
				unit_sequence = "disable_interaction", -- If your unit needs special sequence_manager operations, add the sequence here. If not, remove this line.
				material_config = "mods/int_anim/material_configs/gen_pku_keycard", -- Path to the depth_scaling material_config.
				align_objects = {
					"a_weapon_left" -- Bone that the unit will be parented to.
				}
			}
		}
	},

	-- Long; remove this is if your animation is instant.
	fix_drill = { -- Descriptive name for your animation that you'll use below, in the definition.
		animation_state_machine_name = "fix_drill",
		units = { -- If your animation uses units, add them here. If not, remove this section!
			{
				unit_path = "units/pd2_dlc_glace/props/glc_prop_construction_tool/glc_prop_contruction_tool_wrench01", -- Path to the unit.
				material_config = "mods/int_anim/material_configs/glc_prop_contruction_tool_wrench01", -- Path to the depth_scaling material_config.
				align_objects = {
					"a_weapon_left" -- Bone that the unit will be parented to.
				}
			}
		},
		exit_when_time_left = 1,
		hide_weapon = true
	}
}

local old_init = InteractionTweakData.init
function InteractionTweakData:init(tweak_data)
	old_init(self, tweak_data)
	self.animations = self.animations or {}

	-- Have a look in the original InteractionTweakData for interaction IDs, you can use string_id revealer in-game to find yours more easily; add your animation to the appropriate one.
	-- Structure: self.animations.[interaction_id] = animations.[your_animation]
	-- You can apply a single animation to multiple interaction IDs
	self.animations.key = animations.insert_gensec_keycard 
	self.animations.drill_jammed = animations.fix_drill
end