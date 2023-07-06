# trace generated using paraview version 5.10.1
#import paraview
#paraview.compatibility.major = 5
#paraview.compatibility.minor = 10

#### import the simple module from the paraview
from paraview.simple import *

def plot(filename_no_ext_regex, filename_no_ext_output, base_directory, log_coloring = True, colorbar_fontsize=24, plot_type='placentone', time_fontsize=24, time_shift=0.0, time_scale=1.0):
	Connect()

	#### disable automatic camera reset on 'Show'
	paraview.simple._DisableFirstRenderCameraReset()

	# Get all files with the provided regular expression.
	import os
	import re

	regex = re.compile(filename_no_ext_regex)

	all_filenames = []
	for root, dirs, files in os.walk(base_directory+'output/'):
		if root == base_directory+'output/':
			for file in sorted(sorted(files), key=len):
				if regex.match(file):
					all_filenames.append(os.path.join(root, file))

	no_files = len(all_filenames)

	assert no_files > 0, f"No files found with the regular expression {filename_no_ext_regex}"







	# create a new 'Legacy VTK Reader'
	meshandsoln_placentone_vtk = LegacyVTKReader(registrationName=filename_no_ext_regex, FileNames=all_filenames)

	# # get animation scene
	# animationScene1 = GetAnimationScene()

	# # update animation scene based on data timesteps
	# animationScene1.UpdateAnimationUsingDataTimeSteps()

	# # get active view
	# renderView1 = GetActiveViewOrCreate('RenderView')

	# # show data in view
	# meshandsoln_placentone_Display = Show(meshandsoln_placentone_vtk, renderView1, 'UnstructuredGridRepresentation')

	# # get color transfer function/color map for 'c'
	# cLUT = GetColorTransferFunction('c')
	# cLUT.AutomaticRescaleRangeMode = 'Never'
	# cLUT.InterpretValuesAsCategories = 0
	# cLUT.AnnotationsInitialized = 0
	# cLUT.ShowCategoricalColorsinDataRangeOnly = 0
	# cLUT.RescaleOnVisibilityChange = 0
	# cLUT.EnableOpacityMapping = 0
	# cLUT.RGBPoints = [1e-06, 0.0, 0.0, 0.5625, 4.641581708516032e-06, 0.0, 0.0, 1.0, 0.00015505186699927924, 0.0, 1.0, 1.0, 0.0008961506002067481, 0.5, 1.0, 0.5, 0.005179466160537415, 1.0, 1.0, 0.0, 0.17301987742183927, 1.0, 0.0, 0.0, 1.0, 0.5, 0.0, 0.0]
	# cLUT.UseLogScale = 1
	# cLUT.UseOpacityControlPointsFreehandDrawing = 0
	# cLUT.ShowDataHistogram = 0
	# cLUT.AutomaticDataHistogramComputation = 0
	# cLUT.DataHistogramNumberOfBins = 10
	# cLUT.ColorSpace = 'RGB'
	# cLUT.UseBelowRangeColor = 0
	# cLUT.BelowRangeColor = [0.0, 0.0, 0.0]
	# cLUT.UseAboveRangeColor = 0
	# cLUT.AboveRangeColor = [0.5, 0.5, 0.5]
	# cLUT.NanColor = [1.0, 1.0, 0.0]
	# cLUT.NanOpacity = 1.0
	# cLUT.Discretize = 1
	# cLUT.NumberOfTableValues = 11
	# cLUT.ScalarRangeInitialized = 1.0
	# cLUT.HSVWrap = 0
	# cLUT.VectorComponent = 0
	# cLUT.VectorMode = 'Magnitude'
	# cLUT.AllowDuplicateScalars = 1
	# cLUT.Annotations = []
	# cLUT.ActiveAnnotatedValues = []
	# cLUT.IndexedColors = []
	# cLUT.IndexedOpacities = []

	# # get opacity transfer function/opacity map for 'c'
	# cPWF = GetOpacityTransferFunction('c')
	# cPWF.Points = [1e-06, 0.0, 0.5, 0.0, 1.0, 1.0, 0.5, 0.0]
	# cPWF.AllowDuplicateScalars = 1
	# cPWF.UseLogScale = 0
	# cPWF.ScalarRangeInitialized = 1

	# # trace defaults for the display properties.
	# meshandsoln_placentone_Display.Selection = None
	# meshandsoln_placentone_Display.Representation = 'Surface'
	# meshandsoln_placentone_Display.ColorArrayName = ['POINTS', 'c']
	# meshandsoln_placentone_Display.LookupTable = cLUT
	# meshandsoln_placentone_Display.MapScalars = 1
	# meshandsoln_placentone_Display.MultiComponentsMapping = 0
	# meshandsoln_placentone_Display.InterpolateScalarsBeforeMapping = 1
	# meshandsoln_placentone_Display.Opacity = 1.0
	# meshandsoln_placentone_Display.PointSize = 2.0
	# meshandsoln_placentone_Display.LineWidth = 1.0
	# meshandsoln_placentone_Display.RenderLinesAsTubes = 0
	# meshandsoln_placentone_Display.RenderPointsAsSpheres = 0
	# meshandsoln_placentone_Display.Interpolation = 'Gouraud'
	# meshandsoln_placentone_Display.Specular = 0.0
	# meshandsoln_placentone_Display.SpecularColor = [1.0, 1.0, 1.0]
	# meshandsoln_placentone_Display.SpecularPower = 100.0
	# meshandsoln_placentone_Display.Luminosity = 0.0
	# meshandsoln_placentone_Display.Ambient = 0.0
	# meshandsoln_placentone_Display.Diffuse = 1.0
	# meshandsoln_placentone_Display.Roughness = 0.3
	# meshandsoln_placentone_Display.Metallic = 0.0
	# meshandsoln_placentone_Display.EdgeTint = [1.0, 1.0, 1.0]
	# meshandsoln_placentone_Display.Anisotropy = 0.0
	# meshandsoln_placentone_Display.AnisotropyRotation = 0.0
	# meshandsoln_placentone_Display.BaseIOR = 1.5
	# meshandsoln_placentone_Display.CoatStrength = 0.0
	# meshandsoln_placentone_Display.CoatIOR = 2.0
	# meshandsoln_placentone_Display.CoatRoughness = 0.0
	# meshandsoln_placentone_Display.CoatColor = [1.0, 1.0, 1.0]
	# meshandsoln_placentone_Display.SelectTCoordArray = 'None'
	# meshandsoln_placentone_Display.SelectNormalArray = 'None'
	# meshandsoln_placentone_Display.SelectTangentArray = 'None'
	# meshandsoln_placentone_Display.Texture = None
	# meshandsoln_placentone_Display.RepeatTextures = 1
	# meshandsoln_placentone_Display.InterpolateTextures = 0
	# meshandsoln_placentone_Display.SeamlessU = 0
	# meshandsoln_placentone_Display.SeamlessV = 0
	# meshandsoln_placentone_Display.UseMipmapTextures = 0
	# meshandsoln_placentone_Display.ShowTexturesOnBackface = 1
	# meshandsoln_placentone_Display.BaseColorTexture = None
	# meshandsoln_placentone_Display.NormalTexture = None
	# meshandsoln_placentone_Display.NormalScale = 1.0
	# meshandsoln_placentone_Display.CoatNormalTexture = None
	# meshandsoln_placentone_Display.CoatNormalScale = 1.0
	# meshandsoln_placentone_Display.MaterialTexture = None
	# meshandsoln_placentone_Display.OcclusionStrength = 1.0
	# meshandsoln_placentone_Display.AnisotropyTexture = None
	# meshandsoln_placentone_Display.EmissiveTexture = None
	# meshandsoln_placentone_Display.EmissiveFactor = [1.0, 1.0, 1.0]
	# meshandsoln_placentone_Display.FlipTextures = 0
	# meshandsoln_placentone_Display.BackfaceRepresentation = 'Follow Frontface'
	# meshandsoln_placentone_Display.BackfaceAmbientColor = [1.0, 1.0, 1.0]
	# meshandsoln_placentone_Display.BackfaceOpacity = 1.0
	# meshandsoln_placentone_Display.Position = [0.0, 0.0, 0.0]
	# meshandsoln_placentone_Display.Scale = [1.0, 1.0, 1.0]
	# meshandsoln_placentone_Display.Orientation = [0.0, 0.0, 0.0]
	# meshandsoln_placentone_Display.Origin = [0.0, 0.0, 0.0]
	# meshandsoln_placentone_Display.CoordinateShiftScaleMethod = 'Always Auto Shift Scale'
	# meshandsoln_placentone_Display.Pickable = 1
	# meshandsoln_placentone_Display.Triangulate = 0
	# meshandsoln_placentone_Display.UseShaderReplacements = 0
	# meshandsoln_placentone_Display.ShaderReplacements = ''
	# meshandsoln_placentone_Display.NonlinearSubdivisionLevel = 1
	# meshandsoln_placentone_Display.UseDataPartitions = 0
	# meshandsoln_placentone_Display.OSPRayUseScaleArray = 'All Approximate'
	# meshandsoln_placentone_Display.OSPRayScaleArray = 'c'
	# meshandsoln_placentone_Display.OSPRayScaleFunction = 'PiecewiseFunction'
	# meshandsoln_placentone_Display.OSPRayMaterial = 'None'
	# meshandsoln_placentone_Display.BlockSelectors = ['/']
	# meshandsoln_placentone_Display.BlockColors = []
	# meshandsoln_placentone_Display.BlockOpacities = []
	# meshandsoln_placentone_Display.Orient = 0
	# meshandsoln_placentone_Display.OrientationMode = 'Direction'
	# meshandsoln_placentone_Display.SelectOrientationVectors = 'None'
	# meshandsoln_placentone_Display.Scaling = 0
	# meshandsoln_placentone_Display.ScaleMode = 'No Data Scaling Off'
	# meshandsoln_placentone_Display.ScaleFactor = 0.10500000007450581
	# meshandsoln_placentone_Display.SelectScaleArray = 'c'
	# meshandsoln_placentone_Display.GlyphType = 'Arrow'
	# meshandsoln_placentone_Display.UseGlyphTable = 0
	# meshandsoln_placentone_Display.GlyphTableIndexArray = 'c'
	# meshandsoln_placentone_Display.UseCompositeGlyphTable = 0
	# meshandsoln_placentone_Display.UseGlyphCullingAndLOD = 0
	# meshandsoln_placentone_Display.LODValues = []
	# meshandsoln_placentone_Display.ColorByLODIndex = 0
	# meshandsoln_placentone_Display.GaussianRadius = 0.00525000000372529
	# meshandsoln_placentone_Display.ShaderPreset = 'Sphere'
	# meshandsoln_placentone_Display.CustomTriangleScale = 3
	# meshandsoln_placentone_Display.CustomShader = """ // This custom shader code define a gaussian blur
	# // Please take a look into vtkSMPointGaussianRepresentation.cxx
	# // for other custom shader examples
	# //VTK::Color::Impl
	# 	float dist2 = dot(offsetVCVSOutput.xy,offsetVCVSOutput.xy);
	# 	float gaussian = exp(-0.5*dist2);
	# 	opacity = opacity*gaussian;
	# """
	# meshandsoln_placentone_Display.Emissive = 0
	# meshandsoln_placentone_Display.ScaleByArray = 0
	# meshandsoln_placentone_Display.SetScaleArray = ['POINTS', 'c']
	# meshandsoln_placentone_Display.ScaleArrayComponent = ''
	# meshandsoln_placentone_Display.UseScaleFunction = 1
	# meshandsoln_placentone_Display.ScaleTransferFunction = 'PiecewiseFunction'
	# meshandsoln_placentone_Display.OpacityByArray = 0
	# meshandsoln_placentone_Display.OpacityArray = ['POINTS', 'c']
	# meshandsoln_placentone_Display.OpacityArrayComponent = ''
	# meshandsoln_placentone_Display.OpacityTransferFunction = 'PiecewiseFunction'
	# meshandsoln_placentone_Display.DataAxesGrid = 'GridAxesRepresentation'
	# meshandsoln_placentone_Display.SelectionCellLabelBold = 0
	# meshandsoln_placentone_Display.SelectionCellLabelColor = [0.0, 1.0, 0.0]
	# meshandsoln_placentone_Display.SelectionCellLabelFontFamily = 'Arial'
	# meshandsoln_placentone_Display.SelectionCellLabelFontFile = ''
	# meshandsoln_placentone_Display.SelectionCellLabelFontSize = 18
	# meshandsoln_placentone_Display.SelectionCellLabelItalic = 0
	# meshandsoln_placentone_Display.SelectionCellLabelJustification = 'Left'
	# meshandsoln_placentone_Display.SelectionCellLabelOpacity = 1.0
	# meshandsoln_placentone_Display.SelectionCellLabelShadow = 0
	# meshandsoln_placentone_Display.SelectionPointLabelBold = 0
	# meshandsoln_placentone_Display.SelectionPointLabelColor = [1.0, 1.0, 0.0]
	# meshandsoln_placentone_Display.SelectionPointLabelFontFamily = 'Arial'
	# meshandsoln_placentone_Display.SelectionPointLabelFontFile = ''
	# meshandsoln_placentone_Display.SelectionPointLabelFontSize = 18
	# meshandsoln_placentone_Display.SelectionPointLabelItalic = 0
	# meshandsoln_placentone_Display.SelectionPointLabelJustification = 'Left'
	# meshandsoln_placentone_Display.SelectionPointLabelOpacity = 1.0
	# meshandsoln_placentone_Display.SelectionPointLabelShadow = 0
	# meshandsoln_placentone_Display.PolarAxes = 'PolarAxesRepresentation'
	# meshandsoln_placentone_Display.ScalarOpacityFunction = cPWF
	# meshandsoln_placentone_Display.ScalarOpacityUnitDistance = 0.14348552902828393
	# meshandsoln_placentone_Display.UseSeparateOpacityArray = 0
	# meshandsoln_placentone_Display.OpacityArrayName = ['POINTS', 'c']
	# meshandsoln_placentone_Display.OpacityComponent = ''
	# meshandsoln_placentone_Display.SelectMapper = 'Projected tetra'
	# meshandsoln_placentone_Display.SamplingDimensions = [128, 128, 128]
	# meshandsoln_placentone_Display.UseFloatingPointFrameBuffer = 1

	# # init the 'PiecewiseFunction' selected for 'OSPRayScaleFunction'
	# meshandsoln_placentone_Display.OSPRayScaleFunction.Points = [10.506034069460773, 0.0, 0.5, 0.0, 3909896.977314434, 1.0, 0.5, 0.0]
	# meshandsoln_placentone_Display.OSPRayScaleFunction.UseLogScale = 0

	# # init the 'Arrow' selected for 'GlyphType'
	# meshandsoln_placentone_Display.GlyphType.TipResolution = 6
	# meshandsoln_placentone_Display.GlyphType.TipRadius = 0.1
	# meshandsoln_placentone_Display.GlyphType.TipLength = 0.35
	# meshandsoln_placentone_Display.GlyphType.ShaftResolution = 6
	# meshandsoln_placentone_Display.GlyphType.ShaftRadius = 0.03
	# meshandsoln_placentone_Display.GlyphType.Invert = 0

	# # init the 'PiecewiseFunction' selected for 'ScaleTransferFunction'
	# meshandsoln_placentone_Display.ScaleTransferFunction.Points = [-0.10497211499444196, 0.0, 0.5, 0.0, 1.0300302335397922, 1.0, 0.5, 0.0]
	# meshandsoln_placentone_Display.ScaleTransferFunction.UseLogScale = 0

	# # init the 'PiecewiseFunction' selected for 'OpacityTransferFunction'
	# meshandsoln_placentone_Display.OpacityTransferFunction.Points = [-0.10497211499444196, 0.0, 0.5, 0.0, 1.0300302335397922, 1.0, 0.5, 0.0]
	# meshandsoln_placentone_Display.OpacityTransferFunction.UseLogScale = 0

	# # init the 'GridAxesRepresentation' selected for 'DataAxesGrid'
	# meshandsoln_placentone_Display.DataAxesGrid.XTitle = 'X Axis'
	# meshandsoln_placentone_Display.DataAxesGrid.YTitle = 'Y Axis'
	# meshandsoln_placentone_Display.DataAxesGrid.ZTitle = 'Z Axis'
	# meshandsoln_placentone_Display.DataAxesGrid.XTitleFontFamily = 'Arial'
	# meshandsoln_placentone_Display.DataAxesGrid.XTitleFontFile = ''
	# meshandsoln_placentone_Display.DataAxesGrid.XTitleBold = 0
	# meshandsoln_placentone_Display.DataAxesGrid.XTitleItalic = 0
	# meshandsoln_placentone_Display.DataAxesGrid.XTitleFontSize = 12
	# meshandsoln_placentone_Display.DataAxesGrid.XTitleShadow = 0
	# meshandsoln_placentone_Display.DataAxesGrid.XTitleOpacity = 1.0
	# meshandsoln_placentone_Display.DataAxesGrid.YTitleFontFamily = 'Arial'
	# meshandsoln_placentone_Display.DataAxesGrid.YTitleFontFile = ''
	# meshandsoln_placentone_Display.DataAxesGrid.YTitleBold = 0
	# meshandsoln_placentone_Display.DataAxesGrid.YTitleItalic = 0
	# meshandsoln_placentone_Display.DataAxesGrid.YTitleFontSize = 12
	# meshandsoln_placentone_Display.DataAxesGrid.YTitleShadow = 0
	# meshandsoln_placentone_Display.DataAxesGrid.YTitleOpacity = 1.0
	# meshandsoln_placentone_Display.DataAxesGrid.ZTitleFontFamily = 'Arial'
	# meshandsoln_placentone_Display.DataAxesGrid.ZTitleFontFile = ''
	# meshandsoln_placentone_Display.DataAxesGrid.ZTitleBold = 0
	# meshandsoln_placentone_Display.DataAxesGrid.ZTitleItalic = 0
	# meshandsoln_placentone_Display.DataAxesGrid.ZTitleFontSize = 12
	# meshandsoln_placentone_Display.DataAxesGrid.ZTitleShadow = 0
	# meshandsoln_placentone_Display.DataAxesGrid.ZTitleOpacity = 1.0
	# meshandsoln_placentone_Display.DataAxesGrid.FacesToRender = 63
	# meshandsoln_placentone_Display.DataAxesGrid.CullBackface = 0
	# meshandsoln_placentone_Display.DataAxesGrid.CullFrontface = 1
	# meshandsoln_placentone_Display.DataAxesGrid.ShowGrid = 0
	# meshandsoln_placentone_Display.DataAxesGrid.ShowEdges = 1
	# meshandsoln_placentone_Display.DataAxesGrid.ShowTicks = 1
	# meshandsoln_placentone_Display.DataAxesGrid.LabelUniqueEdgesOnly = 1
	# meshandsoln_placentone_Display.DataAxesGrid.AxesToLabel = 63
	# meshandsoln_placentone_Display.DataAxesGrid.XLabelFontFamily = 'Arial'
	# meshandsoln_placentone_Display.DataAxesGrid.XLabelFontFile = ''
	# meshandsoln_placentone_Display.DataAxesGrid.XLabelBold = 0
	# meshandsoln_placentone_Display.DataAxesGrid.XLabelItalic = 0
	# meshandsoln_placentone_Display.DataAxesGrid.XLabelFontSize = 12
	# meshandsoln_placentone_Display.DataAxesGrid.XLabelShadow = 0
	# meshandsoln_placentone_Display.DataAxesGrid.XLabelOpacity = 1.0
	# meshandsoln_placentone_Display.DataAxesGrid.YLabelFontFamily = 'Arial'
	# meshandsoln_placentone_Display.DataAxesGrid.YLabelFontFile = ''
	# meshandsoln_placentone_Display.DataAxesGrid.YLabelBold = 0
	# meshandsoln_placentone_Display.DataAxesGrid.YLabelItalic = 0
	# meshandsoln_placentone_Display.DataAxesGrid.YLabelFontSize = 12
	# meshandsoln_placentone_Display.DataAxesGrid.YLabelShadow = 0
	# meshandsoln_placentone_Display.DataAxesGrid.YLabelOpacity = 1.0
	# meshandsoln_placentone_Display.DataAxesGrid.ZLabelFontFamily = 'Arial'
	# meshandsoln_placentone_Display.DataAxesGrid.ZLabelFontFile = ''
	# meshandsoln_placentone_Display.DataAxesGrid.ZLabelBold = 0
	# meshandsoln_placentone_Display.DataAxesGrid.ZLabelItalic = 0
	# meshandsoln_placentone_Display.DataAxesGrid.ZLabelFontSize = 12
	# meshandsoln_placentone_Display.DataAxesGrid.ZLabelShadow = 0
	# meshandsoln_placentone_Display.DataAxesGrid.ZLabelOpacity = 1.0
	# meshandsoln_placentone_Display.DataAxesGrid.XAxisNotation = 'Mixed'
	# meshandsoln_placentone_Display.DataAxesGrid.XAxisPrecision = 2
	# meshandsoln_placentone_Display.DataAxesGrid.XAxisUseCustomLabels = 0
	# meshandsoln_placentone_Display.DataAxesGrid.XAxisLabels = []
	# meshandsoln_placentone_Display.DataAxesGrid.YAxisNotation = 'Mixed'
	# meshandsoln_placentone_Display.DataAxesGrid.YAxisPrecision = 2
	# meshandsoln_placentone_Display.DataAxesGrid.YAxisUseCustomLabels = 0
	# meshandsoln_placentone_Display.DataAxesGrid.YAxisLabels = []
	# meshandsoln_placentone_Display.DataAxesGrid.ZAxisNotation = 'Mixed'
	# meshandsoln_placentone_Display.DataAxesGrid.ZAxisPrecision = 2
	# meshandsoln_placentone_Display.DataAxesGrid.ZAxisUseCustomLabels = 0
	# meshandsoln_placentone_Display.DataAxesGrid.ZAxisLabels = []
	# meshandsoln_placentone_Display.DataAxesGrid.UseCustomBounds = 0
	# meshandsoln_placentone_Display.DataAxesGrid.CustomBounds = [0.0, 1.0, 0.0, 1.0, 0.0, 1.0]

	# # init the 'PolarAxesRepresentation' selected for 'PolarAxes'
	# meshandsoln_placentone_Display.PolarAxes.Visibility = 0
	# meshandsoln_placentone_Display.PolarAxes.Translation = [0.0, 0.0, 0.0]
	# meshandsoln_placentone_Display.PolarAxes.Scale = [1.0, 1.0, 1.0]
	# meshandsoln_placentone_Display.PolarAxes.Orientation = [0.0, 0.0, 0.0]
	# meshandsoln_placentone_Display.PolarAxes.EnableCustomBounds = [0, 0, 0]
	# meshandsoln_placentone_Display.PolarAxes.CustomBounds = [0.0, 1.0, 0.0, 1.0, 0.0, 1.0]
	# meshandsoln_placentone_Display.PolarAxes.EnableCustomRange = 0
	# meshandsoln_placentone_Display.PolarAxes.CustomRange = [0.0, 1.0]
	# meshandsoln_placentone_Display.PolarAxes.PolarAxisVisibility = 1
	# meshandsoln_placentone_Display.PolarAxes.RadialAxesVisibility = 1
	# meshandsoln_placentone_Display.PolarAxes.DrawRadialGridlines = 1
	# meshandsoln_placentone_Display.PolarAxes.PolarArcsVisibility = 1
	# meshandsoln_placentone_Display.PolarAxes.DrawPolarArcsGridlines = 1
	# meshandsoln_placentone_Display.PolarAxes.NumberOfRadialAxes = 0
	# meshandsoln_placentone_Display.PolarAxes.AutoSubdividePolarAxis = 1
	# meshandsoln_placentone_Display.PolarAxes.NumberOfPolarAxis = 0
	# meshandsoln_placentone_Display.PolarAxes.MinimumRadius = 0.0
	# meshandsoln_placentone_Display.PolarAxes.MinimumAngle = 0.0
	# meshandsoln_placentone_Display.PolarAxes.MaximumAngle = 90.0
	# meshandsoln_placentone_Display.PolarAxes.RadialAxesOriginToPolarAxis = 1
	# meshandsoln_placentone_Display.PolarAxes.Ratio = 1.0
	# meshandsoln_placentone_Display.PolarAxes.PolarAxisColor = [1.0, 1.0, 1.0]
	# meshandsoln_placentone_Display.PolarAxes.PolarArcsColor = [1.0, 1.0, 1.0]
	# meshandsoln_placentone_Display.PolarAxes.LastRadialAxisColor = [1.0, 1.0, 1.0]
	# meshandsoln_placentone_Display.PolarAxes.SecondaryPolarArcsColor = [1.0, 1.0, 1.0]
	# meshandsoln_placentone_Display.PolarAxes.SecondaryRadialAxesColor = [1.0, 1.0, 1.0]
	# meshandsoln_placentone_Display.PolarAxes.PolarAxisTitleVisibility = 1
	# meshandsoln_placentone_Display.PolarAxes.PolarAxisTitle = 'Radial Distance'
	# meshandsoln_placentone_Display.PolarAxes.PolarAxisTitleLocation = 'Bottom'
	# meshandsoln_placentone_Display.PolarAxes.PolarLabelVisibility = 1
	# meshandsoln_placentone_Display.PolarAxes.PolarLabelFormat = '%-#6.3g'
	# meshandsoln_placentone_Display.PolarAxes.PolarLabelExponentLocation = 'Labels'
	# meshandsoln_placentone_Display.PolarAxes.RadialLabelVisibility = 1
	# meshandsoln_placentone_Display.PolarAxes.RadialLabelFormat = '%-#3.1f'
	# meshandsoln_placentone_Display.PolarAxes.RadialLabelLocation = 'Bottom'
	# meshandsoln_placentone_Display.PolarAxes.RadialUnitsVisibility = 1
	# meshandsoln_placentone_Display.PolarAxes.ScreenSize = 10.0
	# meshandsoln_placentone_Display.PolarAxes.PolarAxisTitleOpacity = 1.0
	# meshandsoln_placentone_Display.PolarAxes.PolarAxisTitleFontFamily = 'Arial'
	# meshandsoln_placentone_Display.PolarAxes.PolarAxisTitleFontFile = ''
	# meshandsoln_placentone_Display.PolarAxes.PolarAxisTitleBold = 0
	# meshandsoln_placentone_Display.PolarAxes.PolarAxisTitleItalic = 0
	# meshandsoln_placentone_Display.PolarAxes.PolarAxisTitleShadow = 0
	# meshandsoln_placentone_Display.PolarAxes.PolarAxisTitleFontSize = 12
	# meshandsoln_placentone_Display.PolarAxes.PolarAxisLabelOpacity = 1.0
	# meshandsoln_placentone_Display.PolarAxes.PolarAxisLabelFontFamily = 'Arial'
	# meshandsoln_placentone_Display.PolarAxes.PolarAxisLabelFontFile = ''
	# meshandsoln_placentone_Display.PolarAxes.PolarAxisLabelBold = 0
	# meshandsoln_placentone_Display.PolarAxes.PolarAxisLabelItalic = 0
	# meshandsoln_placentone_Display.PolarAxes.PolarAxisLabelShadow = 0
	# meshandsoln_placentone_Display.PolarAxes.PolarAxisLabelFontSize = 12
	# meshandsoln_placentone_Display.PolarAxes.LastRadialAxisTextOpacity = 1.0
	# meshandsoln_placentone_Display.PolarAxes.LastRadialAxisTextFontFamily = 'Arial'
	# meshandsoln_placentone_Display.PolarAxes.LastRadialAxisTextFontFile = ''
	# meshandsoln_placentone_Display.PolarAxes.LastRadialAxisTextBold = 0
	# meshandsoln_placentone_Display.PolarAxes.LastRadialAxisTextItalic = 0
	# meshandsoln_placentone_Display.PolarAxes.LastRadialAxisTextShadow = 0
	# meshandsoln_placentone_Display.PolarAxes.LastRadialAxisTextFontSize = 12
	# meshandsoln_placentone_Display.PolarAxes.SecondaryRadialAxesTextOpacity = 1.0
	# meshandsoln_placentone_Display.PolarAxes.SecondaryRadialAxesTextFontFamily = 'Arial'
	# meshandsoln_placentone_Display.PolarAxes.SecondaryRadialAxesTextFontFile = ''
	# meshandsoln_placentone_Display.PolarAxes.SecondaryRadialAxesTextBold = 0
	# meshandsoln_placentone_Display.PolarAxes.SecondaryRadialAxesTextItalic = 0
	# meshandsoln_placentone_Display.PolarAxes.SecondaryRadialAxesTextShadow = 0
	# meshandsoln_placentone_Display.PolarAxes.SecondaryRadialAxesTextFontSize = 12
	# meshandsoln_placentone_Display.PolarAxes.EnableDistanceLOD = 1
	# meshandsoln_placentone_Display.PolarAxes.DistanceLODThreshold = 0.7
	# meshandsoln_placentone_Display.PolarAxes.EnableViewAngleLOD = 1
	# meshandsoln_placentone_Display.PolarAxes.ViewAngleLODThreshold = 0.7
	# meshandsoln_placentone_Display.PolarAxes.SmallestVisiblePolarAngle = 0.5
	# meshandsoln_placentone_Display.PolarAxes.PolarTicksVisibility = 1
	# meshandsoln_placentone_Display.PolarAxes.ArcTicksOriginToPolarAxis = 1
	# meshandsoln_placentone_Display.PolarAxes.TickLocation = 'Both'
	# meshandsoln_placentone_Display.PolarAxes.AxisTickVisibility = 1
	# meshandsoln_placentone_Display.PolarAxes.AxisMinorTickVisibility = 0
	# meshandsoln_placentone_Display.PolarAxes.ArcTickVisibility = 1
	# meshandsoln_placentone_Display.PolarAxes.ArcMinorTickVisibility = 0
	# meshandsoln_placentone_Display.PolarAxes.DeltaAngleMajor = 10.0
	# meshandsoln_placentone_Display.PolarAxes.DeltaAngleMinor = 5.0
	# meshandsoln_placentone_Display.PolarAxes.PolarAxisMajorTickSize = 0.0
	# meshandsoln_placentone_Display.PolarAxes.PolarAxisTickRatioSize = 0.3
	# meshandsoln_placentone_Display.PolarAxes.PolarAxisMajorTickThickness = 1.0
	# meshandsoln_placentone_Display.PolarAxes.PolarAxisTickRatioThickness = 0.5
	# meshandsoln_placentone_Display.PolarAxes.LastRadialAxisMajorTickSize = 0.0
	# meshandsoln_placentone_Display.PolarAxes.LastRadialAxisTickRatioSize = 0.3
	# meshandsoln_placentone_Display.PolarAxes.LastRadialAxisMajorTickThickness = 1.0
	# meshandsoln_placentone_Display.PolarAxes.LastRadialAxisTickRatioThickness = 0.5
	# meshandsoln_placentone_Display.PolarAxes.ArcMajorTickSize = 0.0
	# meshandsoln_placentone_Display.PolarAxes.ArcTickRatioSize = 0.3
	# meshandsoln_placentone_Display.PolarAxes.ArcMajorTickThickness = 1.0
	# meshandsoln_placentone_Display.PolarAxes.ArcTickRatioThickness = 0.5
	# meshandsoln_placentone_Display.PolarAxes.Use2DMode = 0
	# meshandsoln_placentone_Display.PolarAxes.UseLogAxis = 0

	# # reset view to fit data
	# renderView1.ResetCamera(False)

	# # get the material library
	# materialLibrary1 = GetMaterialLibrary()

	# # show color bar/color legend
	# meshandsoln_placentone_Display.SetScalarBarVisibility(renderView1, True)

	# # update the view to ensure updated data information
	# renderView1.Update()

	# # Rescale transfer function
	# cLUT.RescaleTransferFunction(1e-05, 1.0)

	# # Rescale transfer function
	# cPWF.RescaleTransferFunction(1e-05, 1.0)

	# # Apply a preset using its name. Note this may not work as expected when presets have duplicate names.
	# cLUT.ApplyPreset('Jet', True)



	# no_files = 51

	#### disable automatic camera reset on 'Show'
	paraview.simple._DisableFirstRenderCameraReset()

	# get animation scene
	animationScene1 = GetAnimationScene()

	# update animation scene based on data timesteps
	animationScene1.UpdateAnimationUsingDataTimeSteps()

	# get active view
	renderView1 = GetActiveViewOrCreate('RenderView')

	# show data in view
	meshandsoln_placentone_Display = Show(meshandsoln_placentone_vtk, renderView1, 'UnstructuredGridRepresentation')

	# get color transfer function/color map for 'c'
	cLUT = GetColorTransferFunction('c')
	cLUT.AutomaticRescaleRangeMode = "Grow and update on 'Apply'"
	cLUT.InterpretValuesAsCategories = 0
	cLUT.AnnotationsInitialized = 0
	cLUT.ShowCategoricalColorsinDataRangeOnly = 0
	cLUT.RescaleOnVisibilityChange = 0
	cLUT.EnableOpacityMapping = 0
	cLUT.RGBPoints = [1.1757813367477766e-42, 0.0, 0.0, 0.5625, 3.2716780653645004e-42, 0.0, 0.0, 1.0, 3.3934742832154957e-41, 0.0, 1.0, 1.0, 1.0929003431547791e-40, 0.5, 1.0, 0.5, 3.519788453902906e-40, 1.0, 1.0, 0.0, 3.650821187795389e-39, 1.0, 0.0, 0.0, 1.1757813367477768e-38, 0.5, 0.0, 0.0]
	cLUT.UseLogScale = 1
	cLUT.UseOpacityControlPointsFreehandDrawing = 0
	cLUT.ShowDataHistogram = 0
	cLUT.AutomaticDataHistogramComputation = 0
	cLUT.DataHistogramNumberOfBins = 10
	cLUT.ColorSpace = 'RGB'
	cLUT.UseBelowRangeColor = 0
	cLUT.BelowRangeColor = [0.5, 0.5, 0.5]
	cLUT.UseAboveRangeColor = 0
	cLUT.AboveRangeColor = [0.5, 0.5, 0.5]
	cLUT.NanColor = [1.0, 1.0, 0.0]
	cLUT.NanOpacity = 1.0
	cLUT.Discretize = 0
	cLUT.NumberOfTableValues = 11
	cLUT.ScalarRangeInitialized = 1.0
	cLUT.HSVWrap = 0
	cLUT.VectorComponent = 0
	cLUT.VectorMode = 'Magnitude'
	cLUT.AllowDuplicateScalars = 1
	cLUT.Annotations = []
	cLUT.ActiveAnnotatedValues = []
	cLUT.IndexedColors = []
	cLUT.IndexedOpacities = []

	# get opacity transfer function/opacity map for 'c'
	cPWF = GetOpacityTransferFunction('c')
	cPWF.Points = [0.0, 0.0, 0.5, 0.0, 1.1757813367477812e-38, 1.0, 0.5, 0.0]
	cPWF.AllowDuplicateScalars = 1
	cPWF.UseLogScale = 0
	cPWF.ScalarRangeInitialized = 1

	# trace defaults for the display properties.
	meshandsoln_placentone_Display.Selection = None
	meshandsoln_placentone_Display.Representation = 'Surface'
	meshandsoln_placentone_Display.ColorArrayName = ['POINTS', 'c']
	meshandsoln_placentone_Display.LookupTable = cLUT
	meshandsoln_placentone_Display.MapScalars = 1
	meshandsoln_placentone_Display.MultiComponentsMapping = 0
	meshandsoln_placentone_Display.InterpolateScalarsBeforeMapping = 1
	meshandsoln_placentone_Display.Opacity = 1.0
	meshandsoln_placentone_Display.PointSize = 2.0
	meshandsoln_placentone_Display.LineWidth = 1.0
	meshandsoln_placentone_Display.RenderLinesAsTubes = 0
	meshandsoln_placentone_Display.RenderPointsAsSpheres = 0
	meshandsoln_placentone_Display.Interpolation = 'Gouraud'
	meshandsoln_placentone_Display.Specular = 0.0
	meshandsoln_placentone_Display.SpecularColor = [1.0, 1.0, 1.0]
	meshandsoln_placentone_Display.SpecularPower = 100.0
	meshandsoln_placentone_Display.Luminosity = 0.0
	meshandsoln_placentone_Display.Ambient = 0.0
	meshandsoln_placentone_Display.Diffuse = 1.0
	meshandsoln_placentone_Display.Roughness = 0.3
	meshandsoln_placentone_Display.Metallic = 0.0
	meshandsoln_placentone_Display.EdgeTint = [1.0, 1.0, 1.0]
	meshandsoln_placentone_Display.Anisotropy = 0.0
	meshandsoln_placentone_Display.AnisotropyRotation = 0.0
	meshandsoln_placentone_Display.BaseIOR = 1.5
	meshandsoln_placentone_Display.CoatStrength = 0.0
	meshandsoln_placentone_Display.CoatIOR = 2.0
	meshandsoln_placentone_Display.CoatRoughness = 0.0
	meshandsoln_placentone_Display.CoatColor = [1.0, 1.0, 1.0]
	meshandsoln_placentone_Display.SelectTCoordArray = 'None'
	meshandsoln_placentone_Display.SelectNormalArray = 'None'
	meshandsoln_placentone_Display.SelectTangentArray = 'None'
	meshandsoln_placentone_Display.Texture = None
	meshandsoln_placentone_Display.RepeatTextures = 1
	meshandsoln_placentone_Display.InterpolateTextures = 0
	meshandsoln_placentone_Display.SeamlessU = 0
	meshandsoln_placentone_Display.SeamlessV = 0
	meshandsoln_placentone_Display.UseMipmapTextures = 0
	meshandsoln_placentone_Display.ShowTexturesOnBackface = 1
	meshandsoln_placentone_Display.BaseColorTexture = None
	meshandsoln_placentone_Display.NormalTexture = None
	meshandsoln_placentone_Display.NormalScale = 1.0
	meshandsoln_placentone_Display.CoatNormalTexture = None
	meshandsoln_placentone_Display.CoatNormalScale = 1.0
	meshandsoln_placentone_Display.MaterialTexture = None
	meshandsoln_placentone_Display.OcclusionStrength = 1.0
	meshandsoln_placentone_Display.AnisotropyTexture = None
	meshandsoln_placentone_Display.EmissiveTexture = None
	meshandsoln_placentone_Display.EmissiveFactor = [1.0, 1.0, 1.0]
	meshandsoln_placentone_Display.FlipTextures = 0
	meshandsoln_placentone_Display.BackfaceRepresentation = 'Follow Frontface'
	meshandsoln_placentone_Display.BackfaceAmbientColor = [1.0, 1.0, 1.0]
	meshandsoln_placentone_Display.BackfaceOpacity = 1.0
	meshandsoln_placentone_Display.Position = [0.0, 0.0, 0.0]
	meshandsoln_placentone_Display.Scale = [1.0, 1.0, 1.0]
	meshandsoln_placentone_Display.Orientation = [0.0, 0.0, 0.0]
	meshandsoln_placentone_Display.Origin = [0.0, 0.0, 0.0]
	meshandsoln_placentone_Display.CoordinateShiftScaleMethod = 'Always Auto Shift Scale'
	meshandsoln_placentone_Display.Pickable = 1
	meshandsoln_placentone_Display.Triangulate = 0
	meshandsoln_placentone_Display.UseShaderReplacements = 0
	meshandsoln_placentone_Display.ShaderReplacements = ''
	meshandsoln_placentone_Display.NonlinearSubdivisionLevel = 1
	meshandsoln_placentone_Display.UseDataPartitions = 0
	meshandsoln_placentone_Display.OSPRayUseScaleArray = 'All Approximate'
	meshandsoln_placentone_Display.OSPRayScaleArray = 'c'
	meshandsoln_placentone_Display.OSPRayScaleFunction = 'PiecewiseFunction'
	meshandsoln_placentone_Display.OSPRayMaterial = 'None'
	meshandsoln_placentone_Display.BlockSelectors = ['/']
	meshandsoln_placentone_Display.BlockColors = []
	meshandsoln_placentone_Display.BlockOpacities = []
	meshandsoln_placentone_Display.Orient = 0
	meshandsoln_placentone_Display.OrientationMode = 'Direction'
	meshandsoln_placentone_Display.SelectOrientationVectors = 'None'
	meshandsoln_placentone_Display.Scaling = 0
	meshandsoln_placentone_Display.ScaleMode = 'No Data Scaling Off'
	meshandsoln_placentone_Display.ScaleFactor = 0.10500000007450581
	meshandsoln_placentone_Display.SelectScaleArray = 'c'
	meshandsoln_placentone_Display.GlyphType = 'Arrow'
	meshandsoln_placentone_Display.UseGlyphTable = 0
	meshandsoln_placentone_Display.GlyphTableIndexArray = 'c'
	meshandsoln_placentone_Display.UseCompositeGlyphTable = 0
	meshandsoln_placentone_Display.UseGlyphCullingAndLOD = 0
	meshandsoln_placentone_Display.LODValues = []
	meshandsoln_placentone_Display.ColorByLODIndex = 0
	meshandsoln_placentone_Display.GaussianRadius = 0.00525000000372529
	meshandsoln_placentone_Display.ShaderPreset = 'Sphere'
	meshandsoln_placentone_Display.CustomTriangleScale = 3
	meshandsoln_placentone_Display.CustomShader = """ // This custom shader code define a gaussian blur
	// Please take a look into vtkSMPointGaussianRepresentation.cxx
	// for other custom shader examples
	//VTK::Color::Impl
		float dist2 = dot(offsetVCVSOutput.xy,offsetVCVSOutput.xy);
		float gaussian = exp(-0.5*dist2);
		opacity = opacity*gaussian;
	"""
	meshandsoln_placentone_Display.Emissive = 0
	meshandsoln_placentone_Display.ScaleByArray = 0
	meshandsoln_placentone_Display.SetScaleArray = ['POINTS', 'c']
	meshandsoln_placentone_Display.ScaleArrayComponent = ''
	meshandsoln_placentone_Display.UseScaleFunction = 1
	meshandsoln_placentone_Display.ScaleTransferFunction = 'PiecewiseFunction'
	meshandsoln_placentone_Display.OpacityByArray = 0
	meshandsoln_placentone_Display.OpacityArray = ['POINTS', 'c']
	meshandsoln_placentone_Display.OpacityArrayComponent = ''
	meshandsoln_placentone_Display.OpacityTransferFunction = 'PiecewiseFunction'
	meshandsoln_placentone_Display.DataAxesGrid = 'GridAxesRepresentation'
	meshandsoln_placentone_Display.SelectionCellLabelBold = 0
	meshandsoln_placentone_Display.SelectionCellLabelColor = [0.0, 1.0, 0.0]
	meshandsoln_placentone_Display.SelectionCellLabelFontFamily = 'Arial'
	meshandsoln_placentone_Display.SelectionCellLabelFontFile = ''
	meshandsoln_placentone_Display.SelectionCellLabelFontSize = 18
	meshandsoln_placentone_Display.SelectionCellLabelItalic = 0
	meshandsoln_placentone_Display.SelectionCellLabelJustification = 'Left'
	meshandsoln_placentone_Display.SelectionCellLabelOpacity = 1.0
	meshandsoln_placentone_Display.SelectionCellLabelShadow = 0
	meshandsoln_placentone_Display.SelectionPointLabelBold = 0
	meshandsoln_placentone_Display.SelectionPointLabelColor = [1.0, 1.0, 0.0]
	meshandsoln_placentone_Display.SelectionPointLabelFontFamily = 'Arial'
	meshandsoln_placentone_Display.SelectionPointLabelFontFile = ''
	meshandsoln_placentone_Display.SelectionPointLabelFontSize = 18
	meshandsoln_placentone_Display.SelectionPointLabelItalic = 0
	meshandsoln_placentone_Display.SelectionPointLabelJustification = 'Left'
	meshandsoln_placentone_Display.SelectionPointLabelOpacity = 1.0
	meshandsoln_placentone_Display.SelectionPointLabelShadow = 0
	meshandsoln_placentone_Display.PolarAxes = 'PolarAxesRepresentation'
	meshandsoln_placentone_Display.ScalarOpacityFunction = cPWF
	meshandsoln_placentone_Display.ScalarOpacityUnitDistance = 0.14348552902828393
	meshandsoln_placentone_Display.UseSeparateOpacityArray = 0
	meshandsoln_placentone_Display.OpacityArrayName = ['POINTS', 'c']
	meshandsoln_placentone_Display.OpacityComponent = ''
	meshandsoln_placentone_Display.SelectMapper = 'Projected tetra'
	meshandsoln_placentone_Display.SamplingDimensions = [128, 128, 128]
	meshandsoln_placentone_Display.UseFloatingPointFrameBuffer = 1

	# init the 'PiecewiseFunction' selected for 'OSPRayScaleFunction'
	meshandsoln_placentone_Display.OSPRayScaleFunction.Points = [10.506034069460773, 0.0, 0.5, 0.0, 3909896.977314434, 1.0, 0.5, 0.0]
	meshandsoln_placentone_Display.OSPRayScaleFunction.UseLogScale = 0

	# init the 'Arrow' selected for 'GlyphType'
	meshandsoln_placentone_Display.GlyphType.TipResolution = 6
	meshandsoln_placentone_Display.GlyphType.TipRadius = 0.1
	meshandsoln_placentone_Display.GlyphType.TipLength = 0.35
	meshandsoln_placentone_Display.GlyphType.ShaftResolution = 6
	meshandsoln_placentone_Display.GlyphType.ShaftRadius = 0.03
	meshandsoln_placentone_Display.GlyphType.Invert = 0

	# init the 'PiecewiseFunction' selected for 'ScaleTransferFunction'
	meshandsoln_placentone_Display.ScaleTransferFunction.Points = [0.0, 0.0, 0.5, 0.0, 1.1757813367477812e-38, 1.0, 0.5, 0.0]
	meshandsoln_placentone_Display.ScaleTransferFunction.UseLogScale = 0

	# init the 'PiecewiseFunction' selected for 'OpacityTransferFunction'
	meshandsoln_placentone_Display.OpacityTransferFunction.Points = [0.0, 0.0, 0.5, 0.0, 1.1757813367477812e-38, 1.0, 0.5, 0.0]
	meshandsoln_placentone_Display.OpacityTransferFunction.UseLogScale = 0

	# init the 'GridAxesRepresentation' selected for 'DataAxesGrid'
	meshandsoln_placentone_Display.DataAxesGrid.XTitle = 'X Axis'
	meshandsoln_placentone_Display.DataAxesGrid.YTitle = 'Y Axis'
	meshandsoln_placentone_Display.DataAxesGrid.ZTitle = 'Z Axis'
	meshandsoln_placentone_Display.DataAxesGrid.XTitleFontFamily = 'Arial'
	meshandsoln_placentone_Display.DataAxesGrid.XTitleFontFile = ''
	meshandsoln_placentone_Display.DataAxesGrid.XTitleBold = 0
	meshandsoln_placentone_Display.DataAxesGrid.XTitleItalic = 0
	meshandsoln_placentone_Display.DataAxesGrid.XTitleFontSize = 12
	meshandsoln_placentone_Display.DataAxesGrid.XTitleShadow = 0
	meshandsoln_placentone_Display.DataAxesGrid.XTitleOpacity = 1.0
	meshandsoln_placentone_Display.DataAxesGrid.YTitleFontFamily = 'Arial'
	meshandsoln_placentone_Display.DataAxesGrid.YTitleFontFile = ''
	meshandsoln_placentone_Display.DataAxesGrid.YTitleBold = 0
	meshandsoln_placentone_Display.DataAxesGrid.YTitleItalic = 0
	meshandsoln_placentone_Display.DataAxesGrid.YTitleFontSize = 12
	meshandsoln_placentone_Display.DataAxesGrid.YTitleShadow = 0
	meshandsoln_placentone_Display.DataAxesGrid.YTitleOpacity = 1.0
	meshandsoln_placentone_Display.DataAxesGrid.ZTitleFontFamily = 'Arial'
	meshandsoln_placentone_Display.DataAxesGrid.ZTitleFontFile = ''
	meshandsoln_placentone_Display.DataAxesGrid.ZTitleBold = 0
	meshandsoln_placentone_Display.DataAxesGrid.ZTitleItalic = 0
	meshandsoln_placentone_Display.DataAxesGrid.ZTitleFontSize = 12
	meshandsoln_placentone_Display.DataAxesGrid.ZTitleShadow = 0
	meshandsoln_placentone_Display.DataAxesGrid.ZTitleOpacity = 1.0
	meshandsoln_placentone_Display.DataAxesGrid.FacesToRender = 63
	meshandsoln_placentone_Display.DataAxesGrid.CullBackface = 0
	meshandsoln_placentone_Display.DataAxesGrid.CullFrontface = 1
	meshandsoln_placentone_Display.DataAxesGrid.ShowGrid = 0
	meshandsoln_placentone_Display.DataAxesGrid.ShowEdges = 1
	meshandsoln_placentone_Display.DataAxesGrid.ShowTicks = 1
	meshandsoln_placentone_Display.DataAxesGrid.LabelUniqueEdgesOnly = 1
	meshandsoln_placentone_Display.DataAxesGrid.AxesToLabel = 63
	meshandsoln_placentone_Display.DataAxesGrid.XLabelFontFamily = 'Arial'
	meshandsoln_placentone_Display.DataAxesGrid.XLabelFontFile = ''
	meshandsoln_placentone_Display.DataAxesGrid.XLabelBold = 0
	meshandsoln_placentone_Display.DataAxesGrid.XLabelItalic = 0
	meshandsoln_placentone_Display.DataAxesGrid.XLabelFontSize = 12
	meshandsoln_placentone_Display.DataAxesGrid.XLabelShadow = 0
	meshandsoln_placentone_Display.DataAxesGrid.XLabelOpacity = 1.0
	meshandsoln_placentone_Display.DataAxesGrid.YLabelFontFamily = 'Arial'
	meshandsoln_placentone_Display.DataAxesGrid.YLabelFontFile = ''
	meshandsoln_placentone_Display.DataAxesGrid.YLabelBold = 0
	meshandsoln_placentone_Display.DataAxesGrid.YLabelItalic = 0
	meshandsoln_placentone_Display.DataAxesGrid.YLabelFontSize = 12
	meshandsoln_placentone_Display.DataAxesGrid.YLabelShadow = 0
	meshandsoln_placentone_Display.DataAxesGrid.YLabelOpacity = 1.0
	meshandsoln_placentone_Display.DataAxesGrid.ZLabelFontFamily = 'Arial'
	meshandsoln_placentone_Display.DataAxesGrid.ZLabelFontFile = ''
	meshandsoln_placentone_Display.DataAxesGrid.ZLabelBold = 0
	meshandsoln_placentone_Display.DataAxesGrid.ZLabelItalic = 0
	meshandsoln_placentone_Display.DataAxesGrid.ZLabelFontSize = 12
	meshandsoln_placentone_Display.DataAxesGrid.ZLabelShadow = 0
	meshandsoln_placentone_Display.DataAxesGrid.ZLabelOpacity = 1.0
	meshandsoln_placentone_Display.DataAxesGrid.XAxisNotation = 'Mixed'
	meshandsoln_placentone_Display.DataAxesGrid.XAxisPrecision = 2
	meshandsoln_placentone_Display.DataAxesGrid.XAxisUseCustomLabels = 0
	meshandsoln_placentone_Display.DataAxesGrid.XAxisLabels = []
	meshandsoln_placentone_Display.DataAxesGrid.YAxisNotation = 'Mixed'
	meshandsoln_placentone_Display.DataAxesGrid.YAxisPrecision = 2
	meshandsoln_placentone_Display.DataAxesGrid.YAxisUseCustomLabels = 0
	meshandsoln_placentone_Display.DataAxesGrid.YAxisLabels = []
	meshandsoln_placentone_Display.DataAxesGrid.ZAxisNotation = 'Mixed'
	meshandsoln_placentone_Display.DataAxesGrid.ZAxisPrecision = 2
	meshandsoln_placentone_Display.DataAxesGrid.ZAxisUseCustomLabels = 0
	meshandsoln_placentone_Display.DataAxesGrid.ZAxisLabels = []
	meshandsoln_placentone_Display.DataAxesGrid.UseCustomBounds = 0
	meshandsoln_placentone_Display.DataAxesGrid.CustomBounds = [0.0, 1.0, 0.0, 1.0, 0.0, 1.0]

	# init the 'PolarAxesRepresentation' selected for 'PolarAxes'
	meshandsoln_placentone_Display.PolarAxes.Visibility = 0
	meshandsoln_placentone_Display.PolarAxes.Translation = [0.0, 0.0, 0.0]
	meshandsoln_placentone_Display.PolarAxes.Scale = [1.0, 1.0, 1.0]
	meshandsoln_placentone_Display.PolarAxes.Orientation = [0.0, 0.0, 0.0]
	meshandsoln_placentone_Display.PolarAxes.EnableCustomBounds = [0, 0, 0]
	meshandsoln_placentone_Display.PolarAxes.CustomBounds = [0.0, 1.0, 0.0, 1.0, 0.0, 1.0]
	meshandsoln_placentone_Display.PolarAxes.EnableCustomRange = 0
	meshandsoln_placentone_Display.PolarAxes.CustomRange = [0.0, 1.0]
	meshandsoln_placentone_Display.PolarAxes.PolarAxisVisibility = 1
	meshandsoln_placentone_Display.PolarAxes.RadialAxesVisibility = 1
	meshandsoln_placentone_Display.PolarAxes.DrawRadialGridlines = 1
	meshandsoln_placentone_Display.PolarAxes.PolarArcsVisibility = 1
	meshandsoln_placentone_Display.PolarAxes.DrawPolarArcsGridlines = 1
	meshandsoln_placentone_Display.PolarAxes.NumberOfRadialAxes = 0
	meshandsoln_placentone_Display.PolarAxes.AutoSubdividePolarAxis = 1
	meshandsoln_placentone_Display.PolarAxes.NumberOfPolarAxis = 0
	meshandsoln_placentone_Display.PolarAxes.MinimumRadius = 0.0
	meshandsoln_placentone_Display.PolarAxes.MinimumAngle = 0.0
	meshandsoln_placentone_Display.PolarAxes.MaximumAngle = 90.0
	meshandsoln_placentone_Display.PolarAxes.RadialAxesOriginToPolarAxis = 1
	meshandsoln_placentone_Display.PolarAxes.Ratio = 1.0
	meshandsoln_placentone_Display.PolarAxes.PolarAxisColor = [1.0, 1.0, 1.0]
	meshandsoln_placentone_Display.PolarAxes.PolarArcsColor = [1.0, 1.0, 1.0]
	meshandsoln_placentone_Display.PolarAxes.LastRadialAxisColor = [1.0, 1.0, 1.0]
	meshandsoln_placentone_Display.PolarAxes.SecondaryPolarArcsColor = [1.0, 1.0, 1.0]
	meshandsoln_placentone_Display.PolarAxes.SecondaryRadialAxesColor = [1.0, 1.0, 1.0]
	meshandsoln_placentone_Display.PolarAxes.PolarAxisTitleVisibility = 1
	meshandsoln_placentone_Display.PolarAxes.PolarAxisTitle = 'Radial Distance'
	meshandsoln_placentone_Display.PolarAxes.PolarAxisTitleLocation = 'Bottom'
	meshandsoln_placentone_Display.PolarAxes.PolarLabelVisibility = 1
	meshandsoln_placentone_Display.PolarAxes.PolarLabelFormat = '%-#6.3g'
	meshandsoln_placentone_Display.PolarAxes.PolarLabelExponentLocation = 'Labels'
	meshandsoln_placentone_Display.PolarAxes.RadialLabelVisibility = 1
	meshandsoln_placentone_Display.PolarAxes.RadialLabelFormat = '%-#3.1f'
	meshandsoln_placentone_Display.PolarAxes.RadialLabelLocation = 'Bottom'
	meshandsoln_placentone_Display.PolarAxes.RadialUnitsVisibility = 1
	meshandsoln_placentone_Display.PolarAxes.ScreenSize = 10.0
	meshandsoln_placentone_Display.PolarAxes.PolarAxisTitleOpacity = 1.0
	meshandsoln_placentone_Display.PolarAxes.PolarAxisTitleFontFamily = 'Arial'
	meshandsoln_placentone_Display.PolarAxes.PolarAxisTitleFontFile = ''
	meshandsoln_placentone_Display.PolarAxes.PolarAxisTitleBold = 0
	meshandsoln_placentone_Display.PolarAxes.PolarAxisTitleItalic = 0
	meshandsoln_placentone_Display.PolarAxes.PolarAxisTitleShadow = 0
	meshandsoln_placentone_Display.PolarAxes.PolarAxisTitleFontSize = 12
	meshandsoln_placentone_Display.PolarAxes.PolarAxisLabelOpacity = 1.0
	meshandsoln_placentone_Display.PolarAxes.PolarAxisLabelFontFamily = 'Arial'
	meshandsoln_placentone_Display.PolarAxes.PolarAxisLabelFontFile = ''
	meshandsoln_placentone_Display.PolarAxes.PolarAxisLabelBold = 0
	meshandsoln_placentone_Display.PolarAxes.PolarAxisLabelItalic = 0
	meshandsoln_placentone_Display.PolarAxes.PolarAxisLabelShadow = 0
	meshandsoln_placentone_Display.PolarAxes.PolarAxisLabelFontSize = 12
	meshandsoln_placentone_Display.PolarAxes.LastRadialAxisTextOpacity = 1.0
	meshandsoln_placentone_Display.PolarAxes.LastRadialAxisTextFontFamily = 'Arial'
	meshandsoln_placentone_Display.PolarAxes.LastRadialAxisTextFontFile = ''
	meshandsoln_placentone_Display.PolarAxes.LastRadialAxisTextBold = 0
	meshandsoln_placentone_Display.PolarAxes.LastRadialAxisTextItalic = 0
	meshandsoln_placentone_Display.PolarAxes.LastRadialAxisTextShadow = 0
	meshandsoln_placentone_Display.PolarAxes.LastRadialAxisTextFontSize = 12
	meshandsoln_placentone_Display.PolarAxes.SecondaryRadialAxesTextOpacity = 1.0
	meshandsoln_placentone_Display.PolarAxes.SecondaryRadialAxesTextFontFamily = 'Arial'
	meshandsoln_placentone_Display.PolarAxes.SecondaryRadialAxesTextFontFile = ''
	meshandsoln_placentone_Display.PolarAxes.SecondaryRadialAxesTextBold = 0
	meshandsoln_placentone_Display.PolarAxes.SecondaryRadialAxesTextItalic = 0
	meshandsoln_placentone_Display.PolarAxes.SecondaryRadialAxesTextShadow = 0
	meshandsoln_placentone_Display.PolarAxes.SecondaryRadialAxesTextFontSize = 12
	meshandsoln_placentone_Display.PolarAxes.EnableDistanceLOD = 1
	meshandsoln_placentone_Display.PolarAxes.DistanceLODThreshold = 0.7
	meshandsoln_placentone_Display.PolarAxes.EnableViewAngleLOD = 1
	meshandsoln_placentone_Display.PolarAxes.ViewAngleLODThreshold = 0.7
	meshandsoln_placentone_Display.PolarAxes.SmallestVisiblePolarAngle = 0.5
	meshandsoln_placentone_Display.PolarAxes.PolarTicksVisibility = 1
	meshandsoln_placentone_Display.PolarAxes.ArcTicksOriginToPolarAxis = 1
	meshandsoln_placentone_Display.PolarAxes.TickLocation = 'Both'
	meshandsoln_placentone_Display.PolarAxes.AxisTickVisibility = 1
	meshandsoln_placentone_Display.PolarAxes.AxisMinorTickVisibility = 0
	meshandsoln_placentone_Display.PolarAxes.ArcTickVisibility = 1
	meshandsoln_placentone_Display.PolarAxes.ArcMinorTickVisibility = 0
	meshandsoln_placentone_Display.PolarAxes.DeltaAngleMajor = 10.0
	meshandsoln_placentone_Display.PolarAxes.DeltaAngleMinor = 5.0
	meshandsoln_placentone_Display.PolarAxes.PolarAxisMajorTickSize = 0.0
	meshandsoln_placentone_Display.PolarAxes.PolarAxisTickRatioSize = 0.3
	meshandsoln_placentone_Display.PolarAxes.PolarAxisMajorTickThickness = 1.0
	meshandsoln_placentone_Display.PolarAxes.PolarAxisTickRatioThickness = 0.5
	meshandsoln_placentone_Display.PolarAxes.LastRadialAxisMajorTickSize = 0.0
	meshandsoln_placentone_Display.PolarAxes.LastRadialAxisTickRatioSize = 0.3
	meshandsoln_placentone_Display.PolarAxes.LastRadialAxisMajorTickThickness = 1.0
	meshandsoln_placentone_Display.PolarAxes.LastRadialAxisTickRatioThickness = 0.5
	meshandsoln_placentone_Display.PolarAxes.ArcMajorTickSize = 0.0
	meshandsoln_placentone_Display.PolarAxes.ArcTickRatioSize = 0.3
	meshandsoln_placentone_Display.PolarAxes.ArcMajorTickThickness = 1.0
	meshandsoln_placentone_Display.PolarAxes.ArcTickRatioThickness = 0.5
	meshandsoln_placentone_Display.PolarAxes.Use2DMode = 0
	meshandsoln_placentone_Display.PolarAxes.UseLogAxis = 0

	# get layout
	layout1 = GetLayout()

	if (plot_type == 'placentone'):
		# layout/tab size in pixels
		layout1.SetSize(1656, 1578)
	else:
		# layout/tab size in pixels
		layout1.SetSize(2300, 740)

	# reset view to fit data
	renderView1.ResetCamera(False)

	if (plot_type == 'placentone'):
		# current camera placement for renderView1
		renderView1.InteractionMode = '2D'
		renderView1.CameraPosition = [0.5165399239605267, 0.3537072239169405, 10000.0]
		renderView1.CameraFocalPoint = [0.5165399239605267, 0.3537072239169405, 0.0]
		renderView1.CameraParallelScale = 0.7250000002697624
	else:
		# current camera placement for renderView1
		renderView1.InteractionMode = '2D'
		renderView1.CameraPosition = [3.2324151951752396, 0.390660466849554, 12.594792705554676]
		renderView1.CameraFocalPoint = [3.2324151951752396, 0.390660466849554, 0.0]
		renderView1.CameraParallelScale = 1.0386638884273762
	# get color legend/bar for cLUT in view renderView1
	cLUTColorBar = GetScalarBar(cLUT, renderView1)

	if (plot_type == 'placentone'):
		# change scalar bar placement
		cLUTColorBar.Orientation = 'Horizontal'
		cLUTColorBar.WindowLocation = 'Any Location'
		cLUTColorBar.Position = [0.32587258454106277, 0.12119138149556408]
		cLUTColorBar.ScalarBarLength = 0.3299999999999999
	else:
		# change scalar bar placement
		cLUTColorBar.Orientation = 'Horizontal'
		cLUTColorBar.WindowLocation = 'Any Location'
		cLUTColorBar.Position = [0.3244021739130435, 0.08135135135135152]
		cLUTColorBar.ScalarBarLength = 0.32999999999999907

	# change scalar bar placement
	cLUTColorBar.Position = [0.2050996376811594, 0.12119138149556408]

	# change scalar bar placement
	cLUTColorBar.ScalarBarLength = 0.5884541062801927

	# Properties modified on cLUTColorBar
	cLUTColorBar.TitleFontSize = colorbar_fontsize
	cLUTColorBar.LabelFontSize = colorbar_fontsize

	# get the material library
	materialLibrary1 = GetMaterialLibrary()

	# show color bar/color legend
	meshandsoln_placentone_Display.SetScalarBarVisibility(renderView1, True)

	if (log_coloring == 1):
		# # Rescale transfer function
		# cLUT.RescaleTransferFunction(1e-5, 1.0)

		# # Rescale transfer function
		# cPWF.RescaleTransferFunction(1e-5, 1.0)

		# # convert to log space
		# cLUT.MapControlPointsToLogSpace()

		# # Properties modified on cLUT
		# cLUT.UseLogScale = 1

		# Rescale transfer function
		cLUT.RescaleTransferFunction(1e-5, 1.0)

		# Rescale transfer function
		cPWF.RescaleTransferFunction(1e-5, 1.0)
	else:
		# Rescale transfer function
		cLUT.RescaleTransferFunction(1e-5, 1.0)

		# Rescale transfer function
		cPWF.RescaleTransferFunction(1e-5, 1.0)

		# convert from log to linear
		cLUT.MapControlPointsToLinearSpace()

		# Properties modified on cLUT
		cLUT.UseLogScale = 0

		# Rescale transfer function
		cLUT.RescaleTransferFunction(0.0, 1.0)

		# Rescale transfer function
		cPWF.RescaleTransferFunction(0.0, 1.0)

	# Hide orientation axes
	renderView1.OrientationAxesVisibility = 0

	# create a new 'Annotate Time Filter'
	annotateTimeFilter1 = AnnotateTimeFilter(registrationName='AnnotateTimeFilter1', Input=meshandsoln_placentone_vtk)

	# Properties modified on annotateTimeFilter1
	annotateTimeFilter1.Shift = time_shift
	annotateTimeFilter1.Scale = time_scale

	# show data in view
	annotateTimeFilter1Display = Show(annotateTimeFilter1, renderView1, 'TextSourceRepresentation')

	# Properties modified on annotateTimeFilter1Display
	annotateTimeFilter1Display.FontSize = time_fontsize

	# update the view to ensure updated data information
	renderView1.Update()

	# save animation
	# SaveAnimation('/home/pmyambl/Miscellaneous/2023-01-18 Transport with nsku/images/meshandsoln_dg_navier-stokes-ku_placentone_40_transport-linear.png', renderView1, ImageResolution=[1161, 594],
	# 		FontScaling='Scale fonts proportionally',
	# 		OverrideColorPalette='',
	# 		StereoMode='No change',
	# 		TransparentBackground=0,
	# 		FrameRate=1,
	# 		FrameWindow=[0, 50],
	# 		# PNG options
	# 		CompressionLevel='5',
	# 		MetaData=['Application', 'ParaView'],
	# 		SuffixFormat='.%04d')

	# #================================================================
	# # addendum: following script captures some of the application
	# # state to faithfully reproduce the visualization during playback
	# #================================================================

	# #--------------------------------
	# # saving layout sizes for layouts

	# # layout/tab size in pixels
	# layout1.SetSize(1161, 594)

	# #-----------------------------------
	# # saving camera placements for views

	# # current camera placement for renderView1
	# renderView1.InteractionMode = '2D'
	# renderView1.CameraPosition = [0.5, 0.47499999962747097, 10000.0]
	# renderView1.CameraFocalPoint = [0.5, 0.47499999962747097, 0.0]
	# renderView1.CameraParallelScale = 0.7250000002697624

	#--------------------------------------------
	# uncomment the following to render all views
	# RenderAllViews()
	# alternatively, if you want to write images, you can use SaveScreenshot(...).








	if (log_coloring == 1):
		color_type = 'log'
	else:
		color_type = 'linear'

	if (no_files == 1):
		if (plot_type == 'placentone'):
			SaveScreenshot(base_directory+'images/'+filename_no_ext_output+'_transport-'+color_type+'.png', renderView1, ImageResolution=[3312, 3156],
					FontScaling='Scale fonts proportionally',
					OverrideColorPalette='',
					StereoMode='No change',
					TransparentBackground=1,
					# PNG options
					CompressionLevel='5',
					MetaData=['Application', 'ParaView'])
		else:
			# save animation
			SaveScreenshot(base_directory+'images/'+filename_no_ext_output+'_transport-'+color_type+'.png', renderView1, ImageResolution=[4600, 1480],
				FontScaling='Scale fonts proportionally',
				OverrideColorPalette='',
				StereoMode='No change',
				TransparentBackground=1,
				# PNG options
				CompressionLevel='5',
				MetaData=['Application', 'ParaView'])
	else:
		if (plot_type == 'placentone'):
			SaveAnimation(base_directory+'images/'+filename_no_ext_output+'_transport-'+color_type+'.png', renderView1, ImageResolution=[3312, 3156],
					FrameWindow=[0, no_files],
					FontScaling='Scale fonts proportionally',
					OverrideColorPalette='',
					StereoMode='No change',
					TransparentBackground=0,
					# PNG options
					CompressionLevel='5',
					MetaData=['Application', 'ParaView'],
					SuffixFormat='.%04d')
		else:
			# save animation
			SaveAnimation(base_directory+'images/'+filename_no_ext_output+'_transport-'+color_type+'.png', renderView1, ImageResolution=[4600, 1480],
				FrameWindow=[0, no_files],
				FontScaling='Scale fonts proportionally',
				OverrideColorPalette='',
				StereoMode='No change',
				TransparentBackground=0,
				# PNG options
				CompressionLevel='5',
				MetaData=['Application', 'ParaView'],
				SuffixFormat='.%04d')

	Disconnect()

import sys

no_arguments = len(sys.argv)

if(no_arguments != 10):
	print("Incorrect number of arguments.")
	exit(1)
if (no_arguments == 10):
	filename_no_ext_regex  = sys.argv[1]
	filename_no_ext_output = sys.argv[2]
	base_directory         = sys.argv[3]
	log_coloring           = int(sys.argv[4])
	colorbar_fontsize      = int(sys.argv[5])
	plot_type              = sys.argv[6]
	time_fontsize          = int(sys.argv[7])
	time_shift             = float(sys.argv[8])
	time_scale             = float(sys.argv[9])

plot(
	filename_no_ext_regex,
	filename_no_ext_output,
	base_directory,
	log_coloring,
	colorbar_fontsize,
	plot_type,
	time_fontsize,
	time_shift,
	time_scale
)