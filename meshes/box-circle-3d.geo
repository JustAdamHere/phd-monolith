// Gmsh project created on Thu Mar 17 16:40:34 2022
//   Assumes width of 4cm [1 unit] and inlet/outlet size of 2mm [0.05 units]

Geometry.OldNewReg=0;
// TODO: Try OpenCASCADE kernel.

//=/=/=/=/=/=/=/=/=/=//
//=/ OUTPUT FORMAT /=//
//=/  SURFACES
//=/   Non-curved boundary: 100
//=/   Curved boundary:     101
//=/   Inlet:               111
//=/   Outlets:             211, 212
//=/  VOLUMES
//=/   IVS:      301
//=/   Inlet:    412
//=/   Outlets:  411, 413
//=/   Cavities: 501
//=/
//=/=/=/=/=/=/=/=/=/=//

////////////////////////
// Default parameters //
////////////////////////
If (!Exists(h))
	h        = 0.1;
EndIf
If (!Exists(h_refine))
	h_refine = h/10;
EndIf

Printf("h = %f", h);
Printf("h_refine = %f", h_refine);

If (!Exists(location_11))
	location_11 = 0.2;
EndIf
If (!Exists(location_12))
	location_12 = 0.5;
EndIf
If (!Exists(location_13))
	location_13 = 0.8;
EndIf

//////////////////////
// Other parameters //
//////////////////////
artery_width          = 0.06;   // 2.4 mm
artery_width_sm       = 0.0125; // 0.5mm
artery_length         = 0.25;   // 10mm
artery_length_diverge = 0.075;  // 3mm
vein_width            = 0.0375; // 1.5 mm

// Default cavity size.
If (!Exists(central_cavity_width))
	central_cavity_width = 0.25; // 10 mm
EndIf
cavity_height = 2*central_cavity_width;

// Default transition region -- added onto the central cavity width.
If (!Exists(central_cavity_transition))
	central_cavity_transition = 0.02; // 0.8 mm
EndIf

outlet_location_1 = location_11;
inlet_location    = location_12;
outlet_location_2 = location_13;

////////////
// Points //
////////////
// 2D plane points.
Point(1)  = {0,                                  0,               0, h};
Point(2)  = {outlet_location_1 - vein_width/2, 0,               0, h_refine};
// Point(3)  = {outlet_location_1 - vein_width/2, -vein_width,   0, h_refine};
// Point(4)  = {outlet_location_1 + vein_width/2, -vein_width,   0, h_refine};
Point(5)  = {outlet_location_1 + vein_width/2, 0,               0, h_refine};
Point(6)  = {inlet_location    - artery_width/2,  0,               0, h_refine};
// Point(7)  = {inlet_location    - artery_width/2,  -artery_width,    0, h_refine};
// Point(8)  = {inlet_location    + artery_width/2,  -artery_width,    0, h_refine};
Point(9)  = {inlet_location    + artery_width/2,  0,               0, h_refine};
Point(10) = {outlet_location_2 - vein_width/2, 0,               0, h_refine};
// Point(11) = {outlet_location_2 - vein_width/2, -vein_width,   0, h_refine};
// Point(12) = {outlet_location_2 + vein_width/2, -vein_width,   0, h_refine};
Point(13) = {outlet_location_2 + vein_width/2, 0,               0, h_refine};
Point(14) = {1,                 0,   0, h};
Point(15) = {1,                 0.5, 0, h};
Point(16) = {0.5,               1,   0, h};
Point(17) = {0,                 0.5, 0, h};
Point(18) = {0.5,               0.5, 0, h_refine};
Point(22) = {inlet_location,    0,   0, h_refine};
Point(23) = {outlet_location_1, 0,   0, h_refine};
Point(24) = {outlet_location_2, 0,   0, h_refine};

// Inlet 3D.
Point(28) = {inlet_location, 0,             (artery_width)/2, h_refine};
Point(29) = {inlet_location, 0,            -(artery_width)/2, h_refine};

// Outlet 1 3D.
Point(32) = {outlet_location_1, 0,              (vein_width)/2, h_refine};
Point(33) = {outlet_location_1, 0,             -(vein_width)/2, h_refine};

// Outlet 2 3D.
Point(36) = {outlet_location_2, 0,              (vein_width)/2, h_refine};
Point(37) = {outlet_location_2, 0,             -(vein_width)/2, h_refine};

