//=/=/=/=/=/=/=/=/=/=//
//=/ OUTPUT FORMAT /=//
//=/  EDGES
//=/   Non-curved boundary: 100
//=/   Curved boundary:     101
//=/   Inlets:              111-116
//=/   Outlets:             211-222
//=/   Corner outlets:      230, 231
//=/   (Septa outlet:       240, 241, 242, 243)
//=/  SURFACES
//=/   Placentones:  301, 302, 303, 304, 305, 306
//=/   Corner pipes: 401, 402
//=/   Pipes:        411, 412, 413, ..., 463
//=/   (Septa pipe:  403, 404, 405, 406)
//=/   Cavities:     501, 502, 503, 504, 505, 506
//=/
//=/=/=/=/=/=/=/=/=/=//

//////////////////////
// Other parameters //
//////////////////////
placentone_width = 1.0;                               // 40 mm
wall_width       = 0.075*placentone_width;            // 3  mm
placenta_width   = 6*placentone_width + 5*wall_width; // 255mm
pipe_width       = 0.05*placentone_width;             // 2  mm
wall_height      = 0.6*placentone_width;              // 24 mm
cavity_width     = 5*pipe_width;                      // 10 mm
cavity_height    = 10*pipe_width;                     // 20 mm

// Turns on or off the septal veins.
septal_vein_1 = 0;
septal_vein_2 = 0;
septal_vein_3 = 0;
septal_vein_4 = 0;

////////////////////////
// Default parameters //
////////////////////////
h = 0.02;
h_refine = 0.02;

If (!Exists(h))
	h        = 0.01;
EndIf
If (!Exists(h_refine))
	h_refine = h/10;
EndIf

Printf("h = %f", h);
Printf("h_refine = %f", h_refine);

// If (!Exists(location_11))
// 	location_11 = (placentone_width + wall_width)*0 + 0.2*placentone_width;
// EndIf
// If (!Exists(location_21))
// 	location_21 = (placentone_width + wall_width)*1 + 0.2*placentone_width;
// EndIf
// If (!Exists(location_31))
// 	location_31 = (placentone_width + wall_width)*2 + 0.2*placentone_width;
// EndIf
// If (!Exists(location_41))
// 	location_41 = (placentone_width + wall_width)*3 + 0.2*placentone_width;
// EndIf
// If (!Exists(location_51))
// 	location_51 = (placentone_width + wall_width)*4 + 0.2*placentone_width;
// EndIf
// If (!Exists(location_61))
// 	location_61 = (placentone_width + wall_width)*5 + 0.2*placentone_width;
// EndIf

// If (!Exists(location_12))
// 	location_12 = (placentone_width + wall_width)*0 + 0.5*placentone_width;
// EndIf
// If (!Exists(location_22))
// 	location_22 = (placentone_width + wall_width)*1 + 0.5*placentone_width;
// EndIf
// If (!Exists(location_32))
// 	location_32 = (placentone_width + wall_width)*2 + 0.5*placentone_width;
// EndIf
// If (!Exists(location_42))
// 	location_42 = (placentone_width + wall_width)*3 + 0.5*placentone_width;
// EndIf
// If (!Exists(location_52))
// 	location_52 = (placentone_width + wall_width)*4 + 0.5*placentone_width;
// EndIf
// If (!Exists(location_62))
// 	location_62 = (placentone_width + wall_width)*5 + 0.5*placentone_width;
// EndIf

// If (!Exists(location_13))
// 	location_13 = (placentone_width + wall_width)*0 + 0.8*placentone_width;
// EndIf
// If (!Exists(location_23))
// 	location_23 = (placentone_width + wall_width)*1 + 0.8*placentone_width;
// EndIf
// If (!Exists(location_33))
// 	location_33 = (placentone_width + wall_width)*2 + 0.8*placentone_width;
// EndIf
// If (!Exists(location_43))
// 	location_43 = (placentone_width + wall_width)*3 + 0.8*placentone_width;
// EndIf
// If (!Exists(location_53))
// 	location_53 = (placentone_width + wall_width)*4 + 0.8*placentone_width;
// EndIf
// If (!Exists(location_63))
// 	location_63 = (placentone_width + wall_width)*5 + 0.8*placentone_width;
// EndIf

If (!Exists(location_11))
	location_11 = 0.2;
EndIf
If (!Exists(location_21))
	location_21 = 0.2;
EndIf
If (!Exists(location_31))
	location_31 = 0.2;
EndIf
If (!Exists(location_41))
	location_41 = 0.2;
EndIf
If (!Exists(location_51))
	location_51 = 0.2;
EndIf
If (!Exists(location_61))
	location_61 = 0.2;
EndIf

If (!Exists(location_12))
	location_12 = 0.5;
EndIf
If (!Exists(location_22))
	location_22 = 0.5;
EndIf
If (!Exists(location_32))
	location_32 = 0.5;
EndIf
If (!Exists(location_42))
	location_42 = 0.5;
EndIf
If (!Exists(location_52))
	location_52 = 0.5;
EndIf
If (!Exists(location_62))
	location_62 = 0.5;
EndIf

If (!Exists(location_13))
	location_13 = 0.8;
EndIf
If (!Exists(location_23))
	location_23 = 0.8;
EndIf
If (!Exists(location_33))
	location_33 = 0.8;
EndIf
If (!Exists(location_43))
	location_43 = 0.8;
EndIf
If (!Exists(location_53))
	location_53 = 0.8;
EndIf
If (!Exists(location_63))
	location_63 = 0.8;
EndIf

If (!Exists(inlet_location_1))
	inlet_location_1 = 1;
EndIf
If (!Exists(inlet_location_2))
	inlet_location_2 = 1;
EndIf
If (!Exists(inlet_location_3))
	inlet_location_3 = 1;
EndIf
If (!Exists(inlet_location_4))
	inlet_location_4 = 1;
EndIf
If (!Exists(inlet_location_5))
	inlet_location_5 = 1;
EndIf
If (!Exists(inlet_location_6))
	inlet_location_6 = 1;
EndIf

///////////////////////
// Circle parameters //
///////////////////////
centre_x = placenta_width/2;
centre_y = (2*centre_x^2)^0.5;
radius   = centre_y;
placenta_height = centre_y - centre_x;

//////////////////////////
// x and y of the walls //
//////////////////////////
wall_low_x = {
	(placentone_width + wall_width)*0 + placentone_width, (placentone_width + wall_width)*0 + placentone_width + wall_width,
	(placentone_width + wall_width)*1 + placentone_width, (placentone_width + wall_width)*1 + placentone_width + wall_width,
	(placentone_width + wall_width)*2 + placentone_width, (placentone_width + wall_width)*2 + placentone_width + wall_width,
	(placentone_width + wall_width)*3 + placentone_width, (placentone_width + wall_width)*3 + placentone_width + wall_width,
	(placentone_width + wall_width)*4 + placentone_width, (placentone_width + wall_width)*4 + placentone_width + wall_width
};

wall_low_y = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
theta_wall = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
For k In {0:9:1}
	wall_low_y[k] = centre_y - (radius^2 - (wall_low_x[k] - centre_x)^2)^0.5;

	If (wall_low_x[k] <= centre_x)
		theta_wall[k] = -Pi - Atan((wall_low_y[k] - centre_y)/(wall_low_x[k] - centre_x));
	EndIf
	If (wall_low_x[k] > centre_x)
		theta_wall[k] =     - Atan((wall_low_y[k] - centre_y)/(wall_low_x[k] - centre_x));
	EndIf
EndFor

