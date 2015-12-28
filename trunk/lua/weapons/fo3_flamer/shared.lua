include('particletrace.lua')

local sndAttackLoop = Sound("werfer_fire")
local sndAttackStart = Sound("weapons/flamer/wpn_flamer_push.wav")
local sndAttackStop = Sound("weapons/flamer/wpn_flamer_release.wav")



if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType 		= "shotgun"
end

if (CLIENT) then
	SWEP.PrintName 		= "Flammenwerfer"
	SWEP.Slot 			= 3
	SWEP.SlotPos 		= 1
	SWEP.IconLetter 		= " "
	SWEP.ViewModelFOV 		= 70
	killicon.AddFont("weapon_real_cs_ak47", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.EjectDelay			= 0

SWEP.Instructions 		= " "
SWEP.ShellEffect			= "none" -- This is a shell ejection effect
SWEP.Base 				= "fo3_stef_base"

SWEP.Spawnable 			= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModelFlip 		= false

SWEP.ViewModel			= "models/weapons/v_flamer.mdl"
SWEP.WorldModel			= "models/weapons/w_flamer.mdl"
SWEP.HoldType			= "shotgun"
SWEP.Primary.Recoil			= 0
SWEP.Primary.Damage			= 3
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.Delay			= 0.05

SWEP.Primary.ClipSize		= 150
SWEP.Primary.DefaultClip	= 450
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "AirboatGun"

SWEP.Secondary.Recoil			= 0
SWEP.Secondary.Damage			= 3
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0.02
SWEP.Secondary.Delay			= 0.05

SWEP.Secondary.ClipSize		= 1
SWEP.Secondary.DefaultClip	= 1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos = Vector (0, 0, 0)
SWEP.IronSightsAng = Vector (0, 0, 0)



function SWEP:Initialize()


		self:SetWeaponHoldType( self.HoldType )

	
	self.EmittingSound = false
	
	util.PrecacheModel("models/player/charple01.mdl")

end



function SWEP:Reload()


	if ( self.Reloadaftershoot > CurTime() ) then return end 
	-- If you're firering, you can't reload

	self.Weapon:DefaultReload(ACT_VM_RELOAD) 
	-- Animation when you're reloading

	if ( self.Weapon:Clip1() < self.Primary.ClipSize ) and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
	-- When the current clip < full clip and the rest of your ammo > 0, then
			timer.Create( "flamer_reload", 0.15, 1, function()
			self:EmitSound( "weapons/flamer/wpn_flamer_reload.wav" )
		end)
		self.Owner:SetFOV( 0, 0.5 )
		-- Zoom = 0
		self:StopSounds()
		self:SetIronsights(false)
		-- Set the ironsight to false
	end
end

function SWEP:Think()
	self:IronSight()
	if self.Owner:KeyReleased(IN_ATTACK) then
		self:StopSounds()
	end

end

function SWEP:PrimaryAttack()

	local curtime = CurTime()
	local InRange = false

	self.Weapon:SetNextSecondaryFire( curtime + 0.8 )
	self.Weapon:SetNextPrimaryFire( curtime + self.Primary.Delay )
	
	if not self:CanPrimaryAttack() or self.Owner:WaterLevel() > 1 then 
	self:StopSounds() 
	return end
	
	if not self.EmittingSound then
		self.Weapon:EmitSound(sndAttackStart, 500, 100)
		self.Weapon:EmitSound(sndAttackLoop)
		self.EmittingSound = true
	end
	
	self:TakePrimaryAmmo(1)
	
	--if SERVER then
		local PlayerVel = self.Owner:GetVelocity()
		local PlayerPos = self.Owner:GetShootPos()
		local PlayerAng = self.Owner:GetAimVector()
		
		local trace = {}
		trace.start = PlayerPos
		trace.endpos = PlayerPos + (PlayerAng*4096)
		trace.filter = self.Owner
		
		local traceRes = util.TraceLine(trace)
		local hitpos = traceRes.HitPos
		
		local jetlength = (hitpos - PlayerPos):Length()
		if jetlength > 568 then jetlength = 568 end
		if jetlength < 6 then jetlength = 6 end
		
		if self.Owner:Alive() then
			local effectdata = EffectData()
			effectdata:SetOrigin( hitpos )
			effectdata:SetEntity( self.Weapon )
			effectdata:SetStart( PlayerPos )
			effectdata:SetNormal( PlayerAng )
			effectdata:SetScale( jetlength )
			effectdata:SetAttachment( 1 )
			util.Effect( "effect_fo3_fireparticle", effectdata )
		end

		if self.DoShoot then

			local ptrace = {}
			ptrace.startpos = PlayerPos + PlayerAng:GetNormalized()*16
			local ang = (traceRes.HitPos - ptrace.startpos):GetNormalized()
			ptrace.func = burndamage
			ptrace.movetype = MOVETYPE_FLY
			ptrace.velocity = ang*728 + 0.5*PlayerVel
			ptrace.model = "none"
			ptrace.filter = {self.Owner}
			ptrace.killtime = (jetlength + 16)/ptrace.velocity:Length()
			ptrace.runonkill = false
			ptrace.collisionsize = 14
			ptrace.worldcollide = true
			ptrace.owner = self.Owner
			ptrace.name = "flameparticle"
			ParticleTrace(ptrace)
			
			self.DoShoot = false
			else
			self.DoShoot = true
		end
	--end
end

function burndamage(ptres)

	local hitent = ptres.activator
	if hitent:WaterLevel() > 0 then return end

	local ttime = ptres.time
	if ttime == 0 then ttime = 0.1 end --Division by zero is bad! D :
	
	local damage = math.ceil(3/ttime)
	if damage > 15 then damage = 15 end
	
	local radius = math.ceil(256*ttime)
	if radius < 16 then radius = 16 end
	

	local healthpercent = 3
	local isnpc = hitent:IsNPC()
	local enthealth = 1
	local enttable = hitent:GetTable()
	
	if isnpc or hitent:IsPlayer() then
	enthealth = hitent:Health()
	healthpercent = math.ceil(enthealth/5)
	end
	
	local fuel = enttable.FuelLevel
	if fuel and fuel > 0 then
	
	ptres.caller:EmitSound(sndIgnite)
	enttable.FuelLevel = 0
	
	local entpos = hitent:GetPos()
	local boompos = entpos
	boompos.z = boompos.z + hitent:BoundingRadius()/2
	local damagemult = 4*fuel
	local radiusmult = radius + fuel
	
	local effectdata = EffectData()
	effectdata:SetOrigin( entpos )
	effectdata:SetEntity( hitent )
	effectdata:SetStart( entpos )
	effectdata:SetNormal( Vector(0,0,1) )
	effectdata:SetScale( 10 )
	util.Effect( "HelicopterMegaBomb", effectdata )
	
		if damagemult < enthealth then
			hitent:Ignite(math.Rand(7,11),0)
			hitent:SetHealth(24 + damagemult)
			util.BlastDamage(ptres.owner:GetActiveWeapon(), ptres.owner, boompos, radiusmult, damagemult)
		elseif IsHumanoid(hitent) then
			Immolate(hitent,entpos)
			else
			
			util.BlastDamage(ptres.owner:GetActiveWeapon(), ptres.owner, boompos, radiusmult, damagemult)
			hitent:SetHealth(0)

		end
		
	else
	
	util.BlastDamage(ptres.owner:GetActiveWeapon(), ptres.owner, ptres.particlepos, radius, damage)

		local reverselottery = math.random(0,healthpercent)
		if reverselottery == 1 then --it's your lucky day!
		hitent:Ignite(math.Rand(7,11),0)
			if isnpc and enthealth < 32 and hitent:GetMaxHealth() > 24 then
			hitent:SetHealth(32) --So we can watch 'em BURN!  >:D
			end
		end
	end
end

function DeFlamitize(ply) 
   
ply:GetTable().FuelLevel = 0

if ply:IsOnFire() then
	ply:Extinguish()
end
   
end 
   
 hook.Add( "PlayerDeath", "deflame", DeFlamitize )


function SWEP:StopSounds()
	if self.EmittingSound then
		self.Weapon:StopSound(sndAttackLoop)
		self.Weapon:EmitSound(sndAttackStop)
		self.EmittingSound = false
	end	
end


function SWEP:Holster()
	self:StopSounds()
	return true
end

function SWEP:OnRemove()
	self:StopSounds()
	return true
end


