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
	SWEP.HoldType 		= "shotgun"
end

if (CLIENT) then
	SWEP.PrintName 		= "Combat Shotgun"
	SWEP.Slot 			= 3
	SWEP.SlotPos 		= 1
	SWEP.IconLetter 		= " "

	killicon.AddFont("weapon_real_cs_ak47", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.EjectDelay			= 0.05

SWEP.Instructions 		= " "

SWEP.Base 				= "fo3_stef_base"

SWEP.Spawnable 			= true
SWEP.AdminSpawnable 		= true
SWEP.HoldType 		= "shotgun"
SWEP.ViewModelFlip 		= false
SWEP.ShellEffect			= "rg_shelleject_shotgun" -- This is a shell ejection effect
SWEP.ViewModel			= "models/weapons/v_combatshotgun.mdl"
SWEP.WorldModel			= "models/weapons/w_combatshotgun.mdl"
SWEP.MuzzleEffect			= "fo3_muzzle_rifle" -- This is an extra muzzleflash effect

SWEP.Primary.Sound 		= Sound("weapon_combatshotgun.Single")
SWEP.Primary.Recoil 		= 3.5
SWEP.Primary.Damage 		= 4
SWEP.Primary.NumShots 		= 7
SWEP.Primary.Cone 		= 0.09
SWEP.Primary.ClipSize 		= 12
SWEP.Primary.Delay 		= 0.5
SWEP.Primary.DefaultClip 	= 120
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 		= "buckshot"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"




SWEP.IronSightsPos = Vector (-5.9698, 0, 1.9838)
SWEP.IronSightsAng = Vector (-0.1294, 0.0737, 0)


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

	timer.Create( "shotgun_timer", 0.07, 1, function()
	self:RecoilPower()
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:TakePrimaryAmmo(1)
	end )

	if ((SinglePlayer() and SERVER) or CLIENT) then
		self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
	end
end

function SWEP:Reload()

	if ( self.Reloadaftershoot > CurTime() ) then return end 
	-- If you're firing, you can't reload

	self.Weapon:DefaultReload(ACT_VM_RELOAD) 
	-- Animation when you're reloading

	if ( self.Weapon:Clip1() < self.Primary.ClipSize ) and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
	-- When the current clip < full clip and the rest of your ammo > 0, then

		self.Owner:SetFOV( 0, 0.5 )
		-- Zoom = 0
		

				timer.Create( "shottie_reload3", 1.8, 1, function()
			self:EmitSound( "weapons/combatshotgun/reload/reload3.wav" )
		end)
				timer.Create( "shottie_reload2", 1.18, 1, function()
			self:EmitSound( "weapons/combatshotgun/reload/reload2.wav" )
		end)
				timer.Create( "shottie_reload1", 0.35, 1, function()
			self:EmitSound( "weapons/combatshotgun/reload/reload1.wav" )
		end)


		self:SetIronsights(false)
		-- Set the ironsight to false
	end
end

function SWEP:Deploy()

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	-- Set the deploy animation when deploying
	
	self.Reloadaftershoot = CurTime() + 1
	-- Can't shoot while deploying
	self.Owner:EmitSound( "weapons/combatshotgun/wpn_shotguncombat_equip.wav" )
	self:SetIronsights(false)
	-- Set the ironsight mod to false

	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	-- Set the next primary fire to 1 second after deploying

	return true
end