wall_top_x = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
wall_top_y = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
For k In {0:9:1}
	wall_top_x[k] = wall_low_x[k] - wall_height*Cos(theta_wall[k]);
	wall_top_y[k] = wall_low_y[k] + wall_height*Sin(theta_wall[k]);
EndFor

///////////////////////////
// Placentone separators //
///////////////////////////
separator_low_x  = {0, 0, 0, 0, 0};
separator_low_y  = {0, 0, 0, 0, 0};
separator_high_x = {0, 0, 0, 0, 0};
separator_high_y = {0, 0, 0, 0, 0};
theta_separator  = {0, 0, 0, 0, 0};

For k In {0:4:1}
	separator_low_x[k] = (wall_top_x[2*k] + wall_top_x[2*k+1])/2;
	separator_low_y[k] = (wall_top_y[2*k] + wall_top_y[2*k+1])/2;

	If (separator_low_x[k] == centre_x)
		theta_separator[k] = 0;
	EndIf
	If (separator_low_x[k] < centre_x)
		theta_separator[k] = Atan((separator_low_x[k] - centre_x)/(separator_low_y[k] - centre_y));
	EndIf
	If (separator_low_x[k] > centre_x)
		theta_separator[k] = Atan((separator_low_x[k] - centre_x)/(separator_low_y[k] - centre_y));
	EndIf

	separator_high_y[k] = placenta_height;
	separator_high_x[k] = (separator_high_y[k] - separator_low_y[k])*Tan(theta_separator[k]) + separator_low_x[k];
EndFor

///////////////////////////////////////////
// inlets and outlet locations and sizes //
///////////////////////////////////////////
location_1_x = {
	(placentone_width + wall_width)*0 + location_11*placentone_width,
	(placentone_width + wall_width)*1 + location_21*placentone_width,
	(placentone_width + wall_width)*2 + location_31*placentone_width,
	(placentone_width + wall_width)*3 + location_41*placentone_width,
	(placentone_width + wall_width)*4 + location_51*placentone_width,
	(placentone_width + wall_width)*5 + location_61*placentone_width
};
location_2_x = {
	(placentone_width + wall_width)*0 + location_12*placentone_width,
	(placentone_width + wall_width)*1 + location_22*placentone_width,
	(placentone_width + wall_width)*2 + location_32*placentone_width,
	(placentone_width + wall_width)*3 + location_42*placentone_width,
	(placentone_width + wall_width)*4 + location_52*placentone_width,
	(placentone_width + wall_width)*5 + location_62*placentone_width
};
location_3_x = {
	(placentone_width + wall_width)*0 + location_13*placentone_width,
	(placentone_width + wall_width)*1 + location_23*placentone_width,
	(placentone_width + wall_width)*2 + location_33*placentone_width,
	(placentone_width + wall_width)*3 + location_43*placentone_width,
	(placentone_width + wall_width)*4 + location_53*placentone_width,
	(placentone_width + wall_width)*5 + location_63*placentone_width
};

location_1_y   = {0, 0, 0, 0, 0, 0};
location_1_y_1 = {0, 0, 0, 0, 0, 0};
location_1_y_2 = {0, 0, 0, 0, 0, 0};
location_2_y   = {0, 0, 0, 0, 0, 0};
location_2_y_1 = {0, 0, 0, 0, 0, 0};
location_2_y_2 = {0, 0, 0, 0, 0, 0};
location_3_y   = {0, 0, 0, 0, 0, 0};
location_3_y_1 = {0, 0, 0, 0, 0, 0};
location_3_y_2 = {0, 0, 0, 0, 0, 0};

location_1_x_1 = {0, 0, 0, 0, 0, 0};
location_1_x_2 = {0, 0, 0, 0, 0, 0};
location_2_x_1 = {0, 0, 0, 0, 0, 0};
location_2_x_2 = {0, 0, 0, 0, 0, 0};
location_3_x_1 = {0, 0, 0, 0, 0, 0};
location_3_x_2 = {0, 0, 0, 0, 0, 0};

For k In {0:5:1}
	location_1_y  [k] = centre_y - (radius^2 - (location_1_x[k]                - centre_x)^2)^0.5;
	location_2_y  [k] = centre_y - (radius^2 - (location_2_x[k]                - centre_x)^2)^0.5;
	location_3_y  [k] = centre_y - (radius^2 - (location_3_x[k]                - centre_x)^2)^0.5;
EndFor

Printf("location_1_y = %f", location_1_y);

theta_pipe = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
For k In {0:5:1}
	theta_pipe[k*3]   = - Atan((location_1_y[k] - centre_y)/(location_1_x[k] - centre_x));
	theta_pipe[k*3+1] = - Atan((location_2_y[k] - centre_y)/(location_2_x[k] - centre_x));
	theta_pipe[k*3+2] = - Atan((location_3_y[k] - centre_y)/(location_3_x[k] - centre_x));

	If (k <= 2)
		theta_pipe[k*3]   = theta_pipe[k*3]   + Pi;
		theta_pipe[k*3+1] = theta_pipe[k*3+1] + Pi;
		theta_pipe[k*3+2] = theta_pipe[k*3+2] + Pi;
	EndIf

	// Printf("%f", theta_pipe[k]);
EndFor

For k In {0:17:1}
	Printf("theta_pipe[%g] = %f", k, theta_pipe[k]);
EndFor

For k In {0:5:1}
	location_1_x_1[k] = centre_x + radius*Cos(theta_pipe[k*3]   + (pipe_width/2)/radius);
	location_1_y_1[k] = centre_y - radius*Sin(theta_pipe[k*3]   + (pipe_width/2)/radius);
	location_1_x_2[k] = centre_x + radius*Cos(theta_pipe[k*3]   - (pipe_width/2)/radius);
	location_1_y_2[k] = centre_y - radius*Sin(theta_pipe[k*3]   - (pipe_width/2)/radius);

	location_2_x_1[k] = centre_x + radius*Cos(theta_pipe[k*3+1] + (pipe_width/2)/radius);
	location_2_y_1[k] = centre_y - radius*Sin(theta_pipe[k*3+1] + (pipe_width/2)/radius);
	location_2_x_2[k] = centre_x + radius*Cos(theta_pipe[k*3+1] - (pipe_width/2)/radius);
	location_2_y_2[k] = centre_y - radius*Sin(theta_pipe[k*3+1] - (pipe_width/2)/radius);

	location_3_x_1[k] = centre_x + radius*Cos(theta_pipe[k*3+2] + (pipe_width/2)/radius);
	location_3_y_1[k] = centre_y - radius*Sin(theta_pipe[k*3+2] + (pipe_width/2)/radius);
	location_3_x_2[k] = centre_x + radius*Cos(theta_pipe[k*3+2] - (pipe_width/2)/radius);
	location_3_y_2[k] = centre_y - radius*Sin(theta_pipe[k*3+2] - (pipe_width/2)/radius);
EndFor

/////////////////////
// Bottom of pipes //
/////////////////////
location_1_x_pipe1 = {0, 0, 0, 0, 0, 0};
location_1_x_pipe2 = {0, 0, 0, 0, 0, 0};
location_2_x_pipe1 = {0, 0, 0, 0, 0, 0};
location_2_x_pipe2 = {0, 0, 0, 0, 0, 0};
location_3_x_pipe1 = {0, 0, 0, 0, 0, 0};
location_3_x_pipe2 = {0, 0, 0, 0, 0, 0};
location_4_x_pipe1 = {0, 0, 0, 0, 0, 0};
location_4_x_pipe2 = {0, 0, 0, 0, 0, 0};
location_5_x_pipe1 = {0, 0, 0, 0, 0, 0};
location_5_x_pipe2 = {0, 0, 0, 0, 0, 0};
location_6_x_pipe1 = {0, 0, 0, 0, 0, 0};
location_6_x_pipe2 = {0, 0, 0, 0, 0, 0};

