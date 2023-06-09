local Squash = require(script.Parent)

local test = {}

test.Axes = function()
	local input = Axes.new(
		math.random() < 0.5 and Enum.Axis.X,
		math.random() < 0.5 and Enum.Axis.Y,
		math.random() < 0.5 and Enum.Axis.Z,
		math.random() < 0.5 and Enum.NormalId.Top,
		math.random() < 0.5 and Enum.NormalId.Bottom,
		math.random() < 0.5 and Enum.NormalId.Right,
		math.random() < 0.5 and Enum.NormalId.Left,
		math.random() < 0.5 and Enum.NormalId.Back,
		math.random() < 0.5 and Enum.NormalId.Front
	)
	local midput = Squash.Axes.ser(input)
	local output = Squash[typeof(input)].des(midput)

	warn 'Axes'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print(
		'X',
		input.X,
		'Y',
		input.Y,
		'Z',
		input.Z,
		'Top',
		input.Top,
		'Bottom',
		input.Bottom,
		'Right',
		input.Right,
		'Left',
		input.Left,
		'Back',
		input.Back,
		'Front',
		input.Front
	)
	print 'Output:'
	print(
		'X',
		output.X,
		'Y',
		output.Y,
		'Z',
		output.Z,
		'Top',
		output.Top,
		'Bottom',
		output.Bottom,
		'Right',
		output.Right,
		'Left',
		output.Left,
		'Back',
		output.Back,
		'Front',
		output.Front
	)
end

test.CatalogSearchParams = function(alphabet: Squash.Alphabet)
	local input = CatalogSearchParams.new()
	input.SearchKeyword = 'Mahogany! Bigger'
	input.MinPrice = 0
	input.MaxPrice = 100
	input.SortType = Enum.CatalogSortType.PriceLowToHigh
	input.SortAggregation = Enum.CatalogSortAggregation.PastWeek
	input.CategoryFilter = Enum.CatalogCategoryFilter.Premium
	input.SalesTypeFilter = Enum.SalesTypeFilter.Premium
	input.BundleTypes = {
		Enum.BundleType.Shoes,
		Enum.BundleType.DynamicHead,
		Enum.BundleType.DynamicHeadAvatar,
		Enum.BundleType.BodyParts,
	}
	input.AssetTypes = {
		Enum.AvatarAssetType.Gear,
		Enum.AvatarAssetType.Head,
	}
	input.IncludeOffSale = false
	input.CreatorName = 'SOLARSCUFFLE_BOT'

	local midput = Squash.CatalogSearchParams.ser(input, alphabet)
	local output = Squash[typeof(input)].des(midput, alphabet)

	warn 'CatalogSearchParams'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print(
		'SearchKeyword',
		input.SearchKeyword,
		'MinPrice',
		input.MinPrice,
		'MaxPrice',
		input.MaxPrice,
		'SortType',
		input.SortType,
		'SortAggregation',
		input.SortType,
		'SortAggregation',
		input.SortAggregation,
		'CategoryFilter',
		input.CategoryFilter,
		'SalesTypeFilter',
		input.SalesTypeFilter,
		'BundleTypes',
		input.BundleTypes,
		'AssetTypes',
		input.AssetTypes,
		'IncludeOffSale',
		input.IncludeOffSale,
		'CreatorName',
		input.CreatorName
	)
	print 'Output:'
	print(
		'SearchKeyword',
		output.SearchKeyword,
		'MinPrice',
		output.MinPrice,
		'MaxPrice',
		output.MaxPrice,
		'SortType',
		output.SortType,
		'SortAggregation',
		output.SortType,
		'SortAggregation',
		output.SortAggregation,
		'CategoryFilter',
		output.CategoryFilter,
		'SalesTypeFilter',
		output.SalesTypeFilter,
		'BundleTypes',
		output.BundleTypes,
		'AssetTypes',
		output.AssetTypes,
		'IncludeOffSale',
		output.IncludeOffSale,
		'CreatorName',
		output.CreatorName
	)
end

test.CFrame = function(serdes: Squash.NumberSerDes)
	local input = CFrame.fromOrientation(
		math.random() * 2 * math.pi,
		math.random() * 2 * math.pi,
		math.random() * 2 * math.pi
	) + Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 2000
	local midput = Squash.CFrame.ser(input, serdes)
	local output = Squash[typeof(input)].des(midput, serdes)

	warn 'CFrame'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('CFrame', input)
	print 'Output:'
	print('CFrame', output)
