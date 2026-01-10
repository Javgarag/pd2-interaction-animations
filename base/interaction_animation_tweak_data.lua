InteractionTweakData = InteractionTweakData or class()

local animations = {
	insert_gensec_keycard = {
		animation_state_machine_name = "insert_keycard",
		units = {
			{
				unit_path = "units/payday2/pickups/gen_pku_keycard/gen_pku_keycard",  -- For per-object rigging, see FPCameraPlayerBase:spawn_melee_item
				unit_sequence = "disable_interaction",
				material_config = "mods/int_anim/material_configs/gen_pku_keycard",
				align_objects = {
					"a_weapon_left"
				}
			}
		}
	},
	grab = {
		animation_state_machine_name = "grab"
	},
	fix_drill = {
		animation_state_machine_name = "fix_drill",
		units = {
			{
				unit_path = "units/pd2_dlc_glace/props/glc_prop_construction_tool/glc_prop_contruction_tool_wrench01",
				material_config = "mods/int_anim/material_configs/glc_prop_contruction_tool_wrench01",
				align_objects = {
					"a_weapon_left"
				}
			}
		}
	},
	answer_radio = {
		animation_state_machine_name = "answer_radio",
		units = {
			{
				unit_path = "mods/int_anim/units/fps_interact_radio/fps_interact_radio",
				align_objects = {
					"a_weapon_left"
				}
			}
		}
	},
	lockpick = {
		animation_state_machine_name = "lockpick",
		units = {
			{
				unit_path = "mods/int_anim/units/fps_lockpick/fps_lockpick",
				align_objects = {
					"a_weapon_right"
				}
			},
			{
				unit_path = "mods/int_anim/units/fps_tension_tool/fps_tension_tool",
				align_objects = {
					"a_weapon_left"
				}
			}
		},
		exit_when_time_left = 3,
		hide_weapon = true
	}
}