location_1_y_pipe1 = {0, 0, 0, 0, 0, 0};
location_1_y_pipe2 = {0, 0, 0, 0, 0, 0};
location_2_y_pipe1 = {0, 0, 0, 0, 0, 0};
location_2_y_pipe2 = {0, 0, 0, 0, 0, 0};
location_3_y_pipe1 = {0, 0, 0, 0, 0, 0};
location_3_y_pipe2 = {0, 0, 0, 0, 0, 0};
location_4_y_pipe1 = {0, 0, 0, 0, 0, 0};
location_4_y_pipe2 = {0, 0, 0, 0, 0, 0};
location_5_y_pipe1 = {0, 0, 0, 0, 0, 0};
location_5_y_pipe2 = {0, 0, 0, 0, 0, 0};
location_6_y_pipe1 = {0, 0, 0, 0, 0, 0};
location_6_y_pipe2 = {0, 0, 0, 0, 0, 0};

For k In {0:5:1}
	location_1_x_pipe1[k] = location_1_x_1[k] + pipe_width*Cos(theta_pipe[k*3]);
	location_1_y_pipe1[k] = location_1_y_1[k] - pipe_width*Sin(theta_pipe[k*3]);
	location_2_x_pipe1[k] = location_2_x_1[k] + pipe_width*Cos(theta_pipe[k*3+1]);
	location_2_y_pipe1[k] = location_2_y_1[k] - pipe_width*Sin(theta_pipe[k*3+1]);
	location_3_x_pipe1[k] = location_3_x_1[k] + pipe_width*Cos(theta_pipe[k*3+2]);
	location_3_y_pipe1[k] = location_3_y_1[k] - pipe_width*Sin(theta_pipe[k*3+2]);

	location_1_x_pipe2[k] = location_1_x_2[k] + pipe_width*Cos(theta_pipe[k*3]);
	location_1_y_pipe2[k] = location_1_y_2[k] - pipe_width*Sin(theta_pipe[k*3]);
	location_2_x_pipe2[k] = location_2_x_2[k] + pipe_width*Cos(theta_pipe[k*3+1]);
	location_2_y_pipe2[k] = location_2_y_2[k] - pipe_width*Sin(theta_pipe[k*3+1]);
	location_3_x_pipe2[k] = location_3_x_2[k] + pipe_width*Cos(theta_pipe[k*3+2]);
	location_3_y_pipe2[k] = location_3_y_2[k] - pipe_width*Sin(theta_pipe[k*3+2]);
EndFor

///////////////////////////
// Central cavity points //
///////////////////////////
cavity_x_1 = {0, 0, 0, 0, 0, 0};
cavity_x_2 = {0, 0, 0, 0, 0, 0};
cavity_x_3 = {0, 0, 0, 0, 0, 0};

cavity_y_1 = {0, 0, 0, 0, 0, 0};
cavity_y_2 = {0, 0, 0, 0, 0, 0};
cavity_y_3 = {0, 0, 0, 0, 0, 0};

For k In {0:5:1}
	cavity_x_2[k] = (location_2_x_1[k] + location_2_x_2[k])/2;
	cavity_y_2[k] = centre_y - (radius^2 - (centre_x - cavity_x_2[k])^2)^0.5;

	cavity_x_1[k] = centre_x + radius*Cos(theta_pipe[k*3+1] + (cavity_width/2)/radius);
	cavity_y_1[k] = centre_y - radius*Sin(theta_pipe[k*3+1] + (cavity_width/2)/radius);

	cavity_x_3[k] = centre_x + radius*Cos(theta_pipe[k*3+1] - (cavity_width/2)/radius);
	cavity_y_3[k] = centre_y - radius*Sin(theta_pipe[k*3+1] - (cavity_width/2)/radius);
EndFor

////////////////////////////////////////
// Point and line number calculations //
////////////////////////////////////////
numbering_start = 1100;
placentone_step = 100;

////////////
// Points //
////////////
// Circle centre and placentone corners
Point(1000) = {centre_x,                      centre_y,                                                                 0, h};
Point(1001) = {2*pipe_width,                  centre_y - (radius^2 - (2*pipe_width       - centre_x)^2)^0.5,            0, h_refine};
Point(1002) = {placenta_width - 2*pipe_width, centre_y - (radius^2 - (placenta_width - 2*pipe_width - centre_x)^2)^0.5, 0, h_refine};
Point(1003) = {placenta_width,                centre_y - (radius^2 - (placenta_width - 2*pipe_width - centre_x)^2)^0.5, 0, h_refine};
Point(1004) = {placenta_width,                placenta_height,                                                          0, h_refine};
Point(1005) = {placenta_width - 2*pipe_width, placenta_height,                                                          0, h_refine};
Point(1006) = {2*pipe_width,                  placenta_height,                                                          0, h_refine};
Point(1007) = {0.0,                           placenta_height,                                                          0, h_refine};
Point(1008) = {0.0,                           centre_y - (radius^2 - (placenta_width - 2*pipe_width - centre_x)^2)^0.5, 0, h_refine};

// Placentones.
For k In {0:5:1}
	Point(numbering_start + k*placentone_step + 1)   = {location_1_x_1[k],     location_1_y_1[k],     0, h_refine};
	Point(numbering_start + k*placentone_step + 2)   = {location_1_x_pipe1[k], location_1_y_pipe1[k], 0, h_refine};
	Point(numbering_start + k*placentone_step + 3)   = {location_1_x_pipe2[k], location_1_y_pipe2[k], 0, h_refine};
	Point(numbering_start + k*placentone_step + 4)   = {location_1_x_2[k],     location_1_y_2[k],     0, h_refine};
	Point(numbering_start + k*placentone_step + 5)   = {location_2_x_1[k],     location_2_y_1[k],     0, h_refine};
	Point(numbering_start + k*placentone_step + 6)   = {location_2_x_pipe1[k], location_2_y_pipe1[k], 0, h_refine};
	Point(numbering_start + k*placentone_step + 7)   = {location_2_x_pipe2[k], location_2_y_pipe2[k], 0, h_refine};
	Point(numbering_start + k*placentone_step + 8)   = {location_2_x_2[k],     location_2_y_2[k],     0, h_refine};
	Point(numbering_start + k*placentone_step + 9)   = {location_3_x_1[k],     location_3_y_1[k],     0, h_refine};
	Point(numbering_start + k*placentone_step + 10)  = {location_3_x_pipe1[k], location_3_y_pipe1[k], 0, h_refine};
	Point(numbering_start + k*placentone_step + 11)  = {location_3_x_pipe2[k], location_3_y_pipe2[k], 0, h_refine};
	Point(numbering_start + k*placentone_step + 12)  = {location_3_x_2[k],     location_3_y_2[k],     0, h_refine};
EndFor

// Walls.
For k In {0:4:1}
	Point(numbering_start + k*placentone_step + 13) = {wall_low_x[2*k+0], wall_low_y[2*k+0], 0, h};
	Point(numbering_start + k*placentone_step + 14) = {wall_top_x[2*k+0], wall_top_y[2*k+0], 0, h};
	Point(numbering_start + k*placentone_step + 16) = {wall_top_x[2*k+1], wall_top_y[2*k+1], 0, h};
	Point(numbering_start + k*placentone_step + 17) = {wall_low_x[2*k+1], wall_low_y[2*k+1], 0, h};
