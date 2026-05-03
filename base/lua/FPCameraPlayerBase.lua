UnitBase = UnitBase or class()
FPCameraPlayerBase = FPCameraPlayerBase or class(UnitBase)

FPCameraPlayerBase.IDS_WEAPON_ARM_STATE = Idstring("fps/interact/weapon_arm/move")
FPCameraPlayerBase.IDS_WEAPON_ARM_REDIRECT = Idstring("weapon_arm_move")
FPCameraPlayerBase.IDS_WEAPON_ARM_BLEND_REDIRECT = Idstring("weapon_arm_move_blend")
FPCameraPlayerBase.IDS_WEAPON_ARM_EMPTY_REDIRECT = Idstring("weapon_arm_empty")
FPCameraPlayerBase.IDS_WEAPON_ARM_EMPTY_NO_BLEND_REDIRECT = Idstring("weapon_arm_empty_no_blend")

function FPCameraPlayerBase:set_interaction_anim(interaction_anim)
	self._interaction_anim = interaction_anim
	return self._interaction_anim
end

function FPCameraPlayerBase:interaction_anim()
	return self._interaction_anim
end

function FPCameraPlayerBase:clear_interaction_anim()
	if self._interaction_anim then
		self:set_interaction_anim(nil)
		self:play_redirect(FPCameraPlayerBase.IDS_WEAPON_ARM_EMPTY_REDIRECT)
	end
end

-- Avoid empty state if playing interact anim (for blending on segments)
local orig_anim_clbk_idle_full_blend = FPCameraPlayerBase.anim_clbk_idle_full_blend
function FPCameraPlayerBase:anim_clbk_idle_full_blend()
	if self._base_empty_state_allowed then	
		orig_anim_clbk_idle_full_blend(self)
	end
end

local orig_play_redirect = FPCameraPlayerBase.play_redirect
function FPCameraPlayerBase:play_redirect(redirect_name, speed, offset_time)
	if redirect_name ~= FPCameraPlayerBase.IDS_WEAPON_ARM_EMPTY_REDIRECT and redirect_name ~= FPCameraPlayerBase.IDS_WEAPON_ARM_BLEND_REDIRECT then
		self._unit:play_redirect(Idstring("offhand_empty_no_blend"))
		self._unit:play_redirect(FPCameraPlayerBase.IDS_WEAPON_ARM_EMPTY_NO_BLEND_REDIRECT)
	end

	return orig_play_redirect(self, redirect_name, speed, offset_time)
end

function FPCameraPlayerBase:do_offhand_anim(is_spammy)
	if not self._interaction_anim then
		log("[FPCameraPlayerBase:do_offhand_anim] No interaction anim set")
		return
	end

	self:play_redirect(Idstring(self._interaction_anim.animation_state_machine_name))
	self:start_weapon_arm_interaction_anim(is_spammy)
end

-- Timeblending on weapon_arm segment

function FPCameraPlayerBase:reset_weapon_arm_globals()
	local asm = self._unit:anim_state_machine()
	asm:set_global("int_anims_pistol", 0)
end

function FPCameraPlayerBase:start_weapon_arm_interaction_anim(is_spammy)
	self:attach_weapon_to_hand()

	local asm = self._unit:anim_state_machine()
	if managers.player:is_current_weapon_of_category("pistol") then
		asm:set_global("int_anims_pistol", 1)
		self._weapon_arm_anim_td = tweak_data.interaction.animations.weapon_arm.pistol
	end
	
	if not self._weapon_arm_anim_td then return end

	self:play_redirect(FPCameraPlayerBase.IDS_WEAPON_ARM_BLEND_REDIRECT)
end

-- The two animations have distinct hold times; weapon_arm's points to the actual pose in its animation and the intanim's points to the time where that pose should be hit.
Hooks:PostHook(FPCameraPlayerBase, "update", "int_anim_fpcameraplayerbase_update", function(self, unit, t, dt)
	if self._interaction_anim and self._weapon_arm_timeblend then
		local offhand_t = self._unit:anim_state_machine():segment_relative_time(Idstring("offhand"))

		-- Blend-in period
		if offhand_t < self._interaction_anim.hold_blend_in_t then
			self._timeblend_t = math.map_range(offhand_t, 
				self._offhand_start_t, self._interaction_anim.hold_blend_in_t, 
				self._offhand_start_t, self._weapon_arm_anim_td.hold_position_t
			)
		end

		self:play_redirect_timeblend(self.IDS_WEAPON_ARM_STATE, self.IDS_WEAPON_ARM_REDIRECT, 0, self._timeblend_t)
	elseif not self._interaction_anim and self._weapon_arm_timeblend then
		self:play_redirect(self.IDS_WEAPON_ARM_EMPTY_REDIRECT)
	end
end)

-- Weapon attachment

function FPCameraPlayerBase:attach_weapon_to_hand()
	local weap_unit = self._parent_unit:inventory():equipped_unit()
	weap_unit:unlink()
	self._unit:link(Idstring("RightHand"), weap_unit)
end

function FPCameraPlayerBase:attach_weapon_to_align()
	local weap_unit = self._parent_unit:inventory():equipped_unit()
	weap_unit:unlink()
	self._unit:link(Idstring("a_weapon_right"), weap_unit, weap_unit:orientation_object():name())
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

-- Animation callbacks
function FPCameraPlayerBase:spawn_interaction_items()
	for _, unit in pairs((self._interaction_anim and self._interaction_anim.units) or {}) do
		local aligns = unit.align_objects or {
			"a_weapon_left"
		}
		self._interaction_item_units = self._interaction_item_units or {}
		
		for _, align in ipairs(aligns) do
			local align_obj_name = Idstring(align)
			local align_obj = self._unit:get_object(align_obj_name)
			local spawned_unit = World:spawn_unit(Idstring(unit.unit_path), Vector3(), Rotation()) -- CRASH HERE? Interaction unit not loaded; did you forget to add it in main.xml?

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
			unit:set_enabled(false)
			World:delete_unit(unit)
		end
	end

	self._interaction_item_units = {}
end

function FPCameraPlayerBase:anim_clbk_offhand_exit()
	self:anim_clbk_unspawn_interaction_items()
	self:clear_interaction_anim()
	self:clear_interact_object()
end

function FPCameraPlayerBase:anim_clbk_interact_hold_enter()
	self.interaction_hold_anim_playing = true
end

function FPCameraPlayerBase:interact_hold_early_exit()
	self:play_redirect(Idstring("interact_exit"))
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

function FPCameraPlayerBase:anim_clbk_weapon_arm_empty_full_blend()
	self._unit:anim_state_machine():stop_segment(Idstring("weapon_arm"))
	self:attach_weapon_to_align()

	self._weapon_arm_timeblend = false
	self._offhand_start_t = nil

	self:reset_weapon_arm_globals()
end

function FPCameraPlayerBase:anim_clbk_weapon_arm_anim_full_blend()
	self._weapon_arm_timeblend = true
	self._offhand_start_t = self._unit:anim_state_machine():segment_relative_time(Idstring("offhand"))
end