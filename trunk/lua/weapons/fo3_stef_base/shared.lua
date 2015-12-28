-- English is not my first language, so sorry if I did some errors in my little "tutorial"

/*---------------------------------------------------------*/
local HitImpact = function(attacker, tr, dmginfo)

	local hit = EffectData()
	hit:SetOrigin(tr.HitPos)
	hit:SetNormal(tr.HitNormal)
	hit:SetScale(30)
	util.Effect("effect_fo3_hit", hit)

	return true
end
/*---------------------------------------------------------*/

if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight 		= 5
	SWEP.HoldType		= "ar2"		-- Hold type style ("ar2" "pistol" "shotgun" "rpg" "normal" "melee" "grenade" "smg")
end


if (CLIENT) then
	SWEP.DrawAmmo		= true		-- Should we draw the number of ammos and clips?
	SWEP.DrawCrosshair	= false		-- Should we draw the half life 2 crosshair?
	SWEP.ViewModelFOV		= 50			-- "Y" position of the sweps
	SWEP.ViewModelFlip	= true		-- Should we flip the sweps?
	SWEP.CSMuzzleFlashes	= false		-- Should we add a CS Muzzle Flash?

	-- This is the font that's used to draw the death icons
	surface.CreateFont("csd", ScreenScale(30), 500, true, true, "CSKillIcons")

	-- This is the font that's used to draw the select icons
	surface.CreateFont("csd", ScreenScale(60), 500, true, true, "CSSelectIcons")

	-- This is the font that's used to draw the firemod icons
	surface.CreateFont("HalfLife2", ScrW() / 60, 500, true, true, "Firemode")
end

/*---------------------------------------------------------
Muzzle Effect + Shell Effect
---------------------------------------------------------*/
SWEP.MuzzleEffect			= "fo3_muzzle_rifle" -- This is an extra muzzleflash effect
-- Available muzzle effects: fo3_muzzlegrenade, fo3_muzzlehighcal, fo3_muzzlehmg, fo3_muzzlepistol, fo3_muzzlerifle, fo3_muzzlesilenced, none

SWEP.ShellEffect			= "none" -- This is a shell ejection effect
-- Available shell eject effects: rg_shelleject, rg_shelleject_rifle, rg_shelleject_shotgun, none

SWEP.MuzzleAttachment		= "1" -- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.ShellEjectAttachment	= "2" -- Should be "2" for CSS models or "1" for hl2 models

SWEP.EjectDelay			= 0
/*-------------------------------------------------------*/

SWEP.Category			= "Stef's Fallout Weapons"		-- Swep Categorie (You can type what your want)

SWEP.DrawWeaponInfoBox  	= true					-- Should we draw a weapon info when you're selecting your swep?

SWEP.Author 			= "Worshipper & Stef"				-- Author Name
SWEP.Contact 			= ""						-- Author E-Mail
SWEP.Purpose 			= ""						-- Author's Informations
SWEP.Instructions 		= ""						-- Instructions of the sweps

SWEP.Spawnable 			= false					-- Everybody can spawn this swep
SWEP.AdminSpawnable 		= false					-- Admin can spawn this swep

SWEP.Weight 			= 5						-- Weight of the swep
SWEP.AutoSwitchTo 		= false
SWEP.AutoSwitchFrom 		= false

SWEP.Primary.Sound 		= Sound("Weapon_AK47.Single")		-- Sound of the gun
SWEP.Primary.Recoil 		= 0						-- Recoil of the gun
SWEP.Primary.Damage 		= 0						-- Damage of the gun
SWEP.Primary.NumShots 		= 0						-- How many bullet(s) should be fired by the gun at the same time
SWEP.Primary.Cone 		= 0						-- Precision of the gun
SWEP.Primary.ClipSize 		= 0						-- Number of bullets in 1 clip
SWEP.Primary.Delay 		= 0						-- Exemple: If your weapon shoot 800 bullets per minute, this is what you need to do: 1 / (800 / 60) = 0.075
SWEP.Primary.DefaultClip 	= 0						-- How many ammos come with your weapon (ClipSize + "The number of ammo you want"). If you don't want to add additionnal ammo with your weapon, type the ClipSize only!
SWEP.Primary.Automatic 		= false					-- Is the weapon automatic? 
SWEP.Primary.Ammo 		= "none"					-- Type of ammo ("pistol" "ar2" "grenade" "smg1" "xbowbolt" "rpg_round" "351")