EndFor

// Placentone separators.
For k In {0:4:1}
	Point(numbering_start + k*placentone_step + 15) = {separator_low_x[k],  separator_low_y[k],  0, h};
	Point(numbering_start + k*placentone_step + 18) = {separator_high_x[k], separator_high_y[k], 0, h};
EndFor

// Point(15) = {separator_low_x[0], separator_low_y[0], 0, h};
// Point(35) = {separator_low_x[1], separator_low_y[1], 0, h};
// Point(55) = {separator_low_x[2], separator_low_y[2], 0, h};
// Point(75) = {separator_low_x[3], separator_low_y[3], 0, h};
// Point(95) = {separator_low_x[4], separator_low_y[4], 0, h};

// Point(18) = {separator_high_x[0], separator_high_y[0], 0, h};
// Point(38) = {separator_high_x[1], separator_high_y[1], 0, h};
// Point(58) = {separator_high_x[2], separator_high_y[2], 0, h};
// Point(78) = {separator_high_x[3], separator_high_y[3], 0, h};
// Point(98) = {separator_high_x[4], separator_high_y[4], 0, h};

// Central cavities.
For k In {0:5:1}
	offset = numbering_start + k*placentone_step;
	Point(offset + 19) = {cavity_x_1[k], cavity_y_1[k], 0, h_refine};
	Point(offset + 22) = {cavity_x_2[k], cavity_y_2[k], 0, h_refine};
	Point(offset + 21) = {cavity_x_3[k], cavity_y_3[k], 0, h_refine};
	Point(offset + 20) = {cavity_x_2[k] - (cavity_height/2)*Cos(theta_pipe[3*k+1]), cavity_y_2[k] + (cavity_height/2)*Sin(theta_pipe[3*k+1]), 0, h_refine};
EndFor

// Point(211) = {cavity_x_1[0], cavity_y_1[0], 0, h};
// Point(221) = {cavity_x_1[1], cavity_y_1[1], 0, h};
// Point(231) = {cavity_x_1[2], cavity_y_1[2], 0, h};
// Point(241) = {cavity_x_1[3], cavity_y_1[3], 0, h};
// Point(251) = {cavity_x_1[4], cavity_y_1[4], 0, h};
// Point(261) = {cavity_x_1[5], cavity_y_1[5], 0, h};

// Point(212) = {cavity_x_2[0], cavity_y_2[0], 0, h};
// Point(222) = {cavity_x_2[1], cavity_y_2[1], 0, h};
// Point(232) = {cavity_x_2[2], cavity_y_2[2], 0, h};
// Point(242) = {cavity_x_2[3], cavity_y_2[3], 0, h};
// Point(252) = {cavity_x_2[4], cavity_y_2[4], 0, h};
// Point(262) = {cavity_x_2[5], cavity_y_2[5], 0, h};

// Point(213) = {cavity_x_3[0], cavity_y_3[0], 0, h};
// Point(223) = {cavity_x_3[1], cavity_y_3[1], 0, h};
// Point(233) = {cavity_x_3[2], cavity_y_3[2], 0, h};
// Point(243) = {cavity_x_3[3], cavity_y_3[3], 0, h};
// Point(253) = {cavity_x_3[4], cavity_y_3[4], 0, h};
// Point(263) = {cavity_x_3[5], cavity_y_3[5], 0, h};

// Point(214) = {cavity_x_2[0] - (cavity_height/2)*Cos(theta_pipe[3*0+1]), cavity_y_2[0] + (cavity_height/2)*Sin(theta_pipe[3*0+1]), 0, h};
// Point(224) = {cavity_x_2[1] - (cavity_height/2)*Cos(theta_pipe[3*1+1]), cavity_y_2[1] + (cavity_height/2)*Sin(theta_pipe[3*1+1]), 0, h};
// Point(234) = {cavity_x_2[2] - (cavity_height/2)*Cos(theta_pipe[3*2+1]), cavity_y_2[2] + (cavity_height/2)*Sin(theta_pipe[3*2+1]), 0, h};
// Point(244) = {cavity_x_2[3] - (cavity_height/2)*Cos(theta_pipe[3*3+1]), cavity_y_2[3] + (cavity_height/2)*Sin(theta_pipe[3*3+1]), 0, h};
// Point(254) = {cavity_x_2[4] - (cavity_height/2)*Cos(theta_pipe[3*4+1]), cavity_y_2[4] + (cavity_height/2)*Sin(theta_pipe[3*4+1]), 0, h};
// Point(264) = {cavity_x_2[5] - (cavity_height/2)*Cos(theta_pipe[3*5+1]), cavity_y_2[5] + (cavity_height/2)*Sin(theta_pipe[3*5+1]), 0, h};

// Septal vein on right of 4th wall.
If (septal_vein_1 == 1)
	septal_vein_location_x = wall_low_x[7] + 0.5*(wall_top_x[7] - wall_low_x[7]);
	septal_vein_location_y = wall_low_y[7] + 0.5*(wall_top_y[7] - wall_low_y[7]);

	septal_vein_left_x  = septal_vein_location_x + (pipe_width/2)*Cos(theta_wall[3]);
	septal_vein_left_y  = septal_vein_location_y + (pipe_width/2)*Sin(theta_wall[3]);
	septal_vein_right_x = septal_vein_location_x - (pipe_width/2)*Cos(theta_wall[3]);
	septal_vein_right_y = septal_vein_location_y - (pipe_width/2)*Sin(theta_wall[3]);

	septal_vein_pipe_left_x  = septal_vein_left_x  - pipe_width*Sin(theta_wall[3]);
	septal_vein_pipe_left_y  = septal_vein_left_y  + pipe_width*Cos(theta_wall[3]);
	septal_vein_pipe_right_x = septal_vein_right_x - pipe_width*Sin(theta_wall[3]);
	septal_vein_pipe_right_y = septal_vein_right_y + pipe_width*Cos(theta_wall[3]);

	Point(400) = {septal_vein_left_x,       septal_vein_left_y,       0, h_refine};
	Point(401) = {septal_vein_pipe_left_x,  septal_vein_pipe_left_y,  0, h_refine};
	Point(402) = {septal_vein_pipe_right_x, septal_vein_pipe_right_y, 0, h_refine};
	Point(403) = {septal_vein_right_x,      septal_vein_right_y,      0, h_refine};

	Printf("sv[1]_x = %f", septal_vein_location_x);
	Printf("sv[1]_y = %f", septal_vein_location_y);
EndIf

// Septal vein on right of 5th wall.
If (septal_vein_2 == 1)
	septal_vein_location_x = wall_low_x[9] + 0.2*(wall_top_x[9] - wall_low_x[9]);
	septal_vein_location_y = wall_low_y[9] + 0.2*(wall_top_y[9] - wall_low_y[9]);

	septal_vein_left_x  = septal_vein_location_x + (pipe_width/2)*Cos(theta_wall[1]);
	septal_vein_left_y  = septal_vein_location_y + (pipe_width/2)*Sin(theta_wall[1]);
	septal_vein_right_x = septal_vein_location_x - (pipe_width/2)*Cos(theta_wall[1]);
	septal_vein_right_y = septal_vein_location_y - (pipe_width/2)*Sin(theta_wall[1]);

	septal_vein_pipe_left_x  = septal_vein_left_x  - pipe_width*Sin(theta_wall[1]);
	septal_vein_pipe_left_y  = septal_vein_left_y  + pipe_width*Cos(theta_wall[1]);
	septal_vein_pipe_right_x = septal_vein_right_x - pipe_width*Sin(theta_wall[1]);
	septal_vein_pipe_right_y = septal_vein_right_y + pipe_width*Cos(theta_wall[1]);

	Point(410) = {septal_vein_left_x,       septal_vein_left_y,       0, h_refine};
	Point(411) = {septal_vein_pipe_left_x,  septal_vein_pipe_left_y,  0, h_refine};
	Point(412) = {septal_vein_pipe_right_x, septal_vein_pipe_right_y, 0, h_refine};
	Point(413) = {septal_vein_right_x,      septal_vein_right_y,      0, h_refine};

	Printf("sv[2]_x = %f", septal_vein_location_x);
	Printf("sv[2]_y = %f", septal_vein_location_y);