// Inner cavity.
Point(19) = {inlet_location - (central_cavity_width - central_cavity_transition)/2,  0,                                               0, h_refine};
Point(20) = {inlet_location,                                                         (cavity_height - 2*central_cavity_transition)/2, 0, h_refine};
Point(21) = {inlet_location + (central_cavity_width - central_cavity_transition)/2,  0,                                               0, h_refine};
Point(40) = {inlet_location,                                                         0,  (central_cavity_width - central_cavity_transition)/2, h_refine};
Point(41) = {inlet_location,                                                         0, -(central_cavity_width - central_cavity_transition)/2, h_refine};

// Middle cavity.
Point(120) = {inlet_location - (central_cavity_width)/2,  0, 0, h_refine};
Point(121) = {inlet_location,  (cavity_height)/2, 0, h_refine};
Point(122) = {inlet_location + (central_cavity_width)/2,  0, 0, h_refine};
Point(123) = {inlet_location,                             0,  (central_cavity_width)/2, h_refine};
Point(124) = {inlet_location,                             0, -(central_cavity_width)/2, h_refine};

// Outer cavity.
Point(125) = {inlet_location - (central_cavity_width + central_cavity_transition)/2,  0,                                               0, h_refine};
Point(126) = {inlet_location,                                                         (cavity_height + 2*central_cavity_transition)/2, 0, h_refine};
Point(127) = {inlet_location + (central_cavity_width + central_cavity_transition)/2,  0,                                               0, h_refine};
Point(128) = {inlet_location,                                                         0,  (central_cavity_width + central_cavity_transition)/2, h_refine};
Point(129) = {inlet_location,                                                         0, -(central_cavity_width + central_cavity_transition)/2, h_refine};

// Placentone 3D.
Point(42) = {0.5, 0,    0.5, h};
Point(43) = {0.5, 0,   -0.5, h};
Point(44) = {0.5, 0.5,  0.5, h};
Point(45) = {0.5, 0.5, -0.5, h};

///////////
// Pipes //
///////////
// Inlet.
Circle(1) = {6,  22, 28};
Circle(2) = {28, 22, 9};
Circle(3) = {9,  22, 29};
Circle(4) = {29, 22, 6};

Curve Loop(1) = {1, 2, 3, 4}; Plane Surface(1) = {1};

Extrude {0, -artery_width, 0} {
  Curve{1}; Curve{2}; Curve{3}; Curve{4};
}

Curve Loop(2) = {5, 8, 11, 14}; Plane Surface(6) = {2};

// Outlet 1.
// Circle(27) = {2,  23, 32};
// Circle(28) = {32, 23, 5};
// Circle(29) = {5,  23, 33};
// Circle(30) = {33, 23, 2};

// Curve Loop(3) = {27, 28, 29, 30}; Plane Surface(7) = {3};

// Extrude {0, -vein_width, 0} {
//   Curve{27}; Curve{28}; Curve{29}; Curve{30};
// }

// // Curve Loop(4) = {25, 28, 31, 34}; Plane Surface(12) = {4};

Circle(21) = {2,  23, 32};
Circle(22) = {32, 23, 5};
Circle(23) = {5,  23, 33};
Circle(24) = {33, 23, 2};

Curve Loop(3) = {21, 22, 23, 24}; Plane Surface(7) = {3};

Extrude {0, -vein_width, 0} {
  Curve{21}; Curve{22}; Curve{23}; Curve{24};
}

Curve Loop(4) = {25, 28, 31, 34}; Plane Surface(12) = {4};


// Outlet 2.
Circle(41) = {13, 24, 36};
Circle(42) = {36, 24, 10};
Circle(43) = {10, 24, 37};
Circle(44) = {37, 24, 13};

Curve Loop(5) = {41, 42, 43, 44}; Plane Surface(13) = {5};

Extrude {0, -vein_width, 0} {
	Curve{41}; Curve{42}; Curve{43}; Curve{44};
}

Curve Loop(6) = {45, 48, 51, 54}; Plane Surface(18) = {6};

////////////////
// Placentone //
////////////////
// Cavity (part one).
Ellipse(83) = {19, 22, 22, 20};
Ellipse(84) = {20, 22, 22, 21};
Ellipse(85) = {40, 22, 22, 20};
Ellipse(86) = {20, 22, 22, 41};

