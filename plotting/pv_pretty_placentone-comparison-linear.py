filename = 'meshandsoln_dg_velocity_placentone_1_12.vtk'

# trace generated using paraview version 5.11.1
#import paraview
#paraview.compatibility.major = 5
#paraview.compatibility.minor = 11

#### import the simple module from the paraview
from paraview.simple import *
#### disable automatic camera reset on 'Show'
paraview.simple._DisableFirstRenderCameraReset()

# create a new 'Legacy VTK Reader'
meshandsoln_dg_velocity_placentone_vtk = LegacyVTKReader(registrationName=filename, FileNames=['/home/pmyambl/Monolith-4/output/' + filename])

# get active view
renderView1 = GetActiveViewOrCreate('RenderView')

# show data in view
meshandsoln_dg_velocity_placentone_vtkDisplay = Show(meshandsoln_dg_velocity_placentone_vtk, renderView1, 'UnstructuredGridRepresentation')

# get 2D transfer function for 'u'
uTF2D = GetTransferFunction2D('u')
uTF2D.AutomaticRescaleRangeMode = "Grow and update on 'Apply'"
uTF2D.Boxes = []
uTF2D.ScalarRangeInitialized = 0
uTF2D.Range = [0.0, 1.0, 0.0, 1.0]
uTF2D.OutputDimensions = [10, 10]

# get color transfer function/color map for 'u'
uLUT = GetColorTransferFunction('u')
uLUT.AutomaticRescaleRangeMode = "Grow and update on 'Apply'"
uLUT.InterpretValuesAsCategories = 0
uLUT.AnnotationsInitialized = 0
uLUT.ShowCategoricalColorsinDataRangeOnly = 0
uLUT.RescaleOnVisibilityChange = 0
uLUT.EnableOpacityMapping = 0
uLUT.TransferFunction2D = uTF2D
uLUT.Use2DTransferFunction = 0
uLUT.RGBPoints = [-0.07805780076612219, 0.231373, 0.298039, 0.752941, 1.1407698296689306e-06, 0.865003, 0.865003, 0.865003, 0.07806008230578153, 0.705882, 0.0156863, 0.14902]
uLUT.UseLogScale = 0
uLUT.UseOpacityControlPointsFreehandDrawing = 0
uLUT.ShowDataHistogram = 0
uLUT.AutomaticDataHistogramComputation = 0
uLUT.DataHistogramNumberOfBins = 10
uLUT.ColorSpace = 'Diverging'
uLUT.UseBelowRangeColor = 0
uLUT.BelowRangeColor = [0.0, 0.0, 0.0]
uLUT.UseAboveRangeColor = 0
uLUT.AboveRangeColor = [0.5, 0.5, 0.5]
uLUT.NanColor = [1.0, 1.0, 0.0]
uLUT.NanOpacity = 1.0
uLUT.Discretize = 1
uLUT.NumberOfTableValues = 256
uLUT.ScalarRangeInitialized = 1.0
uLUT.HSVWrap = 0
uLUT.VectorComponent = 0
uLUT.VectorMode = 'Magnitude'
uLUT.AllowDuplicateScalars = 1
uLUT.Annotations = []
uLUT.ActiveAnnotatedValues = []
uLUT.IndexedColors = []
uLUT.IndexedOpacities = []

# get opacity transfer function/opacity map for 'u'
uPWF = GetOpacityTransferFunction('u')
uPWF.Points = [-0.07805780076612219, 0.0, 0.5, 0.0, 0.07806008230578153, 1.0, 0.5, 0.0]
uPWF.AllowDuplicateScalars = 1
uPWF.UseLogScale = 0
uPWF.ScalarRangeInitialized = 1