EndIf

// Septal vein on right of 2nd wall.
If (septal_vein_3 == 1)
	septal_vein_location_x = wall_low_x[3] + 0.8*(wall_top_x[3] - wall_low_x[3]);
	septal_vein_location_y = wall_low_y[3] + 0.8*(wall_top_y[3] - wall_low_y[3]);

	septal_vein_left_x  = septal_vein_location_x + (pipe_width/2)*Cos(theta_wall[6]);
	septal_vein_left_y  = septal_vein_location_y + (pipe_width/2)*Sin(theta_wall[6]);
	septal_vein_right_x = septal_vein_location_x - (pipe_width/2)*Cos(theta_wall[6]);
	septal_vein_right_y = septal_vein_location_y - (pipe_width/2)*Sin(theta_wall[6]);

	septal_vein_pipe_left_x  = septal_vein_left_x  - pipe_width*Sin(theta_wall[6]);
	septal_vein_pipe_left_y  = septal_vein_left_y  + pipe_width*Cos(theta_wall[6]);
	septal_vein_pipe_right_x = septal_vein_right_x - pipe_width*Sin(theta_wall[6]);
	septal_vein_pipe_right_y = septal_vein_right_y + pipe_width*Cos(theta_wall[6]);

	Point(420) = {septal_vein_left_x,       septal_vein_left_y,       0, h_refine};
	Point(421) = {septal_vein_pipe_left_x,  septal_vein_pipe_left_y,  0, h_refine};
	Point(422) = {septal_vein_pipe_right_x, septal_vein_pipe_right_y, 0, h_refine};
	Point(423) = {septal_vein_right_x,      septal_vein_right_y,      0, h_refine};

	Printf("sv[3]_x = %f", septal_vein_location_x);
	Printf("sv[3]_y = %f", septal_vein_location_y);
EndIf

// Septal vein on right of 1st wall.
If (septal_vein_4 == 1)
	septal_vein_location_x = wall_low_x[0] + 0.5*(wall_top_x[0] - wall_low_x[0]);
	septal_vein_location_y = wall_low_y[0] + 0.5*(wall_top_y[0] - wall_low_y[0]);

	septal_vein_left_x  = septal_vein_location_x + (pipe_width/2)*Cos(theta_wall[9]);
	septal_vein_left_y  = septal_vein_location_y + (pipe_width/2)*Sin(theta_wall[9]);
	septal_vein_right_x = septal_vein_location_x - (pipe_width/2)*Cos(theta_wall[9]);
	septal_vein_right_y = septal_vein_location_y - (pipe_width/2)*Sin(theta_wall[9]);

	septal_vein_pipe_left_x  = septal_vein_left_x  + pipe_width*Sin(theta_wall[9]);
	septal_vein_pipe_left_y  = septal_vein_left_y  - pipe_width*Cos(theta_wall[9]);
	septal_vein_pipe_right_x = septal_vein_right_x + pipe_width*Sin(theta_wall[9]);
	septal_vein_pipe_right_y = septal_vein_right_y - pipe_width*Cos(theta_wall[9]);

	Point(430) = {septal_vein_left_x,       septal_vein_left_y,       0, h_refine};
	Point(431) = {septal_vein_pipe_left_x,  septal_vein_pipe_left_y,  0, h_refine};
	Point(432) = {septal_vein_pipe_right_x, septal_vein_pipe_right_y, 0, h_refine};
	Point(433) = {septal_vein_right_x,      septal_vein_right_y,      0, h_refine};

	Printf("sv[4]_x = %f", septal_vein_location_x);
	Printf("sv[4]_y = %f", septal_vein_location_y);
EndIf

/////////////////
// Placentones //
/////////////////
For k In {0:5:1}
	If (k == 0)
		Circle(numbering_start + k*placentone_step + 1)   = {1001, 1000, numbering_start + k*placentone_step + 1};
	EndIf
	If (k != 0)
		Circle(numbering_start + k*placentone_step + 1)   = {numbering_start + (k-1)*placentone_step + 17, 1000, numbering_start + k*placentone_step + 1};
	EndIf
	Circle(numbering_start + k*placentone_step + 5)   = {numbering_start + k*    placentone_step + 4,  1000, numbering_start + k*placentone_step + 19};
	Circle(numbering_start + k*placentone_step + 23)  = {numbering_start + k*    placentone_step + 19, 1000, numbering_start + k*placentone_step + 5};
	Circle(numbering_start + k*placentone_step + 26)  = {numbering_start + k*    placentone_step + 8,  1000, numbering_start + k*placentone_step + 21};
	Circle(numbering_start + k*placentone_step + 9)   = {numbering_start + k*    placentone_step + 21, 1000, numbering_start + k*placentone_step + 9};
	If (k != 5)
		Circle(numbering_start + k*placentone_step + 13)  = {numbering_start + k*    placentone_step + 12, 1000, numbering_start + k*placentone_step + 13};
	EndIf
	If (k == 5)
		Circle(numbering_start + k*placentone_step + 13)  = {numbering_start + k*    placentone_step + 12, 1000, 1002};
	EndIf
EndFor

///////////
// Pipes //
///////////
For k In {0:5:1}
	Line(numbering_start + k*placentone_step + 2)   = {numbering_start + k*placentone_step + 1,  numbering_start + k*placentone_step + 2};
	Line(numbering_start + k*placentone_step + 3)   = {numbering_start + k*placentone_step + 2,  numbering_start + k*placentone_step + 3};
	Line(numbering_start + k*placentone_step + 4)   = {numbering_start + k*placentone_step + 3,  numbering_start + k*placentone_step + 4};
	Line(numbering_start + k*placentone_step + 6)   = {numbering_start + k*placentone_step + 5,  numbering_start + k*placentone_step + 6};
	Line(numbering_start + k*placentone_step + 7)   = {numbering_start + k*placentone_step + 6,  numbering_start + k*placentone_step + 7};
	Line(numbering_start + k*placentone_step + 8)   = {numbering_start + k*placentone_step + 7,  numbering_start + k*placentone_step + 8};
	Line(numbering_start + k*placentone_step + 10)  = {numbering_start + k*placentone_step + 9,  numbering_start + k*placentone_step + 10};
	Line(numbering_start + k*placentone_step + 11)  = {numbering_start + k*placentone_step + 10, numbering_start + k*placentone_step + 11};
	Line(numbering_start + k*placentone_step + 12)  = {numbering_start + k*placentone_step + 11, numbering_start + k*placentone_step + 12};

	Circle(numbering_start + k*placentone_step + 18) = {numbering_start + k*placentone_step + 1,  1000, numbering_start + k*placentone_step + 4};
	Circle(numbering_start + k*placentone_step + 24) = {numbering_start + k*placentone_step + 5,  1000, numbering_start + k*placentone_step + 22};
	Circle(numbering_start + k*placentone_step + 25) = {numbering_start + k*placentone_step + 22, 1000, numbering_start + k*placentone_step + 8};
	Circle(numbering_start + k*placentone_step + 20) = {numbering_start + k*placentone_step + 9,  1000, numbering_start + k*placentone_step + 12};
