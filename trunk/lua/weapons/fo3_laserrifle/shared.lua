-- Read the weapon_real_base if you really want to know what each action does

local LaserHitImpact = function(attacker, tr, dmginfo)

	local laserhit = EffectData()
	laserhit:SetOrigin(tr.HitPos)
	laserhit:SetNormal(tr.HitNormal)
	laserhit:SetScale(30)
	util.Effect("effect_fo3_laserhit", laserhit)

	return true
end

if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType 		= "smg"
end

if (CLIENT) then
	SWEP.PrintName 		= "Laser Rifle"
	SWEP.Slot 			= 3
	SWEP.SlotPos 		= 1
	SWEP.IconLetter 		= " "

	killicon.AddFont(" ", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.EjectDelay			= 0

SWEP.Instructions 		= " "

SWEP.Base 				= "fo3_stef_base"
SWEP.MuzzleEffect			= "fo3_muzzle_laserrifle" -- This is an extra muzzleflash effect


SWEP.Spawnable 			= true
SWEP.AdminSpawnable 		= true
SWEP.HoldType 		= "smg"
SWEP.ViewModelFlip 		= false

SWEP.ViewModel			= "models/weapons/v_laserrifle.mdl"
SWEP.WorldModel			= "models/weapons/w_laserrifle.mdl"

SWEP.Primary.Sound 		= Sound("weapon_laserrifle.Single")
SWEP.Primary.Recoil 		= 1.5
SWEP.Primary.Damage 		= 33
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 		= 0.023
SWEP.Primary.ClipSize 		= 12
SWEP.Primary.Delay 		= 0.3
SWEP.Primary.DefaultClip 	= 120
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 		= "ar2"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.IronSightsPos = Vector (-5.5214, 0, -0.7772)
SWEP.IronSightsAng = Vector (0, 0, 0)

function SWEP:PrimaryAttack()

	if not self:CanPrimaryAttack() or self.Owner:WaterLevel() > 2 then return end
	-- If your gun have a problem or if you are under water, you'll not be able to fire

	self.Reloadaftershoot = CurTime() + self.Primary.Delay
	-- Set the reload after shoot to be not able to reload when firering

	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	-- Set next secondary fire after your fire delay

	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	-- Set next primary fire after your fire delay

	self.Weapon:EmitSound(self.Primary.Sound, 150, 100)
	-- Emit the gun sound when you fire

		timer.Create( "laser_timer", 0.05, 1, function()
	self:RecoilPower()
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:TakePrimaryAmmo(1)
end )
	-- Take 1 ammo in you clip

	if ((SinglePlayer() and SERVER) or CLIENT) then
		self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
	end
end

function SWEP:CSShootBullet(dmg, recoil, numbul, cone)

	numbul 		= numbul or 1
	cone 			= cone or 0.01

	local bullet 	= {}
	bullet.Num  	= numbul
	bullet.Src 		= self.Owner:GetShootPos()       					-- Source
	bullet.Dir 		= self.Owner:GetAimVector()      					-- Dir of bullet
	bullet.Spread 	= Vector(cone, cone, 0)     						-- Aim Cone
	bullet.Tracer 	= 1       									-- Show a tracer on every x bullets
	bullet.TracerName 	= "effect_fo3_laser"
	bullet.Force 	= 0.5 * dmg     								-- Amount of force to give to phys objects
	bullet.Damage 	= dmg										-- Amount of damage to give to the bullets
	bullet.Callback 	= LaserHitImpact
-- 	bullet.Callback	= function ( a, b, c ) BulletPenetration( 0, a, b, c ) end 	-- CALL THE FUNCTION BULLETPENETRATION

	self.Owner:FireBullets(bullet)					-- Fire the bullets
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)      	-- View model animation
	self.Owner:MuzzleFlash()        					-- Crappy muzzle light

	self.Owner:SetAnimation(PLAYER_ATTACK1)       			-- 3rd Person Animation

	local fx 		= EffectData()
	fx:SetEntity(self.Weapon)
	fx:SetOrigin(self.Owner:GetShootPos())
	fx:SetNormal(self.Owner:GetAimVector())
	fx:SetAttachment(self.MuzzleAttachment)
	util.Effect(self.MuzzleEffect,fx)					-- Additional muzzle effects
	
	timer.Simple( self.EjectDelay, function()
		if  not IsFirstTimePredicted() then 
			return
		end

			local fx 	= EffectData()
			fx:SetEntity(self.Weapon)
			fx:SetNormal(self.Owner:GetAimVector())
			fx:SetAttachment(self.ShellEjectAttachment)

			util.Effect(self.ShellEffect,fx)				-- Shell ejection
	end)

	if ((SinglePlayer() and SERVER) or (not SinglePlayer() and CLIENT)) then
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		self.Owner:SetEyeAngles(eyeang)
	end
