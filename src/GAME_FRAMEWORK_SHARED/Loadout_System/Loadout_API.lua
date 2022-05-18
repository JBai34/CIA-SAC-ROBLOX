local Loadout_API = {}

local Loadout_Workspace = workspace.GAME_WORKSPACE.Loadout_Workspace
local Database = game:GetService("ReplicatedStorage").GAME_FRAMEWORK_SHARED.Loadout_System.Database
local Parts = {

	["Color"] = "B";

	["Headwear"] = {
		Base_System = "";
		Node = {
			Cover = "";
			Earwear = "";
			Eyewear = "";
			Left_Rail = "";
			NV_Module = "";
			Right_Rail = "";
		}
	};

	["Vest"] = {
		Base_System = "";
		Node = {
			Backpack = "";
			Front_Center = "";
			Front_Left = "";
			Front_Right = "";
			Front_Upper = "";
			Left = "";
			Right = "";
		}
	};


}

local function Update_Color(model:Model,color:string)
	for _,part in pairs(model:GetChildren()) do
		if part:IsA('MeshPart') and part.Parent:GetAttribute("Color_Dependent") == false then
			if part:FindFirstChildOfClass('SurfaceAppearance') then
				part:FindFirstChildOfClass('SurfaceAppearance'):Destroy()
			end
			if part:FindFirstChildOfClass('Folder') and part.Parent:GetAttribute("Color_Dependent") == false then
				if part:FindFirstChildOfClass('Folder'):FindFirstChild(color) then
					part.Colors[color]:Clone().Parent = part
				end
			end
		end
	end
end

function Loadout_API:Update_Compatibility(args1, nodeList, partList)
	--[[
		THIS IS MEANT TO BE RAN WHEN BASE SYSTEM IS UPDATED AND NOT MEANT TO OUTPUT WARNING MESSAGES.
		
		We do not have to specify which table it is within the lists (as above arrays) as the array itself matches the table we want to
		send the data to, for example, we would already know if it is nodeList[Vest] or nodeList[Headwear] so on so forth.
		
		First, check for node incompatibility
		Second,check for individual part incompatiblity
	]]
	table.clear(nodeList)
	table.clear(partList)
	if not Loadout_Workspace.Loadout_Cage.Armor_Preview:FindFirstChild(args1):FindFirstChildOfClass("Model") then 
		return 
	end

	local model = Loadout_Workspace.Loadout_Cage.Armor_Preview:FindFirstChild(args1):FindFirstChildOfClass("Model")
	
	for _,v in pairs(model:FindFirstChild("UnavailableNode"):GetChildren()) do
		if v:IsA('StringValue') and v.Value then
			table.insert(nodeList,v.Value)
		end
	end
	
	for _,v in pairs(model:FindFirstChild("UnavailablePart"):GetChildren()) do
		if v:IsA('StringValue') and v.Value then
			table.insert(partList,v.Value)
		end
	end
	
end

function Loadout_API:Update_All_Color(color:string)
	local Condition
	local Result = true
	
	if color == "M" then Condition = "Color_Multicam" elseif color == "G" then Condition = "Color_Green" else Condition = "Color_Black" end
	
	for _,model in pairs(Loadout_Workspace.Loadout_Cage.Armor_Preview:GetDescendants()) do
		if model:IsA('Model') and model:GetAttribute('Color_Dependent') == false then
			if model:GetAttribute(Condition) == true then
				continue
			else
				Result = false
				break
			end
		end
	end
	
	if Result == true then
		for _,model in pairs(Loadout_Workspace.Loadout_Cage.Armor_Preview:GetDescendants()) do
			if model:IsA('Model') and model:GetAttribute('Color_Dependent') == false then
				if model:GetAttribute(Condition) == true then
					for _,part in pairs(model:GetChildren()) do
						if part:IsA('MeshPart') then
							if part:FindFirstChildOfClass('SurfaceAppearance') and part.Parent:GetAttribute("Color_Dependent") == false then
								part:FindFirstChildOfClass('SurfaceAppearance'):Destroy()
							end
							if part:FindFirstChild('Colors') then
								part.Colors[color]:Clone().Parent = part
							end
						end
					end
				end
			end
		end
		Parts["Color"] = color
	else
		print('Color not available on one or more parts.')
	end
end

function Loadout_API:Clear_Nodes_Table(args1)
	for index, val in pairs(Parts[args1]["Node"]) do
		Parts[args1]["Node"][index] = ""
	end
end

function Loadout_API:Deploy()
	game.ReplicatedStorage.GAME_FRAMEWORK_REP.Loadout_Remotes.Confirm_Loadout_Event:FireServer(Parts)