EndFor

///////////
// Walls //
///////////
offset = numbering_start + 0*placentone_step;

If (septal_vein_4 == 1)
	Line(430)          = {offset + 13,  433};
	Line(431)          = {433,          432};
	Line(432)          = {432,          431};
	Line(433)          = {431,          430};
	Line(434)          = {430,          offset + 14};
	Line(offset + 14)  = {433,          430};
EndIf
If (septal_vein_4 == 0)
	Line(offset + 14) = {offset + 13, offset + 14};
EndIf
Line(offset + 15) = {offset + 14, offset + 15};
Line(offset + 16) = {offset + 15, offset + 16};
Line(offset + 17) = {offset + 16, offset + 17};

offset = numbering_start + 1*placentone_step;

Line(offset + 14) = {offset + 13, offset + 14};
Line(offset + 15) = {offset + 14, offset + 15};
Line(offset + 16) = {offset + 15, offset + 16};
If (septal_vein_3 == 1)
	Line(420)          = {offset + 16,  420};
	Line(421)          = {420,          421};
	Line(422)          = {421,          422};
	Line(423)          = {422,          423};
	Line(424)          = {423,          offset + 17};
	Line(offset + 17)  = {420,          423};
EndIf
If (septal_vein_3 == 0)
	Line(offset + 17) = {offset + 16, offset + 17};
EndIf

offset = numbering_start + 2*placentone_step;

Line(offset + 14) = {offset + 13, offset + 14};
Line(offset + 15) = {offset + 14, offset + 15};
Line(offset + 16) = {offset + 15, offset + 16};
Line(offset + 17) = {offset + 16, offset + 17};

offset = numbering_start + 3*placentone_step;

Line(offset + 14) = {offset + 13, offset + 14};
Line(offset + 15) = {offset + 14, offset + 15};
Line(offset + 16) = {offset + 15, offset + 16};
If (septal_vein_1 == 1)
	Line(400)          = {offset + 16,  400};
	Line(401)          = {400,          401};
	Line(402)          = {401,          402};
	Line(403)          = {402,          403};
	Line(404)          = {403,          offset + 17};
	Line(offset + 17)  = {400,          403};
EndIf
If (septal_vein_1 == 0)
	Line(offset + 17) = {offset + 16, offset + 17};
EndIf

offset = numbering_start + 4*placentone_step;

Line(offset + 14) = {offset + 13, offset + 14};
Line(offset + 15) = {offset + 14, offset + 15};
Line(offset + 16) = {offset + 15, offset + 16};
If (septal_vein_2 == 1)
	Line(410)          = {offset + 16, 410};
	Line(411)          = {410,         411};
	Line(412)          = {411,         412};
	Line(413)          = {412,         413};
	Line(414)          = {413,         offset + 17};
	Line(offset + 17)  = {410,         413};
EndIf
If (septal_vein_2 == 0)
	Line(offset + 17) = {offset + 16, offset + 17};
EndIf

/////////////////
// Fetal plate //
/////////////////
Line(301) = {1005,                                     numbering_start + 4*placentone_step + 18};
Line(302) = {numbering_start + 4*placentone_step + 18, numbering_start + 3*placentone_step + 18};
Line(303) = {numbering_start + 3*placentone_step + 18, numbering_start + 2*placentone_step + 18};
Line(304) = {numbering_start + 2*placentone_step + 18, numbering_start + 1*placentone_step + 18};
Line(305) = {numbering_start + 1*placentone_step + 18, numbering_start + 0*placentone_step + 18};
Line(306) = {numbering_start + 0*placentone_step + 18, 1006};

///////////////////////////
// Placentone separators //
///////////////////////////
Line(201) = {numbering_start + 0*placentone_step + 15, numbering_start + 0*placentone_step + 18};
Line(202) = {numbering_start + 1*placentone_step + 15, numbering_start + 1*placentone_step + 18};
Line(203) = {numbering_start + 2*placentone_step + 15, numbering_start + 2*placentone_step + 18};
Line(204) = {numbering_start + 3*placentone_step + 15, numbering_start + 3*placentone_step + 18};
Line(205) = {numbering_start + 4*placentone_step + 15, numbering_start + 4*placentone_step + 18};

////////////////////
// Corner outlets //
////////////////////
Line(1003) = {1002, 1003};
Line(1004) = {1003, 1004};
Line(1005) = {1004, 1005};
Line(1006) = {1002, 1005};

Line(1007) = {1006, 1007};
Line(1008) = {1007, 1008};
Line(1009) = {1008, 1001};
Line(1010) = {1006, 1001};

//////////////////////
// Central cavities //
//////////////////////
For k In {0:5:1}
	offset = numbering_start + k*placentone_step;

	Ellipse(offset + 21) = {offset + 19, offset + 22, offset + 22, offset + 20};
	Ellipse(offset + 22) = {offset + 20, offset + 22, offset + 22, offset + 21};
EndFor

//////////////////////////////////
// Physical curves and surfaces //
//////////////////////////////////
// Walls.
offset = numbering_start + 0*placentone_step;

Physical Curve("boundary", 100)  = {offset + 15, offset + 16, offset + 17};
If (septal_vein_4 == 1)
	Physical Curve("boundary", 100) += {430, 431, 433, 434};
EndIf
If (septal_vein_4 == 0)
	Physical Curve("boundary", 100) += {offset + 14};
EndIf

offset = numbering_start + 1*placentone_step;

Physical Curve("boundary", 100) += {offset + 14, offset + 15, offset + 16};
If (septal_vein_3 == 1)
	Physical Curve("boundary", 100) += {420, 421, 423, 424};
EndIf
If (septal_vein_3 == 0)
	Physical Curve("boundary", 100) += {offset + 17};
EndIf

offset = numbering_start + 2*placentone_step;

Physical Curve("boundary", 100) += {offset + 14, offset + 15, offset + 16, offset + 17};

// Physical Curve("boundary", 100) += {offset + 14, offset + 15, offset + 16};
// If (septal_vein_3 == 1)
// 	Physical Curve("boundary", 100) += {420, 421, 423, 424};
// EndIf
// If (septal_vein_3 == 0)
// 	Physical Curve("boundary", 100) += {offset + 17};
// EndIf

offset = numbering_start + 3*placentone_step;

Physical Curve("boundary", 100) += {offset + 14, offset + 15, offset + 16};
Physical Curve("boundary", 100) += {offset + 14, offset + 15, offset + 16};
If (septal_vein_1 == 1)
	Physical Curve("boundary", 100) += {400, 401, 403, 404};
EndIf
If (septal_vein_1 == 0)
	Physical Curve("boundary", 100) += {offset + 17};
EndIf

offset = numbering_start + 4*placentone_step;

Physical Curve("boundary", 100) += {offset + 14, offset + 15, offset + 16};
If (septal_vein_2 == 1)
	Physical Curve("boundary", 100) += {410, 411, 413, 414};
EndIf
If (septal_vein_2 == 0)
	Physical Curve("boundary", 100) += {offset + 17};
EndIf

