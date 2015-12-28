-- Read the weapon_real_base if you really want to know what each action does
local HitImpact = function(attacker, tr, dmginfo)

	local hit = EffectData()
	hit:SetOrigin(tr.HitPos)
	hit:SetNormal(tr.HitNormal)
	hit:SetScale(30)
	util.Effect("effect_fo3_hit", hit)

	return true
end
if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType 		= "pistol"
end

if (CLIENT) then
	SWEP.PrintName 		= "N99"
	SWEP.Slot 			= 3
	SWEP.SlotPos 		= 1
	SWEP.IconLetter 		= " "

	killicon.AddFont("weapon_real_cs_ak47", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.EjectDelay			= 0

SWEP.Instructions 		= " "
SWEP.ShellEffect			= "rg_shelleject" -- This is a shell ejection effect
SWEP.Base 				= "fo3_stef_base"

SWEP.Spawnable 			= true
SWEP.AdminSpawnable 		= true
SWEP.HoldType 		= "pistol"
SWEP.ViewModelFlip 		= false

SWEP.ViewModel			= "models/weapons/v_10mmpistol.mdl"
SWEP.WorldModel			= "models/weapons/w_10mmpistol.mdl"
SWEP.MuzzleEffect			= "fo3_muzzle_rifle" -- This is an extra muzzleflash effect
SWEP.Primary.Sound 		= Sound("weapon_10mm.Single")
SWEP.Primary.Recoil 		= 2
SWEP.Primary.Damage 		= 23
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 		= 0.023
SWEP.Primary.ClipSize 		= 12
SWEP.Primary.Delay 		= 0.2
SWEP.Primary.DefaultClip 	= 120
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 		= "pistol"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.IronSightsPos = Vector (-6.1768, 0, 2.6233)
SWEP.IronSightsAng = Vector (-0.1178, -1.3057, 0)


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

		timer.Create( "n99_timer", 0.03, 1, function()
	self:RecoilPower()

	self:TakePrimaryAmmo(1)
end )
	-- Take 1 ammo in you clip

	if ((SinglePlayer() and SERVER) or CLIENT) then
		self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
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
	self:EmitSound( "weapons/pistol_10mm/wpn_pistol10mm_reload.wav" )
		self:SetIronsights(false)
		-- Set the ironsight to false
	end
end

function SWEP:Deploy()

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	-- Set the deploy animation when deploying
	
	self.Reloadaftershoot = CurTime() + 1
	-- Can't shoot while deploying
	self.Owner:EmitSound( "weapons/pistol_10mm/wpn_pistol10mm_equip.wav" )
	self:SetIronsights(false)
	-- Set the ironsight mod to false

	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	-- Set the next primary fire to 1 second after deploying

	return true
end
