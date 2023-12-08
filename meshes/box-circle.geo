// Gmsh project created on Thu Mar 17 16:40:34 2022
//   Assumes width of 4cm [1 unit] and inlet/outlet size of 2mm [0.05 units]

SetFactory("OpenCASCADE");

//=/=/=/=/=/=/=/=/=/=//
//=/ OUTPUT FORMAT /=//
//=/  EDGES
//=/   Non-curved boundary: 100
//=/   Curved boundary:     101
//=/   Inlet:               111
//=/   Outlets:             211, 212
//=/  SURFACES
//=/   IVS:      301
//=/   Inlet:    412
//=/   Outlets:  411, 413
//=/   Cavities: 501
//=/
//=/=/=/=/=/=/=/=/=/=//

////////////////////////
// Default parameters //
////////////////////////
If (!Exists(h_background))
	h_background = 0.1;
EndIf
If (!Exists(h_vein_top))
	h_vein_top = h_background/10;
EndIf
If (!Exists(h_vein_bottom))
	h_vein_bottom = h_background/10;
EndIf
If (!Exists(h_artery_top))
	h_artery_top = h_background/10;
EndIf
If (!Exists(h_artery_middle))
	h_artery_middle = h_background/10;
EndIf
If (!Exists(h_artery_bottom))
	h_artery_bottom = h_background/10;
EndIf
If (!Exists(h_cavity_inner))
	h_cavity_inner = h_background/10;
EndIf
If (!Exists(h_cavity_outer))
	h_cavity_outer = h_background/2;
EndIf

Printf("Mesh resolution settings:");
Printf("  h_background    = %f", h_background);
Printf("  h_vein_top      = %f", h_vein_top);
Printf("  h_vein_bottom   = %f", h_vein_bottom);
Printf("  h_artery_top    = %f", h_artery_top);
Printf("  h_artery_middle = %f", h_artery_middle);
Printf("  h_artery_bottom = %f", h_artery_bottom);
Printf("  h_cavity_inner  = %f", h_cavity_inner);
Printf("  h_cavity_outer  = %f", h_cavity_outer);

If (!Exists(location_11))
	location_11 = 0.2;
EndIf
If (!Exists(location_12))
	location_12 = 0.5;
EndIf
If (!Exists(location_13))
	location_13 = 0.8;
EndIf

If (!Exists(fillet_radius))
	fillet_radius = 0.01;
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
	central_cavity_transition = 0.12; // 4.8 mm
EndIf

outlet_location_1 = location_11;
inlet_location    = location_12;
outlet_location_2 = location_13;

If (!Exists(outlet_location_1))
	outlet_location_1 = 0.2;
EndIf
If (!Exists(inlet_location))
	inlet_location = 0.5;
EndIf
If (!Exists(outlet_location_2))
	outlet_location_2 = 0.8;
EndIf

////////////
// Points //
////////////
Point(1)  = {0,                                     0,              0, h_background};
Point(3)  = {outlet_location_1 - vein_width/2,      -vein_width,    0, h_vein_bottom};
Point(4)  = {outlet_location_1 + vein_width/2,      -vein_width,    0, h_vein_bottom};
Point(25) = {inlet_location    - artery_width_sm/2, -artery_length, 0, h_artery_bottom};
Point(26) = {inlet_location    + artery_width_sm/2, -artery_length, 0, h_artery_bottom};
Point(11) = {outlet_location_2 - vein_width/2,      -vein_width,    0, h_vein_bottom};
Point(12) = {outlet_location_2 + vein_width/2,      -vein_width,    0, h_vein_bottom};

Point(14) = {1,                                                                      0,                                             0, h_background};
Point(15) = {1,                                                                      0.5,                                           0, h_background};
Point(16) = {0.5,                                                                    1,                                             0, h_background};
Point(17) = {0,                                                                      0.5,                                           0, h_background};
Point(18) = {0.5,                                                                    0.5,                                           0, 1};
Point(19) = {inlet_location - (central_cavity_width + central_cavity_transition)/2,  0,                                             0, h_cavity_outer};
Point(22) = {inlet_location,                                                         0,                                             0, h_artery_middle};
Point(21) = {inlet_location + (central_cavity_width + central_cavity_transition)/2,  0,                                             0, h_cavity_outer};
Point(20) = {inlet_location,                                                         (cavity_height)/2 + central_cavity_transition, 0, h_cavity_outer};
Point(23) = {outlet_location_1,                                                      0,                                             0, h_vein_top};
Point(24) = {outlet_location_2,                                                      0,                                             0, h_vein_top};