// Pipe sides.
Physical Curve("boundary", 100) += {numbering_start + 0*placentone_step + 2, numbering_start + 0*placentone_step + 4, numbering_start + 0*placentone_step + 6, numbering_start + 0*placentone_step + 8, numbering_start + 0*placentone_step + 10, numbering_start + 0*placentone_step + 12};
Physical Curve("boundary", 100) += {numbering_start + 1*placentone_step + 2, numbering_start + 1*placentone_step + 4, numbering_start + 1*placentone_step + 6, numbering_start + 1*placentone_step + 8, numbering_start + 1*placentone_step + 10, numbering_start + 1*placentone_step + 12};
Physical Curve("boundary", 100) += {numbering_start + 2*placentone_step + 2, numbering_start + 2*placentone_step + 4, numbering_start + 2*placentone_step + 6, numbering_start + 2*placentone_step + 8, numbering_start + 2*placentone_step + 10, numbering_start + 2*placentone_step + 12};
Physical Curve("boundary", 100) += {numbering_start + 3*placentone_step + 2, numbering_start + 3*placentone_step + 4, numbering_start + 3*placentone_step + 6, numbering_start + 3*placentone_step + 8, numbering_start + 3*placentone_step + 10, numbering_start + 3*placentone_step + 12};
Physical Curve("boundary", 100) += {numbering_start + 4*placentone_step + 2, numbering_start + 4*placentone_step + 4, numbering_start + 4*placentone_step + 6, numbering_start + 4*placentone_step + 8, numbering_start + 4*placentone_step + 10, numbering_start + 4*placentone_step + 12};
Physical Curve("boundary", 100) += {numbering_start + 5*placentone_step + 2, numbering_start + 5*placentone_step + 4, numbering_start + 5*placentone_step + 6, numbering_start + 5*placentone_step + 8, numbering_start + 5*placentone_step + 10, numbering_start + 5*placentone_step + 12};

Physical Curve("boundary", 100) += {1007, 1009};
Physical Curve("boundary", 100) += {1003, 1005};

// Basal plate.
Physical Curve("boundary", 100) += {301, 302, 303, 304, 305, 306};

// Curved boundary.
Physical Curve("boundary-curve", 101)  = {numbering_start + 0*placentone_step + 1, numbering_start + 0*placentone_step + 5, numbering_start + 0*placentone_step + 23, numbering_start + 0*placentone_step + 26, numbering_start + 0*placentone_step + 9, numbering_start + 0*placentone_step + 13};
Physical Curve("boundary-curve", 101) += {numbering_start + 1*placentone_step + 1, numbering_start + 1*placentone_step + 5, numbering_start + 1*placentone_step + 23, numbering_start + 1*placentone_step + 26, numbering_start + 1*placentone_step + 9, numbering_start + 1*placentone_step + 13};
Physical Curve("boundary-curve", 101) += {numbering_start + 2*placentone_step + 1, numbering_start + 2*placentone_step + 5, numbering_start + 2*placentone_step + 23, numbering_start + 2*placentone_step + 26, numbering_start + 2*placentone_step + 9, numbering_start + 2*placentone_step + 13};
Physical Curve("boundary-curve", 101) += {numbering_start + 3*placentone_step + 1, numbering_start + 3*placentone_step + 5, numbering_start + 3*placentone_step + 23, numbering_start + 3*placentone_step + 26, numbering_start + 3*placentone_step + 9, numbering_start + 3*placentone_step + 13};
Physical Curve("boundary-curve", 101) += {numbering_start + 4*placentone_step + 1, numbering_start + 4*placentone_step + 5, numbering_start + 4*placentone_step + 23, numbering_start + 4*placentone_step + 26, numbering_start + 4*placentone_step + 9, numbering_start + 4*placentone_step + 13};
Physical Curve("boundary-curve", 101) += {numbering_start + 5*placentone_step + 1, numbering_start + 5*placentone_step + 5, numbering_start + 5*placentone_step + 23, numbering_start + 5*placentone_step + 26, numbering_start + 5*placentone_step + 9, numbering_start + 5*placentone_step + 13};

// Inlets and outlets.
inlet_location = {
	inlet_location_1,
	inlet_location_2,
	inlet_location_3,
	inlet_location_4,
	inlet_location_5,
	inlet_location_6
};

Physical Curve("flow-in-1",  111) = {};
Physical Curve("flow-in-2",  112) = {};
Physical Curve("flow-in-3",  113) = {};
Physical Curve("flow-in-4",  114) = {};
Physical Curve("flow-in-5",  115) = {};
Physical Curve("flow-in-6",  116) = {};

Physical Curve("flow-out-1",  211) = {};
Physical Curve("flow-out-2",  212) = {};
Physical Curve("flow-out-3",  213) = {};
Physical Curve("flow-out-4",  214) = {};
Physical Curve("flow-out-5",  215) = {};
Physical Curve("flow-out-6",  216) = {};
Physical Curve("flow-out-7",  217) = {};
Physical Curve("flow-out-8",  218) = {};
Physical Curve("flow-out-9",  219) = {};
Physical Curve("flow-out-10", 220) = {};
Physical Curve("flow-out-11", 221) = {};
Physical Curve("flow-out-12", 222) = {};
For k In {0:5:1}
	If (inlet_location[k] == 0)
		Physical Curve(111+k)   += {numbering_start + 3  + k*placentone_step};
		Physical Curve(211+2*k) += {numbering_start + 7  + k*placentone_step};
		Physical Curve(212+2*k) += {numbering_start + 11 + k*placentone_step};
	EndIf
	If (inlet_location[k] == 1)
		Physical Curve(111+k)   += {numbering_start + 7  + k*placentone_step};
		Physical Curve(211+2*k) += {numbering_start + 3  + k*placentone_step};
		Physical Curve(212+2*k) += {numbering_start + 11 + k*placentone_step};
	EndIf
	If (inlet_location[k] == 2)
		Physical Curve(111+k)   += {numbering_start + 11 + k*placentone_step};
		Physical Curve(211+2*k) += {numbering_start + 3  + k*placentone_step};
		Physical Curve(212+2*k) += {numbering_start + 7  + k*placentone_step};
	EndIf
EndFor

Physical Curve("flow-out-corner1", 230) = {1008};
Physical Curve("flow-out-corner2", 231) = {1004};

Physical Curve("flow-out-septa1", 240) = {};
If (septal_vein_1 == 1)
	Physical Curve(240) += {402};
EndIf

Physical Curve("flow-out-septa2", 241) = {};
If (septal_vein_2 == 1)
	Physical Curve(241) += {412};
EndIf

Physical Curve("flow-out-septa3", 242) = {};
If (septal_vein_3 == 1)
	Physical Curve(242) += {422};
EndIf

Physical Curve("flow-out-septa4", 243) = {};
If (septal_vein_4 == 1)
	Physical Curve(243) += {432};
EndIf

//////////////
// Surfaces //
//////////////
// Placentones.
offset = numbering_start + 0*placentone_step;
If (septal_vein_4 == 1)
	Curve Loop(1) = {offset + 1, offset + 18, offset + 5, offset + 21, offset + 22, offset + 9, offset + 20, offset + 13, 430, offset + 14, 434, offset + 15, 201, 306, 1010};
EndIf
If (septal_vein_4 == 0)
	Curve Loop(1) = {offset + 1, offset + 18, offset + 5, offset + 21, offset + 22, offset + 9, offset + 20, offset + 13, offset + 14, offset + 15, 201, 306, 1010};
EndIf