# trace defaults for the display properties.
meshandsoln_dg_velocity_placentone_vtkDisplay.Selection = None
meshandsoln_dg_velocity_placentone_vtkDisplay.Representation = 'Surface'
meshandsoln_dg_velocity_placentone_vtkDisplay.ColorArrayName = ['POINTS', 'u']
meshandsoln_dg_velocity_placentone_vtkDisplay.LookupTable = uLUT
meshandsoln_dg_velocity_placentone_vtkDisplay.MapScalars = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.MultiComponentsMapping = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.InterpolateScalarsBeforeMapping = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.Opacity = 1.0
meshandsoln_dg_velocity_placentone_vtkDisplay.PointSize = 2.0
meshandsoln_dg_velocity_placentone_vtkDisplay.LineWidth = 1.0
meshandsoln_dg_velocity_placentone_vtkDisplay.RenderLinesAsTubes = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.RenderPointsAsSpheres = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.Interpolation = 'Gouraud'
meshandsoln_dg_velocity_placentone_vtkDisplay.Specular = 0.0
meshandsoln_dg_velocity_placentone_vtkDisplay.SpecularColor = [1.0, 1.0, 1.0]
meshandsoln_dg_velocity_placentone_vtkDisplay.SpecularPower = 100.0
meshandsoln_dg_velocity_placentone_vtkDisplay.Luminosity = 0.0
meshandsoln_dg_velocity_placentone_vtkDisplay.Ambient = 0.0
meshandsoln_dg_velocity_placentone_vtkDisplay.Diffuse = 1.0
meshandsoln_dg_velocity_placentone_vtkDisplay.Roughness = 0.3
meshandsoln_dg_velocity_placentone_vtkDisplay.Metallic = 0.0
meshandsoln_dg_velocity_placentone_vtkDisplay.EdgeTint = [1.0, 1.0, 1.0]
meshandsoln_dg_velocity_placentone_vtkDisplay.Anisotropy = 0.0
meshandsoln_dg_velocity_placentone_vtkDisplay.AnisotropyRotation = 0.0
meshandsoln_dg_velocity_placentone_vtkDisplay.BaseIOR = 1.5
meshandsoln_dg_velocity_placentone_vtkDisplay.CoatStrength = 0.0
meshandsoln_dg_velocity_placentone_vtkDisplay.CoatIOR = 2.0
meshandsoln_dg_velocity_placentone_vtkDisplay.CoatRoughness = 0.0
meshandsoln_dg_velocity_placentone_vtkDisplay.CoatColor = [1.0, 1.0, 1.0]
meshandsoln_dg_velocity_placentone_vtkDisplay.SelectTCoordArray = 'None'
meshandsoln_dg_velocity_placentone_vtkDisplay.SelectNormalArray = 'None'
meshandsoln_dg_velocity_placentone_vtkDisplay.SelectTangentArray = 'None'
meshandsoln_dg_velocity_placentone_vtkDisplay.Texture = None
meshandsoln_dg_velocity_placentone_vtkDisplay.RepeatTextures = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.InterpolateTextures = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.SeamlessU = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.SeamlessV = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.UseMipmapTextures = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.ShowTexturesOnBackface = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.BaseColorTexture = None
meshandsoln_dg_velocity_placentone_vtkDisplay.NormalTexture = None
meshandsoln_dg_velocity_placentone_vtkDisplay.NormalScale = 1.0
meshandsoln_dg_velocity_placentone_vtkDisplay.CoatNormalTexture = None
meshandsoln_dg_velocity_placentone_vtkDisplay.CoatNormalScale = 1.0
meshandsoln_dg_velocity_placentone_vtkDisplay.MaterialTexture = None
meshandsoln_dg_velocity_placentone_vtkDisplay.OcclusionStrength = 1.0
meshandsoln_dg_velocity_placentone_vtkDisplay.AnisotropyTexture = None
meshandsoln_dg_velocity_placentone_vtkDisplay.EmissiveTexture = None
meshandsoln_dg_velocity_placentone_vtkDisplay.EmissiveFactor = [1.0, 1.0, 1.0]
meshandsoln_dg_velocity_placentone_vtkDisplay.FlipTextures = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.BackfaceRepresentation = 'Follow Frontface'
meshandsoln_dg_velocity_placentone_vtkDisplay.BackfaceAmbientColor = [1.0, 1.0, 1.0]
meshandsoln_dg_velocity_placentone_vtkDisplay.BackfaceOpacity = 1.0
meshandsoln_dg_velocity_placentone_vtkDisplay.Position = [0.0, 0.0, 0.0]
meshandsoln_dg_velocity_placentone_vtkDisplay.Scale = [1.0, 1.0, 1.0]
meshandsoln_dg_velocity_placentone_vtkDisplay.Orientation = [0.0, 0.0, 0.0]
meshandsoln_dg_velocity_placentone_vtkDisplay.Origin = [0.0, 0.0, 0.0]
meshandsoln_dg_velocity_placentone_vtkDisplay.CoordinateShiftScaleMethod = 'Always Auto Shift Scale'
meshandsoln_dg_velocity_placentone_vtkDisplay.Pickable = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.Triangulate = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.UseShaderReplacements = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.ShaderReplacements = ''
meshandsoln_dg_velocity_placentone_vtkDisplay.NonlinearSubdivisionLevel = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.UseDataPartitions = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.OSPRayUseScaleArray = 'All Approximate'
meshandsoln_dg_velocity_placentone_vtkDisplay.OSPRayScaleArray = 'u'
meshandsoln_dg_velocity_placentone_vtkDisplay.OSPRayScaleFunction = 'PiecewiseFunction'
meshandsoln_dg_velocity_placentone_vtkDisplay.OSPRayMaterial = 'None'
meshandsoln_dg_velocity_placentone_vtkDisplay.BlockSelectors = ['/']
meshandsoln_dg_velocity_placentone_vtkDisplay.BlockColors = []
meshandsoln_dg_velocity_placentone_vtkDisplay.BlockOpacities = []
meshandsoln_dg_velocity_placentone_vtkDisplay.Orient = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.OrientationMode = 'Direction'
meshandsoln_dg_velocity_placentone_vtkDisplay.SelectOrientationVectors = 'None'
meshandsoln_dg_velocity_placentone_vtkDisplay.Scaling = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.ScaleMode = 'No Data Scaling Off'
meshandsoln_dg_velocity_placentone_vtkDisplay.ScaleFactor = 0.125
meshandsoln_dg_velocity_placentone_vtkDisplay.SelectScaleArray = 'u'
meshandsoln_dg_velocity_placentone_vtkDisplay.GlyphType = 'Arrow'
meshandsoln_dg_velocity_placentone_vtkDisplay.UseGlyphTable = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.GlyphTableIndexArray = 'u'
meshandsoln_dg_velocity_placentone_vtkDisplay.UseCompositeGlyphTable = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.UseGlyphCullingAndLOD = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.LODValues = []
meshandsoln_dg_velocity_placentone_vtkDisplay.ColorByLODIndex = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.GaussianRadius = 0.00625
meshandsoln_dg_velocity_placentone_vtkDisplay.ShaderPreset = 'Sphere'
meshandsoln_dg_velocity_placentone_vtkDisplay.CustomTriangleScale = 3
meshandsoln_dg_velocity_placentone_vtkDisplay.CustomShader = """ // This custom shader code define a gaussian blur
 // Please take a look into vtkSMPointGaussianRepresentation.cxx
 // for other custom shader examples
 //VTK::Color::Impl
   float dist2 = dot(offsetVCVSOutput.xy,offsetVCVSOutput.xy);
   float gaussian = exp(-0.5*dist2);
   opacity = opacity*gaussian;
"""
meshandsoln_dg_velocity_placentone_vtkDisplay.Emissive = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.ScaleByArray = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.SetScaleArray = ['POINTS', 'u']
meshandsoln_dg_velocity_placentone_vtkDisplay.ScaleArrayComponent = ''
meshandsoln_dg_velocity_placentone_vtkDisplay.UseScaleFunction = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.ScaleTransferFunction = 'PiecewiseFunction'
meshandsoln_dg_velocity_placentone_vtkDisplay.OpacityByArray = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.OpacityArray = ['POINTS', 'u']
meshandsoln_dg_velocity_placentone_vtkDisplay.OpacityArrayComponent = ''
meshandsoln_dg_velocity_placentone_vtkDisplay.OpacityTransferFunction = 'PiecewiseFunction'
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid = 'GridAxesRepresentation'
meshandsoln_dg_velocity_placentone_vtkDisplay.SelectionCellLabelBold = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.SelectionCellLabelColor = [0.0, 1.0, 0.0]
meshandsoln_dg_velocity_placentone_vtkDisplay.SelectionCellLabelFontFamily = 'Arial'
meshandsoln_dg_velocity_placentone_vtkDisplay.SelectionCellLabelFontFile = ''
meshandsoln_dg_velocity_placentone_vtkDisplay.SelectionCellLabelFontSize = 18
meshandsoln_dg_velocity_placentone_vtkDisplay.SelectionCellLabelItalic = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.SelectionCellLabelJustification = 'Left'
meshandsoln_dg_velocity_placentone_vtkDisplay.SelectionCellLabelOpacity = 1.0
meshandsoln_dg_velocity_placentone_vtkDisplay.SelectionCellLabelShadow = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.SelectionPointLabelBold = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.SelectionPointLabelColor = [1.0, 1.0, 0.0]
meshandsoln_dg_velocity_placentone_vtkDisplay.SelectionPointLabelFontFamily = 'Arial'
meshandsoln_dg_velocity_placentone_vtkDisplay.SelectionPointLabelFontFile = ''
meshandsoln_dg_velocity_placentone_vtkDisplay.SelectionPointLabelFontSize = 18
meshandsoln_dg_velocity_placentone_vtkDisplay.SelectionPointLabelItalic = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.SelectionPointLabelJustification = 'Left'
meshandsoln_dg_velocity_placentone_vtkDisplay.SelectionPointLabelOpacity = 1.0
meshandsoln_dg_velocity_placentone_vtkDisplay.SelectionPointLabelShadow = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes = 'PolarAxesRepresentation'
meshandsoln_dg_velocity_placentone_vtkDisplay.ScalarOpacityFunction = uPWF
meshandsoln_dg_velocity_placentone_vtkDisplay.ScalarOpacityUnitDistance = 0.05221102931807868
meshandsoln_dg_velocity_placentone_vtkDisplay.UseSeparateOpacityArray = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.OpacityArrayName = ['POINTS', 'u']
meshandsoln_dg_velocity_placentone_vtkDisplay.OpacityComponent = ''
meshandsoln_dg_velocity_placentone_vtkDisplay.SelectMapper = 'Projected tetra'
meshandsoln_dg_velocity_placentone_vtkDisplay.SamplingDimensions = [128, 128, 128]
meshandsoln_dg_velocity_placentone_vtkDisplay.UseFloatingPointFrameBuffer = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.SelectInputVectors = [None, '']
meshandsoln_dg_velocity_placentone_vtkDisplay.NumberOfSteps = 40
meshandsoln_dg_velocity_placentone_vtkDisplay.StepSize = 0.25
meshandsoln_dg_velocity_placentone_vtkDisplay.NormalizeVectors = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.EnhancedLIC = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.ColorMode = 'Blend'
meshandsoln_dg_velocity_placentone_vtkDisplay.LICIntensity = 0.8
meshandsoln_dg_velocity_placentone_vtkDisplay.MapModeBias = 0.0
meshandsoln_dg_velocity_placentone_vtkDisplay.EnhanceContrast = 'Off'
meshandsoln_dg_velocity_placentone_vtkDisplay.LowLICContrastEnhancementFactor = 0.0
meshandsoln_dg_velocity_placentone_vtkDisplay.HighLICContrastEnhancementFactor = 0.0
meshandsoln_dg_velocity_placentone_vtkDisplay.LowColorContrastEnhancementFactor = 0.0
meshandsoln_dg_velocity_placentone_vtkDisplay.HighColorContrastEnhancementFactor = 0.0
meshandsoln_dg_velocity_placentone_vtkDisplay.AntiAlias = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.MaskOnSurface = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.MaskThreshold = 0.0
meshandsoln_dg_velocity_placentone_vtkDisplay.MaskIntensity = 0.0
meshandsoln_dg_velocity_placentone_vtkDisplay.MaskColor = [0.5, 0.5, 0.5]
meshandsoln_dg_velocity_placentone_vtkDisplay.GenerateNoiseTexture = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.NoiseType = 'Gaussian'
meshandsoln_dg_velocity_placentone_vtkDisplay.NoiseTextureSize = 128
meshandsoln_dg_velocity_placentone_vtkDisplay.NoiseGrainSize = 2
meshandsoln_dg_velocity_placentone_vtkDisplay.MinNoiseValue = 0.0
meshandsoln_dg_velocity_placentone_vtkDisplay.MaxNoiseValue = 0.8
meshandsoln_dg_velocity_placentone_vtkDisplay.NumberOfNoiseLevels = 1024
meshandsoln_dg_velocity_placentone_vtkDisplay.ImpulseNoiseProbability = 1.0
meshandsoln_dg_velocity_placentone_vtkDisplay.ImpulseNoiseBackgroundValue = 0.0
meshandsoln_dg_velocity_placentone_vtkDisplay.NoiseGeneratorSeed = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.CompositeStrategy = 'AUTO'
meshandsoln_dg_velocity_placentone_vtkDisplay.UseLICForLOD = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.WriteLog = ''

