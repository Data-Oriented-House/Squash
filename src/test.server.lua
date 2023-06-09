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

	print 'Axes'
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
	) + Vector3.new(math.random(), math.random(), math.random()) * 1000
	local midput = Squash.CFrame.ser(input, Squash.uint)
	local output = Squash[typeof(input)].des(midput, Squash.uint)

	print 'CFrame uint'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('CFrame', input)
	print 'Output:'
	print('CFrame', output)
end

test.Color3 = function(serdes: Squash.NumberSerDes)
	local input = Color3.new(math.random(), math.random(), math.random())
	local midput = Squash.Color3.ser(input, serdes)
	local output = Squash[typeof(input)].des(midput, serdes)

	print 'Color3'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('Color3', input)
	print 'Output:'
	print('Color3', output)
end

test.ColorSequence = function(serdes: Squash.NumberSerDes)
	local input = ColorSequence.new(
		Color3.new(math.random(), math.random(), math.random()),
		Color3.new(math.random(), math.random(), math.random())
	)
	local midput = Squash.ColorSequence.ser(input, serdes)
	local output = Squash[typeof(input)].des(midput, serdes)

	print 'ColorSequence'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('Keypoints', input.Keypoints)
	print 'Output:'
	print('Keypoints', output.Keypoints)
end

test.ColorSequenceKeypoint = function()
	local input = ColorSequenceKeypoint.new(
		math.random(),
		Color3.new(math.random(), math.random(), math.random())
	)
	local midput = Squash.ColorSequenceKeypoint.ser(input)
	local output = Squash[typeof(input)].des(midput)

	print 'ColorSequenceKeypoint'
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

	print 'DateTime'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print('UnixTimestamp', input.UnixTimestamp)
	print 'Output:'
	print('UnixTimestamp', output.UnixTimestamp)
end

test.DockWidgetPluginGuiInfo = function()
	local input = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Left,
		false,
		true,
		200,
		300,
		100,
		200
	)
	local midput = Squash.DockWidgetPluginGuiInfo.ser(input)
	local output = Squash[typeof(input)].des(midput)

	print 'DockWidgetPluginGuiInfo'
	print 'Midput:'
	print(midput)
	print 'Input:'
	print(
		'InitialDockState',
		input.InitialDockState,
		'Enabled',
		input.Enabled,
		'OverrideEnabledRestore',
		input.OverrideEnabledRestore,
		'InitialEnabled',
		input.InitialEnabled,
		'FloatingXSize',
		input.FloatingXSize,
		'FloatingYSize',
		input.FloatingYSize,
		'MinimumWindowSize',
		input.MinimumWindowSize
	)
	print 'Output:'
	print(
		'InitialDockState',
		output.InitialDockState,
		'Enabled',
		output.Enabled,
		'OverrideEnabledRestore',
		output.OverrideEnabledRestore,
		'InitialEnabled',
		output.InitialEnabled,
		'FloatingXSize',
		output.FloatingXSize,
		'FloatingYSize',
		output.FloatingYSize,
		'MinimumWindowSize',
		output.MinimumWindowSize
	)
end
