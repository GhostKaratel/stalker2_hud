surface.CreateFont('Stalker.Magazine', { size = 60, weight = 0, antialias = true, extended = true, font = 'Reef'})
surface.CreateFont('Stalker.Ammo', { size = 40, weight = 0, antialias = true, extended = true, font = 'Reef'})
surface.CreateFont('Stalker.AmmoType', { size = 30, weight = 0, antialias = true, extended = true, font = 'Akshar'})

local function Text(Text, Font, w, h, ColorText, xAlign, yAlign)
	draw.Text( {
		text = Text,
		font = Font,
		pos = { w, h },
		color = ColorText,
		xalign = xAlign,
		yalign = yAlign
	} )
end

local MaterialArmorBG = Material('ui/ar_bar.png')
local MaterialArmor = Material('ui/armor.png')
local MaterialHealthBG = Material('ui/hp_bar.png')
local MaterialHealth = Material('ui/hp.png')
local MaterialWaterBG = Material('ui/water_bar.png')
local MaterialWater = Material('ui/water.png')
local MaterialBioBG = Material('ui/bio_bar.png')
local MaterialBio = Material('ui/bio.png')
local MaterialHungerBG = Material('ui/hunger_bar.png')
local MaterialHunger = Material('ui/hunger.png')
local MaterialRadiationBG = Material('ui/radiation_bar.png')
local MaterialRadiation = Material('ui/radiation.png')
local MaterialAmmoBG = Material('ui/weapon.png')

local ColorWhite = Color(150,150,150)

local NotAmmo = {
	['weapon_keypadchecker'] = true, 
	['weapon_stunstick'] = true, 
	['weapon_physcannon'] = true,
	['weapon_crowbar'] = true,
	['weapon_bugbait'] = true,
	['gmod_camera'] = true,
	['weapon_fists'] = true,
	['weapon_medkit'] = true,
	['gmod_tool'] = true,
	['weapon_physgun'] = true,
	// ['class'] = true, Свепы, на которых не отображаются патроны
}

local AmmoModel = {
	['AR2'] = 'models/Items/combine_rifle_cartridge01.mdl',
	['Pistol'] = 'models/Items/BoxSRounds.mdl',
	['SMG1'] = 'models/Items/BoxSRounds.mdl',
	['357'] = 'models/Items/357ammo.mdl',
	['XBowBolt'] = 'models/Items/CrossbowRounds.mdl',
	['Buckshot'] = 'models/Items/BoxBuckshot.mdl',
	['RPG_Round'] = 'models/weapons/w_missile_launch.mdl',
	['Grenade'] = 'models/Items/grenadeAmmo.mdl',
	// ['Название патронов'] = 'полный путь до модели', Название можно получить через game.GetAmmoTypes()
}

------------------------------------------------------------
----------- Отключение элементов интерфейса GMOD -----------
------------------------------------------------------------

local ElementsHUD = {
	['CHudHealth'] = true,
	['CHudBattery'] = true,
	['CHudSuitPower'] = true,
	['CHudAmmo'] = true,
	['CHudSecondaryAmmo'] = true,
	['CHUDQuickInfo'] = true,
	['CHudCrosshair'] = true,
	['CHudChat'] = false,
	['CHudDamageIndicator'] = true,
	['CHudZoom'] = true
}

function HUDShouldDraw(name)
	if ElementsHUD[name] then return false end

	return true
end
hook.Add ("HUDShouldDraw", "HUDShouldDraw", HUDShouldDraw)

function HUDDrawTargetID()
    return false
end
hook.Add ("HUDDrawTargetID", "HUDDrawTargetID", HUDDrawTargetID)

------------------------------------------------------------
-------------------- Интерфейс игрока ----------------------
------------------------------------------------------------