# init the 'PiecewiseFunction' selected for 'OSPRayScaleFunction'
meshandsoln_dg_velocity_placentone_vtkDisplay.OSPRayScaleFunction.Points = [0.0, 0.0, 0.5, 0.0, 1.0, 1.0, 0.5, 0.0]
meshandsoln_dg_velocity_placentone_vtkDisplay.OSPRayScaleFunction.UseLogScale = 0

# init the 'Arrow' selected for 'GlyphType'
meshandsoln_dg_velocity_placentone_vtkDisplay.GlyphType.TipResolution = 6
meshandsoln_dg_velocity_placentone_vtkDisplay.GlyphType.TipRadius = 0.1
meshandsoln_dg_velocity_placentone_vtkDisplay.GlyphType.TipLength = 0.35
meshandsoln_dg_velocity_placentone_vtkDisplay.GlyphType.ShaftResolution = 6
meshandsoln_dg_velocity_placentone_vtkDisplay.GlyphType.ShaftRadius = 0.03
meshandsoln_dg_velocity_placentone_vtkDisplay.GlyphType.Invert = 0

# init the 'PiecewiseFunction' selected for 'ScaleTransferFunction'
meshandsoln_dg_velocity_placentone_vtkDisplay.ScaleTransferFunction.Points = [-0.05703180402200115, 0.0, 0.5, 0.0, 0.05740611252092182, 1.0, 0.5, 0.0]
meshandsoln_dg_velocity_placentone_vtkDisplay.ScaleTransferFunction.UseLogScale = 0

