local HttpService 	= game:GetService("HttpService")
local PhysicsService= game:GetService("PhysicsService")
local TS 			= game:GetService('TweenService')
local Debris 		= game:GetService("Debris")
local PhysicsService= game:GetService("PhysicsService")
local Run 			= game:GetService("RunService")
local RS 			= game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local plr 			= game:GetService("Players")

local ACS_Workspace = workspace:WaitForChild("ACS_WorkSpace")
local Engine 		= RS:WaitForChild("ACS_Engine")
local Evt 			= Engine:WaitForChild("Events")
local Mods 			= Engine:WaitForChild("Modules")
local ArmModel 		= Engine:WaitForChild("ArmModel")
local GunModels 	= Engine:WaitForChild("GunModels")
local SVGunModels 	= Engine:WaitForChild("GrenadeModels")
local HUDs 			= Engine:WaitForChild("HUD")
local AttModels 	= Engine:WaitForChild("AttModels")
local AttModules  	= Engine:WaitForChild("AttModules")
local Rules			= Engine:WaitForChild("GameRules")

local gameRules		= require(Rules:WaitForChild("Config"))
local CombatLog		= require(Rules:WaitForChild("CombatLog"))
local SpringMod 	= require(Mods:WaitForChild("Spring"))
local HitMod 		= require(Mods:WaitForChild("Hitmarker"))
local Ultil			= require(Mods:WaitForChild("Utilities"))
local Ragdoll		= require(Mods:WaitForChild("Ragdoll"))

local ACS_0 		= HttpService:GenerateGUID(true)
local Backup 		= 0

local TempBannedPlayers = {} --Local ban list

local Explosion = {"287390459"; "287390954"; "287391087"; "287391197"; "287391361"; "287391499"; "287391567";}
-----------------------------------------------------------------

game.StarterPlayer.CharacterWalkSpeed = gameRules.NormalWalkSpeed

local function AccessID(SKP_0,SKP_1)
	if SKP_0.UserId ~= SKP_1 then
		SKP_0:kick("Exploit Protocol");
		warn(SKP_0.Name.." - Potential Exploiter! Case 0-A: Client Tried To Access Server Code");
		table.insert(TempBannedPlayers, SKP_0);
	end;
	return ACS_0;
end;

Evt.AcessId.OnServerInvoke = AccessID

--Glenn's Anti-Exploit System (GAE for short). This code is very ugly, but does job done
local function compareTables(arr1, arr2)
	if	arr1.gunName==arr2.gunName 				and 
		arr1.Type==arr2.Type 					and
		arr1.ShootRate==arr2.ShootRate 			and
		arr1.Bullets==arr2.Bullets				and
		arr1.LimbDamage[1]==arr2.LimbDamage[1]	and
		arr1.LimbDamage[2]==arr2.LimbDamage[2]	and
		arr1.TorsoDamage[1]==arr2.TorsoDamage[1]and
		arr1.TorsoDamage[2]==arr2.TorsoDamage[2]and
		arr1.HeadDamage[1]==arr2.HeadDamage[1]	and
		arr1.HeadDamage[2]==arr2.HeadDamage[2]
	then return true; end;
	return false;
end;

local function secureSettings(Player,Gun,Module)
	local PreNewModule = Gun:FindFirstChild("ACS_Settings");
	if not Gun or not PreNewModule then
		Player:kick("Exploit Protocol");
		warn(Player.Name.." - Potential Exploiter! Case 2: Missing Gun And Module")	;
		return false;
	end;

	local NewModule = require(PreNewModule);
	if (compareTables(Module, NewModule) == false) then
		Player:kick("Exploit Protocol");
		warn(Player.Name.." - Potential Exploiter! Case 4: Exploiting Gun Stats")	;
		table.insert(TempBannedPlayers, Player);
		return false;
	end;
	return true;
end;

function CalculateDMG(SKP_0, SKP_1, SKP_2, SKP_4, SKP_5, SKP_6)

	local skp_0	= plr:GetPlayerFromCharacter(SKP_1.Parent) or nil
	local skp_1 = 0
	local skp_2 = SKP_5.MinDamage * SKP_6.minDamageMod

	if SKP_4 == 1 then
		local skp_3 = math.random(SKP_5.HeadDamage[1], SKP_5.HeadDamage[2])
		skp_1 = math.max(skp_2 ,(skp_3 * SKP_6.DamageMod) - (SKP_2/25) * SKP_5.DamageFallOf)
	elseif SKP_4 == 2 then
		local skp_3 = math.random(SKP_5.TorsoDamage[1], SKP_5.TorsoDamage[2])
		skp_1 = math.max(skp_2 ,(skp_3 * SKP_6.DamageMod) - (SKP_2/25) * SKP_5.DamageFallOf)
	else
		local skp_3 = math.random(SKP_5.LimbDamage[1], SKP_5.LimbDamage[2])
		skp_1 = math.max(skp_2 ,(skp_3 * SKP_6.DamageMod) - (SKP_2/25) * SKP_5.DamageFallOf)
	end

	if SKP_1.Parent:FindFirstChild("ACS_Client") and not SKP_5.IgnoreProtection then

		local skp_4 = SKP_1.Parent.ACS_Client.Protecao.VestProtect
		local skp_5 = SKP_1.Parent.ACS_Client.Protecao.HelmetProtect

		if SKP_4 == 1 then
			if SKP_5.BulletPenetration < skp_5.Value  then
				skp_1 = math.max(.5 ,skp_1 * (SKP_5.BulletPenetration/skp_5.Value))
			end
		else
			if SKP_5.BulletPenetration < skp_4.Value  then
				skp_1 = math.max(.5 ,skp_1 * (SKP_5.BulletPenetration/skp_4.Value))
			end
		end
	end		

	if skp_0 then
		if skp_0.Team ~= SKP_0.Team or skp_0.Neutral then
			local skp_t	= Instance.new("ObjectValue")
			skp_t.Name	= "creator"
			skp_t.Value	= SKP_0
			skp_t.Parent= SKP_1
			game.Debris:AddItem(skp_t, 1)

			SKP_1:TakeDamage(skp_1)
			return;
		end;

		if not gameRules.TeamKill then return; end;
		local skp_t	= Instance.new("ObjectValue")
		skp_t.Name	= "creator"
		skp_t.Value	= SKP_0
		skp_t.Parent= SKP_1
		game.Debris:AddItem(skp_t, 1)

		SKP_1:TakeDamage(skp_1 * gameRules.TeamDmgMult)
		return;
	end

	local skp_t	= Instance.new("ObjectValue")
	skp_t.Name	= "creator"
	skp_t.Value	= SKP_0
	skp_t.Parent= SKP_1
	game.Debris:AddItem(skp_t, 1)

	SKP_1:TakeDamage(skp_1)
	return;
