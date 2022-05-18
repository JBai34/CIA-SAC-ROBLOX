local HVTAssets = game:GetService("ServerStorage").Assets.HVT_Assets

local function Weld(elementToWeld:BasePart|Model,weldToPart:BasePart)
	local weld = Instance.new("Weld")
	
	if elementToWeld:IsA("BasePart") then
		weld.Parent = elementToWeld
		weld.Part0 = elementToWeld
		weld.Part1 = weldToPart
		weld.C0 = elementToWeld.CFrame:Inverse()*elementToWeld.CFrame 
		weld.C1 = weldToPart.CFrame:Inverse()*weldToPart.CFrame 
		elementToWeld.Anchored = false
		
	elseif elementToWeld:IsA("Model") then
		for _,element in pairs(elementToWeld:GetDescendants()) do
			if element:IsA("BasePart") then
				weld.Parent = element
				weld.Part0 = element
				weld.Part1 = weldToPart
				weld.C0 = element.CFrame:Inverse()*element.CFrame 
				weld.C1 = weldToPart.CFrame:Inverse()*weldToPart.CFrame 
				element.Anchored = false
			end
		end
	end
	
end

local function Free_Player(playerToFree:Player,action:string)
	if not playerToFree:GetAttribute("SpecialState") then return end
	local character = playerToFree.Character
	
	if action == "Unblind" then
		character:FindFirstChild("Blindfold"):Destroy()
		playerToFree.PlayerGui:FindFirstChild("HVTGUI"):Destroy()

	elseif action == "Release" then
		playerToFree:SetAttribute("SpecialState",nil)
		if character:FindFirstChild("Blindfold") then
			character:FindFirstChild("Blindfold"):Destroy()
		end
		
		character:FindFirstChild("HVT_Proximity"):Destroy()
		character.Torso["Left Shoulder"].C1 = CFrame.new(0.5, 0.5, 0, -4.37113883e-08, 0, -1, 0, 0.99999994, 0, 1, 0, -4.37113883e-08)
		character.Torso["Right Shoulder"].C1 = CFrame.new(-0.5, 0.5, 0, -4.37113883e-08, 0, 1, 0, 0.99999994, 0, -1, 0, -4.37113883e-08)

		if playerToFree.PlayerGui:FindFirstChild("HVTGUI") then
			playerToFree.PlayerGui:FindFirstChild("HVTGUI"):Destroy()
		end

		character.Humanoid:UnequipTools()
		for _,tool in pairs(playerToFree.Backpack:WaitForChild("Bin"):GetChildren()) do
			if tool:IsA("Tool") then
				tool.Parent = playerToFree.Backpack
			end
		end
	end
	
end

local function Choose_Blindfold()
	local newBlindfold
	local rng = Random.new()
	for _,model in pairs(HVTAssets:GetChildren()) do
		if model:IsA("Model") then
			newBlindfold = (rng:NextNumber() < 1/2 and model:Clone()) or nil
			if newBlindfold then 
				return newBlindfold
			else
				continue
			end
		end
	end
	return nil
end

local function Kidnap_Player(playerToKidnap:Player)
	if playerToKidnap:GetAttribute("SpecialState") == "Kidnapped" then return end
	playerToKidnap:SetAttribute("SpecialState","Kidnapped")
	local character = playerToKidnap.Character

	--// Clone the visual components and the proximity prompt
	local newBlindfold = Choose_Blindfold()
	
	if newBlindfold == nil then
		while newBlindfold == nil do
			newBlindfold = Choose_Blindfold()
			task.wait()
		end
	end
	
	newBlindfold.Name = "Blindfold"
	newBlindfold.Parent = character
	Weld(newBlindfold.Middle,character.Head)
	newBlindfold:PivotTo(character.Head:GetPivot())
	
	local newProximity = HVTAssets.HVT_Proximity:Clone()
	newProximity.Parent = character
	newProximity.Transparency = 1
	Weld(newProximity,character.Torso)
	newProximity:PivotTo(character.Torso:GetPivot() + Vector3.new(0,-0.5,0))
	
	character.Torso["Left Shoulder"].C1 = CFrame.new(0.5, 0.5, 0, 0.766044438, 				0, -0.642787695, 0.413175941, 0.766044378, 0.492403835, 0.492403924, -0.642787516, 0.586824059)
	character.Torso["Right Shoulder"].C1 = CFrame.new(-0.5, 0.5, 0, 0.804728329, -0.219846249, 0.551434278, -0.33158803, 0.604022622, 0.724710822, -0.492403805, -0.766044438, 0.413175792)
	
	--// Clone the GUI
	local newGui = HVTAssets.HVTAssets:Clone()
	newGui.Parent = playerToKidnap.PlayerGui
	newGui.Enabled = true
	
	--// Remove HVT weapons
	character.Humanoid:UnequipTools()
	for _,tool in pairs(playerToKidnap.Backpack:GetChildren()) do
		if tool:IsA("Tool") then
			tool.Parent = playerToKidnap.Backpack:WaitForChild("Bin")
		end
	end
end

game:GetService("ReplicatedStorage").KidnapBindableEvent.Event:Connect(Kidnap_Player)
game:GetService("ReplicatedStorage").KidnapReleaseBindableEvent.Event:Connect(Free_Player)