# init the 'PiecewiseFunction' selected for 'OpacityTransferFunction'
meshandsoln_dg_velocity_placentone_vtkDisplay.OpacityTransferFunction.Points = [-0.05703180402200115, 0.0, 0.5, 0.0, 0.05740611252092182, 1.0, 0.5, 0.0]
meshandsoln_dg_velocity_placentone_vtkDisplay.OpacityTransferFunction.UseLogScale = 0

# init the 'GridAxesRepresentation' selected for 'DataAxesGrid'
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.XTitle = 'X Axis'
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.YTitle = 'Y Axis'
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.ZTitle = 'Z Axis'
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.XTitleFontFamily = 'Arial'
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.XTitleFontFile = ''
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.XTitleBold = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.XTitleItalic = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.XTitleFontSize = 12
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.XTitleShadow = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.XTitleOpacity = 1.0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.YTitleFontFamily = 'Arial'
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.YTitleFontFile = ''
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.YTitleBold = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.YTitleItalic = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.YTitleFontSize = 12
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.YTitleShadow = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.YTitleOpacity = 1.0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.ZTitleFontFamily = 'Arial'
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.ZTitleFontFile = ''
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.ZTitleBold = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.ZTitleItalic = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.ZTitleFontSize = 12
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.ZTitleShadow = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.ZTitleOpacity = 1.0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.FacesToRender = 63
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.CullBackface = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.CullFrontface = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.ShowGrid = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.ShowEdges = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.ShowTicks = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.LabelUniqueEdgesOnly = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.AxesToLabel = 63
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.XLabelFontFamily = 'Arial'
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.XLabelFontFile = ''
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.XLabelBold = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.XLabelItalic = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.XLabelFontSize = 12
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.XLabelShadow = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.XLabelOpacity = 1.0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.YLabelFontFamily = 'Arial'
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.YLabelFontFile = ''
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.YLabelBold = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.YLabelItalic = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.YLabelFontSize = 12
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.YLabelShadow = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.YLabelOpacity = 1.0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.ZLabelFontFamily = 'Arial'
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.ZLabelFontFile = ''
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.ZLabelBold = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.ZLabelItalic = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.ZLabelFontSize = 12
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.ZLabelShadow = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.ZLabelOpacity = 1.0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.XAxisNotation = 'Mixed'
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.XAxisPrecision = 2
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.XAxisUseCustomLabels = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.XAxisLabels = []
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.YAxisNotation = 'Mixed'
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.YAxisPrecision = 2
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.YAxisUseCustomLabels = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.YAxisLabels = []
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.ZAxisNotation = 'Mixed'
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.ZAxisPrecision = 2
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.ZAxisUseCustomLabels = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.ZAxisLabels = []
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.UseCustomBounds = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.DataAxesGrid.CustomBounds = [0.0, 1.0, 0.0, 1.0, 0.0, 1.0]

# init the 'PolarAxesRepresentation' selected for 'PolarAxes'
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.Visibility = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.Translation = [0.0, 0.0, 0.0]
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.Scale = [1.0, 1.0, 1.0]
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.Orientation = [0.0, 0.0, 0.0]
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.EnableCustomBounds = [0, 0, 0]
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.CustomBounds = [0.0, 1.0, 0.0, 1.0, 0.0, 1.0]
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.EnableCustomRange = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.CustomRange = [0.0, 1.0]
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarAxisVisibility = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.RadialAxesVisibility = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.DrawRadialGridlines = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarArcsVisibility = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.DrawPolarArcsGridlines = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.NumberOfRadialAxes = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.AutoSubdividePolarAxis = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.NumberOfPolarAxis = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.MinimumRadius = 0.0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.MinimumAngle = 0.0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.MaximumAngle = 90.0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.RadialAxesOriginToPolarAxis = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.Ratio = 1.0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarAxisColor = [1.0, 1.0, 1.0]
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarArcsColor = [1.0, 1.0, 1.0]
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.LastRadialAxisColor = [1.0, 1.0, 1.0]
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.SecondaryPolarArcsColor = [1.0, 1.0, 1.0]
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.SecondaryRadialAxesColor = [1.0, 1.0, 1.0]
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarAxisTitleVisibility = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarAxisTitle = 'Radial Distance'
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarAxisTitleLocation = 'Bottom'
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarLabelVisibility = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarLabelFormat = '%-#6.3g'
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarLabelExponentLocation = 'Labels'
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.RadialLabelVisibility = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.RadialLabelFormat = '%-#3.1f'
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.RadialLabelLocation = 'Bottom'
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.RadialUnitsVisibility = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.ScreenSize = 10.0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarAxisTitleOpacity = 1.0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarAxisTitleFontFamily = 'Arial'
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarAxisTitleFontFile = ''
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarAxisTitleBold = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarAxisTitleItalic = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarAxisTitleShadow = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarAxisTitleFontSize = 12
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarAxisLabelOpacity = 1.0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarAxisLabelFontFamily = 'Arial'
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarAxisLabelFontFile = ''
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarAxisLabelBold = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarAxisLabelItalic = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarAxisLabelShadow = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarAxisLabelFontSize = 12
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.LastRadialAxisTextOpacity = 1.0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.LastRadialAxisTextFontFamily = 'Arial'
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.LastRadialAxisTextFontFile = ''
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.LastRadialAxisTextBold = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.LastRadialAxisTextItalic = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.LastRadialAxisTextShadow = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.LastRadialAxisTextFontSize = 12
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.SecondaryRadialAxesTextOpacity = 1.0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.SecondaryRadialAxesTextFontFamily = 'Arial'
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.SecondaryRadialAxesTextFontFile = ''
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.SecondaryRadialAxesTextBold = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.SecondaryRadialAxesTextItalic = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.SecondaryRadialAxesTextShadow = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.SecondaryRadialAxesTextFontSize = 12
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.EnableDistanceLOD = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.DistanceLODThreshold = 0.7
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.EnableViewAngleLOD = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.ViewAngleLODThreshold = 0.7
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.SmallestVisiblePolarAngle = 0.5
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarTicksVisibility = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.ArcTicksOriginToPolarAxis = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.TickLocation = 'Both'
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.AxisTickVisibility = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.AxisMinorTickVisibility = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.ArcTickVisibility = 1
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.ArcMinorTickVisibility = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.DeltaAngleMajor = 10.0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.DeltaAngleMinor = 5.0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarAxisMajorTickSize = 0.0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarAxisTickRatioSize = 0.3
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarAxisMajorTickThickness = 1.0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.PolarAxisTickRatioThickness = 0.5
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.LastRadialAxisMajorTickSize = 0.0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.LastRadialAxisTickRatioSize = 0.3
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.LastRadialAxisMajorTickThickness = 1.0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.LastRadialAxisTickRatioThickness = 0.5
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.ArcMajorTickSize = 0.0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.ArcTickRatioSize = 0.3
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.ArcMajorTickThickness = 1.0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.ArcTickRatioThickness = 0.5
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.Use2DMode = 0
meshandsoln_dg_velocity_placentone_vtkDisplay.PolarAxes.UseLogAxis = 0

