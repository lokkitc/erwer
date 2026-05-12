local function DebugTab(deps)
	local scroll = deps.Scroll
	local elements = deps.Elements
	local themeService = deps.ThemeService
	local Config = deps.Config
	local Services = deps.Services
	local L = Config.Layout

	local function T()
		return themeService:GetTheme()
	end

	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, 0, 0, 22)
	header.BackgroundTransparency = 1
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Text = "Дебаг (только AsuuBkzt)"
	header.TextColor3 = T().TextSecondary
	themeService:Bind(header, "TextColor3", "TextSecondary")
	header.Font = L.FontTab
	header.TextSize = 14
	header.Parent = scroll

	local function serializeValue(v, indent)
		indent = indent or 0
		local t = typeof(v)
		if t == "string" then
			return string.format("%q", v)
		end
		if t == "number" or t == "boolean" then
			return tostring(v)
		end
		if t == "Color3" then
			return string.format("Color3.fromRGB(%d, %d, %d)", math.floor(v.R * 255 + 0.5), math.floor(v.G * 255 + 0.5), math.floor(v.B * 255 + 0.5))
		end
		if t == "UDim2" then
			return string.format("UDim2.new(%.3f, %d, %.3f, %d)", v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset)
		end
		if t == "UDim" then
			return string.format("UDim.new(%.3f, %d)", v.Scale, v.Offset)
		end
		if t == "EnumItem" then
			return tostring(v)
		end
		if t == "table" then
			local parts = {}
			parts[#parts + 1] = "{"
			for k, vv in pairs(v) do
				local keyStr = (typeof(k) == "string") and k or ("[" .. tostring(k) .. "]")
				parts[#parts + 1] = string.rep("\t", indent + 1) .. tostring(keyStr) .. " = " .. serializeValue(vv, indent + 1) .. ","
			end
			parts[#parts + 1] = string.rep("\t", indent) .. "}"
			return table.concat(parts, "\n")
		end
		return "<" .. t .. ">"
	end

	local function dumpInstanceTree(root, maxDepth, maxNodes)
		maxDepth = maxDepth or 6
		maxNodes = maxNodes or 2500

		local out = {}
		local count = 0

		local function rec(inst, depth, path)
			if count >= maxNodes then
				return
			end
			count += 1
			out[#out + 1] = string.rep("  ", depth) .. "[" .. inst.ClassName .. "] " .. path
			if depth >= maxDepth then
				return
			end
			local children = inst:GetChildren()
			table.sort(children, function(a, b)
				return a.Name < b.Name
			end)
			for _, ch in ipairs(children) do
				rec(ch, depth + 1, path .. "/" .. ch.Name)
				if count >= maxNodes then
					return
				end
			end
		end

		rec(root, 0, root.Name)
		if count >= maxNodes then
			out[#out + 1] = "... (truncated: maxNodes reached)"
		end
		return table.concat(out, "\n")
	end

	local function safeGet(path)
		local cur = game
		for _, seg in ipairs(path) do
			if cur == nil then
				return nil
			end
			cur = cur:FindFirstChild(seg)
		end
		return cur
	end

	local function scanCanPlant()
		local out = {}
		out[#out + 1] = "-- Scan: Can_Plant"
		local farm = safeGet({ "Workspace", "Farm", "Farm", "Important", "Plant_Locations" })
		if not farm then
			out[#out + 1] = "[WARN] Workspace/Farm/Farm/Important/Plant_Locations not found"
			return table.concat(out, "\n")
		end

		local foundAny = false
		for _, obj in ipairs(farm:GetChildren()) do
			if obj.Name == "Can_Plant" and obj:IsA("BasePart") then
				foundAny = true
				out[#out + 1] = obj:GetFullName() .. " [" .. obj.ClassName .. "]"
				for _, d in ipairs(obj:GetDescendants()) do
					if d:IsA("ProximityPrompt") or d:IsA("ClickDetector") then
						out[#out + 1] = "  " .. d.ClassName .. ": " .. d:GetFullName()
					end
				end
			end
		end
		if not foundAny then
			out[#out + 1] = "[WARN] No BasePart named 'Can_Plant' under Plant_Locations"
		end
		return table.concat(out, "\n")
	end

	local function scanReplicatedRemotes(maxItems)
		maxItems = maxItems or 250
		local out = {}
		out[#out + 1] = "-- Scan: ReplicatedStorage Remotes"
		local ok, rs = pcall(function()
			return game:GetService("ReplicatedStorage")
		end)
		if not ok or not rs then
			out[#out + 1] = "[ERROR] ReplicatedStorage unavailable"
			return table.concat(out, "\n")
		end

		local count = 0
		for _, d in ipairs(rs:GetDescendants()) do
			if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
				count += 1
				out[#out + 1] = "[" .. d.ClassName .. "] " .. d:GetFullName()
				if count >= maxItems then
					out[#out + 1] = "... (truncated: max remotes reached)"
					break
				end
			end
		end
		if count == 0 then
			out[#out + 1] = "[INFO] No RemoteEvent/RemoteFunction found (may be truncated by game structure)"
		end
		return table.concat(out, "\n")
	end

	local function truncateText(text, maxChars)
		maxChars = maxChars or 180000
		if type(text) ~= "string" then
			return ""
		end
		if #text <= maxChars then
			return text
		end
		return text:sub(1, maxChars) .. "\n... (truncated: maxChars reached)"
	end

	local dumpPanel = Instance.new("Frame")
	dumpPanel.Name = "DumpPanel"
	dumpPanel.Size = UDim2.new(1, 0, 0, 260)
	dumpPanel.BackgroundColor3 = T().Glass
	themeService:Bind(dumpPanel, "BackgroundColor3", "Glass")
	dumpPanel.BackgroundTransparency = 0.08
	dumpPanel.BorderSizePixel = 0
	dumpPanel.ClipsDescendants = true
	dumpPanel.Visible = false
	dumpPanel.Parent = scroll
	Instance.new("UICorner", dumpPanel).CornerRadius = UDim.new(0, 10)

	local dumpScroll = Instance.new("ScrollingFrame")
	dumpScroll.Name = "DumpScroll"
	dumpScroll.Size = UDim2.new(1, -12, 1, -12)
	dumpScroll.Position = UDim2.new(0, 6, 0, 6)
	dumpScroll.BackgroundTransparency = 1
	dumpScroll.BorderSizePixel = 0
	dumpScroll.CanvasSize = UDim2.fromOffset(0, 0)
	dumpScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	dumpScroll.ScrollBarThickness = 4
	dumpScroll.ScrollBarImageColor3 = T().Accent
	themeService:Bind(dumpScroll, "ScrollBarImageColor3", "Accent")
	dumpScroll.Parent = dumpPanel

	local dumpText = Instance.new("TextLabel")
	dumpText.Name = "DumpText"
	dumpText.Size = UDim2.new(1, -8, 0, 0)
	dumpText.Position = UDim2.new(0, 4, 0, 4)
	dumpText.BackgroundTransparency = 1
	dumpText.TextXAlignment = Enum.TextXAlignment.Left
	dumpText.TextYAlignment = Enum.TextYAlignment.Top
	dumpText.TextWrapped = false
	dumpText.RichText = false
	dumpText.Font = Enum.Font.Code
	dumpText.TextSize = 14
	dumpText.TextColor3 = T().Text
	themeService:Bind(dumpText, "TextColor3", "Text")
	dumpText.AutomaticSize = Enum.AutomaticSize.Y
	dumpText.Text = ""
	dumpText.Parent = dumpScroll

	local pad = Instance.new("UIPadding")
	pad.PaddingBottom = UDim.new(0, 6)
	pad.Parent = dumpScroll

	local currentDumpText = ""

	local dumpTypes = { "InstanceTree", "Scans" }
	local selectedDumpType = dumpTypes[1]

	local dumpTypeDropdown = elements.Dropdown("Тип дампа", dumpTypes, selectedDumpType, function(v)
		selectedDumpType = v
	end)
	dumpTypeDropdown.Parent = scroll

	local targets = { "Workspace", "ReplicatedStorage" }
	local selectedTarget = targets[1]

	local targetDropdown = elements.Dropdown("Источник", targets, selectedTarget, function(v)
		selectedTarget = v
	end)
	targetDropdown.Parent = scroll

	local function buildInstanceTreeDump()
		local parts = {}
		parts[#parts + 1] = "-- Instance Tree: " .. selectedTarget
		local okDump, treeOrErr = pcall(function()
			local root
			if selectedTarget == "ReplicatedStorage" then
				root = game:GetService("ReplicatedStorage")
			else
				root = workspace
			end

			local maxDepth = 6
			local maxNodes = 2500
			if selectedTarget == "ReplicatedStorage" then
				maxNodes = 1800
			end
			return dumpInstanceTree(root, maxDepth, maxNodes)
		end)

		if okDump then
			parts[#parts + 1] = treeOrErr
		else
			parts[#parts + 1] = "[ERROR] dump failed: " .. tostring(treeOrErr)
		end

		local text = table.concat(parts, "\n")
		return truncateText(text, 180000)
	end

	local function buildScansDump()
		local parts = {}
		parts[#parts + 1] = scanCanPlant()
		parts[#parts + 1] = ""
		parts[#parts + 1] = scanReplicatedRemotes(300)
		local text = table.concat(parts, "\n")
		return truncateText(text, 180000)
	end

	local function buildDumpText()
		if selectedDumpType == "Scans" then
			return buildScansDump()
		end
		return buildInstanceTreeDump()
	end

	local dumpBtn = elements.Button("Dump", function()
		dumpPanel.Visible = not dumpPanel.Visible
		if dumpPanel.Visible then
			currentDumpText = buildDumpText()
			dumpText.Text = currentDumpText
		end
	end)
	dumpBtn.Parent = scroll

	local copyBtn = elements.Button("Скопировать", function()
		local text = currentDumpText
		if type(text) ~= "string" or text == "" then
			warn("[Debug] Nothing to copy")
			return
		end
		local ok = false
		pcall(function()
			local sc = rawget(_G, "setclipboard")
			if type(sc) == "function" then
				sc(text)
				ok = true
			end
		end)
		if not ok then
			warn("[Debug] setclipboard not available in this environment")
		end
	end)
	copyBtn.Parent = scroll

	return {
		Scroll = scroll,
	}
end

return DebugTab