end

local function Damage(SKP_0, SKP_1, SKP_2, SKP_3, SKP_4, SKP_5, SKP_6, SKP_7, SKP_8, SKP_9)
	if not SKP_0 or not SKP_0.Character then return; end;
	if not SKP_0.Character:FindFirstChild("Humanoid") or SKP_0.Character.Humanoid.Health <= 0 then return; end;
	if SKP_9 == (ACS_0.."-"..SKP_0.UserId) then
		if SKP_7 then
			SKP_0.Character.Humanoid:TakeDamage(math.max(SKP_8, 0))
			return;
		end

		if SKP_1 then
			local skp_0 = secureSettings(SKP_0,SKP_1, SKP_5)
			if not skp_0 or not SKP_2 then return; end;
			CalculateDMG(SKP_0, SKP_2, SKP_3, SKP_4, SKP_5, SKP_6)
			return;
		end

		SKP_0:kick("Exploit Protocol")
		warn(SKP_0.Name.." - Potential Exploiter! Case 1: Tried To Access Damage Event")
		table.insert(TempBannedPlayers, SKP_0)
		return;
	end
	SKP_0:kick("Exploit Protocol")
	warn(SKP_0.Name.." - Potential Exploiter! Case 0-B: Wrong Permission Code")
	table.insert(TempBannedPlayers, SKP_0)
	return;
end

Evt.Damage.OnServerInvoke = Damage

Evt.HitEffect.OnServerEvent:Connect(function(Player, Position, HitPart, Normal, Material, Settings)
	Evt.HitEffect:FireAllClients(Player, Position, HitPart, Normal, Material, Settings)
end)

Evt.GunStance.OnServerEvent:Connect(function(Player,stance,Data)
	Evt.GunStance:FireAllClients(Player,stance,Data)
end)

Evt.ServerBullet.OnServerEvent:Connect(function(Player,Origin,Direction,WeaponData,ModTable)
	Evt.ServerBullet:FireAllClients(Player,Origin,Direction,WeaponData,ModTable)
end)