# reset view to fit data
renderView1.ResetCamera(False)

#changing interaction mode based on data extents
renderView1.CameraPosition = [0.5, 0.375, 4.1875]
renderView1.CameraFocalPoint = [0.5, 0.375, 0.0]

# get the material library
materialLibrary1 = GetMaterialLibrary()

# show color bar/color legend
meshandsoln_dg_velocity_placentone_vtkDisplay.SetScalarBarVisibility(renderView1, True)

# update the view to ensure updated data information
renderView1.Update()

# create a new 'Calculator'
calculator1 = Calculator(registrationName='Calculator1', Input=meshandsoln_dg_velocity_placentone_vtk)
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
calculator1.ResultArrayName = 'Velocity'
calculator1.Function = '0.35*(iHat*u+jHat*v)'

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
calculator1Display.SelectOrientationVectors = 'Velocity'
calculator1Display.Scaling = 0
calculator1Display.ScaleMode = 'No Data Scaling Off'
calculator1Display.ScaleFactor = 0.125
calculator1Display.SelectScaleArray = 'u'
calculator1Display.GlyphType = 'Arrow'
calculator1Display.UseGlyphTable = 0
calculator1Display.GlyphTableIndexArray = 'u'
calculator1Display.UseCompositeGlyphTable = 0
calculator1Display.UseGlyphCullingAndLOD = 0
calculator1Display.LODValues = []
calculator1Display.ColorByLODIndex = 0
calculator1Display.GaussianRadius = 0.00625
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
calculator1Display.ScalarOpacityUnitDistance = 0.05221102931807868
calculator1Display.UseSeparateOpacityArray = 0
calculator1Display.OpacityArrayName = ['POINTS', 'u']
calculator1Display.OpacityComponent = ''
calculator1Display.SelectMapper = 'Projected tetra'
calculator1Display.SamplingDimensions = [128, 128, 128]
calculator1Display.UseFloatingPointFrameBuffer = 1
calculator1Display.SelectInputVectors = ['POINTS', 'Velocity']
calculator1Display.NumberOfSteps = 40
calculator1Display.StepSize = 0.25
calculator1Display.NormalizeVectors = 1
calculator1Display.EnhancedLIC = 1
calculator1Display.ColorMode = 'Blend'
calculator1Display.LICIntensity = 0.8
calculator1Display.MapModeBias = 0.0
calculator1Display.EnhanceContrast = 'Off'
calculator1Display.LowLICContrastEnhancementFactor = 0.0
calculator1Display.HighLICContrastEnhancementFactor = 0.0
calculator1Display.LowColorContrastEnhancementFactor = 0.0
calculator1Display.HighColorContrastEnhancementFactor = 0.0
calculator1Display.AntiAlias = 0
calculator1Display.MaskOnSurface = 1
calculator1Display.MaskThreshold = 0.0
calculator1Display.MaskIntensity = 0.0
calculator1Display.MaskColor = [0.5, 0.5, 0.5]
calculator1Display.GenerateNoiseTexture = 0
calculator1Display.NoiseType = 'Gaussian'
calculator1Display.NoiseTextureSize = 128
calculator1Display.NoiseGrainSize = 2
calculator1Display.MinNoiseValue = 0.0
calculator1Display.MaxNoiseValue = 0.8
calculator1Display.NumberOfNoiseLevels = 1024
calculator1Display.ImpulseNoiseProbability = 1.0
calculator1Display.ImpulseNoiseBackgroundValue = 0.0
calculator1Display.NoiseGeneratorSeed = 1
calculator1Display.CompositeStrategy = 'AUTO'
calculator1Display.UseLICForLOD = 0
calculator1Display.WriteLog = ''

# init the 'PiecewiseFunction' selected for 'OSPRayScaleFunction'
calculator1Display.OSPRayScaleFunction.Points = [0.0, 0.0, 0.5, 0.0, 1.0, 1.0, 0.5, 0.0]
calculator1Display.OSPRayScaleFunction.UseLogScale = 0

# init the 'Arrow' selected for 'GlyphType'
calculator1Display.GlyphType.TipResolution = 6
calculator1Display.GlyphType.TipRadius = 0.1
calculator1Display.GlyphType.TipLength = 0.35
calculator1Display.GlyphType.ShaftResolution = 6
calculator1Display.GlyphType.ShaftRadius = 0.03
calculator1Display.GlyphType.Invert = 0

