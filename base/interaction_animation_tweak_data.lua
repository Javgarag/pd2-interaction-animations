InteractionTweakData = InteractionTweakData or class()

local animations = {
	insert_gensec_keycard = {
		animation_state_machine_name = "insert_keycard",
		units = {
			{
				unit_path = "mods/int_anim/units/gen_pku_keycard/gen_pku_keycard",  -- For per-object rigging, see FPCameraPlayerBase:spawn_melee_item
				unit_sequence = "disable_interaction",
				material_config = "mods/int_anim/material_configs/gen_pku_keycard",
				align_objects = {
					"a_weapon_left"
				}
			}
		}
	},
	grab = {
		animation_state_machine_name = "grab",
	},
	press_button = {
		animation_state_machine_name = "press_button",
	},
	fix_drill = {
		animation_state_machine_name = "fix_drill",
		exit_when_time_left = 0.5,
		units = {
			{
				unit_path = "units/pd2_dlc_glace/props/glc_prop_construction_tool/glc_prop_contruction_tool_wrench01",
				material_config = "mods/int_anim/material_configs/glc_prop_contruction_tool_wrench01",
				align_objects = {
					"a_weapon_left"
				}
			}
		},
		hide_weapon = true
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
		},
		exit_when_time_left = 0.5,
		hide_weapon = true
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
		exit_when_time_left = 0.25,
		hide_weapon = true
	},
	scarface_phone = {
		animation_state_machine_name = "scarface_phone",
		units = {
			{
				unit_path = "mods/int_anim/units/fps_scarface_phone/fps_scarface_phone",
				align_objects = {
					"a_weapon_left"
				}
			}
		},
		exit_when_time_left = 1.2,
		hide_weapon = true
	}
}