Evt.Stance.OnServerEvent:connect(function(Player, Stance, Virar)

	if not Player or not Player.Character then return; end; --// Player or Character doesn't exist
	if not Player.Character:FindFirstChild("Humanoid") or Player.Character.Humanoid.Health <= 0 then return; end; --// Player is dead

	local ACS_Client= Player.Character:FindFirstChild("ACS_Client")
	if not ACS_Client then return; end;

	local Torso 	= Player.Character:FindFirstChild("Torso")
	local RootPart 	= Player.Character:FindFirstChild("HumanoidRootPart")

	if not Torso or not RootPart then return; end; --// Essential bodyparts doesn't exist in this character

	local RootJoint = RootPart:FindFirstChild("RootJoint")
	local RS 		= Torso:FindFirstChild("Right Shoulder")
	local LS 		= Torso:FindFirstChild("Left Shoulder")
	local RH 		= Torso:FindFirstChild("Right Hip")
	local LH 		= Torso:FindFirstChild("Left Hip")

	if not RootJoint or not RS or not LS or not RH or not LH then return; end; --// Joints doesn't exist

	if Stance == 2 then
		TS:Create(RootJoint, TweenInfo.new(.3), {C1 = CFrame.new(0,1.5,2.45) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(180))} ):Play()
		TS:Create(RH, TweenInfo.new(.3), {C1 = CFrame.new(.5,1,0)* CFrame.Angles(math.rad(-5),math.rad(90),math.rad(0))} ):Play()
		TS:Create(LH, TweenInfo.new(.3), {C1 = CFrame.new(-.5,1,0)* CFrame.Angles(math.rad(-5),math.rad(-90),math.rad(0))} ):Play()
	end
	if Virar == 1 then
		if Stance == 0 then
			TS:Create(RootJoint, TweenInfo.new(.3), {C1 = CFrame.new(-1,-0,0) * CFrame.Angles(math.rad(-90),math.rad(-15),math.rad(-180))} ):Play()
			TS:Create(RH, TweenInfo.new(.3), {C1 = CFrame.new(.5,1,0)* CFrame.Angles(math.rad(0),math.rad(90),math.rad(0))} ):Play()
			TS:Create(LH, TweenInfo.new(.3), {C1 = CFrame.new(-.5,1,0)* CFrame.Angles(math.rad(0),math.rad(-90),math.rad(0))} ):Play()

		elseif Stance == 1 then
			TS:Create(RootJoint, TweenInfo.new(.3), {C1 = CFrame.new(-1,.75,0.25)* CFrame.Angles(math.rad(-80),math.rad(-15),math.rad(-180))} ):Play()
			TS:Create(RH, TweenInfo.new(.3), {C1 = CFrame.new(.5,0,0.4)* CFrame.Angles(math.rad(20),math.rad(90),math.rad(0))} ):Play()
			TS:Create(LH, TweenInfo.new(.3), {C1 = CFrame.new(-.5,0,0.4)* CFrame.Angles(math.rad(20),math.rad(-90),math.rad(0))} ):Play()

		end
	elseif Virar == -1 then
		if Stance == 0 then
			TS:Create(RootJoint, TweenInfo.new(.3), {C1 = CFrame.new(1,0,0) * CFrame.Angles(math.rad(-90),math.rad(15),math.rad(180))} ):Play()
			TS:Create(RH, TweenInfo.new(.3), {C1 = CFrame.new(.5,1,0)* CFrame.Angles(math.rad(0),math.rad(90),math.rad(0))} ):Play()
			TS:Create(LH, TweenInfo.new(.3), {C1 = CFrame.new(-.5,1,0)* CFrame.Angles(math.rad(0),math.rad(-90),math.rad(0))} ):Play()

		elseif Stance == 1 then
			TS:Create(RootJoint, TweenInfo.new(.3), {C1 = CFrame.new(1,.75,0.25)* CFrame.Angles(math.rad(-80),math.rad(15),math.rad(180))} ):Play()
			TS:Create(RH, TweenInfo.new(.3), {C1 = CFrame.new(.5,0,0.4)* CFrame.Angles(math.rad(20),math.rad(90),math.rad(0))} ):Play()
			TS:Create(LH, TweenInfo.new(.3), {C1 = CFrame.new(-.5,0,0.4)* CFrame.Angles(math.rad(20),math.rad(-90),math.rad(0))} ):Play()
		end
	elseif Virar == 0 then
		if Stance == 0 then
			TS:Create(RootJoint, TweenInfo.new(.3), {C1 = CFrame.new(0,0,0)* CFrame.Angles(math.rad(-90),math.rad(0),math.rad(180))} ):Play()
			TS:Create(RH, TweenInfo.new(.3), {C1 = CFrame.new(.5,1,0)* CFrame.Angles(math.rad(0),math.rad(90),math.rad(0))} ):Play()
			TS:Create(LH, TweenInfo.new(.3), {C1 = CFrame.new(-.5,1,0)* CFrame.Angles(math.rad(0),math.rad(-90),math.rad(0))} ):Play()

		elseif Stance == 1 then
			TS:Create(RootJoint, TweenInfo.new(.3), {C1 = CFrame.new(0,1,0.25)* CFrame.Angles(math.rad(-80),math.rad(0),math.rad(180))} ):Play()
			TS:Create(RH, TweenInfo.new(.3), {C1 = CFrame.new(.5,0,0.4)* CFrame.Angles(math.rad(20),math.rad(90),math.rad(0))} ):Play()
			TS:Create(LH, TweenInfo.new(.3), {C1 = CFrame.new(-.5,0,0.4)* CFrame.Angles(math.rad(20),math.rad(-90),math.rad(0))} ):Play()
		end
	end

	if ACS_Client:GetAttribute("Surrender") then
		TS:Create(RS, TweenInfo.new(.3), {C1 = CFrame.new(-.5,0.95,0)* CFrame.Angles(math.rad(-175),math.rad(90),math.rad(0))} ):Play()
		TS:Create(LS, TweenInfo.new(.3), {C1 = CFrame.new(.5,0.95,0)* CFrame.Angles(math.rad(-175),math.rad(-90),math.rad(0))} ):Play()
	elseif Stance == 2 then
		TS:Create(RS, TweenInfo.new(.3), {C1 = CFrame.new(-.5,0.95,0)* CFrame.Angles(math.rad(-175),math.rad(90),math.rad(0))} ):Play()
		TS:Create(LS, TweenInfo.new(.3), {C1 = CFrame.new(.5,0.95,0)* CFrame.Angles(math.rad(-175),math.rad(-90),math.rad(0))} ):Play()
	else
		--p1.CFrame:Inverse() * p2.CFrame
		TS:Create(RS, TweenInfo.new(.3), {C1 = CFrame.new(-.5,0.5,0)* CFrame.Angles(math.rad(0),math.rad(90),math.rad(0))} ):Play()
		TS:Create(LS, TweenInfo.new(.3), {C1 = CFrame.new(.5,0.5,0)* CFrame.Angles(math.rad(0),math.rad(-90),math.rad(0))} ):Play()
	end

end)

Evt.Surrender.OnServerEvent:Connect(function(Player,Victim)
	if not Player or not Player.Character then return; end;

	local PClient 	= nil
	if Victim then
		if Victim == Player or not Victim.Character then return; end;

		PClient = Victim.Character:FindFirstChild("ACS_Client")
		if not PClient then return; end;

		if PClient:GetAttribute("Surrender") then
			PClient:SetAttribute("Surrender",false)
		end
	end

	PClient = Player.Character:FindFirstChild("ACS_Client")
	if not PClient then return; end;

	if not PClient:GetAttribute("Surrender") then
		PClient:SetAttribute("Surrender",true)
	end
end)

Evt.Grenade.OnServerEvent:Connect(function(SKP_0, SKP_1, SKP_2, SKP_3, SKP_4, SKP_5, SKP_6)
	if not SKP_0 or not SKP_0.Character then return; end;
	if not SKP_0.Character:FindFirstChild("Humanoid") or SKP_0.Character.Humanoid.Health <= 0 then return; end;

	if SKP_6 ~= (ACS_0.."-"..SKP_0.UserId) then
		SKP_0:kick("Exploit Protocol")
		warn(SKP_0.Name.." - Potential Exploiter! Case 0-B: Wrong Permission Code")
		table.insert(TempBannedPlayers, SKP_0)
		return;
	end

	if not SKP_1 or not SKP_2 then
		SKP_0:kick("Exploit Protocol")
		warn(SKP_0.Name.." - Potential Exploiter! Case 3: Tried To Access Grenade Event")
		return;
	end

	local skp_0 = secureSettings(SKP_0, SKP_1, SKP_2)
	if not skp_0 or SKP_2.Type ~= "Grenade" then return; end;

	if not SVGunModels:FindFirstChild(SKP_2.gunName) then warn("ACS_Server Couldn't Find "..SKP_2.gunName.." In Grenade Model Folder"); return; end;

	local skp_0 = SVGunModels[SKP_2.gunName]:Clone()

	for SKP_Arg0, SKP_Arg1 in pairs(SKP_0.Character:GetChildren()) do
		if not SKP_Arg1:IsA('BasePart') then continue; end;
		local skp_1 = Instance.new("NoCollisionConstraint")
		skp_1.Parent= skp_0
		skp_1.Part0 = skp_0.PrimaryPart
		skp_1.Part1 = SKP_Arg1
	end

	local skp_1	= Instance.new("ObjectValue")
	skp_1.Name	= "creator"
	skp_1.Value	= SKP_0
	skp_1.Parent= skp_0.PrimaryPart

	skp_0.Parent 	= ACS_Workspace.Server
	skp_0.PrimaryPart.CFrame = SKP_3
	skp_0.PrimaryPart:ApplyImpulse(SKP_4 * SKP_5 * skp_0.PrimaryPart:GetMass())
	skp_0.PrimaryPart:SetNetworkOwner(nil)
	skp_0.PrimaryPart.Damage.Disabled = false

	SKP_1:Destroy()
end)