offset_prev = numbering_start + 0*placentone_step;
offset      = numbering_start + 1*placentone_step;
Curve Loop(2) = {offset + 1, offset + 18, offset + 5, offset + 21, offset + 22, offset + 9, offset + 20, offset + 13, offset + 14, offset + 15, 202, 305, -201, offset_prev + 16, offset_prev + 17};

offset_prev = numbering_start + 1*placentone_step;
offset      = numbering_start + 2*placentone_step;
If (septal_vein_3 == 1)
	Curve Loop(3) = {offset + 1, offset + 18, offset + 5, offset + 21, offset + 22, offset + 9, offset + 20, offset + 13, offset + 14, offset + 15, 203, 304, -202, offset_prev + 16, 420, offset_prev + 17, 424};
EndIf
If (septal_vein_3 == 0)
	Curve Loop(3) = {offset + 1, offset + 18, offset + 5, offset + 21, offset + 22, offset + 9, offset + 20, offset + 13, offset + 14, offset + 15, 203, 304, -202, offset_prev + 16, offset_prev + 17};
EndIf

offset_prev = numbering_start + 2*placentone_step;
offset      = numbering_start + 3*placentone_step;
Curve Loop(4) = {offset + 1, offset + 18, offset + 5, offset + 21, offset + 22, offset + 9, offset + 20, offset + 13, offset + 14, offset + 15, 204, 303, -203, offset_prev + 16, offset_prev + 17};

offset_prev = numbering_start + 3*placentone_step;
offset      = numbering_start + 4*placentone_step;
If (septal_vein_1 == 1)
	Curve Loop(5) = {offset + 1, offset + 18, offset + 5, offset + 21, offset + 22, offset + 9, offset + 20, offset + 13, offset + 14, offset + 15, 205, 302, -204, offset_prev + 16, 400, offset_prev + 17, 404};
EndIf
If (septal_vein_1 == 0)
	Curve Loop(5) = {offset + 1, offset + 18, offset + 5, offset + 21, offset + 22, offset + 9, offset + 20, offset + 13, offset + 14, offset + 15, 205, 302, -204, offset_prev + 16, offset_prev + 17};
EndIf

offset_prev = numbering_start + 4*placentone_step;
offset      = numbering_start + 5*placentone_step;
If (septal_vein_2 == 1)
	Curve Loop(6) = {offset + 1, offset + 18, offset + 5, offset + 21, offset + 22, offset + 9, offset + 20, offset + 13, 1006, 301, -205, offset_prev + 16, 410, offset_prev + 17, 414};
EndIf
If (septal_vein_2 == 0)
	Curve Loop(6) = {offset + 1, offset + 18, offset + 5, offset + 21, offset + 22, offset + 9, offset + 20, offset + 13, 1006, 301, -205, offset_prev + 16, offset_prev + 17};
EndIf

Plane Surface(1)                     = {1};
Plane Surface(2)                     = {2};
Plane Surface(3)                     = {3};
Plane Surface(4)                     = {4};
Plane Surface(5)                     = {5};
Plane Surface(6)                     = {6};
Physical Surface("placentone1", 301) = {1};
Physical Surface("placentone2", 302) = {2};
Physical Surface("placentone3", 303) = {3};
Physical Surface("placentone4", 304) = {4};
Physical Surface("placentone5", 305) = {5};
Physical Surface("placentone6", 306) = {6};

// Pipes.
For k In {0:5:1}
	offset = numbering_start + k*placentone_step;

	Curve Loop(111 + k*10) = {offset + 2, offset + 3, offset + 4, -(offset + 18)};
	Curve Loop(112 + k*10) = {offset + 6, offset + 7, offset + 8, -(offset + 25), -(offset + 24)};
	Curve Loop(113 + k*10) = {offset + 10, offset + 11, offset + 12, -(offset + 20)};
EndFor

Plane Surface(111)                   = {111};
Plane Surface(112)                   = {112};
Plane Surface(113)                   = {113};
Plane Surface(121)                   = {121};
Plane Surface(122)                   = {122};
Plane Surface(123)                   = {123};
Plane Surface(131)                   = {131};
Plane Surface(132)                   = {132};
Plane Surface(133)                   = {133};
Plane Surface(141)                   = {141};
Plane Surface(142)                   = {142};
Plane Surface(143)                   = {143};
Plane Surface(151)                   = {151};
Plane Surface(152)                   = {152};
Plane Surface(153)                   = {153};
Plane Surface(161)                   = {161};
Plane Surface(162)                   = {162};
Plane Surface(163)                   = {163};
Physical Surface("flow-out_11", 411) = {111};
Physical Surface("flow-out_12", 412) = {112};
Physical Surface("flow-out_13", 413) = {113};
Physical Surface("flow-out_21", 421) = {121};
Physical Surface("flow-out_22", 422) = {122};
Physical Surface("flow-out_23", 423) = {123};
Physical Surface("flow-out_31", 431) = {131};
Physical Surface("flow-out_32", 432) = {132};
Physical Surface("flow-out_33", 433) = {133};
Physical Surface("flow-out_41", 441) = {141};
Physical Surface("flow-out_42", 442) = {142};
Physical Surface("flow-out_43", 443) = {143};
Physical Surface("flow-out_51", 451) = {151};
Physical Surface("flow-out_52", 452) = {152};
Physical Surface("flow-out_53", 453) = {153};
Physical Surface("flow-out_61", 461) = {161};
Physical Surface("flow-out_62", 462) = {162};
Physical Surface("flow-out_63", 463) = {163};

Curve Loop(201) = {1007, 1008, 1009, -1010};
Curve Loop(202) = {1003, 1004, 1005, -1006};

Plane Surface(201)                   = {201};
Plane Surface(202)                   = {202};
Physical Surface("flow-out_01", 401) = {201};
Physical Surface("flow-out_02", 402) = {202};

If (septal_vein_1 == 1)
	offset = numbering_start + 3*placentone_step;

	Curve Loop(203)    = {401, 402, 403, -(offset + 17)};
	Plane Surface(203) = {203};

	Physical Surface("flow-out_septa1", 403) = {203};
EndIf
If (septal_vein_2 == 1)
	offset = numbering_start + 4*placentone_step;

	Curve Loop(204)    = {411, 412, 413, -(offset + 17)};
	Plane Surface(204) = {204};

	Physical Surface("flow-out_septa2", 404) = {204};
EndIf
If (septal_vein_3 == 1)
	offset = numbering_start + 1*placentone_step;

	Curve Loop(205)    = {421, 422, 423, -(offset + 17)};
	Plane Surface(205) = {205};

	Physical Surface("flow-out_septa3", 405) = {205};
EndIf
If (septal_vein_4 == 1)
	offset = numbering_start + 0*placentone_step;

	Curve Loop(206)    = {431, 432, 433, -(offset + 14)};
	Plane Surface(206) = {206};

	Physical Surface("flow-out_septa4", 406) = {206};
EndIf

// Central cavities.
For k In {0:5:1}
	offset = numbering_start + k*placentone_step;

	Curve Loop(51 + k) = {offset + 23, offset + 24, offset + 25, offset + 26, -(offset + 22), -(offset + 21)};
EndFor

Plane Surface(51)                = {51};
Plane Surface(52)                = {52};
Plane Surface(53)                = {53};
Plane Surface(54)                = {54};
Plane Surface(55)                = {55};
Plane Surface(56)                = {56};
Physical Surface("cavity1", 501) = {51};
Physical Surface("cavity2", 502) = {52};
Physical Surface("cavity3", 503) = {53};
Physical Surface("cavity4", 504) = {54};
Physical Surface("cavity5", 505) = {55};
Physical Surface("cavity6", 506) = {56};