end

test.Color3 = function(serdes: Squash.NumberSerDes)
	local input = Color3.new(math.random(), math.random(), math.random())
	local midput = Squash.Color3.ser(input)
	local output = Squash[typeof(input)].des(midput, serdes)

	warn 'Color3'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('Color3', input)
	print 'Output:'
	print('Color3', output)
end

test.ColorSequence = function()
	local input = ColorSequence.new(
		Color3.new(math.random(), math.random(), math.random()),
		Color3.new(math.random(), math.random(), math.random())
	)
	local midput = Squash.ColorSequence.ser(input)
	local output = Squash[typeof(input)].des(midput)

	warn 'ColorSequence'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('Keypoints', input.Keypoints)
	print 'Output:'
	print('Keypoints', output.Keypoints)
end

test.ColorSequenceKeypoint = function()
	local input = ColorSequenceKeypoint.new(math.random(), Color3.new(math.random(), math.random(), math.random()))
	local midput = Squash.ColorSequenceKeypoint.ser(input)
	local output = Squash[typeof(input)].des(midput)

	warn 'ColorSequenceKeypoint'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('Time', input.Time, 'Value', input.Value)
	print 'Output:'
	print('Time', output.Time, 'Value', output.Value)
end

test.DateTime = function()
	local input = DateTime.now()
	local midput = Squash.DateTime.ser(input)
	local output = Squash[typeof(input)].des(midput)

	warn 'DateTime'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('UnixTimestamp', input.UnixTimestamp)
	print 'Output:'
	print('UnixTimestamp', output.UnixTimestamp)
end

test.DockWidgetPluginGuiInfo = function()
	local input = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Left, false, true, 200, 300, 100, 200)
	local midput = Squash.DockWidgetPluginGuiInfo.ser(input)
	local output = Squash[typeof(input)].des(midput)

	warn 'DockWidgetPluginGuiInfo'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print(
		-- 'InitialDockState',
		-- input.InitialDockState,
		-- 'Enabled',
		-- input.Enabled,
		-- 'OverrideEnabledRestore',
		-- input.OverrideEnabledRestore,
		-- 'InitialEnabled',
		-- input.InitialEnabled,
		-- 'FloatingXSize',
		-- input.FloatingXSize,
		-- 'FloatingYSize',
		-- input.FloatingYSize,
		-- 'MinimumWindowSize',
		-- input.MinimumWindowSize
	)
	print 'Output:'
	print(
		-- 'InitialDockState',
		-- output.InitialDockState,
		-- 'Enabled',
		-- output.Enabled,
		-- 'OverrideEnabledRestore',
		-- output.OverrideEnabledRestore,
		-- 'InitialEnabled',
		-- output.InitialEnabled,
		-- 'FloatingXSize',
		-- output.FloatingXSize,
		-- 'FloatingYSize',
		-- output.FloatingYSize,
		-- 'MinimumWindowSize',
		-- output.MinimumWindowSize
	)
end

test.Enum = function()
	local input = Enum.CatalogCategoryFilter
	local midput = Squash.Enum.ser(input)
	local output = Squash[typeof(input)].des(midput)

	warn 'Enum'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('Value', input)
	print 'Output:'
	print('Value', output)
end

test.EnumItem = function()
	local input = Enum.CatalogCategoryFilter.Premium
	local midput = Squash.EnumItem.ser(input, input.EnumType)
	local output = Squash[typeof(input)].des(midput, input.EnumType)

	warn 'EnumItem'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('Value', input)
	print 'Output:'
	print('Value', output)
end

test.Faces = function()
	local input = Faces.new(
		math.random() < 0.5 and Enum.NormalId.Top,
		math.random() < 0.5 and Enum.NormalId.Bottom,
		math.random() < 0.5 and Enum.NormalId.Right,
		math.random() < 0.5 and Enum.NormalId.Left,
		math.random() < 0.5 and Enum.NormalId.Back,
		math.random() < 0.5 and Enum.NormalId.Front
	)
	local midput = Squash.Faces.ser(input)
	local output = Squash[typeof(input)].des(midput)

	warn 'Faces'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print(
		'Top',
		input.Top,
		'Bottom',
		input.Bottom,
		'Right',
		input.Right,
		'Left',
		input.Left,
		'Back',
		input.Back,
		'Front',
		input.Front
	)
	print 'Output:'
	print(
		'Top',
		output.Top,
		'Bottom',
		output.Bottom,
		'Right',
		output.Right,
		'Left',
		output.Left,
		'Back',
		output.Back,
		'Front',
		output.Front
	)