SWEP.Secondary.ClipSize 	= 0
SWEP.Secondary.DefaultClip 	= 0
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.data 				= {}
SWEP.mode 				= "semi" 					-- The starting firemode
SWEP.data.ironsights		= 1

SWEP.data.semi 			= {}
SWEP.data.semi.FireMode		= "p"

SWEP.data.auto 			= {}
SWEP.data.auto.FireMode		= "ppppp"

SWEP.data.burst			= {}
SWEP.data.burst.FireMode	= "ppp"

/*---------------------------------------------------------
Auto/Semi/Burst Configuration
---------------------------------------------------------*/
function SWEP.data.semi.Init(self)

	self.Primary.Automatic = false
	self.Weapon:EmitSound("weapons/smg1/switch_single.wav")
	self.Weapon:SetNetworkedInt("firemode", 3)
end

function SWEP.data.auto.Init(self)

	self.Primary.Automatic = true
	self.Weapon:EmitSound("weapons/smg1/switch_burst.wav")
	self.Weapon:SetNetworkedInt("firemode", 1)
end

function SWEP.data.burst.Init(self)

	self.Primary.Automatic = false
	self.Weapon:EmitSound("weapons/smg1/switch_burst.wav")
	self.Weapon:SetNetworkedInt("firemode", 2)
end

/*---------------------------------------------------------
IronSight
---------------------------------------------------------*/
function SWEP:IronSight()

	if !self.Owner:KeyDown(IN_USE) then
	-- If the key E (Use Key) is not pressed, then

		if self.Owner:KeyPressed(IN_ATTACK2) then
		-- When the right click is pressed, then

			self.Owner:SetFOV( 65, 0.5 )

			self:SetIronsights(true, self.Owner)
			-- Set the ironsight true

			if CLIENT then return end
 		end
	end

	if self.Owner:KeyReleased(IN_ATTACK2) then
	-- If the right click is released, then

		self.Owner:SetFOV( 0, 0.5 )

		self:SetIronsights(false, self.Owner)
		-- Set the ironsight false

		if CLIENT then return end
	end
end

/*---------------------------------------------------------
Think
---------------------------------------------------------*/
function SWEP:Think()

	self:IronSight()
end

/*---------------------------------------------------------
Initialize
---------------------------------------------------------*/
function SWEP:Initialize()

--	if (SERVER) then
		self:SetWeaponHoldType(self.HoldType) 	-- Hold type of the 3rd person animation
--	end

	self.Reloadaftershoot = 0 				-- Can't reload when firering

	self.data[self.mode].Init(self)
end

/*---------------------------------------------------------
Reload
---------------------------------------------------------*/
function SWEP:Reload()

	if ( self.Reloadaftershoot > CurTime() ) then return end 
	-- If you're firering, you can't reload

	self.Weapon:DefaultReload(ACT_VM_RELOAD) 
	-- Animation when you're reloading

	if ( self.Weapon:Clip1() < self.Primary.ClipSize ) and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
	-- When the current clip < full clip and the rest of your ammo > 0, then

		self.Owner:SetFOV( 0, 0.5 )
		-- Zoom = 0

		self:SetIronsights(false)
		-- Set the ironsight to false
	end
end

