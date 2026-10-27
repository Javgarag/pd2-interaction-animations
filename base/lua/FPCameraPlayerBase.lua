UnitBase = UnitBase or class()
FPCameraPlayerBase = FPCameraPlayerBase or class(UnitBase)

-- These 3 are ours

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
	end
end

-- Avoid empty state if playing interact anim (for blending on segments)

local orig_anim_clbk_idle_full_blend = FPCameraPlayerBase.anim_clbk_idle_full_blend
Hooks:OverrideFunction(FPCameraPlayerBase, "anim_clbk_idle_full_blend", function(self)
	if self._base_empty_state_allowed then	
		orig_anim_clbk_idle_full_blend(self)
	end
end)

function FPCameraPlayerBase:do_offhand_anim(is_spammy) -- ours
	if not self._interaction_anim then
		log("[FPCameraPlayerBase:do_offhand_anim] No interaction anim set")
		return
	end

	self:attach_weapon_to_right_hand()
	self:play_redirect(Idstring(self._interaction_anim.animation_state_machine_name))
end

-- Weapon deattachment (rattlesnake, minigun, all of those special ones that are held with the left hand)

function FPCameraPlayerBase:attach_weapon_to_right_hand() -- ours
	local weap_unit = self._parent_unit:inventory():equipped_unit()
	self._original_weapon_parent_bone = tweak_data.weapon[weap_unit:base()._name_id].use_data.align_place == "left_hand" and Idstring("a_weapon_left") or Idstring("a_weapon_right")
	weap_unit:unlink()
	self._unit:link(Idstring("RightHand"), weap_unit) -- keep offset
end

-- Arm direction

function FPCameraPlayerBase:set_interact_object(interact_object)
	self._interact_object = interact_object
end

function FPCameraPlayerBase:clear_interact_object()
	self._interact_object = nil
end

local orig_update_rot = FPCameraPlayerBase._update_rot
Hooks:OverrideFunction(FPCameraPlayerBase, "_update_rot", function(self, axis, unscaled_axis)
	orig_update_rot(self, axis, unscaled_axis)
	if not alive(self._interact_object) then return end

	local interact_position = self._interact_object:interaction():interact_position()
	local arm_position = self._unit:position()
	local arm_rot = self._unit:rotation()
	local relative = interact_position - arm_position
	local interact_arm_offset_rot = Rotation()
	local final_rot = Rotation()

	mrotation.set_look_at(interact_arm_offset_rot, relative, math.UP)
	mrotation.multiply(final_rot, interact_arm_offset_rot, arm_rot)

	self:set_rotation(final_rot)
end)

-- Animation callbacks (everything here is ours)

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
				if spawned_unit.interaction and spawned_unit:interaction() then
					spawned_unit:interaction():refresh_material()
				end
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

function FPCameraPlayerBase:anim_clbk_offhand_exit_full_blend()
	if not self._original_weapon_parent_bone then return end

	-- Reattach weapon to its align
	local weap_unit = self._parent_unit:inventory():equipped_unit()
	weap_unit:unlink()
	self._unit:link(self._original_weapon_parent_bone, weap_unit, weap_unit:orientation_object():name())
	self._original_weapon_parent_bone = nil
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