function loadAttachment(weapon,WeaponData)
	if not weapon or not WeaponData or not weapon:FindFirstChild("Nodes") then return; end;
	--load sight Att
	if weapon.Nodes:FindFirstChild("Sight") and WeaponData.SightAtt ~= "" then

		local SightAtt = AttModels[WeaponData.SightAtt]:Clone()
		SightAtt.Parent = weapon
		SightAtt:SetPrimaryPartCFrame(weapon.Nodes.Sight.CFrame)

		for index, key in pairs(weapon:GetChildren()) do
			if not key:IsA('BasePart') or key.Name ~= "IS" then continue; end;
			key.Transparency = 1
		end

		for index, key in pairs(SightAtt:GetChildren()) do
			if key.Name == "SightMark" or key.Name == "Main" then key:Destroy(); continue; end;
			if not key:IsA('BasePart') then continue; end;
			Ultil.Weld(weapon:WaitForChild("Handle"), key )
			key.Anchored = false
			key.CanCollide = false
		end

	end

	--load Barrel Att
	if weapon.Nodes:FindFirstChild("Barrel") and WeaponData.BarrelAtt ~= "" then

		local BarrelAtt = AttModels[WeaponData.BarrelAtt]:Clone()
		BarrelAtt.Parent = weapon
		BarrelAtt:SetPrimaryPartCFrame(weapon.Nodes.Barrel.CFrame)

		if BarrelAtt:FindFirstChild("BarrelPos") then
			weapon.Handle.Muzzle.WorldCFrame = BarrelAtt.BarrelPos.CFrame
		end

		for index, key in pairs(BarrelAtt:GetChildren()) do
			if not key:IsA('BasePart') then continue; end;
			Ultil.Weld(weapon:WaitForChild("Handle"), key )
			key.Anchored = false
			key.CanCollide = false
		end
	end

	--load Under Barrel Att
	if weapon.Nodes:FindFirstChild("UnderBarrel") and WeaponData.UnderBarrelAtt ~= "" then

		local UnderBarrelAtt = AttModels[WeaponData.UnderBarrelAtt]:Clone()
		UnderBarrelAtt.Parent = weapon
		UnderBarrelAtt:SetPrimaryPartCFrame(weapon.Nodes.UnderBarrel.CFrame)


		for index, key in pairs(UnderBarrelAtt:GetChildren()) do
			if not key:IsA('BasePart') then continue; end;
			Ultil.Weld(weapon:WaitForChild("Handle"), key )
			key.Anchored = false
			key.CanCollide = false
		end
	end

	if weapon.Nodes:FindFirstChild("Other") and WeaponData.OtherAtt ~= "" then

		local OtherAtt = AttModels[WeaponData.OtherAtt]:Clone()
		OtherAtt.Parent = weapon
		OtherAtt:SetPrimaryPartCFrame(weapon.Nodes.Other.CFrame)

		for index, key in pairs(OtherAtt:GetChildren()) do
			if not key:IsA('BasePart') then continue; end;
			Ultil.Weld(weapon:WaitForChild("Handle"), key )
			key.Anchored = false
			key.CanCollide = false

		end
	end
end

Evt.Equip.OnServerEvent:Connect(function(Player,Arma,Mode,Settings,Anim)
	if not Player or not Player.Character then return; end;

	local Head 		= Player.Character:FindFirstChild('Head')
	local Torso 	= Player.Character:FindFirstChild('Torso')
	local LeftArm 	= Player.Character:FindFirstChild('Left Arm')
	local RightArm 	= Player.Character:FindFirstChild('Right Arm')

	if not Head or not Torso or not LeftArm or not RightArm then return; end;
	local RS 		= Torso:FindFirstChild("Right Shoulder")
	local LS 		= Torso:FindFirstChild("Left Shoulder")
	if not RS or not LS then return; end;

	--// EQUIP
	if Mode == 1 then
		local GunModel = GunModels:FindFirstChild(Arma.Name)
		if not GunModel then warn(Player.Name..": Couldn't load Server-side weapon model") return; end;

		local ServerGun = GunModel:Clone()
		ServerGun.Name = 'S' .. Arma.Name

		local AnimBase = Instance.new("Part", Player.Character)
		AnimBase.FormFactor = "Custom"
		AnimBase.CanCollide = false
		AnimBase.Transparency = 1
		AnimBase.Anchored = false
		AnimBase.Name = "AnimBase"
		AnimBase.Size = Vector3.new(0.1, 0.1, 0.1)

		local AnimBaseW = Instance.new("Motor6D")
		AnimBaseW.Part0 = Head
		AnimBaseW.Part1 = AnimBase
		AnimBaseW.Parent = AnimBase
		AnimBaseW.Name = "AnimBaseW"
		--AnimBaseW.C0 = CFrame.new(0,-1.25,0)

		local ruaw = Instance.new("Motor6D")
		ruaw.Name = "RAW"
		ruaw.Part0 = RightArm
		ruaw.Part1 = AnimBase
		ruaw.Parent = AnimBase
		ruaw.C0 = Anim.SV_RightArmPos
		RS.Enabled = false

		local luaw = Instance.new("Motor6D")
		luaw.Name = "LAW"
		luaw.Part0 = LeftArm
		luaw.Part1 = AnimBase
		luaw.Parent = AnimBase
		luaw.C0 = Anim.SV_LeftArmPos
		LS.Enabled = false

		ServerGun.Parent = Player.Character

		loadAttachment(ServerGun,Settings)

		if ServerGun:FindFirstChild("Nodes") ~= nil then
			ServerGun.Nodes:Destroy()
		end

		for SKP_001, SKP_002 in pairs(ServerGun:GetDescendants()) do
			if SKP_002.Name ~= "SightMark" then continue; end;
			SKP_002:Destroy()
		end

		for SKP_001, SKP_002 in pairs(ServerGun:GetDescendants()) do
			if not SKP_002:IsA('BasePart') or SKP_002.Name == 'Handle' then continue; end;
			Ultil.WeldComplex(ServerGun:WaitForChild("Handle"), SKP_002, SKP_002.Name)
		end

		local SKP_004 = Instance.new('Motor6D')
		SKP_004.Name = 'Handle'
		SKP_004.Parent = ServerGun.Handle
		SKP_004.Part0 = RightArm
		SKP_004.Part1 = ServerGun.Handle
		SKP_004.C1 = Anim.SV_GunPos:Inverse()

		for L_74_forvar1, L_75_forvar2 in pairs(ServerGun:GetDescendants()) do
			if not L_75_forvar2:IsA('BasePart') then continue; end;
			L_75_forvar2.Anchored = false
			L_75_forvar2.CanCollide = false
		end
		return;
	end;
	--// UNEQUIP
	if Mode == 2 then
		if Arma and Player.Character:FindFirstChild('S' .. Arma.Name) then
			Player.Character['S' .. Arma.Name]:Destroy()
			Player.Character.AnimBase:Destroy()
		end

		RS.Enabled = true
		LS.Enabled = true
	end
	return;
end)