# init the 'PiecewiseFunction' selected for 'ScaleTransferFunction'
calculator1Display.ScaleTransferFunction.Points = [-0.05703180402200115, 0.0, 0.5, 0.0, 0.05740611252092182, 1.0, 0.5, 0.0]
calculator1Display.ScaleTransferFunction.UseLogScale = 0

# init the 'PiecewiseFunction' selected for 'OpacityTransferFunction'
calculator1Display.OpacityTransferFunction.Points = [-0.05703180402200115, 0.0, 0.5, 0.0, 0.05740611252092182, 1.0, 0.5, 0.0]
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
calculator1Display.PolarAxes.Visibility = 0
calculator1Display.PolarAxes.Translation = [0.0, 0.0, 0.0]
calculator1Display.PolarAxes.Scale = [1.0, 1.0, 1.0]
calculator1Display.PolarAxes.Orientation = [0.0, 0.0, 0.0]
calculator1Display.PolarAxes.EnableCustomBounds = [0, 0, 0]
calculator1Display.PolarAxes.CustomBounds = [0.0, 1.0, 0.0, 1.0, 0.0, 1.0]
calculator1Display.PolarAxes.EnableCustomRange = 0
calculator1Display.PolarAxes.CustomRange = [0.0, 1.0]
calculator1Display.PolarAxes.PolarAxisVisibility = 1
calculator1Display.PolarAxes.RadialAxesVisibility = 1
calculator1Display.PolarAxes.DrawRadialGridlines = 1
calculator1Display.PolarAxes.PolarArcsVisibility = 1
calculator1Display.PolarAxes.DrawPolarArcsGridlines = 1
calculator1Display.PolarAxes.NumberOfRadialAxes = 0
calculator1Display.PolarAxes.AutoSubdividePolarAxis = 1
calculator1Display.PolarAxes.NumberOfPolarAxis = 0
calculator1Display.PolarAxes.MinimumRadius = 0.0
calculator1Display.PolarAxes.MinimumAngle = 0.0
calculator1Display.PolarAxes.MaximumAngle = 90.0
calculator1Display.PolarAxes.RadialAxesOriginToPolarAxis = 1
calculator1Display.PolarAxes.Ratio = 1.0
calculator1Display.PolarAxes.PolarAxisColor = [1.0, 1.0, 1.0]
calculator1Display.PolarAxes.PolarArcsColor = [1.0, 1.0, 1.0]
calculator1Display.PolarAxes.LastRadialAxisColor = [1.0, 1.0, 1.0]
calculator1Display.PolarAxes.SecondaryPolarArcsColor = [1.0, 1.0, 1.0]
calculator1Display.PolarAxes.SecondaryRadialAxesColor = [1.0, 1.0, 1.0]
calculator1Display.PolarAxes.PolarAxisTitleVisibility = 1
calculator1Display.PolarAxes.PolarAxisTitle = 'Radial Distance'
calculator1Display.PolarAxes.PolarAxisTitleLocation = 'Bottom'
calculator1Display.PolarAxes.PolarLabelVisibility = 1
calculator1Display.PolarAxes.PolarLabelFormat = '%-#6.3g'
calculator1Display.PolarAxes.PolarLabelExponentLocation = 'Labels'
calculator1Display.PolarAxes.RadialLabelVisibility = 1
calculator1Display.PolarAxes.RadialLabelFormat = '%-#3.1f'
calculator1Display.PolarAxes.RadialLabelLocation = 'Bottom'
calculator1Display.PolarAxes.RadialUnitsVisibility = 1
calculator1Display.PolarAxes.ScreenSize = 10.0
calculator1Display.PolarAxes.PolarAxisTitleOpacity = 1.0
calculator1Display.PolarAxes.PolarAxisTitleFontFamily = 'Arial'
calculator1Display.PolarAxes.PolarAxisTitleFontFile = ''
calculator1Display.PolarAxes.PolarAxisTitleBold = 0
calculator1Display.PolarAxes.PolarAxisTitleItalic = 0
calculator1Display.PolarAxes.PolarAxisTitleShadow = 0
calculator1Display.PolarAxes.PolarAxisTitleFontSize = 12
calculator1Display.PolarAxes.PolarAxisLabelOpacity = 1.0
calculator1Display.PolarAxes.PolarAxisLabelFontFamily = 'Arial'
calculator1Display.PolarAxes.PolarAxisLabelFontFile = ''
calculator1Display.PolarAxes.PolarAxisLabelBold = 0
calculator1Display.PolarAxes.PolarAxisLabelItalic = 0
calculator1Display.PolarAxes.PolarAxisLabelShadow = 0
calculator1Display.PolarAxes.PolarAxisLabelFontSize = 12
calculator1Display.PolarAxes.LastRadialAxisTextOpacity = 1.0
calculator1Display.PolarAxes.LastRadialAxisTextFontFamily = 'Arial'
calculator1Display.PolarAxes.LastRadialAxisTextFontFile = ''
calculator1Display.PolarAxes.LastRadialAxisTextBold = 0
calculator1Display.PolarAxes.LastRadialAxisTextItalic = 0
calculator1Display.PolarAxes.LastRadialAxisTextShadow = 0
calculator1Display.PolarAxes.LastRadialAxisTextFontSize = 12
calculator1Display.PolarAxes.SecondaryRadialAxesTextOpacity = 1.0
calculator1Display.PolarAxes.SecondaryRadialAxesTextFontFamily = 'Arial'
calculator1Display.PolarAxes.SecondaryRadialAxesTextFontFile = ''
calculator1Display.PolarAxes.SecondaryRadialAxesTextBold = 0
calculator1Display.PolarAxes.SecondaryRadialAxesTextItalic = 0
calculator1Display.PolarAxes.SecondaryRadialAxesTextShadow = 0
calculator1Display.PolarAxes.SecondaryRadialAxesTextFontSize = 12
calculator1Display.PolarAxes.EnableDistanceLOD = 1
calculator1Display.PolarAxes.DistanceLODThreshold = 0.7
calculator1Display.PolarAxes.EnableViewAngleLOD = 1
calculator1Display.PolarAxes.ViewAngleLODThreshold = 0.7
calculator1Display.PolarAxes.SmallestVisiblePolarAngle = 0.5
calculator1Display.PolarAxes.PolarTicksVisibility = 1
calculator1Display.PolarAxes.ArcTicksOriginToPolarAxis = 1
calculator1Display.PolarAxes.TickLocation = 'Both'
calculator1Display.PolarAxes.AxisTickVisibility = 1
calculator1Display.PolarAxes.AxisMinorTickVisibility = 0
calculator1Display.PolarAxes.ArcTickVisibility = 1
calculator1Display.PolarAxes.ArcMinorTickVisibility = 0
calculator1Display.PolarAxes.DeltaAngleMajor = 10.0
calculator1Display.PolarAxes.DeltaAngleMinor = 5.0
calculator1Display.PolarAxes.PolarAxisMajorTickSize = 0.0
calculator1Display.PolarAxes.PolarAxisTickRatioSize = 0.3
calculator1Display.PolarAxes.PolarAxisMajorTickThickness = 1.0
calculator1Display.PolarAxes.PolarAxisTickRatioThickness = 0.5
calculator1Display.PolarAxes.LastRadialAxisMajorTickSize = 0.0
calculator1Display.PolarAxes.LastRadialAxisTickRatioSize = 0.3
calculator1Display.PolarAxes.LastRadialAxisMajorTickThickness = 1.0
calculator1Display.PolarAxes.LastRadialAxisTickRatioThickness = 0.5
calculator1Display.PolarAxes.ArcMajorTickSize = 0.0
calculator1Display.PolarAxes.ArcTickRatioSize = 0.3
calculator1Display.PolarAxes.ArcMajorTickThickness = 1.0
calculator1Display.PolarAxes.ArcTickRatioThickness = 0.5
calculator1Display.PolarAxes.Use2DMode = 0
calculator1Display.PolarAxes.UseLogAxis = 0