Point(27) = {inlet_location,                                                        (cavity_height)/2,                             0, h_cavity_inner};
Point(28) = {inlet_location,                                                        (cavity_height)/2 - central_cavity_transition, 0, h_cavity_outer};
Point(29) = {inlet_location - (central_cavity_width)/2,                             0,                                             0, h_cavity_inner};
Point(30) = {inlet_location - (central_cavity_width - central_cavity_transition)/2, 0,                                             0, h_cavity_outer};
Point(31) = {inlet_location + (central_cavity_width - central_cavity_transition)/2, 0,                                             0, h_cavity_outer};
Point(32) = {inlet_location + (central_cavity_width)/2,                             0,                                             0, h_cavity_inner};

////////////////////
// Fillets points //
////////////////////
// Outlet 1.
Point(33) = {outlet_location_1 - vein_width/2 - fillet_radius, 0,              0, h_vein_top};
Point(34) = {outlet_location_1 - vein_width/2                , -fillet_radius, 0, h_vein_top};
Point(35) = {outlet_location_1 - vein_width/2 - fillet_radius, -fillet_radius, 0, 1};

Point(36) = {outlet_location_1 + vein_width/2 + fillet_radius, 0,              0, h_vein_top};
Point(37) = {outlet_location_1 + vein_width/2                , -fillet_radius, 0, h_vein_top};
Point(38) = {outlet_location_1 + vein_width/2 + fillet_radius, -fillet_radius, 0, 1};

// Outlet 2.
Point(39) = {outlet_location_2 - vein_width/2 - fillet_radius, 0,              0, h_vein_top};
Point(40) = {outlet_location_2 - vein_width/2                , -fillet_radius, 0, h_vein_top};
Point(41) = {outlet_location_2 - vein_width/2 - fillet_radius, -fillet_radius, 0, 1};

Point(42) = {outlet_location_2 + vein_width/2 + fillet_radius, 0,              0, h_vein_top};
Point(43) = {outlet_location_2 + vein_width/2                , -fillet_radius, 0, h_vein_top};
Point(44) = {outlet_location_2 + vein_width/2 + fillet_radius, -fillet_radius, 0, 1};

// Inlet divergence.
phi = Atan2(artery_width/2 - artery_width_sm/2, artery_length_diverge);
Point(45)  = {inlet_location - artery_width_sm/2 - fillet_radius*Sin(phi),                   -artery_length_diverge + fillet_radius*Cos(phi),                   0, h_artery_middle};
Point(46)  = {inlet_location - artery_width_sm/2,                                            -artery_length_diverge - fillet_radius,                            0, h_artery_middle};
Point(47)  = {inlet_location - artery_width_sm/2 + Tan(Pi/2+phi/2)*fillet_radius*Cos(phi/2), -artery_length_diverge + Tan(Pi/2+phi/2)*fillet_radius*Sin(phi/2), 0, 1};

Point(48)  = {inlet_location + artery_width_sm/2,                                            -artery_length_diverge - fillet_radius,                            0, h_artery_middle};
Point(49)  = {inlet_location + artery_width_sm/2 + fillet_radius*Sin(phi),                   -artery_length_diverge + fillet_radius*Cos(phi),                   0, h_artery_middle};
Point(50)  = {inlet_location + artery_width_sm/2 - Tan(Pi/2+phi/2)*fillet_radius*Cos(phi/2), -artery_length_diverge + Tan(Pi/2+phi/2)*fillet_radius*Sin(phi/2), 0, 1};

// Inlet near cavity.
Point(51)  = {inlet_location - artery_width/2 - fillet_radius,                                   0,                                                0, h_artery_top};
Point(52)  = {inlet_location - artery_width/2 + fillet_radius*Sin(phi),                          -fillet_radius*Cos(phi),                          0, h_artery_top};
Point(53)  = {inlet_location - artery_width/2 - Tan(Pi/4+phi)*fillet_radius*Sin((Pi/2 - phi)/2), -Tan(Pi/4+phi)*fillet_radius*Cos((Pi/2 - phi)/2), 0, 1};