local old_init = InteractionTweakData.init
function InteractionTweakData:init(tweak_data)
	old_init(self, tweak_data)
	self.animations = {
		key = animations.insert_gensec_keycard,
		timelock_panel = animations.insert_gensec_keycard,
		key_double = animations.insert_gensec_keycard,
		mcm_panicroom_keycard_2 = animations.insert_gensec_keycard,
		vit_keycard_use = animations.insert_gensec_keycard,
		chca_keycard = animations.insert_gensec_keycard,

		diamond_pickup = animations.grab,
		diamond_pickup_pal = animations.grab,
		safe_loot_pickup = animations.grab,
		mus_pku_artifact = animations.grab,
		tiara_pickup = animations.grab,
		diamond_single_pickup = animations.grab,
		diamond_single_pickup_axis = animations.grab,
		suburbia_necklace_pickup = animations.grab,
		money_wrap_single_bundle = animations.grab,
		pickup_phone = animations.grab,
		pickup_tablet = animations.grab,
		pickup_keycard = animations.grab,
		pickup_asset = animations.grab,
		gen_pku_crowbar = animations.grab,
		gen_pku_crowbar_stack = animations.grab,
		pickup_hotel_room_keycard = animations.grab,
		cas_chips_pile = animations.grab,
		diamond_pickup_axis = animations.grab,
		mex_red_room_key = animations.grab,
		pex_red_room_key = animations.grab,
		pickup_wanker_key = animations.grab,
		pickup_keycard_axis = animations.grab,
		chas_pickup_keychain_forklift = animations.grab,
		money_wrap_single_chas = animations.grab,
		pent_press_take_gas_can = animations.grab,
		pent_take_wire = animations.grab,
		ranc_hold_take_bugging_device = animations.grab,
		ranc_press_pickup_horseshoe = animations.grab,
		pickup_asset_zaxis = animations.grab,
		deep_press_pickup_texas_suit = animations.grab,
		muriatic_acid = animations.grab,
		caustic_soda = animations.grab,
		hydrogen_chloride = animations.grab,
		hospital_veil_take = animations.grab,
		christmas_present = animations.grab,
		take_confidential_folder = animations.grab,
		stn_int_take_camera = animations.grab,
		gen_pku_thermite = animations.grab,
		gen_pku_thermite_paste = animations.grab,
		gen_pku_thermite_paste_not_deployable = animations.grab,
		gen_pku_lance_part = animations.grab,
		take_keys = animations.grab,
		pku_take_mask = animations.grab,
		press_c4_pku = animations.grab,
		take_chainsaw = animations.grab,
		mus_take_diamond = animations.grab,
		panic_room_key = animations.grab,
		cas_take_usb_key = animations.grab,
		cas_take_usb_key_data = animations.grab,
		cas_bfd_drill_toolbox = animations.grab,
		cas_elevator_key = animations.grab,
		winning_slip = animations.grab,
		red_take_envelope = animations.grab,
		press_printer_ink = animations.grab,
		press_printer_paper = animations.grab,
		ring_band = animations.grab,
		press_take_liquid_nitrogen = animations.grab,
		press_take_folder = animations.grab,
		press_take_sample = animations.grab,
		press_take_chimichanga = animations.grab,
		press_take_elevator = animations.grab,
		tag_take_stapler = animations.grab,
		hold_take_compound_a = animations.grab, 
		hold_take_compound_b = animations.grab,
		hold_take_compound_c = animations.grab,
		hold_take_compound_d = animations.grab,
		pex_get_unloaded_card = animations.grab,
		sand_take_adrenaline = animations.grab,
		sand_take_usb = animations.grab,
		sand_take_laxative = animations.grab,
		sand_take_paddles = animations.grab,
		sand_take_note = animations.grab,
		chca_hold_take_business_card = animations.grab,
		ranc_press_take_laptop = animations.grab,
		ranc_hold_take_barrel = animations.grab,
		ranc_hold_take_receiver = animations.grab,
		ranc_hold_take_stock = animations.grab,
		ranc_take_acid = animations.grab,
		ranc_take_sheriff_star = animations.grab,
		ranc_take_hammer = animations.grab,
		ranc_take_silver_ingot = animations.grab,
		ranc_take_mould = animations.grab,
		trai_achievement_container_key = animations.grab,
		corp_key_fob = animations.grab,
		pku_manifest = animations.grab,
		money_bag = animations.grab,

		drill_jammed = animations.fix_drill,
		lance_jammed = animations.fix_drill,
		huge_lance_jammed = animations.fix_drill,
		hospital_saw_jammed = animations.fix_drill,
		apartment_saw_jammed = animations.fix_drill,
		secret_stash_saw_jammed = animations.fix_drill,
		gen_int_saw_jammed = animations.fix_drill,
		drill_upgrade = animations.fix_drill,

		corpse_alarm_pager = animations.answer_radio,

		pick_lock_easy = animations.lockpick,
		pick_lock_easy_no_skill = animations.lockpick,
		pick_lock_hard = animations.lockpick,
		pick_lock_hard_no_skill = animations.lockpick,
		pick_lock_deposit_transport = animations.lockpick,
		lockpick_locker = animations.lockpick,
		pick_lock_30 = animations.lockpick,
		man_trunk_lockpick = animations.lockpick,
		trai_hold_picklock_toolsafe = animations.lockpick,
		pex_pick_lock_easy_no_skill = animations.lockpick,
		fex_pick_lock_easy_no_skill = animations.lockpick,
		chas_pick_lock_easy_no_skill = animations.lockpick,
		fake_pick_lock_easy_no_skill = animations.lockpick,
		pent_pick_lock = animations.lockpick,
		pick_lock_easy_no_skill_pent = animations.lockpick,
		lockpick_int_office = animations.lockpick,
		no_interaction = animations.lockpick,
		pick_lock_x_axis = animations.lockpick,
		pick_lock_hard_no_skill_deactivated = animations.lockpick,
	}
end