Evt.Squad.OnServerEvent:Connect(function(Player,SquadName,SquadColor)
	if not Player or not Player.Character then return; end;
	if not Player.Character:FindFirstChild("ACS_Client") then return; end;

	Player.Character.ACS_Client.FireTeam.SquadName.Value = SquadName
	Player.Character.ACS_Client.FireTeam.SquadColor.Value = SquadColor
end)

Evt.HeadRot.OnServerEvent:connect(function(Player, CF)
	Evt.HeadRot:FireAllClients(Player, CF)
end)

Evt.Atirar.OnServerEvent:Connect(function(Player, Arma, Suppressor, FlashHider)
	Evt.Atirar:FireAllClients(Player, Arma, Suppressor, FlashHider)
end)

Evt.Whizz.OnServerEvent:Connect(function(Player, Victim)
	Evt.Whizz:FireClient(Victim)
end)

Evt.Suppression.OnServerEvent:Connect(function(Player,Victim,Mode,Intensity,Time)
	Evt.Suppression:FireClient(Victim,Mode,Intensity,Time)
end)

Evt.Refil.OnServerEvent:Connect(function(Player, Stored, NewStored)
	Stored.Value = Stored.Value - NewStored
end)

Evt.SVLaser.OnServerEvent:Connect(function(Player,Position,Modo,Cor,IRmode,Arma)
	Evt.SVLaser:FireAllClients(Player,Position,Modo,Cor,IRmode,Arma)
end)

Evt.SVFlash.OnServerEvent:Connect(function(Player,Arma,Mode)
	Evt.SVFlash:FireAllClients(Player,Arma,Mode)
end)

----------------------------------------------------------------
--\\DOORS & BREACHING SYSTEM
----------------------------------------------------------------

local DoorsFolder 		= ACS_Workspace:FindFirstChild("Doors")
local DoorsFolderClone 	= DoorsFolder:Clone()
local BreachClone 		= ACS_Workspace.Breach:Clone()
BreachClone.Parent 		= ServerStorage
DoorsFolderClone.Parent = ServerStorage

function ToggleDoor(Door)
	local Hinge = Door.Door:FindFirstChild("Hinge")
	if not Hinge then return end
	local HingeConstraint = Hinge.HingeConstraint

	if HingeConstraint.TargetAngle == 0 then
		HingeConstraint.TargetAngle = -90
	elseif HingeConstraint.TargetAngle == -90 then
		HingeConstraint.TargetAngle = 0
	end	
end

Evt.DoorEvent.OnServerEvent:Connect(function(Player,Door,Mode,Key)
	if Door ~= nil then
		if Mode == 1 then
			if Door:FindFirstChild("Locked") ~= nil and Door.Locked.Value == true then
				if Door:FindFirstChild("RequiresKey") then
					local Character = Player.Character
					if Character:FindFirstChild(Key) ~= nil or Player.Backpack:FindFirstChild(Key) ~= nil then
						if Door.Locked.Value == true then
							Door.Locked.Value = false
						end
						ToggleDoor(Door)
					end	
				end
			else
				ToggleDoor(Door)
			end
		elseif Mode == 2 then
			if Door:FindFirstChild("Locked") == nil or (Door:FindFirstChild("Locked") ~= nil and Door.Locked.Value == false) then
				ToggleDoor(Door)
			end
		elseif Mode == 3 then
			if Door:FindFirstChild("RequiresKey") then
				local Character = Player.Character
				Key = Door.RequiresKey.Value
				if Character:FindFirstChild(Key) ~= nil or Player.Backpack:FindFirstChild(Key) ~= nil then
					if Door:FindFirstChild("Locked") ~= nil and Door.Locked.Value == true then
						Door.Locked.Value = false
					else
						Door.Locked.Value = true
					end
				end
			end
		elseif Mode == 4 then
			if Door:FindFirstChild("Locked") ~= nil and Door.Locked.Value == true then
				Door.Locked.Value = false
			end
		end
	end
end)

Evt.MedSys.Collapse.OnServerEvent:Connect(function(Player)

	if not Player or not Player.Character then return; end;

	local Human 	= Player.Character:FindFirstChild("Humanoid") 
	local PClient 	= Player.Character:FindFirstChild("ACS_Client") 

	if not Human or not PClient then return; end;

	local Dor 		= PClient.Variaveis.Dor
	local Sangue 	= PClient.Variaveis.Sangue

	if (Sangue.Value <= 3500) or (Dor.Value >= 200) or PClient:GetAttribute("Collapsed") then -- Man this Guy's Really wounded,
		Human.PlatformStand = true
		Human.AutoRotate = false	
		PClient:SetAttribute("Collapsed",true)
	elseif (Sangue.Value > 3500) and (Dor.Value < 200) and not PClient:GetAttribute("Collapsed")  then -- YAY A MEDIC ARRIVED! =D
		Human.PlatformStand = false
		Human.AutoRotate = true	
		PClient:SetAttribute("Collapsed",false)
	end
end)