end

function Loadout_API:Update_Preview(model,color:string)
	local Type:string = nil
	local args1:string = nil
	
	if color == "G" and model:GetAttribute("Color_Green") == false or
		color == "M" and model:GetAttribute("Color_Multicam") == false then
		return
	end
	
	-- REMOVE ITEM
	if model:IsA("Folder") and color == "Remove" then
		if model:FindFirstChildOfClass("Model"):GetAttribute('Is_Base_System') == true then
			Type = "Base_System"
		else
			Type = "Node"
		end
		
		if Type == "Base_System" then
			args1 = model.Parent.Name

			if args1 == "Vest" then
				if Loadout_Workspace.Loadout_Cage.Armor_Preview.Vest:FindFirstChildOfClass("Model") then
					Loadout_Workspace.Loadout_Cage.Armor_Preview.Vest:ClearAllChildren()
				end

			elseif args1 == "Headwear" then
				if Loadout_Workspace.Loadout_Cage.Armor_Preview.Headwear:FindFirstChildOfClass("Model") then
					Loadout_Workspace.Loadout_Cage.Armor_Preview.Headwear:ClearAllChildren()
				end
			end
			Parts[args1][Type] = ""
			Loadout_API:Clear_Nodes_Table(args1)

		elseif Type == "Node" then
			args1 = model.Parent.Parent.Name
			local NodeToReplace = model:GetAttribute('Node') or model.Name

			if args1 == "Vest" then
				if Loadout_Workspace.Loadout_Cage.Armor_Preview.Vest:FindFirstChildOfClass("Model") then
					Loadout_Workspace.Loadout_Cage.Armor_Preview.Vest:FindFirstChildOfClass("Model").Nodes:FindFirstChild(NodeToReplace):ClearAllChildren()
					
				end
				Parts[args1][Type][Loadout_Workspace.Loadout_Cage.Armor_Preview.Vest:FindFirstChildOfClass("Model").Nodes:FindFirstChild(NodeToReplace).Name] = ""

			elseif args1 == "Headwear" then
				if Loadout_Workspace.Loadout_Cage.Armor_Preview.Headwear:FindFirstChildOfClass("Model") then
					Loadout_Workspace.Loadout_Cage.Armor_Preview.Headwear:FindFirstChildOfClass("Model").Nodes:FindFirstChild(NodeToReplace):ClearAllChildren()
				end
				Parts[args1][Type][Loadout_Workspace.Loadout_Cage.Armor_Preview.Headwear:FindFirstChildOfClass("Model").Nodes:FindFirstChild(NodeToReplace).Name] = ""

			end
		end
		return args1
	end
	
	local New_Model = model:Clone()
	-- Determine if it is a base or part
	if model:GetAttribute('Is_Base_System') == true then
		Type = "Base_System"
	else
		Type = "Node"
	end
	
	-- Determine what category this model is under.  Vest? Helmet? Hat? or node Backpack? Front_Center?
	-- Update args1 for that.
	
	-- Find out where it goes
	if Type == "Base_System" then
		args1 = model.Parent.Parent.Name
		
		if args1 == "Vest" then
			if Loadout_Workspace.Loadout_Cage.Armor_Preview.Vest:FindFirstChildOfClass("Model") then
				Loadout_Workspace.Loadout_Cage.Armor_Preview.Vest:ClearAllChildren()
			end
			New_Model.Parent = Loadout_Workspace.Loadout_Cage.Armor_Preview.Vest
			New_Model:PivotTo(Loadout_Workspace.Loadout_Cage.Dummy.HumanoidRootPart:GetPivot())
			
			
		elseif args1 == "Headwear" then
			if Loadout_Workspace.Loadout_Cage.Armor_Preview.Headwear:FindFirstChildOfClass("Model") then
				Loadout_Workspace.Loadout_Cage.Armor_Preview.Headwear:ClearAllChildren()
			end
			New_Model.Parent = Loadout_Workspace.Loadout_Cage.Armor_Preview.Headwear
			New_Model:PivotTo(Loadout_Workspace.Loadout_Cage.Dummy.Head:GetPivot())
		end
		Parts[args1][Type] = New_Model.Name
		Loadout_API:Clear_Nodes_Table(args1)
		
	elseif Type == "Node" then
		args1 = model.Parent.Parent.Parent.Name
		local NodeToReplace = model:GetAttribute('Node') or model.Parent.Name
		
		if args1 == "Vest" then
			if Loadout_Workspace.Loadout_Cage.Armor_Preview.Vest:FindFirstChildOfClass("Model") then
				Loadout_Workspace.Loadout_Cage.Armor_Preview.Vest:FindFirstChildOfClass("Model").Nodes:FindFirstChild(NodeToReplace):ClearAllChildren()
				New_Model.Parent = Loadout_Workspace.Loadout_Cage.Armor_Preview.Vest:FindFirstChildOfClass("Model").Nodes:FindFirstChild(NodeToReplace)
				New_Model:PivotTo(Loadout_Workspace.Loadout_Cage.Armor_Preview.Vest:FindFirstChildOfClass("Model").Nodes:FindFirstChild(NodeToReplace):GetPivot())
			end
			Parts[args1][Type][Loadout_Workspace.Loadout_Cage.Armor_Preview.Vest:FindFirstChildOfClass("Model").Nodes:FindFirstChild(NodeToReplace).Name] = New_Model.Name
			
		elseif args1 == "Headwear" then
			if Loadout_Workspace.Loadout_Cage.Armor_Preview.Headwear:FindFirstChildOfClass("Model") then
				Loadout_Workspace.Loadout_Cage.Armor_Preview.Headwear:FindFirstChildOfClass("Model").Nodes:FindFirstChild(NodeToReplace):ClearAllChildren()
				New_Model.Parent = Loadout_Workspace.Loadout_Cage.Armor_Preview.Headwear:FindFirstChildOfClass("Model").Nodes:FindFirstChild(NodeToReplace)
				New_Model:PivotTo(Loadout_Workspace.Loadout_Cage.Armor_Preview.Headwear:FindFirstChildOfClass("Model").Nodes:FindFirstChild(NodeToReplace):GetPivot())
			end
			Parts[args1][Type][Loadout_Workspace.Loadout_Cage.Armor_Preview.Headwear:FindFirstChildOfClass("Model").Nodes:FindFirstChild(NodeToReplace).Name] = New_Model.Name
			
		end
		
	end
	Update_Color(New_Model,color)

	return args1
