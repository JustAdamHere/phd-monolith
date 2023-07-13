// Gmsh project created on Thu Mar 17 16:40:34 2022
//   Assumes width of 4cm [1 unit] and inlet/outlet size of 2mm [0.05 units]

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
If (!Exists(h))
	h        = 0.02;
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
inlet_width  = 0.05;              // 2 mm
outlet_width = 0.05;              // 2 mm

// Default cavity size.
If (!Exists(central_cavity_width))
	central_cavity_width = 5*inlet_width; // 10 mm
EndIf
cavity_height = 2*central_cavity_width;

// Default transition region -- added onto the central cavity width.
If (!Exists(central_cavity_transition))
	central_cavity_transition = 0.02; // 0.8 mm
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
Point(1)  = {0,                                                                      0,                                             0, h};
Point(2)  = {outlet_location_1 - outlet_width/2,                                     0,                                             0, h_refine/10};
//Point(3)  = {outlet_location_1 - outlet_width/2,                                     -outlet_width,                                 0, h_refine};
Point(3)  = {outlet_location_1 - outlet_width/2,                                     -outlet_width,                                 0, h_refine/10};
Point(4)  = {outlet_location_1 + outlet_width/2,                                     -outlet_width,                                 0, h_refine};
Point(5)  = {outlet_location_1 + outlet_width/2,                                     0,                                             0, h_refine/10};
Point(6)  = {inlet_location    - inlet_width/2,                                      0,                                             0, h_refine/10};
Point(7)  = {inlet_location    - inlet_width/2,                                      -inlet_width,                                  0, h_refine};
Point(8)  = {inlet_location    + inlet_width/2,                                      -inlet_width,                                  0, h_refine};
Point(9)  = {inlet_location    + inlet_width/2,                                      0,                                             0, h_refine/10};
Point(10) = {outlet_location_2 - outlet_width/2,                                     0,                                             0, h_refine/10};
Point(11) = {outlet_location_2 - outlet_width/2,                                     -outlet_width,                                 0, h_refine};
//Point(12) = {outlet_location_2 + outlet_width/2,                                     -outlet_width,                                 0, h_refine};
Point(12) = {outlet_location_2 + outlet_width/2,                                     -outlet_width,                                 0, h_refine/10};
Point(13) = {outlet_location_2 + outlet_width/2,                                     0,                                             0, h_refine/10};
Point(14) = {1,                                                                      0,                                             0, h};
Point(15) = {1,                                                                      0.5,                                           0, h};
Point(16) = {0.5,                                                                    1,                                             0, h};
Point(17) = {0,                                                                      0.5,                                           0, h};
Point(18) = {0.5,                                                                    0.5,                                           0, h_refine};
Point(19) = {inlet_location - (central_cavity_width + central_cavity_transition)/2,  0,                                             0, h_refine};
Point(22) = {inlet_location,                                                         0,                                             0, h_refine};
Point(21) = {inlet_location + (central_cavity_width + central_cavity_transition)/2,  0,                                             0, h_refine};
Point(20) = {inlet_location,                                                         (cavity_height)/2 + central_cavity_transition, 0, h_refine};
Point(23) = {outlet_location_1,                                                      0,                                             0, h_refine};
Point(24) = {outlet_location_2,                                                      0,                                             0, h_refine};

///////////
// Lines //
///////////
// Placentones.
Line(1)     = {1,  2};
Line(5)     = {5,  19};
Line(9)     = {21,  10};
Line(13)    = {13, 14};
Line(14)    = {14, 15};
Circle(15)  = {15, 18, 17};
Line(16)    = {17, 1};

// Cavity.
Ellipse(21) = {19, 22, 22, 20};
Ellipse(22) = {20, 22, 22, 21};
Line(23)    = {19, 6};
Line(24)    = {6, 22};
Line(25)    = {22, 9};
Line(26)    = {9, 21};

// Pipe 1.
Line(2)     = {2,  3};
Line(3)     = {3,  4};
Line(4)     = {4,  5};
Line(18)    = {5, 23};
Line(19)   =  {23, 2};

// Pipe 2.
Line(6)     = {6,  7};
Line(7)     = {7,  8};
Line(8)     = {8,  9};

// Pipe 3.
Line(10)    = {10, 11};
Line(11)    = {11, 12};
Line(12)    = {12, 13};
Line(20)    = {13, 24};
Line(27)    = {24, 10};

/////////////////////
// Physical curves //
/////////////////////
Physical Curve("boundary",       100) = {1, 2, 4, 5, 23, 6, 8, 26, 9, 10, 12, 13, 14, 16};
Physical Curve("boundary-curve", 101) = {15};
Physical Curve("flow-in",        111) = {7};
Physical Curve("flow-out-1",     211) = {3};
Physical Curve("flow-out-2",     212) = {11};

///////////////////////
// Physical surfaces //
///////////////////////
// Placentone.
Curve Loop(1) = {1, -19, -18, 5, 21, 22, 9, -27, -20, 13, 14, 15, 16};

// Pipes.
Curve Loop(2) = {6, 7, 8, -25, -24};
Curve Loop(3) = {2, 3, 4, 18, 19};
Curve Loop(4) = {10, 11, 12, 20, 27};

// Cavity.
Curve Loop (5) = {23, 24, 25, 26, -22, -21};

Plane Surface(1)                  = {1};
Plane Surface(2)                  = {2};
Plane Surface(3)                  = {3};
Plane Surface(4)                  = {4};
Plane Surface(5)                  = {5};
Physical Surface("interior", 301) = {1};
Physical Surface("inlets",   412) = {2};
Physical Surface("outlet-1", 411) = {3};
Physical Surface("outlet-2", 413) = {4};
Physical Surface("cavity",   501) = {5};