Evt.MedSys.MedHandler.OnServerEvent:Connect(function(Player, Victim, Mode)
	if not Player or not Player.Character then return; end;
	if not Player.Character:FindFirstChild("Humanoid") or Player.Character.Humanoid.Health <= 0 then return; end;

	local P1_Client = Player.Character:FindFirstChild("ACS_Client")
	if not P1_Client then warn(Player.Name.."'s Action Failed: Missing ACS_Client"); return; end;

	if P1_Client:GetAttribute("Collapsed") then return; end;

	if Victim then --Multiplayer functions
		if not Victim.Character or not Victim.Character:FindFirstChild("HumanoidRootPart") or not Player.Character:FindFirstChild("HumanoidRootPart") then return; end;
		if (Player.Character.HumanoidRootPart.Position - Victim.Character.HumanoidRootPart.Position).Magnitude > 15 then warn(Player.Name.." is too far to treat "..Victim.Name); return; end;


		local P2_Client = Victim.Character:FindFirstChild("ACS_Client")
		if not P2_Client then warn(Player.Name.."'s Action Failed: Missing "..Victim.Name.."'s ACS_Client"); return; end;

		if Mode == 1 and P1_Client.Kit.Bandage.Value > 0 and P2_Client:GetAttribute("Bleeding") then
			P1_Client.Kit.Bandage.Value = P1_Client.Kit.Bandage.Value - 1
			P2_Client:SetAttribute("Bleeding",false)
			return;

		elseif Mode == 2 and P1_Client.Kit.Splint.Value > 0 and P2_Client:GetAttribute("Injured") then
			P1_Client.Kit.Splint.Value = P1_Client.Kit.Splint.Value - 1
			P2_Client:SetAttribute("Injured",false)
			return;

		elseif Mode == 3 and (P2_Client:GetAttribute("Bleeding") == true or P2_Client:GetAttribute("Tourniquet")) then --Tourniquet works a little different :T
			if P2_Client:GetAttribute("Tourniquet")then
				P1_Client.Kit.Tourniquet.Value = P1_Client.Kit.Tourniquet.Value + 1
				P2_Client:SetAttribute("Tourniquet",false)
				return;
			end

			if P1_Client.Kit.Tourniquet.Value <= 0 then return; end;
			P1_Client.Kit.Tourniquet.Value = P1_Client.Kit.Tourniquet.Value - 1
			P2_Client:SetAttribute("Tourniquet",true)
			return;

		elseif Mode == 4 and P1_Client.Kit.PainKiller.Value > 0 and P2_Client.Variaveis.Dor.Value > 0 then
			P1_Client.Kit.PainKiller.Value = P1_Client.Kit.PainKiller.Value - 1
			P2_Client.Variaveis.Dor.Value = math.clamp(P2_Client.Variaveis.Dor.Value - math.random(35,65),0,300)
			Evt.MedSys.MedHandler:FireClient(Victim,4)
			return;

		elseif Mode == 5 and P1_Client.Kit.EnergyShot.Value > 0 and Victim.Character.Humanoid.Health < Victim.Character.Humanoid.MaxHealth then
			P1_Client.Kit.EnergyShot.Value = P1_Client.Kit.EnergyShot.Value - 1
			local HealValue = math.random(15,25)
			if Victim.Character.Humanoid.Health + HealValue < Victim.Character.Humanoid.MaxHealth then
				Victim.Character.Humanoid:TakeDamage(-HealValue)
			else
				Victim.Character.Humanoid.Health = Victim.Character.Humanoid.MaxHealth
			end
			Evt.MedSys.MedHandler:FireClient(Victim,5)
			return;

		elseif Mode == 6 and P1_Client.Kit.Morphine.Value > 0 and P2_Client.Variaveis.Dor.Value > 0 then
			P1_Client.Kit.Morphine.Value = P1_Client.Kit.Morphine.Value - 1
			P2_Client.Variaveis.Dor.Value = 0
			Evt.MedSys.MedHandler:FireClient(Victim,6)
			return;

		elseif Mode == 7 and P1_Client.Kit.Epinephrine.Value > 0 and P2_Client:GetAttribute("Collapsed")then
			P1_Client.Kit.Epinephrine.Value = P1_Client.Kit.Epinephrine.Value - 1
			local HealValue = math.random(45,55)
			if Victim.Character.Humanoid.Health + HealValue < Victim.Character.Humanoid.MaxHealth then
				Victim.Character.Humanoid:TakeDamage(-HealValue)
			else
				Victim.Character.Humanoid.Health = Victim.Character.Humanoid.MaxHealth
			end
			P2_Client:SetAttribute("Collapsed",false)
			Evt.MedSys.MedHandler:FireClient(Victim,7)
			return;

		elseif Mode == 8 and P1_Client.Kit.BloodBag.Value > 0 and P2_Client.Variaveis.Sangue.Value < P2_Client.Variaveis.Sangue.MaxValue then
			P1_Client.Kit.BloodBag.Value = P1_Client.Kit.BloodBag.Value - 1
			P2_Client.Variaveis.Sangue.Value = P2_Client.Variaveis.Sangue.Value + 2000
			return;
		else
			warn(Player.Name.."'s Action Failed: Unknow Method")
		end
		return;
	end 
	--Self treat
	if Mode == 1 and P1_Client.Kit.Bandage.Value > 0 and P1_Client:GetAttribute("Bleeding") then
		P1_Client.Kit.Bandage.Value = P1_Client.Kit.Bandage.Value - 1
		P1_Client:SetAttribute("Bleeding",false)
		return;

	elseif Mode == 2 and P1_Client.Kit.Splint.Value > 0 and P1_Client:GetAttribute("Injured") then
		P1_Client.Kit.Splint.Value = P1_Client.Kit.Splint.Value - 1
		P1_Client:SetAttribute("Injured",false)
		return;

	elseif Mode == 3 and (P1_Client:GetAttribute("Bleeding") or P1_Client:GetAttribute("Tourniquet")) then --Tourniquet works a little diferent :T
		if P1_Client:GetAttribute("Tourniquet") then
			P1_Client.Kit.Tourniquet.Value = P1_Client.Kit.Tourniquet.Value + 1
			P1_Client:SetAttribute("Tourniquet",false)
			return;
		end

		if P1_Client.Kit.Tourniquet.Value <= 0 then return; end;
		P1_Client.Kit.Tourniquet.Value = P1_Client.Kit.Tourniquet.Value - 1
		P1_Client:SetAttribute("Tourniquet",true)
		return;

	elseif Mode == 4 and P1_Client.Kit.PainKiller.Value > 0 and P1_Client.Variaveis.Dor.Value > 0 then
		P1_Client.Kit.PainKiller.Value = P1_Client.Kit.PainKiller.Value - 1
		P1_Client.Variaveis.Dor.Value = math.clamp(P1_Client.Variaveis.Dor.Value - math.random(35,65),0,300)
		Evt.MedSys.MedHandler:FireClient(Player,4)
		return;

	elseif Mode == 5 and P1_Client.Kit.EnergyShot.Value > 0 and Player.Character.Humanoid.Health < Player.Character.Humanoid.MaxHealth then
		P1_Client.Kit.EnergyShot.Value = P1_Client.Kit.EnergyShot.Value - 1
		local HealValue = math.random(15,25)
		if Player.Character.Humanoid.Health + HealValue < Player.Character.Humanoid.MaxHealth then
			Player.Character.Humanoid:TakeDamage(-HealValue)
		else
			Player.Character.Humanoid.Health = Player.Character.Humanoid.MaxHealth
		end
		Evt.MedSys.MedHandler:FireClient(Player,5)
		return;

	elseif Mode == 6 and P1_Client.Kit.Morphine.Value > 0 and P1_Client.Variaveis.Dor.Value > 0 then
		P1_Client.Kit.Morphine.Value = P1_Client.Kit.Morphine.Value - 1
		P1_Client.Variaveis.Dor.Value = math.clamp(P1_Client.Variaveis.Dor.Value - math.random(125,175),0,300)
		Evt.MedSys.MedHandler:FireClient(Player,6)
		return;

	elseif Mode == 7 and P1_Client.Kit.Epinephrine.Value > 0 and Player.Character.Humanoid.Health < Player.Character.Humanoid.MaxHealth then
		P1_Client.Kit.Epinephrine.Value = P1_Client.Kit.Epinephrine.Value - 1
		local HealValue = math.random(45,55)
		if Player.Character.Humanoid.Health + HealValue < Player.Character.Humanoid.MaxHealth then
			Player.Character.Humanoid:TakeDamage(-HealValue)
		else
			Player.Character.Humanoid.Health = Player.Character.Humanoid.MaxHealth
		end
		Evt.MedSys.MedHandler:FireClient(Player,7)
		return;

	elseif Mode == 8 and P1_Client.Kit.BloodBag.Value > 0 and P1_Client.Variaveis.Sangue.Value < P1_Client.Variaveis.Sangue.MaxValue then
		P1_Client.Kit.BloodBag.Value = P1_Client.Kit.BloodBag.Value - 1
		P1_Client.Variaveis.Sangue.Value = P1_Client.Variaveis.Sangue.Value + 2000
		return;
	else
		warn(Player.Name.."'s Action Failed: Unknow Method")
	end
	return;
end)