end

Loadout_API.Stream_Data = function(Data)
	if Data == nil then return end
	Parts = Data

	---NEED TO PUT MODEL ON DUMMY ON THE CLIENT SIDE---	
	local Character = Loadout_Workspace.Loadout_Cage.Dummy
	local Armor_Preview = Loadout_Workspace:WaitForChild("Loadout_Cage").Armor_Preview

	local HeadBase
	local VestBase

	for i,v in pairs(Data) do
		if i == "Headwear" then
			for _,targetPart in pairs(Database.Headwear.Base_System:GetChildren()) do
				--print(targetPart,v["Base_System"])
				if targetPart.Name == v["Base_System"] then
					local newPart = targetPart:Clone()
					newPart.Parent = Armor_Preview.Headwear
					newPart.PrimaryPart.Transparency = 1
					newPart:PivotTo(Character.Head:GetPivot())
					HeadBase = newPart
					break
				end	
			end
			if HeadBase then
				for index,val in pairs(v["Node"]) do
					local directory = Database[i]["Node"][index]
					if val ~= "" then
						local success, message = pcall(function()
							if HeadBase.Nodes:FindFirstChild(index) then
								local newPart = directory:FindFirstChild(val):Clone()
								newPart.Parent = HeadBase
								newPart.PrimaryPart.Transparency = 1
								task.wait()
								newPart:PivotTo(HeadBase.Nodes[index]:GetPivot())
							end
						end)
						if not success then
							val = ""
						end
					end
				end
			else
				Loadout_API:Clear_Nodes_Table("Headwear")
			end

		elseif i == 'Vest' then
			for _,targetPart in pairs(Database.Vest.Base_System:GetChildren()) do
				--print(targetPart,v["Base_System"])
				if targetPart.Name == v["Base_System"] then
					local newPart = targetPart:Clone()
					newPart.Parent = Armor_Preview.Vest
					newPart.PrimaryPart.Transparency = 1
					newPart:PivotTo(Character.HumanoidRootPart:GetPivot())
					VestBase = newPart
					break
				end				
			end
			if VestBase then
				for index,val in pairs(v["Node"]) do
					local directory = Database[i]["Node"][index]
					if val ~= "" then
						local success, message = pcall(function()
							if VestBase.Nodes:FindFirstChild(index) then
								local newPart = directory:FindFirstChild(val):Clone()
								newPart.Parent = VestBase
								newPart.PrimaryPart.Transparency = 1
								task.wait()
								newPart:PivotTo(VestBase.Nodes[index]:GetPivot())
							end
						end)
						if not success then
							val = ""
						end
					end
				end
			else
				Loadout_API:Clear_Nodes_Table("Vest")
			end
			

		end
	end

	Loadout_API:Update_All_Color(Data["Color"])

end


return Loadout_API
