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
    if self._interaction_anim and self._interact_expire_t and ((self._interact_expire_t <= (self._interaction_anim.exit_when_time_left or 0.15))) and self._camera_unit:base().interaction_hold_anim_playing then
        self._camera_unit:base():interact_hold_early_exit()
    end 
end)

--[[
	PlayerStandard._ext_camera = PlayerCamera object
	PlayerStandard._camera_unit:base() = FPCameraPlayerBase object
]]--
PlayerMovementState = PlayerMovementState or class()
PlayerStandard = PlayerStandard or class(PlayerMovementState)

-- Instant interactions
function PlayerStandard:_play_interact_redirect(t)

	if self._shooting or self._running or not self._equipped_unit:base():start_shooting_allowed() or self:_is_reloading() or self:_changing_weapon() or self:_is_meleeing() or self:in_steelsight() then
		return
	end

	self._state_data.interact_redirect_t = t + 1

	local current_offhand_state = self._camera_unit:anim_state_machine():segment_state(Idstring("offhand"))
	if current_offhand_state ~= Idstring("") and current_offhand_state ~= Idstring("fps/interact/offhand_empty") and current_offhand_state ~= Idstring("fps/interact/offhand_empty_no_blend") then
		self._spammy_interact = true
	else
		self._spammy_interact = false
	end

	self._interaction_anim = self._camera_unit:base():set_interaction_anim(tweak_data.interaction.animations[self._interaction_unit:interaction().tweak_data])

	local has_akimbo = alive(self._equipped_unit) and self._equipped_unit:base().akimbo

	if not self._interaction_anim or not self._can_play_interact_anim or has_akimbo then
		self._ext_camera:play_redirect(self:get_animation("use"))
		return
	end

	self._camera_unit:base():do_offhand_anim(self._spammy_interact)
end

-- Timed interactions
Hooks:PostHook(PlayerStandard, "_start_action_interact", "int_anim_start_action_interact", function(self, t, input, timer, interact_object)
	self._interaction_anim = self._camera_unit:base():set_interaction_anim(tweak_data.interaction.animations[self._interaction_unit:interaction().tweak_data])

	if self._interaction_anim then
		local tweak_data = self._equipped_unit:base():weapon_tweak_data()
		self._unequip_weapon_on_interaction_expire_t = t + ((tweak_data.timers.unequip or 0.5) / (self._interaction_anim.unequip_speed_multiplier or 1))
	end
end)

-- (play specific interupt redirect)
Hooks:PreHook(PlayerStandard, "_interupt_action_interact", "int_anim_interupt_action_interact", function(self, t, input, complete)
	if self._interact_expire_t then
		self._in_interupt_action_interact = true
	end
end)

-- Equip/unequip
Hooks:PreHook(PlayerStandard, "_play_equip_animation", "int_anim_play_equip_animation", function(self)
	if self._in_interupt_action_interact then
		self._in_interupt_action_interact = false

		if self._interaction_anim and self._camera_unit:base().interaction_hold_anim_playing then 
			self._ext_camera:play_redirect(Idstring("interact_interupt"))
		elseif self._interaction_anim then
			self._camera_unit:base():anim_clbk_unspawn_interaction_items()
			self._camera_unit:base():clear_interaction_anim()
			self._camera_unit:base():clear_interact_object()

			if self._interaction_anim.hide_weapon then
				self._camera_unit:base():show_weapon()
			end
		end
	end
end)

-- resmod has its own speed_multipliers for this so unequip_speed_multiplier will NOT work with it installed! 
function PlayerStandard:_play_unequip_animation()
	local speed_multiplier = self._interaction_anim and self._interaction_anim.unequip_speed_multiplier or nil
	self._ext_camera:play_redirect(self:get_animation("unequip"), speed_multiplier)
	self._equipped_unit:base():tweak_data_anim_stop("equip")
	self._equipped_unit:base():tweak_data_anim_play("unequip", speed_multiplier)
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