Evt.Drag.OnServerEvent:Connect(function(player,Victim)
	if not player or not player.Character then return; end;

	local P1_Client = player.Character:FindFirstChild("ACS_Client")
	local Human 	= player.Character:FindFirstChild("Humanoid")

	if not P1_Client then return; end;

	if Victim then
		P1_Client:SetAttribute("DragPlayer",Victim.Name)
	else
		P1_Client:SetAttribute("DragPlayer","")
		P1_Client:SetAttribute("Dragging",false)
	end

	local target = P1_Client:GetAttribute("DragPlayer")

	if P1_Client:GetAttribute("Collapsed") or target == "" then return; end;

	local player2 = game.Players:FindFirstChild(target)
	if not player2 or not player2.Character then return; end;

	local PlHuman = player2.Character:FindFirstChild("Humanoid")
	local P2_Client = player2.Character:FindFirstChild("ACS_Client")
	if not PlHuman or not P2_Client then return; end;

	if P1_Client:GetAttribute("Dragging") then return; end;
	if not P2_Client:GetAttribute("Collapsed") then return; end;
	P1_Client:SetAttribute("Dragging",true)	
	while P1_Client:GetAttribute("Dragging") and target ~= "" and P2_Client:GetAttribute("Collapsed") and PlHuman.Health > 0 and Human.Health > 0 and not P1_Client:GetAttribute("Collapsed") do Run.Heartbeat:Wait() 
		player2.Character.Torso.Anchored = true
		player2.Character.Torso.CFrame = Human.Parent.Torso.CFrame*CFrame.new(0,0.75,1.5)*CFrame.Angles(math.rad(0), math.rad(0), math.rad(90))
	end
	player2.Character.Torso.Anchored = false		
end)