local HUD_PANEL
local function UserInterface()
	if !LocalPlayer():Alive() then 
		if IsValid(HUD_PANEL) then HUD_PANEL:Remove() end
		return 
	end

	if IsValid(HUD_PANEL) then return end

	local ply = LocalPlayer()
	local scrw, scrh = ScrW(), ScrH()
	local HP, HPMax, AR, HR, ClampHP, ClampAR, ClampHR, LerpHP, LerpHP2, LerpAR, LerpAR2, WEP, MAG, AMMO, AmmoTYPE, ModelAmmo
	local math_Clamp = math.Clamp
	local FT = FrameTime()
	local lerp = Lerp

	local BarPanel = vgui.Create('EditablePanel')
	HUD_PANEL = BarPanel
	BarPanel:SetPos(10, scrh-268)
	BarPanel:SetSize(69, 258)
	function HUD_PANEL:Paint(w,h)
		HP = ply:Health()
		AR = ply:Armor() // Можете поменять на стамину
		MaxHP = ply:GetMaxHealth()
		MaxAR = ply:GetMaxArmor() // Если изменили "AR", то установите здесь максимальное значение "AR"
		
		--	HR = ply:GetHunger() // Можете установить свои вызовы
		--	RAD = ply:GetRadiation()
		--	TH = ply:GetThirst()
		--	TX = ply:GetToxin()

		LerpHP = lerp(FT*2, LerpHP or 0, HP or 0)
		LerpHP2 = lerp(FT*8, LerpHP2 or 0, HP or 0)
		LerpAR = lerp(FT*2, LerpAR or 0, AR or 0)
		LerpAR2 = lerp(FT*8, LerpAR2 or 0, AR or 0)

		draw.NoTexture()
		surface.SetDrawColor(color_white)
		
		surface.SetMaterial( MaterialArmorBG )
		surface.DrawTexturedRect( 0, 0, 29, h ) 

		surface.SetMaterial( MaterialHealthBG )
		surface.DrawTexturedRect( 19, 0, 16, h )

		/*
		surface.SetMaterial( MaterialWaterBG )
		surface.DrawTexturedRect( w-20, h/2, 18, 24 )

		surface.SetMaterial( MaterialHungerBG )
		surface.DrawTexturedRect( w-22, h/2+34, 22, 22 )

		surface.SetMaterial( MaterialRadiationBG )
		surface.DrawTexturedRect( w-24, h/2+66, 24, 22 )

		surface.SetMaterial( MaterialBioBG )
		surface.DrawTexturedRect( w-23, h/2+97, 22, 21 )

		render.SetScissorRect( w-20, scrh-h/2-12, 80, scrh-h/2+14, true )
			draw.NoTexture()
			surface.SetDrawColor(color_white)
			surface.SetMaterial( MaterialWater ) // Вода
			surface.DrawTexturedRect( w-20, h/2, 18, 24 ) 
		render.SetScissorRect( 0, 0, 0, 0, false ) 

		render.SetScissorRect( w-22, scrh-h/2+25, 80, scrh-h/2+45, true )
			draw.NoTexture()
			surface.SetDrawColor(color_white)
			surface.SetMaterial( MaterialHunger ) // Еда
			surface.DrawTexturedRect( w-22, h/2+34, 22, 22 ) 
		render.SetScissorRect( 0, 0, 0, 0, false ) 

		render.SetScissorRect( w-24, scrh-h/2+55, 80, scrh-h/2+78, true )
			draw.NoTexture()
			surface.SetDrawColor(color_white)
			surface.SetMaterial( MaterialRadiation ) // Радиация
			surface.DrawTexturedRect( w-24, h/2+66, 24, 22 ) 
		render.SetScissorRect( 0, 0, 0, 0, false ) 
		
		render.SetScissorRect( w-23, scrh-h/2+87, 80, scrh-h/2+109, true )
			draw.NoTexture()
			surface.SetDrawColor(color_white)
			surface.SetMaterial( MaterialBio ) // Токсины
			surface.DrawTexturedRect( w-23, h/2+97, 22, 21 ) 
		render.SetScissorRect( 0, 0, 0, 0, false ) 
		*/

		render.SetScissorRect( 0, scrh-math_Clamp(LerpAR, 0, MaxAR)*(268/MaxAR)-10, 20, scrh, true )
			draw.NoTexture()
			surface.SetDrawColor(ColorWhite)
			surface.SetMaterial( MaterialArmor )
			surface.DrawTexturedRect( 0, 0, 10, h ) 
		render.SetScissorRect( 0, 0, 0, 0, false ) 

		render.SetScissorRect( 0, scrh-math_Clamp(LerpAR2, 0, MaxAR)*(268/MaxAR)-10, 20, scrh, true )
			draw.NoTexture()
			surface.SetDrawColor(color_white)
			surface.SetMaterial( MaterialArmor )
			surface.DrawTexturedRect( 0, 0, 10, h ) 
		render.SetScissorRect( 0, 0, 0, 0, false ) 

		render.SetScissorRect( 19, scrh-math_Clamp(LerpHP, 0, MaxHP)*(268/MaxHP)-10, 45, scrh, true )
			draw.NoTexture()
			surface.SetDrawColor(ColorWhite)
			surface.SetMaterial( MaterialHealth )
			surface.DrawTexturedRect( 19, 0, 16, h )
		render.SetScissorRect( 0, 0, 0, 0, false ) 

		render.SetScissorRect( 19, scrh-math.Clamp(LerpHP2, 0, MaxHP)*(268/MaxHP)-10, 45, scrh, true )
			draw.NoTexture()
			surface.SetDrawColor(color_white)
			surface.SetMaterial( MaterialHealth )
			surface.DrawTexturedRect( 19, 0, 16, h )
		render.SetScissorRect( 0, 0, 0, 0, false ) 
	end

	local AmmoPanel = vgui.Create('EditablePanel')
	AmmoPanel:SetPos(scrw-241, scrh-110)
	AmmoPanel:SetSize(221, 100)

	local SpawnI = vgui.Create( "SpawnIcon" , AmmoPanel )
	SpawnI:SetPos( AmmoPanel:GetWide()-58, 0 )
	SpawnI:SetSize( 48, 48 )

	function AmmoPanel:Paint(w,h)
		if not IsValid(HUD_PANEL) then
			self:Remove()
		end

		if not IsValid(ply:GetActiveWeapon()) then 
			SpawnI:SetVisible(false) 
			return 
		else
			SpawnI:SetVisible(true) 
		end

		if NotAmmo[ply:GetActiveWeapon():GetClass()] then 
			SpawnI:SetVisible(false) 
			return 
		else
			SpawnI:SetVisible(true) 
		end

		WEP = ply:GetActiveWeapon()
		MAG = WEP:Clip1()
		AMMO = ply:GetAmmoCount(WEP:GetPrimaryAmmoType())
		AmmoTYPE = game.GetAmmoName( WEP:GetPrimaryAmmoType() )

		draw.NoTexture()
		surface.SetDrawColor(color_white)
		
		surface.SetMaterial( MaterialAmmoBG )
		surface.DrawTexturedRect( 0, 20, 221, 47 ) 

		if MAG > -1 then
			Text(MAG, 'Stalker.Magazine', w/2-45, -5, color_white, 2, 0)
		end

		Text(AMMO, 'Stalker.Ammo', w/2-25, 10, color_white, 0, 0)
		Text(AmmoTYPE, 'Stalker.AmmoType', w-10, h-40, color_white, 2, 0)

		SpawnI:SetModel( AmmoModel[AmmoTYPE] or 'models/Items/BoxMRounds.mdl' )
	end
end

local Dealy = 0

hook.Add( "Think", "DrawHUD", function()
	if LocalPlayer():Alive() and IsValid(HUD_PANEL) then return end

	UserInterface()
end ) 

concommand.Add('RefreshHUD', function(ply)
	if IsValid(HUD_PANEL) then HUD_PANEL:Remove() end
end)