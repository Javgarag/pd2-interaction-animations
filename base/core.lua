PackageManager:load("packages/intanim")

if RequiredScript == "lib/units/beings/player/states/playerstandard" then
	Hooks:PostHook(PlayerStandard, "_update_check_actions", "int_anim_update_check_interacting", function(self, t, dt, paused)
		self:_update_unequip_interaction_timers(t)
	end)

	Hooks:PreHook(PlayerStandard, "_check_action_interact", "int_anim_do_interact_anim_checks", function(self, t, input)
		self._interaction_unit = self._interaction:active_unit()
		if not self._interaction_unit or not alive(self._interaction_unit) then
			return
		end

		self._can_play_interact_anim = self._interaction_unit:interaction():can_interact(managers.player:player_unit())
	end)

	Hooks:PostHook(PlayerStandard, "_update_interaction_timers", "int_anim_update_interaction_timers", function(self, t)
		if self._interaction_anim and self._interact_expire_t and ((self._interact_expire_t <= (self._interaction_anim.exit_when_time_left or 1))) and self._camera_unit:base().interaction_hold_anim_playing then
			self._camera_unit:base().queue_interaction_anim_exit = true
		end 
	end)
end

if RequiredScript == "lib/units/beings/player/states/playercarry" then
	Hooks:PostHook(PlayerCarry, "_update_check_actions", "int_anim_update_check_interacting_carry", function(self, t, dt, paused)
		self:_update_unequip_interaction_timers(t)
	end)
end

UnitBase = UnitBase or class()
PlayerMovementState = PlayerMovementState or class()

--[[
	PlayerStandard._ext_camera = PlayerCamera object
	PlayerStandard._ext_camera:camera_unit() = FPCameraPlayerBase object
]]--
PlayerStandard = PlayerStandard or class(PlayerMovementState)

FPCameraPlayerBase = FPCameraPlayerBase or class(UnitBase)
PlayerCamera = PlayerCamera or class()

-- Instant interactions
function PlayerStandard:_play_interact_redirect(t)

	if self._shooting or self._running or not self._equipped_unit:base():start_shooting_allowed() or self:_is_reloading() or self:_changing_weapon() or self:_is_meleeing() or self:in_steelsight() then
		return
	end

	self._state_data.interact_redirect_t = t + 1
	self._interaction_anim = self._camera_unit:base():set_interaction_anim(tweak_data.interaction.animations[self._interaction_unit:interaction().tweak_data])

	local has_akimbo = alive(self._equipped_unit) and self._equipped_unit:base().akimbo

	if not self._interaction_anim or not self._can_play_interact_anim or has_akimbo then
		self._ext_camera:play_redirect(self:get_animation("use"))
		return
	end

	self._ext_camera:play_ik_redirect("tester")
	--self._ext_camera:play_redirect(Idstring(self._interaction_anim.animation_state_machine_name))
end

-- Timed interactions (hard overwrite)
function PlayerStandard:_start_action_interact(t, input, timer, interact_object)
	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self:_interupt_action_running(t)
	self:_interupt_action_charging_weapon(t)

	local final_timer = timer
	final_timer = managers.modifiers:modify_value("PlayerStandard:OnStartInteraction", final_timer, interact_object)
	self._interact_expire_t = final_timer
	local start_timer = 0
	self._interact_params = {
		object = interact_object,
		timer = final_timer,
		tweak_data = interact_object:interaction().tweak_data
	}
	
	self._interaction_anim = self._camera_unit:base():set_interaction_anim(tweak_data.interaction.animations[self._interaction_unit:interaction().tweak_data])

	if self._interaction_anim then
		local tweak_data = self._equipped_unit:base():weapon_tweak_data()
		self._unequip_weapon_on_interaction_expire_t = t + ((tweak_data.timers.unequip or 0.5) / (self._interaction_anim.unequip_speed_multiplier or 1))
	end
	self:_play_unequip_animation(self._interaction_anim and self._interaction_anim.unequip_speed_multiplier or nil)

	managers.hud:show_interaction_bar(start_timer, final_timer)
	managers.network:session():send_to_peers_synched("sync_teammate_progress", 1, true, self._interact_params.tweak_data, final_timer, false)
	self._unit:network():send("sync_interaction_anim", true, self._interact_params.tweak_data)