/*---------------------------------------------------------
Deploy
---------------------------------------------------------*/
function SWEP:Deploy()

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	-- Set the deploy animation when deploying
	
	self.Reloadaftershoot = CurTime() + 1
	-- Can't shoot while deploying

	self:SetIronsights(false)
	-- Set the ironsight mod to false

	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	-- Set the next primary fire to 1 second after deploying

	return true
end

/*---------------------------------------------------------
PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	if not self:CanPrimaryAttack() or self.Owner:WaterLevel() > 2 then return end
	-- If your gun have a problem or if you are under water, you'll not be able to fire

	self.Reloadaftershoot = CurTime() + self.Primary.Delay
	-- Set the reload after shoot to be not able to reload when firering

	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	-- Set next secondary fire after your fire delay

	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	-- Set next primary fire after your fire delay

	self.Weapon:EmitSound(self.Primary.Sound)
	-- Emit the gun sound when you fire

	self:RecoilPower()

	self:TakePrimaryAmmo(1)
	-- Take 1 ammo in you clip

	if ((SinglePlayer() and SERVER) or CLIENT) then
		self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
	end
end

/*---------------------------------------------------------
SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

end

/*---------------------------------------------------------
CanPrimaryAttack
---------------------------------------------------------*/
function SWEP:CanPrimaryAttack()

	if ( self.Weapon:Clip1() <= 0 ) and self.Primary.ClipSize > -1 then
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
		self.Weapon:EmitSound("weapons/pistol_10mm/wpn_pistol10mm_firedry.wav")
		return false
	end
	return true
end

/*---------------------------------------------------------
DrawWeaponSelection
---------------------------------------------------------*/
function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)

	draw.SimpleText(self.IconLetter, "CSSelectIcons", x + wide / 2, y + tall * 0.2, Color(255, 210, 0, 255), TEXT_ALIGN_CENTER)
	-- Draw a CS:S select icon

	self:PrintWeaponInfo(x + wide + 20, y + tall * 0.95, alpha)
	-- Print weapon information
end

SWEP.CrossHairScale = 1
-- CROSSHAIR THAT I DIDN'T ADD IN THIS VERSION. IT WAS JUST EXPERIMENTAL AGAIN.
/*---------------------------------------------------------
DrawHUD
---------------------------------------------------------*/
function SWEP:DrawHUD()

	local mode = self.Weapon:GetNetworkedInt("firemode")

	if mode == 1 then
		self.mode = "auto"
	elseif mode == 2 then
		self.mode = "burst"
	elseif mode == 3 then
		self.mode = "semi"
	else
		self.mode = "semi"
	end

	surface.SetFont("Firemode")
	surface.SetTextPos(surface.ScreenWidth() * .9225, surface.ScreenHeight() * .9125)
	surface.SetTextColor(255,220,0,100)

	surface.DrawText(self.data[self.mode].FireMode)

/*---------------------------------------------------------
	local x = ScrW() / 2
	local y = ScrH() / 2

	if self:GetNetworkedBool("Ironsights") then
		return
	end

	local scalebyheight = (ScrH() / 770) * 15

	local scale

	if not self.Owner:IsValid() then return end

	if self.Owner:GetVelocity():Length() > 0 then
		scale = scalebyheight * (self.Primary.Cone * 1.5)

	elseif self.Owner:Crouching() then
		scale = scalebyheight * (self.Primary.Cone / 1.5)

	else
		scale = scalebyheight * self.Primary.Cone
	end

	LastShootTime = self.Weapon:GetNetworkedFloat( "LastShootTime", 0 )
	scale = scale * (2 - math.Clamp( (CurTime() - LastShootTime) * 5, 0.0, 1.0 ))

	surface.SetDrawColor(255, 255, 255, 230)

	self.CrossHairScale = math.Approach(self.CrossHairScale, scale, FrameTime() * 3 + math.abs(self.CrossHairScale - scale) * 0.012)

	local dispscale = self.CrossHairScale

	local gap = 40 * dispscale
	local length = gap + 15
	surface.DrawLine(x - length, y, x - gap, y)
	surface.DrawLine(x + length, y, x + gap, y)
	surface.DrawLine(x, y - length, x, y - gap)
	surface.DrawLine(x, y + length, x, y + gap)

--	surface.SetDrawColor(200, 0, 0, 230)
--	surface.DrawRect(x - 2, y - 2, 2, 2)
---------------------------------------------------------*/
end