end

function SWEP:Reload()

	if ( self.Reloadaftershoot > CurTime() ) then return end 
	-- If you're firering, you can't reload

	self.Weapon:DefaultReload(ACT_VM_RELOAD) 
	-- Animation when you're reloading

	if ( self.Weapon:Clip1() < self.Primary.ClipSize ) and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
	-- When the current clip < full clip and the rest of your ammo > 0, then

		self.Owner:SetFOV( 0, 0.5 )
		-- Zoom = 0
	self:EmitSound( "weapons/laserrifle/wpn_riflelaser_reloadinout.wav" )
		self:SetIronsights(false)
		-- Set the ironsight to false
	end
end


function SWEP:RecoilPower()

	if not self.Owner:IsOnGround() then
		if (self:GetIronsights() == true) then
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone)
			-- Put normal recoil when you're in ironsight mod
			
			self.Owner:ViewPunch(Angle(math.Rand(-2.5,2.5) * (self.Primary.Recoil), math.Rand(-2.5,2.5) * (self.Primary.Recoil), 0))
			-- Punch the screen 1x less hard when you're in ironsigh mod
		else
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil * math.Rand(-2.5,2.5), self.Primary.NumShots, self.Primary.Cone)
			-- Recoil * 2.5
			
			self.Owner:ViewPunch(Angle(math.Rand(-2.5,2.5) * (self.Primary.Recoil * math.Rand(-2.5,2.5)), math.Rand(-2.5,2.5) * (self.Primary.Recoil), 0))
			-- Punch the screen * 2.5
		end

	elseif self.Owner:KeyDown(IN_FORWARD | IN_BACK | IN_MOVELEFT | IN_MOVERIGHT) then
		if (self:GetIronsights() == true) then
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil / 2, self.Primary.NumShots, self.Primary.Cone)
			-- Put recoil / 2 when you're in ironsight mod
			
			self.Owner:ViewPunch(Angle(math.Rand(-2.5,2.5) * (self.Primary.Recoil / 1.5), math.Rand(-2.5,2.5) * (self.Primary.Recoil / 1.5), 0))
			-- Punch the screen 1.5x less hard when you're in ironsigh mod
		else
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil * 1.5, self.Primary.NumShots, self.Primary.Cone)
			-- Recoil * 1.5
		
			self.Owner:ViewPunch(Angle(math.Rand(-2.5,2.5) * (self.Primary.Recoil * 1.5), math.Rand(-2.5,2.5) * (self.Primary.Recoil * 1.5), 0))
			-- Punch the screen * 1.5
		end

	elseif self.Owner:Crouching() then
		if (self:GetIronsights() == true) then
			self:CSShootBullet(self.Primary.Damage, 0, self.Primary.NumShots, self.Primary.Cone)
			-- Put 0 recoil when you're in ironsight mod
	
			self.Owner:ViewPunch(Angle(math.Rand(-2.5,2.5) * (self.Primary.Recoil / 3), math.Rand(-2.5,2.5) * (self.Primary.Recoil / 3), 0))
			-- Punch the screen 3x less hard when you're in ironsigh mod
		else
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil / 2, self.Primary.NumShots, self.Primary.Cone)
			-- Recoil / 2
			self.Owner:ViewPunch(Angle(math.Rand(-2.5,2.5) * (self.Primary.Recoil / 2), math.Rand(-2.5,2.5) * (self.Primary.Recoil / 2), 0))
			-- Punch the screen / 2
		end
	else
		if (self:GetIronsights() == true) then
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil / 6, self.Primary.NumShots, self.Primary.Cone)
			-- Put recoil / 4 when you're in ironsight mod

			self.Owner:ViewPunch(Angle(math.Rand(-2.5,2.5) * (self.Primary.Recoil / 2), math.Rand(-2.5,2.5) * (self.Primary.Recoil / 2), 0))
			-- Punch the screen 2x less hard when you're in ironsigh mod
		else
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone)
			-- Put normal recoil when you're not in ironsight mod
	
			self.Owner:ViewPunch(Angle(math.Rand(-2.5,2.5) * self.Primary.Recoil, math.Rand(-2.5,2.5) *self.Primary.Recoil, 0))
			-- Punch the screen
		end
	end
end