Extrude {{0, 1, 0}, {0.5, 0, 0}, Pi/2} {
	Line{83}; Line{84}; Line{85}; Line{86};
}

// Basal plate.
Circle(61) = {1, 22, 42};
Circle(62) = {42, 22, 14};
Circle(63) = {14, 22, 43};
Circle(64) = {43, 22, 1};

Curve Loop(7) = {61, 62, 63, 64}; Curve Loop(8) = {88, 90, 92, 94}; Plane Surface(28) = {8, 1};

// Upstairs circle.
Extrude {0, 0.5, 0} {
	Curve{61}; Curve{62}; Curve{63}; Curve{64};
}

// Spherical top.
Extrude {{0, 0, 1}, {0.5, 0.5, 0}, Pi/2} {
	Curve{98}; Curve{101};
}
Extrude {{0, 0, -1}, {0.5, 0.5, 0}, Pi/2} {
	Curve{95}; Curve{104};
}

// Cavity (part two).
Ellipse(113) = {120, 22, 22, 121};
Ellipse(114) = {122, 22, 22, 121};
Ellipse(115) = {123, 22, 22, 121};
Ellipse(116) = {124, 22, 22, 121};

Extrude {{0, 1, 0}, {0.5, 0, 0}, Pi/2} {
	Line{113}; Line{114}; Line{115}; Line{116};
}

Ellipse(125) = {125, 22, 22, 126};
Ellipse(126) = {127, 22, 22, 126};
Ellipse(127) = {128, 22, 22, 126};
Ellipse(128) = {129, 22, 22, 126};

Extrude {{0, 1, 0}, {0.5, 0, 0}, Pi/2} {
	Line{125}; Line{126}; Line{127}; Line{128};
}

Curve Loop(45) = {124, 118, 122, 120}; Surface(45) = {45, 8};
Curve Loop(46) = {136, 130, 134, 132}; Surface(46) = {46, 45};

Curve Loop(9) = {118, 120, 122, 124}; Curve Loop(10) = {130, 132, 134, 136}; Plane Surface(27) = {7, 3, 5, 10}; 

//////////////////////
// Inlet (part two) //
//////////////////////
// Dilate {{inlet_location, -artery_length_diverge, 0}, artery_width_sm/artery_width} {
// 	Curve{14}; Curve{5}; Curve{8}; Curve{11};
// }
// Extrude {0, artery_length_diverge-artery_length, 0} {
//   Curve{14}; Curve{5}; Curve{8}; Curve{11};
// }

/////////////
// Volumes //
/////////////
// Cavity volume (part one).
Surface Loop(1) = {1, 19, 20, 21, 22, 28}; Volume(1) = {1};

// Pipe volumes.
Surface Loop(2) = {1, 2, 3, 4, 5, 6}; Volume(2) = {2};
Surface Loop(3) = {7, 8, 9, 10, 11, 12}; Volume(3) = {3};
Surface Loop(4) = {13, 14, 15, 16, 17, 18}; Volume(4) = {4};

// Placentone volume.
Surface Loop(5) = {7, 13, 41, 42, 43, 44, 27, 29, 30, 31, 32, 33, 34, 35, 36}; Volume(5) = {5};

// Cavity volumes (part two).
Surface Loop(6) = {19, 21, 20, 22, 45, 37, 40, 38, 39}; Volume(6) = {6};
Surface Loop(7) = {37, 40, 38, 39, 46, 41, 44, 42, 43}; Volume(7) = {7};

///////////////////////
// Physical surfaces //
///////////////////////
Physical Surface("boundary",       100) = {2, 3, 4, 5, 8, 9, 10, 11, 14, 15, 16, 17, 27, 28, 45, 46, 29, 30, 31, 32};
Physical Surface("boundary-curve", 101) = {33, 34, 35, 36};
Physical Surface("inlet",          111) = {6};
Physical Surface("outlet-1",       211) = {12};
Physical Surface("outlet-2",       212) = {18};

//////////////////////
// Physical volumes //
//////////////////////
Physical Volume("interior", 301) = {5};
Physical Volume("inlets",   412) = {2};
Physical Volume("outlet-1", 411) = {3};
Physical Volume("outlet-2", 413) = {4};
Physical Volume("cavity-i", 501) = {1};
Physical Volume("cavity-m", 511) = {6};
Physical Volume("cavity-o", 521) = {7};
