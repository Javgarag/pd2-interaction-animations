Hooks:PostHook(PlayerCarry, "_update_check_actions", "int_anim_update_check_interacting_carry", function(self, t, dt, paused)
    self:_update_unequip_interaction_timers(t)
end)