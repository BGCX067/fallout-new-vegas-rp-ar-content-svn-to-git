-- Read the weapon_real_base if you really want to know what each action does
local PlasmaHitImpact = function(attacker, tr, dmginfo)

	local plasmahit = EffectData()
	plasmahit:SetOrigin(tr.HitPos)
	plasmahit:SetNormal(tr.HitNormal)
	plasmahit:SetScale(30)
	util.Effect("effect_fo3_plasmahit", plasmahit)

	return true
end
if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType 		= "ar2"
end

if (CLIENT) then
	SWEP.PrintName 		= "Plasma Rifle"
	SWEP.Slot 			= 3
	SWEP.SlotPos 		= 1
	SWEP.IconLetter 		= " "

	killicon.AddFont("weapon_real_cs_ak47", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.EjectDelay			= 0.0

SWEP.Instructions 		= " "

SWEP.Base 				= "fo3_stef_base"
SWEP.MuzzleEffect			= "fo3_muzzle_plasmarifle" -- This is an extra muzzleflash effect
SWEP.Spawnable 			= true
SWEP.AdminSpawnable 		= true
SWEP.HoldType 		= "smg"
SWEP.ViewModelFlip 		= false

SWEP.ViewModel			= "models/weapons/v_laserrifle.mdl"
SWEP.WorldModel			= "models/Sheo/w_plasmarifle.mdl"

SWEP.Primary.Sound 		= Sound("weapon_plasmarifle.Single")
SWEP.Primary.Recoil 		= 1.5
SWEP.Primary.Damage 		= 30
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 		= 0
SWEP.Primary.ClipSize 		= 12
SWEP.Primary.Delay 		= 0.4
SWEP.Primary.DefaultClip 	= 120
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 		= "XBowBolt"

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
		timer.Create( "plasma_timer", 0.05, 1, function()
	self:RecoilPower()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:TakePrimaryAmmo(1)
	-- Take 1 ammo in you clip
end)
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
	bullet.TracerName 	= "none"
	bullet.Force 	= 0.5 * dmg     								-- Amount of force to give to phys objects
	bullet.Damage 	= dmg										-- Amount of damage to give to the bullets

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