end

test.FloatCurveKey = function()
	local input = FloatCurveKey.new(
		math.random(),
		math.random(),
		Enum.KeyInterpolationMode:GetEnumItems()[math.random(#Enum.KeyInterpolationMode:GetEnumItems())]
	)
	if input.Interpolation == Enum.KeyInterpolationMode.Cubic then
		input.LeftTangent = (math.random() - 0.5) * 10
		input.RightTangent = (math.random() - 0.5) * 10
	end
	local midput = Squash.FloatCurveKey.ser(input)
	local output = Squash[typeof(input)].des(midput)

	warn 'FloatCurveKey'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('Time', input.Time, 'Value', input.Value, 'Interpolation', input.Interpolation, 'LeftTangent', input.LeftTangent, 'RightTangent', input.RightTangent)
	print 'Output:'
	print('Time', output.Time, 'Value', output.Value, 'Interpolation', output.Interpolation, 'LeftTangent', output.LeftTangent, 'RightTangent', output.RightTangent)
end

test.Font = function()
	local input = Font.fromEnum(Enum.Font.SourceSans)
	local midput = Squash.Font.ser(input)
	local output = Squash[typeof(input)].des(midput)

	warn 'Font'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('Value', input)
	print 'Output:'
	print('Value', output)
end

test.NumberRange = function(serdes: Squash.NumberSerDes)
	local a = math.random() * 1000
	local b = math.random() * 1000
	local input = NumberRange.new(math.min(a, b), math.max(a, b))
	local midput = Squash.NumberRange.ser(input, serdes)
	local output = Squash[typeof(input)].des(midput, serdes)

	warn 'NumberRange'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('Min', input.Min, 'Max', input.Max)
	print 'Output:'
	print('Min', output.Min, 'Max', output.Max)
end

test.NumberSequence = function(serdes: Squash.NumberSerDes)
	local input = NumberSequence.new {
		NumberSequenceKeypoint.new(0, math.random(), math.random()),
		NumberSequenceKeypoint.new(math.random(), math.random(), math.random()),
		NumberSequenceKeypoint.new(1, math.random(), math.random()),
	}
	local midput = Squash.NumberSequence.ser(input, serdes)
	local output = Squash[typeof(input)].des(midput, serdes)

	warn 'NumberSequence'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('Keypoints', input.Keypoints)
	print 'Output:'
	print('Keypoints', output.Keypoints)
end

test.NumberSequenceKeypoint = function(serdes: Squash.NumberSerDes)
	local input = NumberSequenceKeypoint.new(math.random(), math.random(), math.random())
	local midput = Squash.NumberSequenceKeypoint.ser(input, serdes)
	local output = Squash[typeof(input)].des(midput, serdes)

	warn 'NumberSequenceKeypoint'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('Time', input.Time, 'Value', input.Value, 'Envelope', input.Envelope)
	print 'Output:'
	print('Time', output.Time, 'Value', output.Value, 'Envelope', output.Envelope)
end

test.OverlapParams = function()
	local input = OverlapParams.new()
	input.FilterType = Enum.RaycastFilterType.Include
	input.MaxParts = 100
	input.CollisionGroup = 'iaendp iofpedn oiqefd;yqfu'
	input.RespectCanCollide = true
	local midput = Squash.OverlapParams.ser(input)
	local output = Squash[typeof(input)].des(midput)

	warn 'OverlapParams'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print(
		'FilterType',
		input.FilterType,
		'MaxParts',
		input.MaxParts,
		'CollisionGroup',
		input.CollisionGroup,
		'RespectCanCollide',
		input.RespectCanCollide
	)
	print 'Output:'
	print(
		'FilterType',
		output.FilterType,
		'MaxParts',
		output.MaxParts,
		'CollisionGroup',
		output.CollisionGroup,
		'RespectCanCollide',
		output.RespectCanCollide
	)
end

test.PathWaypoint = function(serdes: Squash.NumberSerDes)
	local input = PathWaypoint.new(
		Vector3.new(math.random(), math.random(), math.random()),
		Enum.PathWaypointAction:GetEnumItems()[math.random(#Enum.PathWaypointAction:GetEnumItems())],
		' oawfupqywgnudioqfwmq32wfgmo_'
	)
	local midput = Squash.PathWaypoint.ser(input, serdes)
	local output = Squash[typeof(input)].des(midput, serdes)

	warn 'PathWaypoint'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('Position', input.Position, 'Action', input.Action, 'Label', input.Label)
	print 'Output:'
	print('Position', output.Position, 'Action', output.Action, 'Label', output.Label)
end

test.PhysicalProperties = function(serdes: Squash.NumberSerDes)
	local input = PhysicalProperties.new(math.random(), math.random(), math.random(), math.random(), math.random())
	local midput = Squash.PhysicalProperties.ser(input, serdes)
	local output = Squash[typeof(input)].des(midput, serdes)

	warn 'PhysicalProperties'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print(
		'Density',
		input.Density,
		'Friction',
		input.Friction,
		'Elasticity',
		input.Elasticity,
		'FrictionWeight',
		input.FrictionWeight,
		'ElasticityWeight',
		input.ElasticityWeight
	)
	print 'Output:'
	print(
		'Density',
		output.Density,
		'Friction',
		output.Friction,
		'Elasticity',
		output.Elasticity,
		'FrictionWeight',
		output.FrictionWeight,
		'ElasticityWeight',
		output.ElasticityWeight
	)
end

test.Ray = function(serdes: Squash.NumberSerDes)
	local input = Ray.new(
		Vector3.new(math.random(), math.random(), math.random()),
		Vector3.new(math.random(), math.random(), math.random())
	)
	local midput = Squash.Ray.ser(input, serdes)
	local output = Squash[typeof(input)].des(midput, serdes)

	warn 'Ray'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('Origin', input.Origin, 'Direction', input.Direction)
	print 'Output:'
	print('Origin', output.Origin, 'Direction', output.Direction)
end

test.RaycastParams = function()
	local input = RaycastParams.new()
	input.FilterType = Enum.RaycastFilterType.Exclude
	input.IgnoreWater = true
	input.CollisionGroup = 'iaendp iofpedn oiqefd;yqfu'
	input.RespectCanCollide = true
	local midput = Squash.RaycastParams.ser(input)
	local output = Squash[typeof(input)].des(midput)

	warn 'RaycastParams'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print(
		'FilterDescendantsInstances',
		input.FilterDescendantsInstances,
		'FilterType',
		input.FilterType,
		'IgnoreWater',
		input.IgnoreWater,
		'CollisionGroup',
		input.CollisionGroup,
		'CollisionGroupId',
		input.CollisionGroupId
	)
	print 'Output:'
	print(
		'FilterDescendantsInstances',
		output.FilterDescendantsInstances,
		'FilterType',
		output.FilterType,
		'IgnoreWater',
		output.IgnoreWater,
		'CollisionGroup',
		output.CollisionGroup,
		'CollisionGroupId',
		output.CollisionGroupId
	)
end

test.RaycastResult = function()
	local input = workspace:Raycast(
		Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 2000,
		Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5),
		RaycastParams.new()
	)
	local midput = Squash.RaycastResult.ser(input)
	local output = Squash[typeof(input)].des(midput)

	warn 'RaycastResult'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print(
		'Position',
		input.Position,
		'Normal',
		input.Normal,
		'Material',
		input.Material,
		'Distance',
		input.Distance,
		'Unit',
		input.Unit
	)
end

test.Rect = function()
	local input = Rect.new(math.random(), math.random(), math.random(), math.random())
	local midput = Squash.Rect.ser(input, 4)
	local output = Squash[typeof(input)].des(midput, 4)

	print 'Rect'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('Min', input.Min, 'Max', input.Max)
	print 'Output:'
	print('Min', output.Min, 'Max', output.Max)
end

test.Region3 = function(serdes: Squash.NumberSerDes)
	local input = Region3.new(
		Vector3.new(math.random(), math.random(), math.random()),
		Vector3.new(math.random(), math.random(), math.random())
	)
	input.CFrame *= CFrame.fromOrientation(
		math.random() * 2 * math.pi,
		math.random() * 2 * math.pi,
		math.random() * 2 * math.pi
	)
	local midput = Squash.Region3.ser(input, serdes)
	local output = Squash[typeof(input)].des(midput, serdes)

	print 'Region3'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('Min', input.Min, 'Max', input.Max)
	print 'Output:'
	print('Min', output.Min, 'Max', output.Max)
end

test.Regeion3int16 = function()
	local input = Region3int16.new(
		Vector3int16.new(math.random(), math.random(), math.random()),
		Vector3int16.new(math.random(), math.random(), math.random())
	)
	local midput = Squash.Region3int16.ser(input)
	local output = Squash[typeof(input)].des(midput)

	print 'Region3int16'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('Min', input.Min, 'Max', input.Max)
	print 'Output:'
	print('Min', output.Min, 'Max', output.Max)
end

test.TweenInfo = function(serdes: Squash.NumberSerDes)
	local input = TweenInfo.new(
		math.random(),
		Enum.EasingStyle:GetEnumItems()[math.random(#Enum.EasingStyle:GetEnumItems())],
		Enum.EasingDirection:GetEnumItems()[math.random(#Enum.EasingDirection:GetEnumItems())],
		math.random(),
		math.random() < 0.5,
		math.random()
	)
	local midput = Squash.TweenInfo.ser(input, serdes)
	local output = Squash[typeof(input)].des(midput, serdes)

	print 'TweenInfo'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print(
		'Time',
		input.Time,
		'EasingStyle',
		input.EasingStyle,
		'EasingDirection',
		input.EasingDirection,
		'RepeatCount',
		input.RepeatCount,
		'Reverses',
		input.Reverses,
		'DelayTime',
		input.DelayTime
	)
	print 'Output:'
	print(
		'Time',
		output.Time,
		'EasingStyle',
		output.EasingStyle,
		'EasingDirection',
		output.EasingDirection,
		'RepeatCount',
		output.RepeatCount,
		'Reverses',
		output.Reverses,
		'DelayTime',
		output.DelayTime
	)
end

test.UDim = function(serdes: Squash.NumberSerDes)
	local input = UDim.new(math.random(), math.random())
	local midput = Squash.UDim.ser(input, serdes)
	local output = Squash[typeof(input)].des(midput, serdes)

	print 'UDim'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('Scale', input.Scale, 'Offset', input.Offset)
	print 'Output:'
	print('Scale', output.Scale, 'Offset', output.Offset)
end

test.UDim2 = function(serdes: Squash.NumberSerDes)
	local input = UDim2.new(math.random(), math.random(), math.random(), math.random())
	local midput = Squash.UDim2.ser(input, serdes)
	local output = Squash[typeof(input)].des(midput, serdes)

	print 'UDim2'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('X.Scale', input.X.Scale, 'X.Offset', input.X.Offset, 'Y.Scale', input.Y.Scale, 'Y.Offset', input.Y.Offset)
	print 'Output:'
	print(
		'X.Scale',
		output.X.Scale,
		'X.Offset',
		output.X.Offset,
		'Y.Scale',
		output.Y.Scale,
		'Y.Offset',
		output.Y.Offset
	)
end

test.Vector2 = function(serdes: Squash.NumberSerDes)
	local input = Vector2.new(math.random(), math.random())
	local midput = Squash.Vector2.ser(input, serdes)
	local output = Squash[typeof(input)].des(midput, serdes)

	print 'Vector2'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('X', input.X, 'Y', input.Y)
	print 'Output:'
	print('X', output.X, 'Y', output.Y)
end

test.Vector2int16 = function()
	local input = Vector2int16.new(math.random(), math.random())
	local midput = Squash.Vector2int16.ser(input)
	local output = Squash[typeof(input)].des(midput)

	print 'Vector2int16'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('X', input.X, 'Y', input.Y)
	print 'Output:'
	print('X', output.X, 'Y', output.Y)
end

test.Vector3 = function(serdes: Squash.NumberSerDes)
	local input = (Vector3.new(math.random(), math.random(), math.random()) - Vector3.one * 0.5) * 2000
	local midput = Squash.Vector3.ser(input, serdes)
	local output = Squash[typeof(input)].des(midput, serdes)

	print 'Vector3'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('X', input.X, 'Y', input.Y, 'Z', input.Z)
	print 'Output:'
	print('X', output.X, 'Y', output.Y, 'Z', output.Z)
end

test.Vector3int16 = function()
	local input = Vector3int16.new(math.random(), math.random(), math.random())
	local midput = Squash.Vector3int16.ser(input)
	local output = Squash[typeof(input)].des(midput)

	print 'Vector3int16'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('X', input.X, 'Y', input.Y, 'Z', input.Z)
	print 'Output:'
	print('X', output.X, 'Y', output.Y, 'Z', output.Z)
end

return test
