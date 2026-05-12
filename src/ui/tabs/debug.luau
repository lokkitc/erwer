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
	dumpPanel.Visible = false
	dumpPanel.Parent = scroll
	Instance.new("UICorner", dumpPanel).CornerRadius = UDim.new(0, 10)

	local dumpBox = Instance.new("TextBox")
	dumpBox.Size = UDim2.new(1, -12, 1, -12)
	dumpBox.Position = UDim2.new(0, 6, 0, 6)
	dumpBox.BackgroundTransparency = 1
	dumpBox.TextXAlignment = Enum.TextXAlignment.Left
	dumpBox.TextYAlignment = Enum.TextYAlignment.Top
	dumpBox.ClearTextOnFocus = false
	dumpBox.MultiLine = true
	dumpBox.TextEditable = false
	dumpBox.Font = Enum.Font.Code
	dumpBox.TextSize = 14
	dumpBox.TextColor3 = T().Text
	themeService:Bind(dumpBox, "TextColor3", "Text")
	dumpBox.Text = ""
	dumpBox.Parent = dumpPanel

	local targets = { "Workspace", "ReplicatedStorage" }
	local selectedTarget = targets[1]

	local targetDropdown = elements.Dropdown("Источник", targets, selectedTarget, function(v)
		selectedTarget = v
	end)
	targetDropdown.Parent = scroll

	local function buildDumpText()
		local parts = {}
		parts[#parts + 1] = "-- Config"
		parts[#parts + 1] = serializeValue(Config, 0)
		parts[#parts + 1] = ""
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

	local dumpBtn = elements.Button("Dump", function()
		dumpPanel.Visible = not dumpPanel.Visible
		if dumpPanel.Visible then
			local text = buildDumpText()
			dumpBox.Text = text
		end
	end)
	dumpBtn.Parent = scroll

	local copyBtn = elements.Button("Скопировать", function()
		local text = dumpBox.Text
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