Point(54)  = {inlet_location + artery_width/2 + fillet_radius,                                   0,                                                0, h_artery_top};
Point(55)  = {inlet_location + artery_width/2 - fillet_radius*Sin(phi),                          -fillet_radius*Cos(phi),                          0, h_artery_top};
Point(56)  = {inlet_location + artery_width/2 + Tan(Pi/4+phi)*fillet_radius*Sin((Pi/2 - phi)/2), -Tan(Pi/4+phi)*fillet_radius*Cos((Pi/2 - phi)/2), 0, 1};

///////////
// Lines //
///////////
// Placentones.
Line(1)     = {1,  33};
Line(5)     = {36, 19};
Line(9)     = {21, 39};
Line(13)    = {42, 14};
Line(14)    = {14, 15};
Circle(15)  = {15, 18, 16};
Circle(16)  = {16, 18, 17};
Line(17)    = {17, 1};

// Cavity.
Ellipse(21) = {19, 22, 20, 20};
Ellipse(22) = {20, 22, 20, 21};
Ellipse(30) = {29, 22, 27, 27};
Ellipse(31) = {27, 22, 27, 32};
Ellipse(32) = {30, 22, 28, 28};
Ellipse(33) = {28, 22, 28, 31};
Line(34)    = {19, 29};
Line(35)    = {29, 30};
Line(23)    = {30, 51};
Line(24)    = {51, 22};
Line(25)    = {22, 54};
Line(26)    = {54, 31};
Line(36)    = {31, 32};
Line(37)    = {32, 21};

// Pipe 1.
Line(2)     = {34,  3};
Line(3)     = {3,  4};
Line(4)     = {4,  37};
Line(18)    = {36, 23};
Line(19)   =  {23, 33};

// Pipe 2.
Line(6)     = {52,  45};
Line(28)    = {46, 25};
Line(7)     = {25, 26};
Line(29)    = {26, 48};
Line(8)     = {49, 55};

// Pipe 3.
Line(10)    = {40, 11};
Line(11)    = {11, 12};
Line(12)    = {12, 43};
Line(20)    = {42, 24};
Line(27)    = {24, 39};

///////////////////
// Fillets lines //
///////////////////
// Outlet 1.
Circle(38) = {33, 35, 34};
Circle(39) = {36, 38, 37};

// Outlet 2.
Circle(40) = {39, 41, 40};
Circle(41) = {43, 44, 42};

// Inlet divergence.
Circle(42) = {45, 47, 46};
Circle(43) = {48, 50, 49};

// Inlet near cavity.
Circle(44) = {51, 53, 52};
Circle(45) = {55, 56, 54};

/////////////////////
// Physical curves //
/////////////////////
Physical Curve("boundary",       100) = {1, 38, 2, 4, 39, 5, 34, 35, 23, 44, 6, 42, 28, 29, 43, 8, 45, 26, 36, 37, 9, 40, 10, 12, 41, 13, 14, 17};
Physical Curve("boundary-curve", 101) = {15, 16};
Physical Curve("flow-in",        111) = {7};
Physical Curve("flow-out-1",     211) = {3};
Physical Curve("flow-out-2",     212) = {11};

///////////////////////
// Physical surfaces //
///////////////////////
// Placentone.
Curve Loop(1) = {1, -19, -18, 5, 21, 22, 9, -27, -20, 13, 14, 15, 16, 17};

// Pipes.
Curve Loop(2) = {44, 6, 42, 28, 7, 29, 43, 8, 45, -25, -24};
Curve Loop(3) = {38, 2, 3, 4, 39, 18, 19};
Curve Loop(4) = {40, 10, 11, 12, 41, 20, 27};

// Cavity.
Curve Loop(50) = {23, 24, 25, 26, -33, -32};
Curve Loop(51) = {35, 32, 33, 36, -31, -30};
Curve Loop(52) = {34, 30, 31, 37, -22, -21};

Plane Surface(1)                  = {1};
Plane Surface(2)                  = {2};
Plane Surface(3)                  = {3};
Plane Surface(4)                  = {4};
Plane Surface(50)                 = {50};
Plane Surface(51)                 = {51};
Plane Surface(52)                 = {52};
Physical Surface("interior", 301) = {1};
Physical Surface("inlets",   412) = {2};
Physical Surface("outlet-1", 411) = {3};
Physical Surface("outlet-2", 413) = {4};
Physical Surface("cavity0",  501) = {50};
Physical Surface("cavity1",  511) = {51};
Physical Surface("cavity2",  521) = {52};