function BreachFunction(Player,Mode,BreachPlace,Pos,Norm,Hit)

	if Mode == 1 then
		if Player.Character.ACS_Client.Kit.BreachCharges.Value > 0 then
			Player.Character.ACS_Client.Kit.BreachCharges.Value = Player.Character.ACS_Client.Kit.BreachCharges.Value - 1
			BreachPlace.Destroyed.Value = true
			local C4 = Engine.FX.BreachCharge:Clone()

			C4.Parent = BreachPlace.Destroyable
			C4.Center.CFrame = CFrame.new(Pos, Pos + Norm) * CFrame.Angles(math.rad(-90),math.rad(0),math.rad(0))
			C4.Center.Place:play()

			local weld = Instance.new("WeldConstraint")
			weld.Parent = C4
			weld.Part0 = BreachPlace.Destroyable.Charge
			weld.Part1 = C4.Center

			task.wait(1)
			C4.Center.Beep:play()
			task.wait(4)
			if C4 and C4:FindFirstChild("Center") then
				local att = Instance.new("Attachment")
				att.CFrame = C4.Center.CFrame
				att.Parent = workspace.Terrain

				local aw = Engine.FX.ExpEffect:Clone()
				aw.Parent = att
				aw.Enabled = false
				aw:Emit(35)
				Debris:AddItem(aw,aw.Lifetime.Max)

				local Exp = Instance.new("Explosion")
				Exp.BlastPressure = 0
				Exp.BlastRadius = 0
				Exp.DestroyJointRadiusPercent = 0
				Exp.Position = C4.Center.Position
				Exp.Parent = workspace

				local S = Instance.new("Sound")
				S.EmitterSize = 10
				S.MaxDistance = 1000
				S.SoundId = "rbxassetid://"..Explosion[math.random(1, 7)]
				S.PlaybackSpeed = math.random(30,55)/40
				S.Volume = 2
				S.Parent = att
				S.PlayOnRemove = true
				S:Destroy()

				for SKP_001, SKP_002 in pairs(game.Players:GetChildren()) do
					if SKP_002:IsA('Player') and SKP_002.Character and SKP_002.Character:FindFirstChild('Head') and (SKP_002.Character.Head.Position - C4.Center.Position).magnitude <= 15 then
						local DistanceMultiplier = (((SKP_002.Character.Head.Position - C4.Center.Position).magnitude/35) - 1) * -1
						local intensidade = DistanceMultiplier
						local Tempo = 15 * DistanceMultiplier
						Evt.Suppression:FireClient(SKP_002,2,intensidade,Tempo)
					end
				end

				Debris:AddItem(BreachPlace.Destroyable,0)
			end
		end

	elseif Mode == 2 then

		local aw = Engine.FX.DoorBreachFX:Clone()
		aw.Parent = BreachPlace.Door.Door
		aw.RollOffMaxDistance = 100
		aw.RollOffMinDistance = 5
		aw:Play()

		BreachPlace.Destroyed.Value = true
		if BreachPlace.Door:FindFirstChild("Hinge") ~= nil then
			BreachPlace.Door.Hinge:Destroy()
		end
		if BreachPlace.Door:FindFirstChild("Knob") ~= nil then
			BreachPlace.Door.Knob:Destroy()
		end

		local forca = Instance.new("BodyForce")
		forca.Force = -Norm * BreachPlace.Door.Door:GetMass() * Vector3.new(50,0,50)
		forca.Parent = BreachPlace.Door.Door

		Debris:AddItem(BreachPlace,3)

	elseif Mode == 3 then
		if Player.Character.ACS_Client.Kit.Fortifications.Value > 0 then
			Player.Character.ACS_Client.Kit.Fortifications.Value = Player.Character.ACS_Client.Kit.Fortifications.Value - 1
			BreachPlace.Fortified.Value = true
			local C4 = Instance.new('Part')

			C4.Parent = BreachPlace.Destroyable
			C4.Size =  Vector3.new(Hit.Size.X + .05,Hit.Size.Y + .05,Hit.Size.Z + 0.5) 
			C4.Material = Enum.Material.DiamondPlate
			C4.Anchored = true
			C4.CFrame = Hit.CFrame

			local S = Engine.FX.FortFX:Clone()
			S.PlaybackSpeed = math.random(30,55)/40
			S.Volume = 1
			S.Parent = C4
			S.PlayOnRemove = true
			S:Destroy()
		end
	end
end

Evt.Breach.OnServerInvoke = BreachFunction

function UpdateLog(Player,humanoid)

	local tag = humanoid:findFirstChild("creator")

	if tag ~= nil then

		local hours = os.date("*t")["hour"]
		local mins = os.date("*t")["min"]
		local sec = os.date("*t")["sec"]
		local TagType = tag:findFirstChild("type")

		if tag.Value.Name == Player.Name then
			local String = Player.Name.." Died | "..hours..":"..mins..":"..sec
			table.insert(CombatLog,String)
		else
			local String = tag.Value.Name.." Killed "..Player.Name.." | "..hours..":"..mins..":"..sec
			table.insert(CombatLog,String)
		end

		if #CombatLog > 50 then
			Backup = Backup + 1
			warn("ACS: Cleaning Combat Log | Backup: "..Backup)
			warn(CombatLog)
			CombatLog = {}
		end
	end
end


plr.PlayerAdded:Connect(function(player)

	for i,v in ipairs(TempBannedPlayers) do
		if v == player.Name then
			player:Kick('Blacklisted')
			warn(player.Name.." (Temporary Banned) tried to join to server")
			break
		end
	end

	for i,v in ipairs(gameRules.Blacklist) do
		if v == player.UserId then
			player:Kick('Blacklisted')
			warn(player.Name.." (Blacklisted) tried to join to server")
			break
		end
	end

	if gameRules.AgeRestrictEnabled and not Run:IsStudio() then
		if player.AccountAge < gameRules.AgeLimit then
			player:Kick('Age restricted server! Please wait: '..(gameRules.AgeLimit - player.AccountAge)..' Days')
		end
	end

	if game.CreatorType == Enum.CreatorType.User then
		if player.UserId == game.CreatorId or Run:IsStudio() then
			player.Chatted:Connect(function(Message)
				if string.lower(Message) == "/acslog" then
					Evt.CombatLog:FireClient(player,CombatLog)
				end
			end)
		end
	elseif game.CreatorType == Enum.CreatorType.Group then
		if player:IsInGroup(game.CreatorId) or Run:IsStudio() then
			player.Chatted:Connect(function(Message)
				if string.lower(Message) == "/acslog" then
					Evt.CombatLog:FireClient(player,CombatLog)
				end
			end)
		end
	end


	player.CharacterAdded:Connect(function(char)

		if gameRules.TeamTags then
			local L_17_ = HUDs:WaitForChild('TeamTagUI'):clone()
			L_17_.Parent = char
			L_17_.Adornee = char.Head
		end

		char.Humanoid.BreakJointsOnDeath = false
		char.Humanoid.Died:Connect(function()
			UpdateLog(player,char.Humanoid)
			pcall(function()
				Ragdoll(char)
			end)
		end)
	end)
end)

print(gameRules.Version)