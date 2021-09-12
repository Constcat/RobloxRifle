Tool = script.Parent
local arms = nil
local torso = nil
local fakearms = {}
local welds = {}

function Weld(x,y)
	local W = Instance.new("Weld")
	W.Part0 = x
	W.Part1 = y
	local CJ = CFrame.new(x.Position)
	local C0 = x.CFrame:inverse()*CJ
	local C1 = y.CFrame:inverse()*CJ
	W.C0 = C0
	W.C1 = C1
	W.Parent = x
end

function SimpleWeld(x,y)
	local W = Instance.new("Weld")
	W.Part0 = x
	W.Part1 = y
	W.Parent = x
end

function Get(A)
	if A:IsA("BasePart") then
		if Tool:FindFirstChild(A.name.."Rotation") then
			Weld(Tool[A.name.."Rotation"], A) 
			if A.Name == "Frizzen" then
				local C = A:GetChildren()
				for i=1, #C do
				Get(C[i])
				end
			end
		elseif string.find(A.name,"Rotation") then
			SimpleWeld(Tool[string.gsub(A.name, "Rotation", "Attachment")], A) 
		elseif A.Parent.Name == "Frizzen" then
			Weld(A.Parent, A)
		elseif A.Name == "RamRodEnd" then
			Weld(Tool["RamRodRotation"], A)
		else
			Weld(Tool.Handle, A)
		end
		A.Anchored = false
	else
		local C = A:GetChildren()
		for i=1, #C do
		Get(C[i])
		end
	end
end

function Finale()
	Get(Tool)
end
wait(0.1)
Finale()
script.Parent:WaitForChild("BoltAttachment"):WaitForChild("Weld").C1 = CFrame.new(0,0,0)*CFrame.fromEulerAnglesXYZ(0,0,math.rad(40))

function Equip()
	local Plr = game.Players:WaitForChild(Tool.Parent.Name)
	Chr = Plr.Character
	wait()
	arms = {Chr:FindFirstChild("Left Arm"), Chr:FindFirstChild("Right Arm")}
	torso = Chr:FindFirstChild("Torso")
	if script:IsDescendantOf(workspace) and torso and arms then
		if workspace:FindFirstChild(Chr.Name.."'s high quality arms") then
			workspace:FindFirstChild(Chr.Name.."'s high quality arms"):Destroy()
		end

		model = Instance.new("Model", workspace)
		model.Name = Chr.Name.."'s high quality arms"
		local humanoid = Instance.new("Humanoid", model)
		humanoid.Name = "ArmHumanoid"
		local Link = Instance.new("ObjectValue",model)
		Link.Name, Link.Value = "HumanoidLink", Chr.Humanoid
		local Shirt
		for _,Child in pairs(Chr:GetChildren()) do
			if Child:IsA("Shirt") then
				Shirt = Child
				break
			end
		end
		if Shirt then
			Shirt:Clone().Parent = model
			Shirt.Changed:connect(function()
				model.Shirt.ShirtTemplate = Chr.Shirt.ShirtTemplate
			end)
			Chr.ChildAdded:connect(function(newChild)
				if newChild:IsA("Shirt") then
					model.Shirt.ShirtTemplate = newChild.ShirtTemplate
				end
			end)
		end
		for n,v in ipairs(arms) do
			local P = v:Clone()
			P.Transparency = 0
			P.CanCollide = false
			P.Parent = model
			P.TopSurface, P.BottomSurface = "Smooth", "Smooth"
			local PW = Instance.new("Weld")
			PW.Name = "Mweld3"
			PW.Parent = v
			PW.Part0, PW.Part1, PW.C0, PW.C1 = v, P, v.CFrame:inverse(), P.CFrame:inverse()
			v.Transparency = 1
			fakearms[n] = P
		end
		Tool:WaitForChild("Animation").Disabled = false

		coroutine.resume(coroutine.create(function()
			while script:IsDescendantOf(Chr) and arms[1] and arms[2] do
				arms[1].Transparency = 1	arms[2].Transparency = 1
				fakearms[1].Transparency = 0 fakearms[2].Transparency = 0
				wait()
			end		
		end))

		if fakearms[2]:FindFirstChild("RightGrip") then fakearms[2].RightGrip:Destroy() end
	end
end

function Unequip()
	if model then model:Destroy() end
	if workspace:FindFirstChild(Chr.Name.."'s high quality arms") then workspace:FindFirstChild(Chr.Name.."'s high quality arms"):Destroy() end
	for n,v in ipairs(arms) do
		v.Transparency = 0
	end
end
Tool.Equipped:connect(Equip)
Tool.Unequipped:connect(Unequip)

function Fire()
	local MuzzleFlash = coroutine.create(function()
		Tool.Muzzle.MuzzleSmoke.Enabled = true
		Tool.Muzzle.Flash.Enabled = true
		Tool.Muzzle.Flame.Enabled = true
		wait(0.1)
		Tool.Muzzle.Flash.Enabled = false
		wait(0.15)
		Tool.Muzzle.Flame.Enabled = false			
		Tool.PanMuzzle.Smoke.Enabled = false
		wait(0.05)
		Tool.Muzzle.MuzzleSmoke.Enabled = false
	end)
	coroutine.resume(MuzzleFlash)
end
script:WaitForChild("Fire").OnServerEvent:connect(Fire)

if Tool:FindFirstChild("BayonetOn") then
	Tool.BayonetOn.Changed:connect(function()
		if Tool.BayonetOn.Value then
			Tool:FindFirstChild("BayonetBlade").Transparency = 0
		else
			Tool:FindFirstChild("BayonetBlade").Transparency = 1
		end
	end)
end