end

-- Timed interaction interupt (play specific interupt redirect, also a hard overwrite)
function PlayerStandard:_interupt_action_interact(t, input, complete)
	if self._interact_expire_t then
		self:_clear_tap_to_interact()

		self._interact_expire_t = nil

		if alive(self._interact_params.object) then
			self._interact_params.object:interaction():interact_interupt(self._unit, complete)
		end

		self._ext_camera:camera_unit():base():remove_limits()
		self._interaction:interupt_action_interact(self._unit)
		managers.network:session():send_to_peers_synched("sync_teammate_progress", 1, false, self._interact_params.tweak_data, 0, complete and true or false)

		self._interact_params = nil

		if self._interaction_anim and self._camera_unit:base().interaction_hold_anim_playing then  -- Changes to vanilla code are here (+ see FPCameraPlayerBase:anim_clbk_interact_interupt_exit)
			self._ext_camera:play_redirect(Idstring("interact_interupt"))
		else
			self._camera_unit:base():anim_clbk_unspawn_interaction_items()
			self:_play_equip_animation()
		end

		managers.hud:hide_interaction_bar(complete)
		self._unit:network():send("sync_interaction_anim", false, "") -- Vanilla third person animation
	end
end

-- Equip/unequip hard overwrites
function PlayerStandard:_play_equip_animation(speed_multiplier)
	local tweak_data = self._equipped_unit:base():weapon_tweak_data()
	self._equip_weapon_expire_t = managers.player:player_timer():time() + (tweak_data.timers.equip or 0.7)
	self._ext_camera:play_redirect(self:get_animation("equip"), speed_multiplier or nil)

	self._equipped_unit:base():tweak_data_anim_stop("unequip")
	self._equipped_unit:base():tweak_data_anim_play("equip", speed_multiplier or nil)

	local interaction_anim = self._camera_unit:base():interaction_anim()
	if interaction_anim then
		if interaction_anim.hide_weapon then
			self._camera_unit:base():show_weapon()
		end
		self._camera_unit:base():clear_interaction_anim()
		self._camera_unit:base():clear_interact_object()
	end
end

function PlayerStandard:_play_unequip_animation(speed_multiplier)
	self._ext_camera:play_redirect(self:get_animation("unequip"), speed_multiplier or nil)
	self._equipped_unit:base():tweak_data_anim_stop("equip")
	self._equipped_unit:base():tweak_data_anim_play("unequip", speed_multiplier or nil)
end

-- For PlayerCarry; cancelling an interaction causes bag drop as interaction has technically "ended" but self:_changing_weapons() returns false (as interaction interupt anim is playing).
-- More observations: self:_interacting() will always return false in PlayerCarry:_check_use_item() when interupting an interaction.
function PlayerStandard:_changing_weapon()
	return self._unequip_weapon_expire_t or self._equip_weapon_expire_t or self._camera_unit:base().interaction_interupt_anim_playing
end

-- Called every frame to check if the unequip interaction timer has expired
function PlayerStandard:_update_unequip_interaction_timers(t)
	if self._camera_unit:base():interaction_anim() and self._unequip_weapon_on_interaction_expire_t and self._unequip_weapon_on_interaction_expire_t <= t then
		self._unequip_weapon_on_interaction_expire_t = nil

		if self._shooting or self._running or not self._equipped_unit:base():start_shooting_allowed() or self:_is_reloading() or self:_changing_weapon() or self:_is_meleeing() or self:in_steelsight() then
			return
		end

		self._camera_unit:base().has_unequipped_for_interaction = true

		if self._interact_params and self._interact_params.timer > 0 then
			self._camera_unit:base():set_interact_object(self._interact_params.object)
			self._ext_camera:play_redirect(Idstring(self._interaction_anim.animation_state_machine_name))

			if self._interaction_anim.hide_weapon then
				self._camera_unit:base():hide_weapon()
			end
		else
			self._ext_camera:play_redirect(Idstring("interact"))
		end
	end
end

