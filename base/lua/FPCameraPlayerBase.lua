dofile(ModPath .. "lua/PlayerCamera.lua")

UnitBase = UnitBase or class()
FPCameraPlayerBase = FPCameraPlayerBase or class(UnitBase)

local ids_right_ik_modifier_name = Idstring("right_arm_ik")

function FPCameraPlayerBase:set_interaction_anim(interaction_anim)
	self._interaction_anim = interaction_anim
	return self._interaction_anim
end

function FPCameraPlayerBase:interaction_anim()
	return self._interaction_anim
end

function FPCameraPlayerBase:right_modifier_blend_t()
	return self._ik_modifiers["right"]:blend() or 0
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

-- IK

function FPCameraPlayerBase:set_ik_unit(ik_unit)
	self._ik = ik_unit

	self._ik_modifiers = {
		right = self._unit:anim_state_machine():get_modifier(ids_right_ik_modifier_name)
	}
end

function FPCameraPlayerBase:start_ik()
	local weap_unit = self._parent_unit:inventory():equipped_unit()
	self._unit:anim_state_machine():force_modifier(ids_right_ik_modifier_name)

	-- align objs don't move with the IK so relink to hand
	weap_unit:unlink()
	self._unit:link(Idstring("RightHand"), weap_unit)

	self._ik_update = true
end

function FPCameraPlayerBase:update_ik()
	local locator = self._ik:get_object(Idstring("ik_right"))
	if not self._ik or not alive(self._ik) or not locator then
		return
	end

	local pos = Vector3()
	mvector3.add(pos, locator:local_position())
	mvector3.rotate_with(pos, self._unit:rotation())
	mvector3.add(pos, self._unit:position())

	local rot = Rotation()
	mrotation.multiply(rot, self._unit:rotation())
	mrotation.multiply(rot, locator:local_rotation())

	self._ik_modifiers["right"]:set_target_position(pos)
	self._ik_modifiers["right"]:set_target_rotation(rot)
	Application:draw_sphere(pos, 5, 1, 0, 0)
end

function FPCameraPlayerBase:stop_ik()
	if not self._ik or not alive(self._ik) then
		return
	end

	self._unit:anim_state_machine():forbid_modifier(ids_right_ik_modifier_name)
end

function FPCameraPlayerBase:reattach_weapon()
	if not self._ik or not alive(self._ik) then
		return
	end

	local weap_unit = self._parent_unit:inventory():equipped_unit()
	self._unit:link(Idstring("a_weapon_right"), weap_unit, weap_unit:orientation_object():name())
	self._ik_update = false
end

-- Avoid going into the empty state while doing IK or else it won't work
local orig_anim_clbk_idle_full_blend = FPCameraPlayerBase.anim_clbk_idle_full_blend
function FPCameraPlayerBase:anim_clbk_idle_full_blend()
	if not self._ik_update then	
		orig_anim_clbk_idle_full_blend(self)
	end
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