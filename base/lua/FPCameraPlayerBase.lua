UnitBase = UnitBase or class()
FPCameraPlayerBase = FPCameraPlayerBase or class(UnitBase)

FPCameraPlayerBase.IDS_WEAPON_ARM_STATE = Idstring("fps/interact/weapon_arm/test")
FPCameraPlayerBase.IDS_WEAPON_ARM_REDIRECT = Idstring("weapon_arm_test")
FPCameraPlayerBase.IDS_WEAPON_ARM_EMPTY_REDIRECT = Idstring("weapon_arm_empty")

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
		self:play_redirect(Idstring("weapon_arm_empty"))
	end
end

-- Avoid empty state if playing interact anim (for blending on weapon_arm segment)
local orig_anim_clbk_idle_full_blend = FPCameraPlayerBase.anim_clbk_idle_full_blend
function FPCameraPlayerBase:anim_clbk_idle_full_blend()
	--if not self._interaction_anim then	
		--orig_anim_clbk_idle_full_blend(self)
	--end
end

function FPCameraPlayerBase:do_offhand_anim()
	if not self._interaction_anim then
		log("[FPCameraPlayerBase:do_offhand_anim] No interaction anim set")
		return
	end

	self:play_redirect(Idstring(self._interaction_anim.animation_state_machine_name))
	self:start_weapon_arm_interaction_anim()
end

-- Timeblending on weapon_arm segment

function FPCameraPlayerBase:start_weapon_arm_interaction_anim()
	self:attach_weapon_to_hand()

	self._weapon_arm_timeblend = true
	self._weapon_arm_timeblend_t = TimerManager:game():time()
	self._weapon_arm_anim_td = tweak_data.interaction.animations.weapon_arm.test

	self:play_redirect_timeblend(self.IDS_WEAPON_ARM_STATE, self.IDS_WEAPON_ARM_REDIRECT, 0, self._weapon_arm_timeblend_t)
end

-- The two animations have distinct hold times; weapon_arm's points to the actual pose in its animation and the intanim's points to the time where that pose should be hit.
-- To sync both, map_range is used
Hooks:PostHook(FPCameraPlayerBase, "update", "int_anim_fpcameraplayerbase_update", function(self, unit, t, dt)
	if self._interaction_anim and self._weapon_arm_timeblend then
		local offhand_t = self._unit:anim_state_machine():segment_relative_time(Idstring("offhand"))

		-- Blend-in period
		if offhand_t < self._interaction_anim.hold_blend_in_t then
			self._timeblend_t = math.map_range(offhand_t, 
				0, self._interaction_anim.hold_blend_in_t, 
				0, self._weapon_arm_anim_td.hold_position_t
			)
		end

		-- Hold (nothing)

		-- Blend-out period
		if offhand_t - self._interaction_anim.hold_blend_in_t >= self._interaction_anim.hold_duration_t then
			self._timeblend_t = math.map_range(offhand_t, 
				self._interaction_anim.hold_blend_in_t + self._interaction_anim.hold_duration_t, 1, 
				self._weapon_arm_anim_td.hold_position_t, 1
			)
		end

		self:play_redirect_timeblend(self.IDS_WEAPON_ARM_STATE, self.IDS_WEAPON_ARM_REDIRECT, 0, self._timeblend_t)
	elseif not self._interaction_anim and self._weapon_arm_timeblend then
		self._weapon_arm_timeblend = false
		self._weapon_arm_timeblend_t = nil
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

function FPCameraPlayerBase:anim_clbk_weapon_arm_empty_full_blend()
	self:attach_weapon_to_align()
end