function FPCameraPlayerBase:set_interaction_anim(interaction_anim)
	self._interaction_anim = interaction_anim
	return self._interaction_anim
end

function FPCameraPlayerBase:interaction_anim()
	return self._interaction_anim
end

function FPCameraPlayerBase:clear_interaction_anim()
	if self._interaction_anim then
		self._unit:anim_state_machine():set_global(self._interaction_anim.weight, 0)
		self:set_interaction_anim(nil)
	end
end

-- Arm direction

function FPCameraPlayerBase:set_interact_object(interact_object)
	self._interact_object = interact_object
end

function FPCameraPlayerBase:clear_interact_object()
	self._interact_object = nil
end

local orig_update_rot = FPCameraPlayerBase._update_rot
function FPCameraPlayerBase:_update_rot(axis, unscaled_axis)
	orig_update_rot(self, axis, unscaled_axis)
	if not self._interact_object then return end

	local interact_position = self._interact_object:interaction():interact_position()
	local arm_position = self._unit:position()
	local arm_rot = self._unit:rotation()
	local relative = interact_position - arm_position
	local interact_arm_offset_rot = Rotation()
	local final_rot = Rotation()

	mrotation.set_look_at(interact_arm_offset_rot, relative, math.UP)
	mrotation.multiply(final_rot, interact_arm_offset_rot, arm_rot)

	self:set_rotation(final_rot)
end

-- IK Controller
local ids_left_ik_modifier_name = Idstring("left_arm_ik")
local ids_right_ik_modifier_name = Idstring("right_arm_ik")

local orig_spawn_camera_unit = PlayerCamera.spawn_camera_unit
function PlayerCamera:spawn_camera_unit()
	self._ik = World:spawn_unit(Idstring("mods/int_anim/units/fps_ik_controller/fps_ik_controller"), self._m_cam_pos, self._m_cam_rot)
	self._ik_machine = self._ik:anim_state_machine()
	self._unit:link(self._ik)

	orig_spawn_camera_unit(self)

	self._camera_unit:base():set_ik_unit(self._ik)
end

function PlayerCamera:play_ik_redirect(redirect_name)
	if self._ik and alive(self._ik) then
		log("[PlayerCamera:play_ik_redirect] Playing IK redirect: " .. redirect_name)
		local ids_redirect_name = Idstring(redirect_name)
		local result = self._ik:play_redirect(ids_redirect_name)
		if result ~= PlayerCamera.IDS_NOTHING then
			self._ik_animation = ids_redirect_name
			self._camera_unit:base():start_ik()
		end
	end
end

local orig_update_player_camera = PlayerCamera.update
function PlayerCamera:update(unit, t, dt)
	if self._ik_machine and self._camera_unit and alive(self._camera_unit) and self._ik_animation then
		if not self._ik:anim_data().playing then
			self._ik_animation = nil
			self._camera_unit:base():stop_ik()
			log("Stopped IK animation")
			return
		end

		self._last_ik_t = self._last_ik_t or t 
		if t - self._last_ik_t > .005 then
			self._last_ik_t = t
			self._camera_unit:base():update_ik()
		end
	end

	orig_update_player_camera(self, unit, t, dt)
end

function FPCameraPlayerBase:set_ik_unit(ik_unit)
	self._ik = ik_unit

	self._left_ik_modifier = self._unit:anim_state_machine():get_modifier(ids_left_ik_modifier_name)
	self._right_ik_modifier = self._unit:anim_state_machine():get_modifier(ids_right_ik_modifier_name)
end

function FPCameraPlayerBase:start_ik()
	--self._unit:anim_state_machine():force_modifier(ids_left_ik_modifier_name)
	self._unit:anim_state_machine():force_modifier(ids_right_ik_modifier_name)
	
	self:play_redirect(Idstring("idle")) -- modifiers don't work in an empty state
end

