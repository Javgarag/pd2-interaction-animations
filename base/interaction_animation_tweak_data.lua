InteractionTweakData = InteractionTweakData or class()

local animations = {
	insert_gensec_keycard = {
		animation_state_machine_name = "insert_keycard",
		offhand_animation = {
			name = "tester",
			speed = 1.3
		},
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
		animation_state_machine_name = "grab",
		offhand_animation = {
			name = "tester",
			speed = 1
		}
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
end