/*---------------------------------------------------------
GetViewModelPosition
---------------------------------------------------------*/
local IRONSIGHT_TIME = 0.5
-- Time to enter in the ironsight mod

function SWEP:GetViewModelPosition(pos, ang)

	if (not self.IronSightsPos) then return pos, ang end

	local bIron = self.Weapon:GetNWBool("Ironsights")

	if (bIron != self.bLastIron) then
		self.bLastIron = bIron
		self.fIronTime = CurTime()

		if (bIron) then
			self.SwayScale 	= 0.3
			self.BobScale 	= 0.1
		else
			self.SwayScale 	= 2.0
			self.BobScale 	= 1.0
		end
	end

	local fIronTime = self.fIronTime or 0

	if (not bIron and fIronTime < CurTime() - IRONSIGHT_TIME) then
		return pos, ang
	end

	local Mul = 1.0

	if (fIronTime > CurTime() - IRONSIGHT_TIME) then
		Mul = math.Clamp((CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1)

		if not bIron then Mul = 1 - Mul end
	end

	local Offset	= self.IronSightsPos

	if (self.IronSightsAng) then
		ang = ang * 1
		ang:RotateAroundAxis(ang:Right(), 		self.IronSightsAng.x * Mul)
		ang:RotateAroundAxis(ang:Up(), 		self.IronSightsAng.y * Mul)
		ang:RotateAroundAxis(ang:Forward(), 	self.IronSightsAng.z * Mul)
	end

	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()

	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul

	return pos, ang
end

/*---------------------------------------------------------
SetIronsights
---------------------------------------------------------*/
function SWEP:SetIronsights(b)

	self.Weapon:SetNetworkedBool("Ironsights", b)
end

function SWEP:GetIronsights()

	return self.Weapon:GetNWBool("Ironsights")
end

/*---------------------------------------------------------
RecoilPower
---------------------------------------------------------*/
function SWEP:RecoilPower()

	if not self.Owner:IsOnGround() then
		if (self:GetIronsights() == true) then
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone)
			-- Put normal recoil when you're in ironsight mod
		
			self.Owner:ViewPunch(Angle(math.Rand(-1.5,1.5) * (self.Primary.Recoil), math.Rand(-2.5,2.5) * (self.Primary.Recoil), 0))
			-- Punch the screen 1x less hard when you're in ironsigh mod
		else
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil * math.Rand(-2.5,2.5), self.Primary.NumShots, self.Primary.Cone)
			-- Recoil * 2.5
		
			self.Owner:ViewPunch(Angle(math.Rand(-1.5,1.5) * (self.Primary.Recoil * math.Rand(-2.5,2.5)), math.Rand(-2.5,2.5) * (self.Primary.Recoil), 0))
			-- Punch the screen * 2.5
		end

	elseif self.Owner:KeyDown(IN_FORWARD | IN_BACK | IN_MOVELEFT | IN_MOVERIGHT) then
		if (self:GetIronsights() == true) then
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil / 2, self.Primary.NumShots, self.Primary.Cone)
			-- Put recoil / 2 when you're in ironsight mod
	
			self.Owner:ViewPunch(Angle(math.Rand(-1.5,1.5) * (self.Primary.Recoil / 1.5), math.Rand(-2.5,2.5) * (self.Primary.Recoil / 1.5), 0))
			-- Punch the screen 1.5x less hard when you're in ironsigh mod
		else
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil * 1.5, self.Primary.NumShots, self.Primary.Cone)
			-- Recoil * 1.5
	
			self.Owner:ViewPunch(Angle(math.Rand(-1.5,1.5) * (self.Primary.Recoil * 1.5), math.Rand(-2.5,2.5) * (self.Primary.Recoil * 1.5), 0))
			-- Punch the screen * 1.5
		end

	elseif self.Owner:Crouching() then
		if (self:GetIronsights() == true) then
			self:CSShootBullet(self.Primary.Damage, 0, self.Primary.NumShots, self.Primary.Cone)
			-- Put 0 recoil when you're in ironsight mod
		
			self.Owner:ViewPunch(Angle(math.Rand(-1.5,1.5) * (self.Primary.Recoil / 3), math.Rand(-2.5,2.5) * (self.Primary.Recoil / 3), 0))
			-- Punch the screen 3x less hard when you're in ironsigh mod
		else
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil / 2, self.Primary.NumShots, self.Primary.Cone)
			-- Recoil / 2
		
			self.Owner:ViewPunch(Angle(math.Rand(-1.5,1.5) * (self.Primary.Recoil / 2), math.Rand(-2.5,2.5) * (self.Primary.Recoil / 2), 0))
			-- Punch the screen / 2
		end
	else
		if (self:GetIronsights() == true) then
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil / 6, self.Primary.NumShots, self.Primary.Cone)
			-- Put recoil / 4 when you're in ironsight mod
			
			self.Owner:ViewPunch(Angle(math.Rand(-1.5,1.5) * (self.Primary.Recoil / 2), math.Rand(-2.5,2.5) * (self.Primary.Recoil / 2), 0))
			-- Punch the screen 2x less hard when you're in ironsigh mod
		else
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone)
			-- Put normal recoil when you're not in ironsight mod
			
			self.Owner:ViewPunch(Angle(math.Rand(-1.5,1.5) * self.Primary.Recoil, math.Rand(-2.5,2.5) *self.Primary.Recoil, 0))
			-- Punch the screen
		end
	end