# hide data in view
Hide(meshandsoln_dg_velocity_placentone_vtk, renderView1)

# show color bar/color legend
calculator1Display.SetScalarBarVisibility(renderView1, True)

# update the view to ensure updated data information
renderView1.Update()

# set scalar coloring
ColorBy(calculator1Display, ('POINTS', 'Velocity', 'Magnitude'))

# Hide the scalar bar for this color map if no visible data is colored by it.
HideScalarBarIfNotNeeded(uLUT, renderView1)

# rescale color and/or opacity maps used to include current data range
calculator1Display.RescaleTransferFunctionToDataRange(True, False)

# show color bar/color legend
calculator1Display.SetScalarBarVisibility(renderView1, True)

# get 2D transfer function for 'Velocity'
velocityTF2D = GetTransferFunction2D('Velocity')
velocityTF2D.AutomaticRescaleRangeMode = "Grow and update on 'Apply'"
velocityTF2D.Boxes = []
velocityTF2D.ScalarRangeInitialized = 1
velocityTF2D.Range = [0.0, 0.35, 0.0, 1.0]
velocityTF2D.OutputDimensions = [10, 10]

# get color transfer function/color map for 'Velocity'
velocityLUT = GetColorTransferFunction('Velocity')
velocityLUT.AutomaticRescaleRangeMode = 'Never'
velocityLUT.InterpretValuesAsCategories = 0
velocityLUT.AnnotationsInitialized = 0
velocityLUT.ShowCategoricalColorsinDataRangeOnly = 0
velocityLUT.RescaleOnVisibilityChange = 0
velocityLUT.EnableOpacityMapping = 0
velocityLUT.TransferFunction2D = velocityTF2D
velocityLUT.Use2DTransferFunction = 0
velocityLUT.RGBPoints = [0.0, 0.0, 0.0, 0.5625, 0.038888849999999996, 0.0, 0.0, 1.0, 0.12777782499999998, 0.0, 1.0, 1.0, 0.172222225, 0.5, 1.0, 0.5, 0.21666662499999997, 1.0, 1.0, 0.0, 0.3055556, 1.0, 0.0, 0.0, 0.35, 0.5, 0.0, 0.0]
velocityLUT.UseLogScale = 0
velocityLUT.UseOpacityControlPointsFreehandDrawing = 0
velocityLUT.ShowDataHistogram = 0
velocityLUT.AutomaticDataHistogramComputation = 0
velocityLUT.DataHistogramNumberOfBins = 10
velocityLUT.ColorSpace = 'RGB'
velocityLUT.UseBelowRangeColor = 0
velocityLUT.BelowRangeColor = [0.0, 0.0, 0.0]
velocityLUT.UseAboveRangeColor = 0
velocityLUT.AboveRangeColor = [0.5, 0.5, 0.5]
velocityLUT.NanColor = [1.0, 1.0, 0.0]
velocityLUT.NanOpacity = 1.0
velocityLUT.Discretize = 0
velocityLUT.NumberOfTableValues = 45
velocityLUT.ScalarRangeInitialized = 1.0
velocityLUT.HSVWrap = 0
velocityLUT.VectorComponent = 0
velocityLUT.VectorMode = 'Magnitude'
velocityLUT.AllowDuplicateScalars = 1
velocityLUT.Annotations = []
velocityLUT.ActiveAnnotatedValues = []
velocityLUT.IndexedColors = []
velocityLUT.IndexedOpacities = []

# get opacity transfer function/opacity map for 'Velocity'
velocityPWF = GetOpacityTransferFunction('Velocity')
velocityPWF.Points = [0.0, 0.0, 0.5, 0.0, 0.35, 1.0, 0.5, 0.0]
velocityPWF.AllowDuplicateScalars = 1
velocityPWF.UseLogScale = 0
velocityPWF.ScalarRangeInitialized = 1

# Apply a preset using its name. Note this may not work as expected when presets have duplicate names.
velocityLUT.ApplyPreset('Jet', True)

