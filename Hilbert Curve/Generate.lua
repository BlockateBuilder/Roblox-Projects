--\\ Hilbert Curve Implementation in LuaU


-- Function to generate the Hilbert curve points recursively
local function Hilbert(x, y, xi, xj, yi, yj, n, points)
	if n <= 0 then
		table.insert(points, {x + (xi + yi) // 2, y + (xj + yj) // 2})
	else
		Hilbert(x, y, yi // 2, yj // 2, xi // 2, xj // 2, n - 1, points)
		Hilbert(x + xi // 2, y + xj // 2, xi // 2, xj // 2, yi // 2, yj // 2, n - 1, points)
		Hilbert(x + xi // 2 + yi // 2, y + xj // 2 + yj // 2, xi // 2, xj // 2, yi // 2, yj // 2, n - 1, points)
		Hilbert(x + xi // 2 + yi, y + xj // 2 + yj, -yi // 2, -yj // 2, -xi // 2, -xj // 2, n - 1, points)
	end
end

-- Main function to generate the Hilbert curve points
local function Create(order, size)
	local points = {}
	Hilbert(0, 0, size, 0, 0, size, order, points)
	return points
end

local order = 5
local size = 550
local points = Create(order,size)

local scaledPoints = {}
for i,_ in points do
	scaledPoints[i] = Vector2.new(points[i][1]/workspace.CurrentCamera.ViewportSize.X,points[i][2]/workspace.CurrentCamera.ViewportSize.Y)
end

local function PlacePoints(t)
	for i,v in t do
		local f = Instance.new("Frame")
		f.AnchorPoint = Vector2.new(.5,.5)
		f.Position = UDim2.fromScale(points[i][1]/workspace.CurrentCamera.ViewportSize.X,points[i][2]/workspace.CurrentCamera.ViewportSize.Y)
		f.Size = UDim2.fromScale(math.sqrt(128)/workspace.CurrentCamera.ViewportSize.X,math.sqrt(128)/workspace.CurrentCamera.ViewportSize.Y)
		f.Name = i
		f.BackgroundTransparency = 0.7
		f.Parent = script.Parent.Container
	end
end

local function DrawLine(PointA, PointB, Parent)
	local Distance = math.sqrt(math.pow(math.max(PointA.X-PointB.X,-(PointA.X-PointB.X)), 2) + math.pow(math.max(PointA.Y-PointB.Y,-(PointA.Y-PointB.Y)), 2))
	local Center = Vector2.new((PointA.X + PointB.X)/2, (PointA.Y + PointB.Y)/2)	
	local Rotation = math.atan2(math.max(PointA.Y-PointB.Y,-(PointA.Y-PointB.Y)), math.max(PointA.X-PointB.X,-(PointA.X-PointB.X)))
	local LineThickness = 2

	local Line = Instance.new("Frame")
	Line.Size = UDim2.new(0, Distance, 0, LineThickness)
	Line.AnchorPoint = Vector2.new(0.5,0.5)
	Line.Position = UDim2.new(0, Center.X, 0, Center.Y)
	Line.Rotation = math.deg(Rotation)
	Line.Parent = Parent
end

local function ConnectPoints(t)
	for i,v in t do
		if t[i+1] then
			DrawLine(script.Parent.Container[tostring(i)].AbsolutePosition,script.Parent.Container[tostring(i+1)].AbsolutePosition,script.Parent.Connectors)
		end
	end
end

PlacePoints(scaledPoints)
ConnectPoints(scaledPoints)