end

function SWEP:Holster( wep )
	timer.Destroy("fatman_reload2")
	timer.Destroy("fatman_reload3")
	timer.Destroy("fatman_reload4")
	timer.Destroy("fatman_reload5")
	timer.Destroy("fatman_reload6")
	timer.Destroy("alien_reload1")
	timer.Destroy("alien_reload2")
	timer.Destroy("shottie_reload1")
	timer.Destroy("shottie_reload2")
	timer.Destroy("shottie_reload3")
	return true
end

/*---------------------------------------------------------
ShootBullet
---------------------------------------------------------*/
function SWEP:CSShootBullet(dmg, recoil, numbul, cone)

	numbul 		= numbul or 1
	cone 			= cone or 0.01

	local bullet 	= {}
	bullet.Num  	= numbul
	bullet.Src 		= self.Owner:GetShootPos()       					-- Source
	bullet.Dir 		= self.Owner:GetAimVector()      					-- Dir of bullet
	bullet.Spread 	= Vector(cone, cone, 0)     						-- Aim Cone
	bullet.Tracer 	= 1       									-- Show a tracer on every x bullets
	bullet.TracerName 	= "HardcoreBullet"
	bullet.Force 	= 0.5 * dmg     								-- Amount of force to give to phys objects
	bullet.Damage 	= dmg										-- Amount of damage to give to the bullets
	bullet.Callback 	= HitImpact
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

-- BULLET PENETRATION | EXPERIMENTAL CODE | BULLETS CAN PASS TROUGHT THE SMALL PROPS
/*---------------------------------------------------------
BulletPenetration
---------------------------------------------------------*/