# get color legend/bar for velocityLUT in view renderView1
velocityLUTColorBar = GetScalarBar(velocityLUT, renderView1)
velocityLUTColorBar.AutoOrient = 1
velocityLUTColorBar.Orientation = 'Vertical'
velocityLUTColorBar.WindowLocation = 'Lower Right Corner'
velocityLUTColorBar.Position = [0.89, 0.02]
velocityLUTColorBar.Title = 'Velocity'
velocityLUTColorBar.ComponentTitle = 'Magnitude'
velocityLUTColorBar.TitleJustification = 'Centered'
velocityLUTColorBar.HorizontalTitle = 0
velocityLUTColorBar.TitleOpacity = 1.0
velocityLUTColorBar.TitleFontFamily = 'Arial'
velocityLUTColorBar.TitleFontFile = ''
velocityLUTColorBar.TitleBold = 0
velocityLUTColorBar.TitleItalic = 0
velocityLUTColorBar.TitleShadow = 0
velocityLUTColorBar.TitleFontSize = 16
velocityLUTColorBar.LabelOpacity = 1.0
velocityLUTColorBar.LabelFontFamily = 'Arial'
velocityLUTColorBar.LabelFontFile = ''
velocityLUTColorBar.LabelBold = 0
velocityLUTColorBar.LabelItalic = 0
velocityLUTColorBar.LabelShadow = 0
velocityLUTColorBar.LabelFontSize = 16
velocityLUTColorBar.ScalarBarThickness = 16
velocityLUTColorBar.ScalarBarLength = 0.33
velocityLUTColorBar.DrawBackground = 0
velocityLUTColorBar.BackgroundColor = [1.0, 1.0, 1.0, 0.5]
velocityLUTColorBar.BackgroundPadding = 2.0
velocityLUTColorBar.DrawScalarBarOutline = 0
velocityLUTColorBar.ScalarBarOutlineColor = [1.0, 1.0, 1.0]
velocityLUTColorBar.ScalarBarOutlineThickness = 1
velocityLUTColorBar.AutomaticLabelFormat = 1
velocityLUTColorBar.LabelFormat = '%-#6.3g'
velocityLUTColorBar.DrawTickMarks = 1
velocityLUTColorBar.DrawTickLabels = 1
velocityLUTColorBar.UseCustomLabels = 0
velocityLUTColorBar.CustomLabels = []
velocityLUTColorBar.AddRangeLabels = 1
velocityLUTColorBar.RangeLabelFormat = '%-#6.1e'
velocityLUTColorBar.DrawDataRange = 0
velocityLUTColorBar.DataRangeLabelFormat = '%-#6.1e'
velocityLUTColorBar.DrawAnnotations = 1
velocityLUTColorBar.AddRangeAnnotations = 0
velocityLUTColorBar.AutomaticAnnotations = 0
velocityLUTColorBar.DrawNanAnnotation = 0
velocityLUTColorBar.NanAnnotation = 'NaN'
velocityLUTColorBar.TextPosition = 'Ticks right/top, annotations left/bottom'
velocityLUTColorBar.ReverseLegend = 0

# change scalar bar placement
velocityLUTColorBar.Orientation = 'Horizontal'
velocityLUTColorBar.WindowLocation = 'Any Location'
velocityLUTColorBar.Position = [0.3480373831775702, 0.04485819975339081]
velocityLUTColorBar.ScalarBarLength = 0.3299999999999999

# change scalar bar placement
velocityLUTColorBar.Position = [0.061121495327102884, 0.04485819975339081]
velocityLUTColorBar.ScalarBarLength = 0.6169158878504672

# change scalar bar placement
velocityLUTColorBar.ScalarBarLength = 0.8963551401869159

# Properties modified on velocityLUTColorBar
velocityLUTColorBar.ComponentTitle = 'Magnitude (m/s)'
velocityLUTColorBar.TitleFontSize = 32
velocityLUTColorBar.LabelFontSize = 32

# Properties modified on velocityLUTColorBar
velocityLUTColorBar.UseCustomLabels = 1
velocityLUTColorBar.CustomLabels = [0.0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35]

# Properties modified on velocityLUTColorBar
velocityLUTColorBar.AddRangeLabels = 0

# change scalar bar placement
velocityLUTColorBar.Position = [0.053644859813084214, 0.10959309494451289]

# change scalar bar placement
velocityLUTColorBar.Position = [0.053644859813084214, 0.11205918618988897]
velocityLUTColorBar.ScalarBarLength = 0.896355140186916

# get layout
layout1 = GetLayout()

# layout/tab size in pixels
layout1.SetSize(1070, 1622)

# current camera placement for renderView1
renderView1.InteractionMode = '2D'
renderView1.CameraPosition = [0.4952178491473526, 0.23496881349427168, 4.1875]
renderView1.CameraFocalPoint = [0.4952178491473526, 0.23496881349427168, 0.0]
renderView1.CameraParallelScale = 0.8287017823711735

# save screenshot
SaveScreenshot('C:\\Users\\adam\\Dropbox\\Apps\\Overleaf\\PhD thesis\\diagrams\\results-modelling\\velocity-comparison\\meshandsoln_dg_velocity_placentone_12_velocity-linear.png', renderView1, ImageResolution=[2140, 3244],
    FontScaling='Scale fonts proportionally',
    OverrideColorPalette='',
    StereoMode='No change',
    TransparentBackground=1, 
    # PNG options
    CompressionLevel='5',
    MetaData=['Application', 'ParaView'])

#================================================================
# addendum: following script captures some of the application
# state to faithfully reproduce the visualization during playback
#================================================================

#--------------------------------
# saving layout sizes for layouts

# layout/tab size in pixels
layout1.SetSize(1070, 1622)

#-----------------------------------
# saving camera placements for views

# current camera placement for renderView1
renderView1.InteractionMode = '2D'
renderView1.CameraPosition = [0.4952178491473526, 0.23496881349427168, 4.1875]
renderView1.CameraFocalPoint = [0.4952178491473526, 0.23496881349427168, 0.0]
renderView1.CameraParallelScale = 0.8287017823711735

#--------------------------------------------
# uncomment the following to render all views
# RenderAllViews()
# alternatively, if you want to write images, you can use SaveScreenshot(...).