local old_init = InteractionTweakData.init
function InteractionTweakData:init(tweak_data)
	old_init(self, tweak_data)
	self.animations = self.animations or {}

	self.animations.key = animations.insert_gensec_keycard
	self.animations.timelock_panel = animations.insert_gensec_keycard
	self.animations.key_double = animations.insert_gensec_keycard
	self.animations.mcm_panicroom_keycard_2 = animations.insert_gensec_keycard
	self.animations.vit_keycard_use = animations.insert_gensec_keycard
	self.animations.chca_keycard = animations.insert_gensec_keycard

	self.animations.diamond_pickup = animations.grab
	self.animations.diamond_pickup_pal = animations.grab
	self.animations.safe_loot_pickup = animations.grab
	self.animations.mus_pku_artifact = animations.grab
	self.animations.tiara_pickup = animations.grab
	self.animations.diamond_single_pickup = animations.grab
	self.animations.diamond_single_pickup_axis = animations.grab
	self.animations.suburbia_necklace_pickup = animations.grab
	self.animations.money_wrap_single_bundle = animations.grab
	self.animations.pickup_phone = animations.grab
	self.animations.pickup_tablet = animations.grab
	self.animations.pickup_keycard = animations.grab
	self.animations.pickup_asset = animations.grab
	self.animations.gen_pku_crowbar = animations.grab
	self.animations.gen_pku_crowbar_stack = animations.grab
	self.animations.pickup_hotel_room_keycard = animations.grab
	self.animations.cas_chips_pile = animations.grab
	self.animations.diamond_pickup_axis = animations.grab
	self.animations.mex_red_room_key = animations.grab
	self.animations.pex_red_room_key = animations.grab
	self.animations.pickup_wanker_key = animations.grab
	self.animations.pickup_keycard_axis = animations.grab
	self.animations.chas_pickup_keychain_forklift = animations.grab
	self.animations.money_wrap_single_chas = animations.grab
	self.animations.pent_press_take_gas_can = animations.grab
	self.animations.pent_take_wire = animations.grab
	self.animations.ranc_hold_take_bugging_device = animations.grab
	self.animations.ranc_press_pickup_horseshoe = animations.grab
	self.animations.pickup_asset_zaxis = animations.grab
	self.animations.deep_press_pickup_texas_suit = animations.grab
	self.animations.muriatic_acid = animations.grab
	self.animations.caustic_soda = animations.grab
	self.animations.hydrogen_chloride = animations.grab
	self.animations.hospital_veil_take = animations.grab
	self.animations.christmas_present = animations.grab
	self.animations.take_confidential_folder = animations.grab
	self.animations.stn_int_take_camera = animations.grab
	self.animations.gen_pku_thermite = animations.grab
	self.animations.gen_pku_thermite_paste = animations.grab
	self.animations.gen_pku_thermite_paste_not_deployable = animations.grab
	self.animations.gen_pku_lance_part = animations.grab
	self.animations.take_keys = animations.grab
	self.animations.pku_take_mask = animations.grab
	self.animations.press_c4_pku = animations.grab
	self.animations.take_chainsaw = animations.grab
	self.animations.mus_take_diamond = animations.grab
	self.animations.panic_room_key = animations.grab
	self.animations.cas_take_usb_key = animations.grab
	self.animations.cas_take_usb_key_data = animations.grab
	self.animations.cas_bfd_drill_toolbox = animations.grab
	self.animations.cas_elevator_key = animations.grab
	self.animations.winning_slip = animations.grab
	self.animations.red_take_envelope = animations.grab
	self.animations.press_printer_ink = animations.grab
	self.animations.press_printer_paper = animations.grab
	self.animations.ring_band = animations.grab
	self.animations.press_take_liquid_nitrogen = animations.grab
	self.animations.press_take_folder = animations.grab
	self.animations.press_take_sample = animations.grab
	self.animations.press_take_chimichanga = animations.grab
	self.animations.press_take_elevator = animations.grab
	self.animations.tag_take_stapler = animations.grab
	self.animations.hold_take_compound_a = animations.grab
	self.animations.hold_take_compound_b = animations.grab
	self.animations.hold_take_compound_c = animations.grab
	self.animations.hold_take_compound_d = animations.grab
	self.animations.pex_get_unloaded_card = animations.grab
	self.animations.sand_take_adrenaline = animations.grab
	self.animations.sand_take_usb = animations.grab
	self.animations.sand_take_laxative = animations.grab
	self.animations.sand_take_paddles = animations.grab
	self.animations.sand_take_note = animations.grab
	self.animations.chca_hold_take_business_card = animations.grab
	self.animations.ranc_press_take_laptop = animations.grab
	self.animations.ranc_hold_take_barrel = animations.grab
	self.animations.ranc_hold_take_receiver = animations.grab
	self.animations.ranc_hold_take_stock = animations.grab
	self.animations.ranc_take_acid = animations.grab
	self.animations.ranc_take_sheriff_star = animations.grab
	self.animations.ranc_take_hammer = animations.grab
	self.animations.ranc_take_silver_ingot = animations.grab
	self.animations.ranc_take_mould = animations.grab
	self.animations.trai_achievement_container_key = animations.grab
	self.animations.corp_key_fob = animations.grab
	self.animations.pku_manifest = animations.grab
	self.animations.money_bag = animations.grab

	self.animations.drill_jammed = animations.fix_drill
	self.animations.lance_jammed = animations.fix_drill
	self.animations.huge_lance_jammed = animations.fix_drill
	self.animations.hospital_saw_jammed = animations.fix_drill
	self.animations.apartment_saw_jammed = animations.fix_drill
	self.animations.secret_stash_saw_jammed = animations.fix_drill
	self.animations.gen_int_saw_jammed = animations.fix_drill
	self.animations.drill_upgrade = animations.fix_drill
	self.animations.gen_int_saw_upgrade = animations.fix_drill

	self.animations.corpse_alarm_pager = animations.answer_radio

	self.animations.pick_lock_easy = animations.lockpick
	self.animations.pick_lock_easy_no_skill = animations.lockpick
	self.animations.pick_lock_hard = animations.lockpick
	self.animations.pick_lock_hard_no_skill = animations.lockpick
	self.animations.pick_lock_deposit_transport = animations.lockpick
	self.animations.lockpick_locker = animations.lockpick
	self.animations.pick_lock_30 = animations.lockpick
	self.animations.man_trunk_lockpick = animations.lockpick
	self.animations.trai_hold_picklock_toolsafe = animations.lockpick
	self.animations.pex_pick_lock_easy_no_skill = animations.lockpick
	self.animations.fex_pick_lock_easy_no_skill = animations.lockpick
	self.animations.chas_pick_lock_easy_no_skill = animations.lockpick
	self.animations.fake_pick_lock_easy_no_skill = animations.lockpick
	self.animations.pent_pick_lock = animations.lockpick
	self.animations.pick_lock_easy_no_skill_pent = animations.lockpick
	self.animations.lockpick_int_office = animations.lockpick
	self.animations.no_interaction = animations.lockpick
	self.animations.pick_lock_x_axis = animations.lockpick
	self.animations.pick_lock_hard_no_skill_deactivated = animations.lockpick

	self.animations.hold_phone_call_office = animations.scarface_phone

	self.animations.push_button_secret = animations.press_button
	self.animations.push_button_des = animations.press_button
	self.animations.fex_press_frog_symbol = animations.press_button
	self.animations.fex_press_ant_symbol = animations.press_button
	self.animations.fex_press_bat_symbol = animations.press_button
	self.animations.fex_press_boar_symbol = animations.press_button
	self.animations.fex_press_bunny_symbol = animations.press_button
	self.animations.fex_press_butterfly_symbol = animations.press_button
	self.animations.fex_press_crab_symbol = animations.press_button
	self.animations.fex_press_crocodile_symbol = animations.press_button
	self.animations.fex_press_dog_symbol = animations.press_button
	self.animations.fex_press_fish_symbol = animations.press_button
	self.animations.fex_press_jaguar_symbol = animations.press_button
	self.animations.fex_press_lizard_symbol = animations.press_button
	self.animations.fex_press_millipede_symbol = animations.press_button
	self.animations.fex_press_monkey_symbol = animations.press_button
	self.animations.fex_press_owl_symbol = animations.press_button
	self.animations.fex_press_snail_symbol = animations.press_button
	self.animations.fex_press_snake_symbol = animations.press_button
	self.animations.fex_press_spider_symbol = animations.press_button
	self.animations.fex_press_squirrel_symbol = animations.press_button
	self.animations.fex_press_turtle_symbol = animations.press_button
	self.animations.sand_button_number_sign = animations.press_button
	self.animations.pent_press_call_elevator = animations.press_button
	self.animations.pent_kitchen_elevator = animations.press_button
	self.animations.ranc_press_turn_off_radio = animations.press_button
	self.animations.deep_press_test_oil_sample = animations.press_button
	self.animations.deep_press_achi_intercom_phone = animations.press_button
	self.animations.button_infopad = animations.press_button
	self.animations.cas_button_01 = animations.press_button
	self.animations.cas_button_02 = animations.press_button
	self.animations.cas_button_03 = animations.press_button
	self.animations.cas_button_04 = animations.press_button
	self.animations.cas_button_05 = animations.press_button
	self.animations.cas_button_06 = animations.press_button
	self.animations.cas_button_07 = animations.press_button
	self.animations.cas_button_08 = animations.press_button
	self.animations.cas_button_09 = animations.press_button
	self.animations.cas_button_0 = animations.press_button
	self.animations.cas_button_clear = animations.press_button
	self.animations.cas_button_enter = animations.press_button
	self.animations.press_play_music = animations.press_button
	self.animations.press_start_weapon_course = animations.press_button
	self.animations.press_play_jacket_sound = animations.press_button
	self.animations.press_touch_book = animations.press_button
	self.animations.press_call_elevator = animations.press_button
	self.animations.pent_press_signal_operator = animations.press_button
	self.animations.press_play_jacket_sound = animations.press_button
	self.animations.press_play_jacket_sound = animations.press_button
	self.animations.barrier_numpad = animations.press_button
end