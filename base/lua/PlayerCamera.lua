-- IK unit spawning / updating (leaves positioning work to FPCameraPlayerBase)

PlayerCamera = PlayerCamera or class()
PackageManager:load("packages/intanim")

local orig_spawn_camera_unit = PlayerCamera.spawn_camera_unit
function PlayerCamera:spawn_camera_unit()
	self._ik = World:spawn_unit(Idstring("mods/int_anim/units/fps_ik_controller/fps_ik_controller"), self._m_cam_pos, self._m_cam_rot)
	self._ik_machine = self._ik:anim_state_machine()
	self._unit:link(self._ik)

	orig_spawn_camera_unit(self)

	self._camera_unit:base():set_ik_unit(self._ik)
end

function PlayerCamera:play_ik_redirect(redirect_name, speed_multiplier)
	if self._ik and alive(self._ik) then
		local ids_redirect_name = Idstring(redirect_name)
		local result = self._ik:play_redirect(ids_redirect_name)
		if result ~= PlayerCamera.IDS_NOTHING then
			self._ik_animation = ids_redirect_name
			self._ik_machine:set_speed(result, speed_multiplier or 1)
			self._camera_unit:base():start_ik(self._ik:anim_data().left or false, self._ik:anim_data().right or false)
		end
	end
end

local orig_update_player_camera = PlayerCamera.update
function PlayerCamera:update(unit, t, dt)
	if self._ik_machine and self._camera_unit and alive(self._camera_unit) and self._ik_animation then
		if not self._ik:anim_data().playing and not self._camera_unit:base():interaction_anim() then
			self._ik_animation = nil
			self._camera_unit:base():stop_ik()
			return
		end

		self._last_ik_t = self._last_ik_t or t 
		if t - self._last_ik_t > 10^-3 then
			self._last_ik_t = t
			self._camera_unit:base():update_ik(self._ik:anim_data().right and "right" or "left") -- "right" takes priority
		end
	end

	orig_update_player_camera(self, unit, t, dt)
end