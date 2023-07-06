# trace generated using paraview version 5.10.1
#import paraview
#paraview.compatibility.major = 5
#paraview.compatibility.minor = 10

#### import the simple module from the paraview
from paraview.simple import *

def plot(filename_no_ext_regex, filename_no_ext_output, base_directory, log_coloring = True, colorbar_fontsize=24, plot_streamlines=False, plot_glyphs=False, plot_type='placentone', time_fontsize=24, time_shift=0.0, time_scale=1.0):
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
	#meshandsoln_placentone_vtk = LegacyVTKReader(registrationName=filename_no_ext_regex+'.vtk', FileNames=[base_directory+'output/'+filename_no_ext_regex+'.vtk'])
	meshandsoln_placentone_vtk = LegacyVTKReader(registrationName=filename_no_ext_regex, FileNames=all_filenames)

	# get animation scene
	animationScene1 = GetAnimationScene()

	# update animation scene based on data timesteps
	animationScene1.UpdateAnimationUsingDataTimeSteps()

	# get active view
	renderView1 = GetActiveViewOrCreate('RenderView')

	# show data in view
	meshandsoln_placentone_vtk_Display = Show(meshandsoln_placentone_vtk, renderView1, 'UnstructuredGridRepresentation')

	# get color transfer function/color map for 'u'
	uLUT = GetColorTransferFunction('u')

	# get opacity transfer function/opacity map for 'u'
	uPWF = GetOpacityTransferFunction('u')

	# trace defaults for the display properties.
	meshandsoln_placentone_vtk_Display.Selection = None
	meshandsoln_placentone_vtk_Display.Representation = 'Surface'
	meshandsoln_placentone_vtk_Display.ColorArrayName = ['POINTS', 'u']
	meshandsoln_placentone_vtk_Display.LookupTable = uLUT
	meshandsoln_placentone_vtk_Display.MapScalars = 1
	meshandsoln_placentone_vtk_Display.MultiComponentsMapping = 0
	meshandsoln_placentone_vtk_Display.InterpolateScalarsBeforeMapping = 1
	meshandsoln_placentone_vtk_Display.Opacity = 1.0
	meshandsoln_placentone_vtk_Display.PointSize = 2.0
	meshandsoln_placentone_vtk_Display.LineWidth = 1.0
	meshandsoln_placentone_vtk_Display.RenderLinesAsTubes = 0
	meshandsoln_placentone_vtk_Display.RenderPointsAsSpheres = 0
	meshandsoln_placentone_vtk_Display.Interpolation = 'Gouraud'
	meshandsoln_placentone_vtk_Display.Specular = 0.0
	meshandsoln_placentone_vtk_Display.SpecularColor = [1.0, 1.0, 1.0]
	meshandsoln_placentone_vtk_Display.SpecularPower = 100.0
	meshandsoln_placentone_vtk_Display.Luminosity = 0.0
	meshandsoln_placentone_vtk_Display.Ambient = 0.0
	meshandsoln_placentone_vtk_Display.Diffuse = 1.0
	meshandsoln_placentone_vtk_Display.Roughness = 0.3
	meshandsoln_placentone_vtk_Display.Metallic = 0.0
	meshandsoln_placentone_vtk_Display.EdgeTint = [1.0, 1.0, 1.0]
	meshandsoln_placentone_vtk_Display.Anisotropy = 0.0
	meshandsoln_placentone_vtk_Display.AnisotropyRotation = 0.0
	meshandsoln_placentone_vtk_Display.BaseIOR = 1.5
	meshandsoln_placentone_vtk_Display.CoatStrength = 0.0
	meshandsoln_placentone_vtk_Display.CoatIOR = 2.0
	meshandsoln_placentone_vtk_Display.CoatRoughness = 0.0
	meshandsoln_placentone_vtk_Display.CoatColor = [1.0, 1.0, 1.0]
	meshandsoln_placentone_vtk_Display.SelectTCoordArray = 'None'
	meshandsoln_placentone_vtk_Display.SelectNormalArray = 'None'
	meshandsoln_placentone_vtk_Display.SelectTangentArray = 'None'
	meshandsoln_placentone_vtk_Display.Texture = None
	meshandsoln_placentone_vtk_Display.RepeatTextures = 1
	meshandsoln_placentone_vtk_Display.InterpolateTextures = 0
	meshandsoln_placentone_vtk_Display.SeamlessU = 0
	meshandsoln_placentone_vtk_Display.SeamlessV = 0
	meshandsoln_placentone_vtk_Display.UseMipmapTextures = 0
	meshandsoln_placentone_vtk_Display.ShowTexturesOnBackface = 1
	meshandsoln_placentone_vtk_Display.BaseColorTexture = None
	meshandsoln_placentone_vtk_Display.NormalTexture = None
	meshandsoln_placentone_vtk_Display.NormalScale = 1.0
	meshandsoln_placentone_vtk_Display.CoatNormalTexture = None
	meshandsoln_placentone_vtk_Display.CoatNormalScale = 1.0
	meshandsoln_placentone_vtk_Display.MaterialTexture = None
	meshandsoln_placentone_vtk_Display.OcclusionStrength = 1.0
	meshandsoln_placentone_vtk_Display.AnisotropyTexture = None
	meshandsoln_placentone_vtk_Display.EmissiveTexture = None
	meshandsoln_placentone_vtk_Display.EmissiveFactor = [1.0, 1.0, 1.0]
	meshandsoln_placentone_vtk_Display.FlipTextures = 0
	meshandsoln_placentone_vtk_Display.BackfaceRepresentation = 'Follow Frontface'
	meshandsoln_placentone_vtk_Display.BackfaceAmbientColor = [1.0, 1.0, 1.0]
	meshandsoln_placentone_vtk_Display.BackfaceOpacity = 1.0
	meshandsoln_placentone_vtk_Display.Position = [0.0, 0.0, 0.0]
	meshandsoln_placentone_vtk_Display.Scale = [1.0, 1.0, 1.0]
	meshandsoln_placentone_vtk_Display.Orientation = [0.0, 0.0, 0.0]
	meshandsoln_placentone_vtk_Display.Origin = [0.0, 0.0, 0.0]
	meshandsoln_placentone_vtk_Display.CoordinateShiftScaleMethod = 'Always Auto Shift Scale'
	meshandsoln_placentone_vtk_Display.Pickable = 1
	meshandsoln_placentone_vtk_Display.Triangulate = 0
	meshandsoln_placentone_vtk_Display.UseShaderReplacements = 0
	meshandsoln_placentone_vtk_Display.ShaderReplacements = ''
	meshandsoln_placentone_vtk_Display.NonlinearSubdivisionLevel = 1
	meshandsoln_placentone_vtk_Display.UseDataPartitions = 0
	meshandsoln_placentone_vtk_Display.OSPRayUseScaleArray = 'All Approximate'
	meshandsoln_placentone_vtk_Display.OSPRayScaleArray = 'u'
	meshandsoln_placentone_vtk_Display.OSPRayScaleFunction = 'PiecewiseFunction'
	meshandsoln_placentone_vtk_Display.OSPRayMaterial = 'None'
	meshandsoln_placentone_vtk_Display.BlockSelectors = ['/']
	meshandsoln_placentone_vtk_Display.BlockColors = []
	meshandsoln_placentone_vtk_Display.BlockOpacities = []
	meshandsoln_placentone_vtk_Display.Orient = 0
	meshandsoln_placentone_vtk_Display.OrientationMode = 'Direction'
	meshandsoln_placentone_vtk_Display.SelectOrientationVectors = 'None'
	meshandsoln_placentone_vtk_Display.Scaling = 0
	meshandsoln_placentone_vtk_Display.ScaleMode = 'No Data Scaling Off'
	meshandsoln_placentone_vtk_Display.ScaleFactor = 0.10500000007450581
	meshandsoln_placentone_vtk_Display.SelectScaleArray = 'u'
	meshandsoln_placentone_vtk_Display.GlyphType = 'Arrow'
	meshandsoln_placentone_vtk_Display.UseGlyphTable = 0
	meshandsoln_placentone_vtk_Display.GlyphTableIndexArray = 'u'
	meshandsoln_placentone_vtk_Display.UseCompositeGlyphTable = 0
	meshandsoln_placentone_vtk_Display.UseGlyphCullingAndLOD = 0
	meshandsoln_placentone_vtk_Display.LODValues = []
	meshandsoln_placentone_vtk_Display.ColorByLODIndex = 0
	meshandsoln_placentone_vtk_Display.GaussianRadius = 0.00525000000372529
	meshandsoln_placentone_vtk_Display.ShaderPreset = 'Sphere'
	meshandsoln_placentone_vtk_Display.CustomTriangleScale = 3
	meshandsoln_placentone_vtk_Display.CustomShader = """ // This custom shader code define a gaussian blur
	// Please take a look into vtkSMPointGaussianRepresentation.cxx
	// for other custom shader examples
	//VTK::Color::Impl
		float dist2 = dot(offsetVCVSOutput.xy,offsetVCVSOutput.xy);
		float gaussian = exp(-0.5*dist2);
		opacity = opacity*gaussian;
	"""
	meshandsoln_placentone_vtk_Display.Emissive = 0
	meshandsoln_placentone_vtk_Display.ScaleByArray = 0
	meshandsoln_placentone_vtk_Display.SetScaleArray = ['POINTS', 'u']
	meshandsoln_placentone_vtk_Display.ScaleArrayComponent = ''
	meshandsoln_placentone_vtk_Display.UseScaleFunction = 1
	meshandsoln_placentone_vtk_Display.ScaleTransferFunction = 'PiecewiseFunction'
	meshandsoln_placentone_vtk_Display.OpacityByArray = 0
	meshandsoln_placentone_vtk_Display.OpacityArray = ['POINTS', 'u']
	meshandsoln_placentone_vtk_Display.OpacityArrayComponent = ''
	meshandsoln_placentone_vtk_Display.OpacityTransferFunction = 'PiecewiseFunction'
	meshandsoln_placentone_vtk_Display.DataAxesGrid = 'GridAxesRepresentation'
	meshandsoln_placentone_vtk_Display.SelectionCellLabelBold = 0
	meshandsoln_placentone_vtk_Display.SelectionCellLabelColor = [0.0, 1.0, 0.0]
	meshandsoln_placentone_vtk_Display.SelectionCellLabelFontFamily = 'Arial'
	meshandsoln_placentone_vtk_Display.SelectionCellLabelFontFile = ''
	meshandsoln_placentone_vtk_Display.SelectionCellLabelFontSize = 18
	meshandsoln_placentone_vtk_Display.SelectionCellLabelItalic = 0
	meshandsoln_placentone_vtk_Display.SelectionCellLabelJustification = 'Left'
	meshandsoln_placentone_vtk_Display.SelectionCellLabelOpacity = 1.0
	meshandsoln_placentone_vtk_Display.SelectionCellLabelShadow = 0
	meshandsoln_placentone_vtk_Display.SelectionPointLabelBold = 0
	meshandsoln_placentone_vtk_Display.SelectionPointLabelColor = [1.0, 1.0, 0.0]
	meshandsoln_placentone_vtk_Display.SelectionPointLabelFontFamily = 'Arial'
	meshandsoln_placentone_vtk_Display.SelectionPointLabelFontFile = ''
	meshandsoln_placentone_vtk_Display.SelectionPointLabelFontSize = 18
	meshandsoln_placentone_vtk_Display.SelectionPointLabelItalic = 0
	meshandsoln_placentone_vtk_Display.SelectionPointLabelJustification = 'Left'
	meshandsoln_placentone_vtk_Display.SelectionPointLabelOpacity = 1.0
	meshandsoln_placentone_vtk_Display.SelectionPointLabelShadow = 0
	meshandsoln_placentone_vtk_Display.PolarAxes = 'PolarAxesRepresentation'
	meshandsoln_placentone_vtk_Display.ScalarOpacityFunction = uPWF
	meshandsoln_placentone_vtk_Display.ScalarOpacityUnitDistance = 0.14212151558048683
	meshandsoln_placentone_vtk_Display.UseSeparateOpacityArray = 0
	meshandsoln_placentone_vtk_Display.OpacityArrayName = ['POINTS', 'u']
	meshandsoln_placentone_vtk_Display.OpacityComponent = ''
	meshandsoln_placentone_vtk_Display.SelectMapper = 'Projected tetra'
	meshandsoln_placentone_vtk_Display.SamplingDimensions = [128, 128, 128]
	meshandsoln_placentone_vtk_Display.UseFloatingPointFrameBuffer = 1

	# init the 'PiecewiseFunction' selected for 'OSPRayScaleFunction'
	meshandsoln_placentone_vtk_Display.OSPRayScaleFunction.Points = [10.506034069460773, 0.0, 0.5, 0.0, 3909896.977314434, 1.0, 0.5, 0.0]
	meshandsoln_placentone_vtk_Display.OSPRayScaleFunction.UseLogScale = 0

	# init the 'Arrow' selected for 'GlyphType'
	meshandsoln_placentone_vtk_Display.GlyphType.TipResolution = 6
	meshandsoln_placentone_vtk_Display.GlyphType.TipRadius = 0.1
	meshandsoln_placentone_vtk_Display.GlyphType.TipLength = 0.35
	meshandsoln_placentone_vtk_Display.GlyphType.ShaftResolution = 6
	meshandsoln_placentone_vtk_Display.GlyphType.ShaftRadius = 0.03
	meshandsoln_placentone_vtk_Display.GlyphType.Invert = 0

	# init the 'PiecewiseFunction' selected for 'ScaleTransferFunction'
	meshandsoln_placentone_vtk_Display.ScaleTransferFunction.Points = [-0.27520780171538306, 0.0, 0.5, 0.0, 0.2690516587864361, 1.0, 0.5, 0.0]
	meshandsoln_placentone_vtk_Display.ScaleTransferFunction.UseLogScale = 0

	# init the 'PiecewiseFunction' selected for 'OpacityTransferFunction'
	meshandsoln_placentone_vtk_Display.OpacityTransferFunction.Points = [-0.27520780171538306, 0.0, 0.5, 0.0, 0.2690516587864361, 1.0, 0.5, 0.0]
	meshandsoln_placentone_vtk_Display.OpacityTransferFunction.UseLogScale = 0

	# init the 'GridAxesRepresentation' selected for 'DataAxesGrid'
	meshandsoln_placentone_vtk_Display.DataAxesGrid.XTitle = 'X Axis'
	meshandsoln_placentone_vtk_Display.DataAxesGrid.YTitle = 'Y Axis'
	meshandsoln_placentone_vtk_Display.DataAxesGrid.ZTitle = 'Z Axis'
	meshandsoln_placentone_vtk_Display.DataAxesGrid.XTitleFontFamily = 'Arial'
	meshandsoln_placentone_vtk_Display.DataAxesGrid.XTitleFontFile = ''
	meshandsoln_placentone_vtk_Display.DataAxesGrid.XTitleBold = 0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.XTitleItalic = 0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.XTitleFontSize = 12
	meshandsoln_placentone_vtk_Display.DataAxesGrid.XTitleShadow = 0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.XTitleOpacity = 1.0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.YTitleFontFamily = 'Arial'
	meshandsoln_placentone_vtk_Display.DataAxesGrid.YTitleFontFile = ''
	meshandsoln_placentone_vtk_Display.DataAxesGrid.YTitleBold = 0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.YTitleItalic = 0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.YTitleFontSize = 12
	meshandsoln_placentone_vtk_Display.DataAxesGrid.YTitleShadow = 0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.YTitleOpacity = 1.0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.ZTitleFontFamily = 'Arial'
	meshandsoln_placentone_vtk_Display.DataAxesGrid.ZTitleFontFile = ''
	meshandsoln_placentone_vtk_Display.DataAxesGrid.ZTitleBold = 0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.ZTitleItalic = 0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.ZTitleFontSize = 12
	meshandsoln_placentone_vtk_Display.DataAxesGrid.ZTitleShadow = 0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.ZTitleOpacity = 1.0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.FacesToRender = 63
	meshandsoln_placentone_vtk_Display.DataAxesGrid.CullBackface = 0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.CullFrontface = 1
	meshandsoln_placentone_vtk_Display.DataAxesGrid.ShowGrid = 0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.ShowEdges = 1
	meshandsoln_placentone_vtk_Display.DataAxesGrid.ShowTicks = 1
	meshandsoln_placentone_vtk_Display.DataAxesGrid.LabelUniqueEdgesOnly = 1
	meshandsoln_placentone_vtk_Display.DataAxesGrid.AxesToLabel = 63
	meshandsoln_placentone_vtk_Display.DataAxesGrid.XLabelFontFamily = 'Arial'
	meshandsoln_placentone_vtk_Display.DataAxesGrid.XLabelFontFile = ''
	meshandsoln_placentone_vtk_Display.DataAxesGrid.XLabelBold = 0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.XLabelItalic = 0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.XLabelFontSize = 12
	meshandsoln_placentone_vtk_Display.DataAxesGrid.XLabelShadow = 0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.XLabelOpacity = 1.0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.YLabelFontFamily = 'Arial'
	meshandsoln_placentone_vtk_Display.DataAxesGrid.YLabelFontFile = ''
	meshandsoln_placentone_vtk_Display.DataAxesGrid.YLabelBold = 0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.YLabelItalic = 0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.YLabelFontSize = 12
	meshandsoln_placentone_vtk_Display.DataAxesGrid.YLabelShadow = 0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.YLabelOpacity = 1.0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.ZLabelFontFamily = 'Arial'
	meshandsoln_placentone_vtk_Display.DataAxesGrid.ZLabelFontFile = ''
	meshandsoln_placentone_vtk_Display.DataAxesGrid.ZLabelBold = 0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.ZLabelItalic = 0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.ZLabelFontSize = 12
	meshandsoln_placentone_vtk_Display.DataAxesGrid.ZLabelShadow = 0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.ZLabelOpacity = 1.0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.XAxisNotation = 'Mixed'
	meshandsoln_placentone_vtk_Display.DataAxesGrid.XAxisPrecision = 2
	meshandsoln_placentone_vtk_Display.DataAxesGrid.XAxisUseCustomLabels = 0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.XAxisLabels = []
	meshandsoln_placentone_vtk_Display.DataAxesGrid.YAxisNotation = 'Mixed'
	meshandsoln_placentone_vtk_Display.DataAxesGrid.YAxisPrecision = 2
	meshandsoln_placentone_vtk_Display.DataAxesGrid.YAxisUseCustomLabels = 0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.YAxisLabels = []
	meshandsoln_placentone_vtk_Display.DataAxesGrid.ZAxisNotation = 'Mixed'
	meshandsoln_placentone_vtk_Display.DataAxesGrid.ZAxisPrecision = 2
	meshandsoln_placentone_vtk_Display.DataAxesGrid.ZAxisUseCustomLabels = 0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.ZAxisLabels = []
	meshandsoln_placentone_vtk_Display.DataAxesGrid.UseCustomBounds = 0
	meshandsoln_placentone_vtk_Display.DataAxesGrid.CustomBounds = [0.0, 1.0, 0.0, 1.0, 0.0, 1.0]

	# init the 'PolarAxesRepresentation' selected for 'PolarAxes'
	meshandsoln_placentone_vtk_Display.PolarAxes.Visibility = 0
	meshandsoln_placentone_vtk_Display.PolarAxes.Translation = [0.0, 0.0, 0.0]
	meshandsoln_placentone_vtk_Display.PolarAxes.Scale = [1.0, 1.0, 1.0]
	meshandsoln_placentone_vtk_Display.PolarAxes.Orientation = [0.0, 0.0, 0.0]
	meshandsoln_placentone_vtk_Display.PolarAxes.EnableCustomBounds = [0, 0, 0]
	meshandsoln_placentone_vtk_Display.PolarAxes.CustomBounds = [0.0, 1.0, 0.0, 1.0, 0.0, 1.0]
	meshandsoln_placentone_vtk_Display.PolarAxes.EnableCustomRange = 0
	meshandsoln_placentone_vtk_Display.PolarAxes.CustomRange = [0.0, 1.0]
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarAxisVisibility = 1
	meshandsoln_placentone_vtk_Display.PolarAxes.RadialAxesVisibility = 1
	meshandsoln_placentone_vtk_Display.PolarAxes.DrawRadialGridlines = 1
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarArcsVisibility = 1
	meshandsoln_placentone_vtk_Display.PolarAxes.DrawPolarArcsGridlines = 1
	meshandsoln_placentone_vtk_Display.PolarAxes.NumberOfRadialAxes = 0
	meshandsoln_placentone_vtk_Display.PolarAxes.AutoSubdividePolarAxis = 1
	meshandsoln_placentone_vtk_Display.PolarAxes.NumberOfPolarAxis = 0
	meshandsoln_placentone_vtk_Display.PolarAxes.MinimumRadius = 0.0
	meshandsoln_placentone_vtk_Display.PolarAxes.MinimumAngle = 0.0
	meshandsoln_placentone_vtk_Display.PolarAxes.MaximumAngle = 90.0
	meshandsoln_placentone_vtk_Display.PolarAxes.RadialAxesOriginToPolarAxis = 1
	meshandsoln_placentone_vtk_Display.PolarAxes.Ratio = 1.0
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarAxisColor = [1.0, 1.0, 1.0]
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarArcsColor = [1.0, 1.0, 1.0]
	meshandsoln_placentone_vtk_Display.PolarAxes.LastRadialAxisColor = [1.0, 1.0, 1.0]
	meshandsoln_placentone_vtk_Display.PolarAxes.SecondaryPolarArcsColor = [1.0, 1.0, 1.0]
	meshandsoln_placentone_vtk_Display.PolarAxes.SecondaryRadialAxesColor = [1.0, 1.0, 1.0]
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarAxisTitleVisibility = 1
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarAxisTitle = 'Radial Distance'
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarAxisTitleLocation = 'Bottom'
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarLabelVisibility = 1
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarLabelFormat = '%-#6.3g'
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarLabelExponentLocation = 'Labels'
	meshandsoln_placentone_vtk_Display.PolarAxes.RadialLabelVisibility = 1
	meshandsoln_placentone_vtk_Display.PolarAxes.RadialLabelFormat = '%-#3.1f'
	meshandsoln_placentone_vtk_Display.PolarAxes.RadialLabelLocation = 'Bottom'
	meshandsoln_placentone_vtk_Display.PolarAxes.RadialUnitsVisibility = 1
	meshandsoln_placentone_vtk_Display.PolarAxes.ScreenSize = 10.0
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarAxisTitleOpacity = 1.0
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarAxisTitleFontFamily = 'Arial'
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarAxisTitleFontFile = ''
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarAxisTitleBold = 0
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarAxisTitleItalic = 0
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarAxisTitleShadow = 0
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarAxisTitleFontSize = 12
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarAxisLabelOpacity = 1.0
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarAxisLabelFontFamily = 'Arial'
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarAxisLabelFontFile = ''
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarAxisLabelBold = 0
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarAxisLabelItalic = 0
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarAxisLabelShadow = 0
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarAxisLabelFontSize = 12
	meshandsoln_placentone_vtk_Display.PolarAxes.LastRadialAxisTextOpacity = 1.0
	meshandsoln_placentone_vtk_Display.PolarAxes.LastRadialAxisTextFontFamily = 'Arial'
	meshandsoln_placentone_vtk_Display.PolarAxes.LastRadialAxisTextFontFile = ''
	meshandsoln_placentone_vtk_Display.PolarAxes.LastRadialAxisTextBold = 0
	meshandsoln_placentone_vtk_Display.PolarAxes.LastRadialAxisTextItalic = 0
	meshandsoln_placentone_vtk_Display.PolarAxes.LastRadialAxisTextShadow = 0
	meshandsoln_placentone_vtk_Display.PolarAxes.LastRadialAxisTextFontSize = 12
	meshandsoln_placentone_vtk_Display.PolarAxes.SecondaryRadialAxesTextOpacity = 1.0
	meshandsoln_placentone_vtk_Display.PolarAxes.SecondaryRadialAxesTextFontFamily = 'Arial'
	meshandsoln_placentone_vtk_Display.PolarAxes.SecondaryRadialAxesTextFontFile = ''
	meshandsoln_placentone_vtk_Display.PolarAxes.SecondaryRadialAxesTextBold = 0
	meshandsoln_placentone_vtk_Display.PolarAxes.SecondaryRadialAxesTextItalic = 0
	meshandsoln_placentone_vtk_Display.PolarAxes.SecondaryRadialAxesTextShadow = 0
	meshandsoln_placentone_vtk_Display.PolarAxes.SecondaryRadialAxesTextFontSize = 12
	meshandsoln_placentone_vtk_Display.PolarAxes.EnableDistanceLOD = 1
	meshandsoln_placentone_vtk_Display.PolarAxes.DistanceLODThreshold = 0.7
	meshandsoln_placentone_vtk_Display.PolarAxes.EnableViewAngleLOD = 1
	meshandsoln_placentone_vtk_Display.PolarAxes.ViewAngleLODThreshold = 0.7
	meshandsoln_placentone_vtk_Display.PolarAxes.SmallestVisiblePolarAngle = 0.5
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarTicksVisibility = 1
	meshandsoln_placentone_vtk_Display.PolarAxes.ArcTicksOriginToPolarAxis = 1
	meshandsoln_placentone_vtk_Display.PolarAxes.TickLocation = 'Both'
	meshandsoln_placentone_vtk_Display.PolarAxes.AxisTickVisibility = 1
	meshandsoln_placentone_vtk_Display.PolarAxes.AxisMinorTickVisibility = 0
	meshandsoln_placentone_vtk_Display.PolarAxes.ArcTickVisibility = 1
	meshandsoln_placentone_vtk_Display.PolarAxes.ArcMinorTickVisibility = 0
	meshandsoln_placentone_vtk_Display.PolarAxes.DeltaAngleMajor = 10.0
	meshandsoln_placentone_vtk_Display.PolarAxes.DeltaAngleMinor = 5.0
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarAxisMajorTickSize = 0.0
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarAxisTickRatioSize = 0.3
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarAxisMajorTickThickness = 1.0
	meshandsoln_placentone_vtk_Display.PolarAxes.PolarAxisTickRatioThickness = 0.5
	meshandsoln_placentone_vtk_Display.PolarAxes.LastRadialAxisMajorTickSize = 0.0
	meshandsoln_placentone_vtk_Display.PolarAxes.LastRadialAxisTickRatioSize = 0.3
	meshandsoln_placentone_vtk_Display.PolarAxes.LastRadialAxisMajorTickThickness = 1.0
	meshandsoln_placentone_vtk_Display.PolarAxes.LastRadialAxisTickRatioThickness = 0.5
	meshandsoln_placentone_vtk_Display.PolarAxes.ArcMajorTickSize = 0.0
	meshandsoln_placentone_vtk_Display.PolarAxes.ArcTickRatioSize = 0.3
	meshandsoln_placentone_vtk_Display.PolarAxes.ArcMajorTickThickness = 1.0
	meshandsoln_placentone_vtk_Display.PolarAxes.ArcTickRatioThickness = 0.5
	meshandsoln_placentone_vtk_Display.PolarAxes.Use2DMode = 0
	meshandsoln_placentone_vtk_Display.PolarAxes.UseLogAxis = 0

	# reset view to fit data
	renderView1.ResetCamera(False)

	if (plot_type == 'placentone'):
		#changing interaction mode based on data extents
		renderView1.InteractionMode = '2D'
		renderView1.CameraPosition = [0.5, 0.5, 10000.0]
		renderView1.CameraFocalPoint = [0.5, 0.5, 0.0]
	else:
		#changing interaction mode based on data extents
		renderView1.InteractionMode = '2D'
		renderView1.CameraPosition = [3.2324151951752396, 0.390660466849554, 12.594792705554676]
		renderView1.CameraFocalPoint = [3.2324151951752396, 0.390660466849554, 0.0]

	# get the material library
	materialLibrary1 = GetMaterialLibrary()

	# show color bar/color legend
	meshandsoln_placentone_vtk_Display.SetScalarBarVisibility(renderView1, True)

	# update the view to ensure updated data information
	renderView1.Update()

	# Rescale transfer function
	uLUT.RescaleTransferFunction(-0.27520780171538306, 0.2690516587864361)

	# create a new 'Calculator'
	calculator1 = Calculator(registrationName='Calculator1', Input=meshandsoln_placentone_vtk)
	calculator1.AttributeType = 'Point Data'
	calculator1.CoordinateResults = 0
	calculator1.ResultNormals = 0
	calculator1.ResultTCoords = 0
	calculator1.ResultArrayName = 'Result'
	calculator1.Function = ''
	calculator1.ReplaceInvalidResults = 1
	calculator1.ReplacementValue = 0.0
	calculator1.ResultArrayType = 'Double'

	# Properties modified on calculator1
	calculator1.Function = ''

	# show data in view
	calculator1Display = Show(calculator1, renderView1, 'UnstructuredGridRepresentation')

	# trace defaults for the display properties.
	calculator1Display.Selection = None
	calculator1Display.Representation = 'Surface'
	calculator1Display.ColorArrayName = ['POINTS', 'u']
	calculator1Display.LookupTable = uLUT
	calculator1Display.MapScalars = 1
	calculator1Display.MultiComponentsMapping = 0
	calculator1Display.InterpolateScalarsBeforeMapping = 1
	calculator1Display.Opacity = 1.0
	calculator1Display.PointSize = 2.0
	calculator1Display.LineWidth = 1.0
	calculator1Display.RenderLinesAsTubes = 0
	calculator1Display.RenderPointsAsSpheres = 0
	calculator1Display.Interpolation = 'Gouraud'
	calculator1Display.Specular = 0.0
	calculator1Display.SpecularColor = [1.0, 1.0, 1.0]
	calculator1Display.SpecularPower = 100.0
	calculator1Display.Luminosity = 0.0
	calculator1Display.Ambient = 0.0
	calculator1Display.Diffuse = 1.0
	calculator1Display.Roughness = 0.3
	calculator1Display.Metallic = 0.0
	calculator1Display.EdgeTint = [1.0, 1.0, 1.0]
	calculator1Display.Anisotropy = 0.0
	calculator1Display.AnisotropyRotation = 0.0
	calculator1Display.BaseIOR = 1.5
	calculator1Display.CoatStrength = 0.0
	calculator1Display.CoatIOR = 2.0
	calculator1Display.CoatRoughness = 0.0
	calculator1Display.CoatColor = [1.0, 1.0, 1.0]
	calculator1Display.SelectTCoordArray = 'None'
	calculator1Display.SelectNormalArray = 'None'
	calculator1Display.SelectTangentArray = 'None'
	calculator1Display.Texture = None
	calculator1Display.RepeatTextures = 1
	calculator1Display.InterpolateTextures = 0
	calculator1Display.SeamlessU = 0
	calculator1Display.SeamlessV = 0
	calculator1Display.UseMipmapTextures = 0
	calculator1Display.ShowTexturesOnBackface = 1
	calculator1Display.BaseColorTexture = None
	calculator1Display.NormalTexture = None
	calculator1Display.NormalScale = 1.0
	calculator1Display.CoatNormalTexture = None
	calculator1Display.CoatNormalScale = 1.0
	calculator1Display.MaterialTexture = None
	calculator1Display.OcclusionStrength = 1.0
	calculator1Display.AnisotropyTexture = None
	calculator1Display.EmissiveTexture = None
	calculator1Display.EmissiveFactor = [1.0, 1.0, 1.0]
	calculator1Display.FlipTextures = 0
	calculator1Display.BackfaceRepresentation = 'Follow Frontface'
	calculator1Display.BackfaceAmbientColor = [1.0, 1.0, 1.0]
	calculator1Display.BackfaceOpacity = 1.0
	calculator1Display.Position = [0.0, 0.0, 0.0]
	calculator1Display.Scale = [1.0, 1.0, 1.0]
	calculator1Display.Orientation = [0.0, 0.0, 0.0]
	calculator1Display.Origin = [0.0, 0.0, 0.0]
	calculator1Display.CoordinateShiftScaleMethod = 'Always Auto Shift Scale'
	calculator1Display.Pickable = 1
	calculator1Display.Triangulate = 0
	calculator1Display.UseShaderReplacements = 0
	calculator1Display.ShaderReplacements = ''
	calculator1Display.NonlinearSubdivisionLevel = 1
	calculator1Display.UseDataPartitions = 0
	calculator1Display.OSPRayUseScaleArray = 'All Approximate'
	calculator1Display.OSPRayScaleArray = 'u'
	calculator1Display.OSPRayScaleFunction = 'PiecewiseFunction'
	calculator1Display.OSPRayMaterial = 'None'
	calculator1Display.BlockSelectors = ['/']
	calculator1Display.BlockColors = []
	calculator1Display.BlockOpacities = []
	calculator1Display.Orient = 0
	calculator1Display.OrientationMode = 'Direction'
	calculator1Display.SelectOrientationVectors = 'None'
	calculator1Display.Scaling = 0
	calculator1Display.ScaleMode = 'No Data Scaling Off'
	calculator1Display.ScaleFactor = 0.10500000007450581
	calculator1Display.SelectScaleArray = 'u'
	calculator1Display.GlyphType = 'Arrow'
	calculator1Display.UseGlyphTable = 0
	calculator1Display.GlyphTableIndexArray = 'u'
	calculator1Display.UseCompositeGlyphTable = 0
	calculator1Display.UseGlyphCullingAndLOD = 0
	calculator1Display.LODValues = []
	calculator1Display.ColorByLODIndex = 0
	calculator1Display.GaussianRadius = 0.00525000000372529
	calculator1Display.ShaderPreset = 'Sphere'
	calculator1Display.CustomTriangleScale = 3
	calculator1Display.CustomShader = """ // This custom shader code define a gaussian blur
	// Please take a look into vtkSMPointGaussianRepresentation.cxx
	// for other custom shader examples
	//VTK::Color::Impl
		float dist2 = dot(offsetVCVSOutput.xy,offsetVCVSOutput.xy);
		float gaussian = exp(-0.5*dist2);
		opacity = opacity*gaussian;
	"""
	calculator1Display.Emissive = 0
	calculator1Display.ScaleByArray = 0
	calculator1Display.SetScaleArray = ['POINTS', 'u']
	calculator1Display.ScaleArrayComponent = ''
	calculator1Display.UseScaleFunction = 1
	calculator1Display.ScaleTransferFunction = 'PiecewiseFunction'
	calculator1Display.OpacityByArray = 0
	calculator1Display.OpacityArray = ['POINTS', 'u']
	calculator1Display.OpacityArrayComponent = ''
	calculator1Display.OpacityTransferFunction = 'PiecewiseFunction'
	calculator1Display.DataAxesGrid = 'GridAxesRepresentation'
	calculator1Display.SelectionCellLabelBold = 0
	calculator1Display.SelectionCellLabelColor = [0.0, 1.0, 0.0]
	calculator1Display.SelectionCellLabelFontFamily = 'Arial'
	calculator1Display.SelectionCellLabelFontFile = ''
	calculator1Display.SelectionCellLabelFontSize = 18
	calculator1Display.SelectionCellLabelItalic = 0
	calculator1Display.SelectionCellLabelJustification = 'Left'
	calculator1Display.SelectionCellLabelOpacity = 1.0
	calculator1Display.SelectionCellLabelShadow = 0
	calculator1Display.SelectionPointLabelBold = 0
	calculator1Display.SelectionPointLabelColor = [1.0, 1.0, 0.0]
	calculator1Display.SelectionPointLabelFontFamily = 'Arial'
	calculator1Display.SelectionPointLabelFontFile = ''
	calculator1Display.SelectionPointLabelFontSize = 18
	calculator1Display.SelectionPointLabelItalic = 0
	calculator1Display.SelectionPointLabelJustification = 'Left'
	calculator1Display.SelectionPointLabelOpacity = 1.0
	calculator1Display.SelectionPointLabelShadow = 0
	calculator1Display.PolarAxes = 'PolarAxesRepresentation'
	calculator1Display.ScalarOpacityFunction = uPWF
	calculator1Display.ScalarOpacityUnitDistance = 0.14212151558048683
	calculator1Display.UseSeparateOpacityArray = 0
	calculator1Display.OpacityArrayName = ['POINTS', 'u']
	calculator1Display.OpacityComponent = ''
	calculator1Display.SelectMapper = 'Projected tetra'
	calculator1Display.SamplingDimensions = [128, 128, 128]
	calculator1Display.UseFloatingPointFrameBuffer = 1

	# init the 'PiecewiseFunction' selected for 'OSPRayScaleFunction'
	calculator1Display.OSPRayScaleFunction.Points = [10.506034069460773, 0.0, 0.5, 0.0, 3909896.977314434, 1.0, 0.5, 0.0]
	calculator1Display.OSPRayScaleFunction.UseLogScale = 0

	# init the 'Arrow' selected for 'GlyphType'
	calculator1Display.GlyphType.TipResolution = 6
	calculator1Display.GlyphType.TipRadius = 0.1
	calculator1Display.GlyphType.TipLength = 0.35
	calculator1Display.GlyphType.ShaftResolution = 6
	calculator1Display.GlyphType.ShaftRadius = 0.03
	calculator1Display.GlyphType.Invert = 0

	# init the 'PiecewiseFunction' selected for 'ScaleTransferFunction'
	calculator1Display.ScaleTransferFunction.Points = [-0.27520780171538306, 0.0, 0.5, 0.0, 0.2690516587864361, 1.0, 0.5, 0.0]
	calculator1Display.ScaleTransferFunction.UseLogScale = 0

	# init the 'PiecewiseFunction' selected for 'OpacityTransferFunction'
	calculator1Display.OpacityTransferFunction.Points = [-0.27520780171538306, 0.0, 0.5, 0.0, 0.2690516587864361, 1.0, 0.5, 0.0]
	calculator1Display.OpacityTransferFunction.UseLogScale = 0

	# init the 'GridAxesRepresentation' selected for 'DataAxesGrid'
	calculator1Display.DataAxesGrid.XTitle = 'X Axis'
	calculator1Display.DataAxesGrid.YTitle = 'Y Axis'
	calculator1Display.DataAxesGrid.ZTitle = 'Z Axis'
	calculator1Display.DataAxesGrid.XTitleFontFamily = 'Arial'
	calculator1Display.DataAxesGrid.XTitleFontFile = ''
	calculator1Display.DataAxesGrid.XTitleBold = 0
	calculator1Display.DataAxesGrid.XTitleItalic = 0
	calculator1Display.DataAxesGrid.XTitleFontSize = 12
	calculator1Display.DataAxesGrid.XTitleShadow = 0
	calculator1Display.DataAxesGrid.XTitleOpacity = 1.0
	calculator1Display.DataAxesGrid.YTitleFontFamily = 'Arial'
	calculator1Display.DataAxesGrid.YTitleFontFile = ''
	calculator1Display.DataAxesGrid.YTitleBold = 0
	calculator1Display.DataAxesGrid.YTitleItalic = 0
	calculator1Display.DataAxesGrid.YTitleFontSize = 12
	calculator1Display.DataAxesGrid.YTitleShadow = 0
	calculator1Display.DataAxesGrid.YTitleOpacity = 1.0
	calculator1Display.DataAxesGrid.ZTitleFontFamily = 'Arial'
	calculator1Display.DataAxesGrid.ZTitleFontFile = ''
	calculator1Display.DataAxesGrid.ZTitleBold = 0
	calculator1Display.DataAxesGrid.ZTitleItalic = 0
	calculator1Display.DataAxesGrid.ZTitleFontSize = 12
	calculator1Display.DataAxesGrid.ZTitleShadow = 0
	calculator1Display.DataAxesGrid.ZTitleOpacity = 1.0
	calculator1Display.DataAxesGrid.FacesToRender = 63
	calculator1Display.DataAxesGrid.CullBackface = 0
	calculator1Display.DataAxesGrid.CullFrontface = 1
	calculator1Display.DataAxesGrid.ShowGrid = 0
	calculator1Display.DataAxesGrid.ShowEdges = 1
	calculator1Display.DataAxesGrid.ShowTicks = 1
	calculator1Display.DataAxesGrid.LabelUniqueEdgesOnly = 1
	calculator1Display.DataAxesGrid.AxesToLabel = 63
	calculator1Display.DataAxesGrid.XLabelFontFamily = 'Arial'
	calculator1Display.DataAxesGrid.XLabelFontFile = ''
	calculator1Display.DataAxesGrid.XLabelBold = 0
	calculator1Display.DataAxesGrid.XLabelItalic = 0
	calculator1Display.DataAxesGrid.XLabelFontSize = 12
	calculator1Display.DataAxesGrid.XLabelShadow = 0
	calculator1Display.DataAxesGrid.XLabelOpacity = 1.0
	calculator1Display.DataAxesGrid.YLabelFontFamily = 'Arial'
	calculator1Display.DataAxesGrid.YLabelFontFile = ''
	calculator1Display.DataAxesGrid.YLabelBold = 0
	calculator1Display.DataAxesGrid.YLabelItalic = 0
	calculator1Display.DataAxesGrid.YLabelFontSize = 12
	calculator1Display.DataAxesGrid.YLabelShadow = 0
	calculator1Display.DataAxesGrid.YLabelOpacity = 1.0
	calculator1Display.DataAxesGrid.ZLabelFontFamily = 'Arial'
	calculator1Display.DataAxesGrid.ZLabelFontFile = ''
	calculator1Display.DataAxesGrid.ZLabelBold = 0
	calculator1Display.DataAxesGrid.ZLabelItalic = 0
	calculator1Display.DataAxesGrid.ZLabelFontSize = 12
	calculator1Display.DataAxesGrid.ZLabelShadow = 0
	calculator1Display.DataAxesGrid.ZLabelOpacity = 1.0
	calculator1Display.DataAxesGrid.XAxisNotation = 'Mixed'
	calculator1Display.DataAxesGrid.XAxisPrecision = 2
	calculator1Display.DataAxesGrid.XAxisUseCustomLabels = 0
	calculator1Display.DataAxesGrid.XAxisLabels = []
	calculator1Display.DataAxesGrid.YAxisNotation = 'Mixed'
	calculator1Display.DataAxesGrid.YAxisPrecision = 2
	calculator1Display.DataAxesGrid.YAxisUseCustomLabels = 0
	calculator1Display.DataAxesGrid.YAxisLabels = []
	calculator1Display.DataAxesGrid.ZAxisNotation = 'Mixed'
	calculator1Display.DataAxesGrid.ZAxisPrecision = 2
	calculator1Display.DataAxesGrid.ZAxisUseCustomLabels = 0
	calculator1Display.DataAxesGrid.ZAxisLabels = []
	calculator1Display.DataAxesGrid.UseCustomBounds = 0
	calculator1Display.DataAxesGrid.CustomBounds = [0.0, 1.0, 0.0, 1.0, 0.0, 1.0]

	# init the 'PolarAxesRepresentation' selected for 'PolarAxes'
	# calculator1Display.PolarAxes.Visibility = 0
	# calculator1Display.PolarAxes.Translation = [0.0, 0.0, 0.0]
	# calculator1Display.PolarAxes.Scale = [1.0, 1.0, 1.0]
	# calculator1Display.PolarAxes.Orientation = [0.0, 0.0, 0.0]
	# calculator1Display.PolarAxes.EnableCustomBounds = [0, 0, 0]
	# calculator1Display.PolarAxes.CustomBounds = [0.0, 1.0, 0.0, 1.0, 0.0, 1.0]
	# calculator1Display.PolarAxes.EnableCustomRange = 0
	# calculator1Display.PolarAxes.CustomRange = [0.0, 1.0]
	# calculator1Display.PolarAxes.PolarAxisVisibility = 1
	# calculator1Display.PolarAxes.RadialAxesVisibility = 1
	# calculator1Display.PolarAxes.DrawRadialGridlines = 1
	# calculator1Display.PolarAxes.PolarArcsVisibility = 1
	# calculator1Display.PolarAxes.DrawPolarArcsGridlines = 1
	# calculator1Display.PolarAxes.NumberOfRadialAxes = 0
	# calculator1Display.PolarAxes.AutoSubdividePolarAxis = 1
	# calculator1Display.PolarAxes.NumberOfPolarAxis = 0
	# calculator1Display.PolarAxes.MinimumRadius = 0.0
	# calculator1Display.PolarAxes.MinimumAngle = 0.0
	# calculator1Display.PolarAxes.MaximumAngle = 90.0
	# calculator1Display.PolarAxes.RadialAxesOriginToPolarAxis = 1
	# calculator1Display.PolarAxes.Ratio = 1.0
	# calculator1Display.PolarAxes.PolarAxisColor = [1.0, 1.0, 1.0]
	# calculator1Display.PolarAxes.PolarArcsColor = [1.0, 1.0, 1.0]
	# calculator1Display.PolarAxes.LastRadialAxisColor = [1.0, 1.0, 1.0]
	# calculator1Display.PolarAxes.SecondaryPolarArcsColor = [1.0, 1.0, 1.0]
	# calculator1Display.PolarAxes.SecondaryRadialAxesColor = [1.0, 1.0, 1.0]
	# calculator1Display.PolarAxes.PolarAxisTitleVisibility = 1
	# calculator1Display.PolarAxes.PolarAxisTitle = 'Radial Distance'
	# calculator1Display.PolarAxes.PolarAxisTitleLocation = 'Bottom'
	# calculator1Display.PolarAxes.PolarLabelVisibility = 1
	# calculator1Display.PolarAxes.PolarLabelFormat = '%-#6.3g'
	# calculator1Display.PolarAxes.PolarLabelExponentLocation = 'Labels'
	# calculator1Display.PolarAxes.RadialLabelVisibility = 1
	# calculator1Display.PolarAxes.RadialLabelFormat = '%-#3.1f'
	# calculator1Display.PolarAxes.RadialLabelLocation = 'Bottom'
	# calculator1Display.PolarAxes.RadialUnitsVisibility = 1
	# calculator1Display.PolarAxes.ScreenSize = 10.0
	# calculator1Display.PolarAxes.PolarAxisTitleOpacity = 1.0
	# calculator1Display.PolarAxes.PolarAxisTitleFontFamily = 'Arial'
	# calculator1Display.PolarAxes.PolarAxisTitleFontFile = ''
	# calculator1Display.PolarAxes.PolarAxisTitleBold = 0
	# calculator1Display.PolarAxes.PolarAxisTitleItalic = 0
	# calculator1Display.PolarAxes.PolarAxisTitleShadow = 0
	# calculator1Display.PolarAxes.PolarAxisTitleFontSize = 12
	# calculator1Display.PolarAxes.PolarAxisLabelOpacity = 1.0
	# calculator1Display.PolarAxes.PolarAxisLabelFontFamily = 'Arial'
	# calculator1Display.PolarAxes.PolarAxisLabelFontFile = ''
	# calculator1Display.PolarAxes.PolarAxisLabelBold = 0
	# calculator1Display.PolarAxes.PolarAxisLabelItalic = 0
	# calculator1Display.PolarAxes.PolarAxisLabelShadow = 0
	# calculator1Display.PolarAxes.PolarAxisLabelFontSize = 12
	# calculator1Display.PolarAxes.LastRadialAxisTextOpacity = 1.0
	# calculator1Display.PolarAxes.LastRadialAxisTextFontFamily = 'Arial'
	# calculator1Display.PolarAxes.LastRadialAxisTextFontFile = ''
	# calculator1Display.PolarAxes.LastRadialAxisTextBold = 0
	# calculator1Display.PolarAxes.LastRadialAxisTextItalic = 0
	# calculator1Display.PolarAxes.LastRadialAxisTextShadow = 0
	# calculator1Display.PolarAxes.LastRadialAxisTextFontSize = 12
	# calculator1Display.PolarAxes.SecondaryRadialAxesTextOpacity = 1.0
	# calculator1Display.PolarAxes.SecondaryRadialAxesTextFontFamily = 'Arial'
	# calculator1Display.PolarAxes.SecondaryRadialAxesTextFontFile = ''
	# calculator1Display.PolarAxes.SecondaryRadialAxesTextBold = 0
	# calculator1Display.PolarAxes.SecondaryRadialAxesTextItalic = 0
	# calculator1Display.PolarAxes.SecondaryRadialAxesTextShadow = 0
	# calculator1Display.PolarAxes.SecondaryRadialAxesTextFontSize = 12
	# calculator1Display.PolarAxes.EnableDistanceLOD = 1
	# calculator1Display.PolarAxes.DistanceLODThreshold = 0.7
	# calculator1Display.PolarAxes.EnableViewAngleLOD = 1
	# calculator1Display.PolarAxes.ViewAngleLODThreshold = 0.7
	# calculator1Display.PolarAxes.SmallestVisiblePolarAngle = 0.5
	# calculator1Display.PolarAxes.PolarTicksVisibility = 1
	# calculator1Display.PolarAxes.ArcTicksOriginToPolarAxis = 1
	# calculator1Display.PolarAxes.TickLocation = 'Both'
	# calculator1Display.PolarAxes.AxisTickVisibility = 1
	# calculator1Display.PolarAxes.AxisMinorTickVisibility = 0
	# calculator1Display.PolarAxes.ArcTickVisibility = 1
	# calculator1Display.PolarAxes.ArcMinorTickVisibility = 0
	# calculator1Display.PolarAxes.DeltaAngleMajor = 10.0
	# calculator1Display.PolarAxes.DeltaAngleMinor = 5.0
	# calculator1Display.PolarAxes.PolarAxisMajorTickSize = 0.0
	# calculator1Display.PolarAxes.PolarAxisTickRatioSize = 0.3
	# calculator1Display.PolarAxes.PolarAxisMajorTickThickness = 1.0
	# calculator1Display.PolarAxes.PolarAxisTickRatioThickness = 0.5
	# calculator1Display.PolarAxes.LastRadialAxisMajorTickSize = 0.0
	# calculator1Display.PolarAxes.LastRadialAxisTickRatioSize = 0.3
	# calculator1Display.PolarAxes.LastRadialAxisMajorTickThickness = 1.0
	# calculator1Display.PolarAxes.LastRadialAxisTickRatioThickness = 0.5
	# calculator1Display.PolarAxes.ArcMajorTickSize = 0.0
	# calculator1Display.PolarAxes.ArcTickRatioSize = 0.3
	# calculator1Display.PolarAxes.ArcMajorTickThickness = 1.0
	# calculator1Display.PolarAxes.ArcTickRatioThickness = 0.5
	# calculator1Display.PolarAxes.Use2DMode = 0
	# calculator1Display.PolarAxes.UseLogAxis = 0

	# hide data in view
	Hide(meshandsoln_placentone_vtk, renderView1)

	# show color bar/color legend
	calculator1Display.SetScalarBarVisibility(renderView1, True)

	# update the view to ensure updated data information
	renderView1.Update()

	# Rescale transfer function
	uLUT.RescaleTransferFunction(-0.27520780171538306, 0.2690516587864361)

	# Properties modified on calculator1
	calculator1.ResultArrayName = 'Velocity'
	calculator1.Function = 'iHat*u+jHat*v'

	# update the view to ensure updated data information
	renderView1.Update()

	# Rescale transfer function
	uLUT.RescaleTransferFunction(-0.27520780171538306, 0.2690516587864361)

	# set scalar coloring
	ColorBy(calculator1Display, ('POINTS', 'Velocity', 'Magnitude'))

	# Hide the scalar bar for this color map if no visible data is colored by it.
	HideScalarBarIfNotNeeded(uLUT, renderView1)

	# rescale color and/or opacity maps used to include current data range
	calculator1Display.RescaleTransferFunctionToDataRange(True, False)

	# show color bar/color legend
	calculator1Display.SetScalarBarVisibility(renderView1, True)

	# get color transfer function/color map for 'Velocity'
	velocityLUT = GetColorTransferFunction('Velocity')

	velocityLUT.ColorSpace = 'RGB'
	velocityLUT.UseBelowRangeColor = 0
	velocityLUT.BelowRangeColor = [0.5, 0.5, 0.5]
	velocityLUT.UseAboveRangeColor = 0
	velocityLUT.AboveRangeColor = [0.5, 0.5, 0.5]

	# get opacity transfer function/opacity map for 'Velocity'
	velocityPWF = GetOpacityTransferFunction('Velocity')

	# Hide orientation axes
	renderView1.OrientationAxesVisibility = 0

	# get color legend/bar for velocityLUT in view renderView1
	velocityLUTColorBar = GetScalarBar(velocityLUT, renderView1)

	if (plot_type == 'placentone'):
		# change scalar bar placement
		velocityLUTColorBar.Orientation = 'Horizontal'
		velocityLUTColorBar.WindowLocation = 'Any Location'
		velocityLUTColorBar.Position = [0.32587258454106277, 0.12119138149556408]
		velocityLUTColorBar.ScalarBarLength = 0.3299999999999999
	else:
		# change scalar bar placement
		velocityLUTColorBar.Orientation = 'Horizontal'
		velocityLUTColorBar.WindowLocation = 'Any Location'
		velocityLUTColorBar.Position = [0.3244021739130435, 0.08135135135135152]
		velocityLUTColorBar.ScalarBarLength = 0.32999999999999907

	# change scalar bar placement
	velocityLUTColorBar.Position = [0.2050996376811594, 0.12119138149556408]
	velocityLUTColorBar.ScalarBarLength = 0.45077294685990327

	# change scalar bar placement
	velocityLUTColorBar.ScalarBarLength = 0.5884541062801927

	if (log_coloring == 1):
		# Rescale transfer function
		velocityLUT.RescaleTransferFunction(1e-05, 1.0)

		# Rescale transfer function
		velocityPWF.RescaleTransferFunction(1e-05, 1.0)

		# convert to log space
		velocityLUT.MapControlPointsToLogSpace()

		# Properties modified on velocityLUT
		velocityLUT.UseLogScale = 1

		# Rescale transfer function
		velocityLUT.RescaleTransferFunction(1e-05, 1.0)

		# Rescale transfer function
		velocityPWF.RescaleTransferFunction(1e-05, 1.0)
	else:
		# Rescale transfer function
		velocityLUT.RescaleTransferFunction(1e-05, 1.0)

		# Rescale transfer function
		velocityPWF.RescaleTransferFunction(1e-05, 1.0)

		# convert from log to linear
		velocityLUT.MapControlPointsToLinearSpace()

		# Properties modified on velocityLUT
		velocityLUT.UseLogScale = 0

		# Rescale transfer function
		velocityLUT.RescaleTransferFunction(0.0, 1.0)

		# Rescale transfer function
		velocityPWF.RescaleTransferFunction(0.0, 1.0)

	# Properties modified on velocityLUT
	velocityLUT.Discretize = 0

	# change scalar bar placement
	velocityLUTColorBar.Position = [0.2014764492753623, 0.09584283903675545]

	# Properties modified on velocityLUTColorBar
	velocityLUTColorBar.TitleFontSize = colorbar_fontsize
	velocityLUTColorBar.LabelFontSize = colorbar_fontsize

	# Apply a preset using its name. Note this may not work as expected when presets have duplicate names.
	velocityLUT.ApplyPreset('Jet', True)

	# get layout
	layout1 = GetLayout()

	if (plot_type == 'placentone'):
		# layout/tab size in pixels
		layout1.SetSize(1656, 1578)
	else:
		# layout/tab size in pixels
		layout1.SetSize(2300, 740)

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

	if (log_coloring == 1):
		color_type = 'log'
	else:
		color_type = 'linear'

	if (plot_streamlines == 1):
		# create a new 'Evenly Spaced Streamlines 2D'
		evenlySpacedStreamlines2D1 = EvenlySpacedStreamlines2D(registrationName='EvenlySpacedStreamlines2D1', Input=calculator1)
		evenlySpacedStreamlines2D1.Vectors = ['POINTS', 'Velocity']

		if (plot_type == 'placentone'):
			evenlySpacedStreamlines2D1.StartPosition = [0.5, 0.5, 0.0]
		else:
			evenlySpacedStreamlines2D1.StartPosition = [3.0, 0.9, 0.0]

		# show data in view
		evenlySpacedStreamlines2D1Display = Show(evenlySpacedStreamlines2D1, renderView1, 'GeometryRepresentation')

		# turn off scalar coloring
		ColorBy(evenlySpacedStreamlines2D1Display, ['POINTS', ''])

		# Properties modified on evenlySpacedStreamlines2D1Display
		evenlySpacedStreamlines2D1Display.LineWidth = 2.0

		# Properties modified on evenlySpacedStreamlines2D1
		evenlySpacedStreamlines2D1.InitialStepLength = 0.1
		evenlySpacedStreamlines2D1.ClosedLoopMaximumDistance = 0.01
		evenlySpacedStreamlines2D1.MaximumSteps = 20000
		#evenlySpacedStreamlines2D1.SeparatingDistanceRatio = 0.4
		evenlySpacedStreamlines2D1.SeparatingDistanceRatio = 0.8
		#evenlySpacedStreamlines2D1.SeparatingDistance = 4.0
		evenlySpacedStreamlines2D1.SeparatingDistance = 1.1

		if (plot_glyphs == 1):
			# create a new 'Glyph'
			glyph1 = Glyph(registrationName='Glyph1', Input=evenlySpacedStreamlines2D1,
					GlyphType='Arrow')
			glyph1.OrientationArray = ['POINTS', 'Normals']
			glyph1.ScaleArray = ['POINTS', 'u']
			glyph1.ScaleFactor = 0.09765807241201402
			glyph1.GlyphTransform = 'Transform2'

			# Properties modified on glyph1
			glyph1.GlyphType = '2D Glyph'
			glyph1.GlyphType.GlyphType = 'EdgeArrow'

			# Properties modified on glyph1
			glyph1.GlyphType

			# show data in view
			glyph1Display = Show(glyph1, renderView1, 'GeometryRepresentation')

			# Properties modified on glyph1
			glyph1.OrientationArray = ['POINTS', 'Velocity']
			glyph1.ScaleArray = ['POINTS', 'No scale array']

			# Properties modified on glyph1
			glyph1.ScaleFactor = 0.05

			# Properties modified on glyph1
			glyph1.GlyphMode = 'Every Nth Point'
			glyph1.Stride = 150

			# Properties modified on glyph1Display
			glyph1Display.LineWidth = 2.0

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

	if (no_files == 1):
		if (plot_type == 'placentone'):
			SaveScreenshot(base_directory+'images/'+filename_no_ext_output+'_velocity-'+color_type+'.png', renderView1, ImageResolution=[3312, 3156],
					FontScaling='Scale fonts proportionally',
					OverrideColorPalette='',
					StereoMode='No change',
					TransparentBackground=1,
					# PNG options
					CompressionLevel='5',
					MetaData=['Application', 'ParaView'])
		else:
			# save animation
			SaveScreenshot(base_directory+'images/'+filename_no_ext_output+'_velocity-'+color_type+'.png', renderView1, ImageResolution=[4600, 1480],
				FontScaling='Scale fonts proportionally',
				OverrideColorPalette='',
				StereoMode='No change',
				TransparentBackground=1,
				# PNG options
				CompressionLevel='5',
				MetaData=['Application', 'ParaView'])
	else:
		if (plot_type == 'placentone'):
			SaveAnimation(base_directory+'images/'+filename_no_ext_output+'_velocity-'+color_type+'.png', renderView1, ImageResolution=[3312, 3156],
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
			SaveAnimation(base_directory+'images/'+filename_no_ext_output+'_velocity-'+color_type+'.png', renderView1, ImageResolution=[4600, 1480],
				FrameWindow=[0, no_files],
				FontScaling='Scale fonts proportionally',
				OverrideColorPalette='',
				StereoMode='No change',
				TransparentBackground=0,
				# PNG options
				CompressionLevel='5',
				MetaData=['Application', 'ParaView'],
				SuffixFormat='.%04d')

	#================================================================
	# addendum: following script captures some of the application
	# state to faithfully reproduce the visualization during playback
	#================================================================

	#--------------------------------
	# saving layout sizes for layouts

	# layout/tab size in pixels
	layout1.SetSize(1656, 1578)

	#-----------------------------------
	# saving camera placements for views

	# current camera placement for renderView1
	renderView1.InteractionMode = '2D'
	renderView1.CameraPosition = [0.5165399239605267, 0.3537072239169405, 10000.0]
	renderView1.CameraFocalPoint = [0.5165399239605267, 0.3537072239169405, 0.0]
	renderView1.CameraParallelScale = 0.7250000002697624

	#--------------------------------------------
	# uncomment the following to render all views
	# RenderAllViews()
	# alternatively, if you want to write images, you can use SaveScreenshot(...).

	Disconnect()

import sys

no_arguments = len(sys.argv)

if(no_arguments != 12):
	print("Incorrect number of arguments.")
	exit(1)
if (no_arguments == 12):
	filename_no_ext_regex  = sys.argv[1]
	filename_no_ext_output = sys.argv[2]
	base_directory         = sys.argv[3]
	log_coloring           = int(sys.argv[4])
	colorbar_fontsize      = int(sys.argv[5])
	plot_streamlines       = int(sys.argv[6])
	plot_glyphs            = int(sys.argv[7])
	plot_type              = sys.argv[8]
	time_fontsize          = int(sys.argv[9])
	time_shift             = float(sys.argv[10])
	time_scale             = float(sys.argv[11])

plot(
	filename_no_ext_regex,
	filename_no_ext_output,
	base_directory,
	log_coloring,
	colorbar_fontsize,
	plot_streamlines,
	plot_glyphs,
	plot_type,
	time_fontsize,
	time_shift,
	time_scale
)