function FPCameraPlayerBase:update_ik()
	if not self._ik or not alive(self._ik) then
		return
	end

	local left_locator = self._ik:get_object(Idstring("ik_left"))
	local right_locator = self._ik:get_object(Idstring("ik_right"))

	--self._left_ik_modifier:set_target_position(left_locator:local_position())
	--self._left_ik_modifier:set_target_rotation(left_locator:local_rotation())

	local right_pos = Vector3()
	mvector3.add(right_pos, right_locator:local_position())
	mvector3.rotate_with(right_pos, self._unit:rotation())
	mvector3.add(right_pos, self._unit:position())
	self._right_ik_modifier:set_target_position(right_pos)

	local right_rot = Rotation()
	mrotation.multiply(right_rot, self._unit:rotation()) -- order matters here as its rot multiplication
	mrotation.multiply(right_rot, right_locator:local_rotation())
	self._right_ik_modifier:set_target_rotation(right_rot)

	Application:draw_sphere(right_pos, 20, 1, 1, 1)
end

function FPCameraPlayerBase:stop_ik()
	if not self._ik or not alive(self._ik) then
		return
	end

	log("Forbidding IK modifiers")
	self._unit:anim_state_machine():forbid_modifier(ids_right_ik_modifier_name)
	self._unit:anim_state_machine():forbid_modifier(ids_left_ik_modifier_name)
end

-- Avoid going into the empty state or else the IK won't work
local orig_anim_clbk_idle_full_blend = FPCameraPlayerBase.anim_clbk_idle_full_blend
function FPCameraPlayerBase:anim_clbk_idle_full_blend()
	if not self._ik:anim_data().playing then	
		orig_anim_clbk_idle_full_blend(self)
	end
end

-- Animation callbacks

function FPCameraPlayerBase:spawn_interaction_items()
	for _, unit in pairs((self._interaction_anim and self._interaction_anim.units) or {}) do
		local aligns = unit.align_objects or {
			"a_weapon_left"
		}
		local unit_path = unit.unit_path or {}
		self._interaction_item_units = self._interaction_item_units or {}
		
		for _, align in ipairs(aligns) do
			local align_obj_name = Idstring(align)
			local align_obj = self._unit:get_object(align_obj_name)
			local spawned_unit = World:spawn_unit(Idstring(unit_path), Vector3(), Rotation()) -- CRASH HERE? Interaction unit not loaded; did you forget to add it in main.xml?

			spawned_unit:anim_stop()

			if unit.material_config then
				spawned_unit:set_material_config(Idstring(unit.material_config), true)
			end

			for i = 0, spawned_unit:num_bodies() - 1 do
				spawned_unit:body(i):set_collisions_enabled(false)
			end

			self._unit:link(align_obj:name(), spawned_unit, spawned_unit:orientation_object():name())

			if alive(spawned_unit) and spawned_unit:damage() and spawned_unit:damage():has_sequence(unit.unit_sequence) then
				spawned_unit:damage():run_sequence_simple(unit.unit_sequence)
			end

			table.insert(self._interaction_item_units, spawned_unit)
		end
	end
end

function FPCameraPlayerBase:anim_clbk_unspawn_interaction_items()
	if not self._interaction_item_units then
		return
	end

	for _, unit in ipairs(self._interaction_item_units) do
		if alive(unit) then
			unit:unlink()
			World:delete_unit(unit)
		end
	end

	self._interaction_item_units = {}
end

function FPCameraPlayerBase:anim_clbk_offhand_exit()
	self:clear_interaction_anim()
	self:clear_interact_object()
end

function FPCameraPlayerBase:anim_clbk_interact_hold_enter()
	self.interaction_hold_anim_playing = true
	self.queue_interaction_anim_exit = false
end

function FPCameraPlayerBase:anim_clbk_interact_hold_loop()
	if self.queue_interaction_anim_exit then
		self.queue_interaction_anim_exit = false
		self:play_redirect(Idstring("interact_exit"))
	end
end

function FPCameraPlayerBase:anim_clbk_interact_hold_exit()
	self.interaction_hold_anim_playing = false
end

function FPCameraPlayerBase:anim_clbk_interact_interupt_enter()
	self.interaction_interupt_anim_playing = true
end

function FPCameraPlayerBase:anim_clbk_interact_interupt_exit()
	self.interaction_interupt_anim_playing = false

	if self._interaction_anim.hide_weapon then
		self:show_weapon()
	end

	self:clear_interaction_anim()
	self:clear_interact_object()
end