/*---------------------------------------------------------
function BulletPenetration( hitNum, attacker, tr, dmginfo ) 

 	local DoDefaultEffect = true; 
 	if ( !tr.HitWorld ) then DoDefaultEffect = true end
	if ( tr.HitWorld ) then return end

	if tr.Hit then
	end

 	if ( CLIENT ) then return end 
 	if ( hitNum > 6 ) then return end 

 	local bullet =  
 	{	 
 		Num 		= 1, 
 		Src 		= tr.HitPos + attacker:GetAimVector() * 4, 
 		Dir 		= attacker:GetAimVector(),
 		Spread 	= Vector( 0.005, 0.005, 0 ), 
 		Tracer	= 1, 
 		TracerName 	= "effect_trace_bulletpenetration", 
 		Force		= 0, 
 		Damage	= 25 / hitNum, 
 		AmmoType 	= "Pistol"  
 	} 
 	if (SERVER) then 
 		bullet.Callback    = function( a, b, c ) BulletPenetration( hitNum + 1, a, b, c ) end 
 	end 
 	timer.Simple( 0.01 * hitNum, attacker.FireBullets, attacker, bullet ) 
 	return { damage = true, effects = DoDefaultEffect } 
end
---------------------------------------------------------*/

local function GetMuzzlePosition( weapon, attachment )

    if( !IsValid( weapon ) ) then
        return vector_origin, Angle( 0, 0, 0 );
    end

    local origin = weapon:GetPos();
    local angle = weapon:GetAngles();
    
    // if we're not in a camera and we're being carried by the local player
    // use their view model instead.
    if( weapon:IsWeapon() && weapon:IsCarriedByLocalPlayer() ) then
    
        local owner = weapon:GetOwner();
        if( IsValid( owner ) && GetViewEntity() == owner ) then
        
            local viewmodel = owner:GetViewModel();
            if( IsValid( viewmodel ) ) then
                weapon = viewmodel;
            end
            
        end
    
    end

    // get the attachment
    local attachment = weapon:GetAttachment( attachment or 1 );
    if( !attachment ) then
        return origin, angle;
    end
    
    return attachment.Pos, attachment.Ang;

end



if( CLIENT ) then

    local SparkMaterial = CreateMaterial( "fo3weapons/bullet", "UnlitGeneric", {
        [ "$basetexture" ]    = "sprites/orangeflare1",
        [ "$brightness" ]    = "effects/spark_brightness",
        [ "$additive" ]        = "1",
        [ "$vertexcolor" ]    = "1",
        [ "$vertexalpha" ]    = "1",
    } );
    
    local EFFECT = {};
    
    
    --[[------------------------------------
        Init()
    ------------------------------------]]
    function EFFECT:Init( data )
    
        local weapon = data:GetEntity();
        local attachment = data:GetAttachment();
                
        local startPos = GetMuzzlePosition( weapon, attachment );
        local endPos = data:GetOrigin();
        local distance = ( startPos - endPos ):Length();
        
        self.StartPos = startPos;
        self.EndPos = endPos;
        self.Normal = ( endPos - startPos ):GetNormal();
        self.Length = math.random( 128, 500 );
        self.Magnitude = 50;
        self.StartTime = CurTime();
        self.DieTime = CurTime() + ( distance + self.Length ) / 15000;
        
    end
    
    
    --[[------------------------------------
        Think()
    ------------------------------------]]
    function EFFECT:Think()
        
        return self.DieTime >= CurTime();
        
    end
    
    
    --[[------------------------------------
        Render()
    ------------------------------------]]
    function EFFECT:Render()
    
        local time = CurTime() - self.StartTime;
    
        local endDistance = 15000 * time;
        local startDistance = endDistance - self.Length;
        
        // clamp the start distance so we don't extend behind the weapon
        startDistance = math.max( 0, startDistance );
        
        local startPos = self.StartPos + self.Normal * startDistance;
        local endPos = self.StartPos + self.Normal * endDistance;
        
        // draw the beam
        render.SetMaterial( SparkMaterial );
        render.DrawBeam( startPos, endPos, 25, 0, 1, Color( 255, 255, 255, 255 ) );
    
    end
    
    effects.Register( EFFECT, "HardcoreBullet" );
    
end