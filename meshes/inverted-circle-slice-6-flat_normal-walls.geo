// TODO: Need to fix surface numbers for septal walls.

//=/=/=/=/=/=/=/=/=/=//
//=/ OUTPUT FORMAT /=//
//=/  EDGES
//=/   Non-curved boundary: 100
//=/   Curved boundary:     101
//=/   Inlets:              111-117
//=/   Outlets:             211-224
//=/   Corner outlets:      230, 231
//=/   (Septa outlet:       241, 242, 243, 251, ..., 283)
//=/  SURFACES
//=/   Placentones:  301, 302, 303, 304, 305, 306
//=/   Corner pipes: 401, 402
//=/   Pipes:        411, 412, 413, ..., 463
//=/   (Septa pipe:  471, ..., 495)
//=/   Cavities:     501, 502, 503, 504, 505, 506
//=/
//=/=/=/=/=/=/=/=/=/=//

//////////////////////
// Other parameters //
//////////////////////
placentone_width      = 1.0;                               // 40 mm
wall_width            = 0.075*placentone_width;            // 3  mm
// placenta_width     = 6*placentone_width + 5*wall_width; // 255mm
placenta_width        = 5.5;                               // 220mm
ms_pipe_width         = 0.075*placentone_width;            // 3  mm
artery_width_sm       = 0.0125*placentone_width;           // 0.5mm
artery_length         = 0.25*placentone_width;             // 10 mm
artery_length_diverge = 0.075*placentone_width;            // 3  mm
vein_width            = 0.0375*placentone_width;           // 1.5mm
vein_length           = 0.0375*placentone_width;           // 1.5mm

If (!Exists(no_placentones))
	no_placentones = 6;
EndIf

If (no_placentones != 6 && no_placentones != 7)
	Error("ERROR: no_placentones must be 6 or 7.");
	Abort;
EndIf

// Default artery width.
If (!Exists(artery_width))
	artery_width = 0.06*placentone_width; // 2.4mm
EndIf

// Default cavity size.
If (!Exists(central_cavity_width))
	central_cavity_width = 0.25*placentone_width; // 10 mm
EndIf
central_cavity_height = 2*central_cavity_width;

If (!Exists(central_cavity_transition))
	central_cavity_transition = 0.04; // 1.6mm
EndIf

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

// Placentone widths and central cavity sizes.
If (no_placentones == 7)
	// Set such that 220-18=1*40+2*40*x+2*40*x^2+2*40*x^3.
	ratio = 0.815957986;

	// Placentone widths.
	placentone_widths = {};
	For k In {no_placentones-1:Floor(no_placentones/2):-1}
		width = placentone_width*ratio^Fabs(k-Floor(no_placentones/2));
		placentone_widths += {width};
	EndFor
	For k In {Floor(no_placentones/2)-1:0:-1}
		width = placentone_width*ratio^Fabs(k-Floor(no_placentones/2));
		placentone_widths += {width};
	EndFor

	// Central cavity sizes.
	central_cavity_widths  = {};
	central_cavity_heights = {};
	For k In {no_placentones-1:Floor(no_placentones/2):-1}
		width = central_cavity_width*ratio^Fabs(k-Floor(no_placentones/2));
		central_cavity_widths += {width};

		height = central_cavity_height*ratio^Fabs(k-Floor(no_placentones/2));
		central_cavity_heights += {height};
	EndFor
	For k In {Floor(no_placentones/2)-1:0:-1}
		width = central_cavity_width*ratio^Fabs(k-Floor(no_placentones/2));
		central_cavity_widths += {width};

		height = central_cavity_height*ratio^Fabs(k-Floor(no_placentones/2));
		central_cavity_heights += {height};
	EndFor

ElseIf (no_placentones == 6)
	// Set such that 220-5*3=2*40+2*40*x+2*40*x^2.
	ratio = Sqrt(29)/4 - 0.5;

	// Placentone widths.
	placentone_widths = {0, 0, 0, 0, 0, 0};
	For k In {0:Ceil(no_placentones/2)-1:1}
		If (!Exists(placentone_width~{k+1}))
			placentone_width~{k+1} = placentone_width*ratio^(2-k);
		EndIf
		If (!Exists(placentone_width~{no_placentones-k}))
			placentone_width~{no_placentones-k} = placentone_width*ratio^(2-k);
		EndIf

		placentone_widths[k]                  = placentone_width~{k+1};
		placentone_widths[no_placentones-1-k] = placentone_width~{no_placentones-k};
	EndFor

	// Central cavity sizes.
	central_cavity_widths  = {0, 0, 0, 0, 0, 0};
	central_cavity_heights = {0, 0, 0, 0, 0, 0};
	For k In {0:Ceil(no_placentones/2)-1:1}
		If (!Exists(central_cavity_width~{k+1}))
			central_cavity_width~{k+1} = central_cavity_width*ratio^(2-k);
		EndIf
		If (!Exists(central_cavity_width~{no_placentones-k}))
			central_cavity_width~{no_placentones-k} = central_cavity_width*ratio^(2-k);
		EndIf

		central_cavity_widths[k]                  = central_cavity_width~{k+1};
		central_cavity_widths[no_placentones-1-k] = central_cavity_width~{no_placentones-k};

		If (!Exists(central_cavity_height~{k+1}))
			central_cavity_height~{k+1} = central_cavity_height*ratio^(2-k);
		EndIf
		If (!Exists(central_cavity_height~{no_placentones-k}))
			central_cavity_height~{no_placentones-k} = central_cavity_height*ratio^(2-k);
		EndIf

		central_cavity_heights[k]                  = central_cavity_height~{k+1};
		central_cavity_heights[no_placentones-1-k] = central_cavity_height~{no_placentones-k};
	EndFor
EndIf

For k In {1:no_placentones:1}
	Printf("placentone_width %g = %f", k, placentone_widths[k-1]);
EndFor

// Default locations of the 3 vessels.
location_1_x = {};
location_2_x = {};
location_3_x = {};
cumulative_width = 0;
For k In {1:no_placentones:1}
	If (!Exists(location~{10*k + 1}))
		location~{10*k + 1} = cumulative_width + 0.2*placentone_widths[k-1];
	EndIf
	If (!Exists(location~{10*k + 2}))
		location~{10*k + 2} = cumulative_width + 0.5*placentone_widths[k-1];
	EndIf
	If (!Exists(location~{10*k + 3}))
		location~{10*k + 3} = cumulative_width + 0.8*placentone_widths[k-1];
	EndIf

	location_1_x += {location~{10*k + 1}};
	location_2_x += {location~{10*k + 2}};
	location_3_x += {location~{10*k + 3}};

	If (k < no_placentones)
		cumulative_width += placentone_widths[k-1] + wall_width;
	EndIf
EndFor

// Default turn on/off for marginal sinuses.
If (!Exists(ms_1))
	ms_1 = 1;
EndIf
If (!Exists(ms_2))
	ms_2 = 1;
EndIf

// Default turn on/off for arteries and veins.
For k In {0:no_placentones-1:1}
	If (!Exists(vein~{(k+1)*10+1}))
		vein~{(k+1)*10+1} = 1;
	EndIf
	If (!Exists(vein~{(k+1)*10+2}))
		vein~{(k+1)*10+2} = 1;
	EndIf

	If (!Exists(artery~{(k+1)*10+1}))
		artery~{(k+1)*10+1} = 1;
	EndIf
EndFor

// Default wall heights.
// TAKEN FROM CONVERSATION WITH DIMI.
If (no_placentones == 6)
	wall_height = {0, 0, 0, 0, 0};
	For k In {0:4:2}
		If (!Exists(wall_height~{k+1}))
			wall_height~{k+1} = 0.1725*placentone_width; // 6.90 mm
		EndIf
		wall_height[k] = wall_height~{k+1};
	EndFor
	For k In {1:3:2}
		If (!Exists(wall_height~{k+1}))
			wall_height~{k+1} = 0.35175*placentone_width; // 14.07 mm
		EndIf
		wall_height[k] = wall_height~{k+1};
	EndFor
ElseIf (no_placentones == 7)
	wall_height = {0, 0, 0, 0, 0, 0};
	For k In {0:5:1}
		If (!Exists(wall_height~{k+1}))
			wall_height~{k+1} = 0.1725*placentone_width; // 6.90 mm
		EndIf
		wall_height[k] = wall_height~{k+1};
	EndFor
EndIf

// Default turn on/off for septal veins.
For k In {0:no_placentones-2:1}
	If (!Exists(septal_vein~{(k+1)*10+1}))
		septal_vein~{(k+1)*10+1} = 0;
	EndIf
	If (!Exists(septal_vein~{(k+1)*10+2}))
		septal_vein~{(k+1)*10+2} = 0;
	EndIf
	If (!Exists(septal_vein~{(k+1)*10+3}))
		septal_vein~{(k+1)*10+3} = 0;
	EndIf
EndFor

// Default positions of septal wall veins.
For k In {0:no_placentones-2:1}
	If (!Exists(septal_vein_position~{(k+1)*10+1}))
		septal_vein_position~{(k+1)*10+1} = 0.2;
	EndIf
	If (!Exists(septal_vein_position~{(k+1)*10+2}))
		septal_vein_position~{(k+1)*10+2} = 0.5;
	EndIf
	If (!Exists(septal_vein_position~{(k+1)*10+3}))
		septal_vein_position~{(k+1)*10+3} = 0.5;
	EndIf
EndFor

///////////////////////
// Circle parameters //
///////////////////////
// TAKEN FROM :: Tongsong, T., Wanapirak, C. and Sirichotiyakul, S. (1999), Placental thickness at mid-pregnancy as a predictor of Hb Bart's disease. Prenat. Diagn., 19: 1027-1030. https://doi.org/10.1002/(SICI)1097-0223(199911)19:11<1027::AID-PD691>3.0.CO;2-C
// placenta_height = 0.615; // 24.6mm 
// TAKEN FROM: Correlation between placental thickness in the second and third trimester and fetal weight. https://doi.org/10.1590/S0100-72032013000700006
placenta_height = 0.9065; // 36.26mm
// OLD VALUE:
//placental_height = centre_y - centre_x;

centre_x = placenta_width/2;
//centre_y = 2.5*(2*centre_x^2)^0.5;//(2*centre_x^2)^0.5;
// centre_y = 5;
centre_y = (placenta_height - ms_pipe_width)/2 + centre_x^2/(2*(placenta_height - ms_pipe_width));
radius   = centre_y;

//////////////////////////
// x and y of the walls //
//////////////////////////
wall_low_x = {};
offset = 0;
For k In {0:no_placentones-2:1}
	wall_low_x += {offset + placentone_widths[k], offset + placentone_widths[k] + wall_width};
	offset += placentone_widths[k] + wall_width;
EndFor

wall_low_y = {};
theta_wall = {};
For k In {0:2*(no_placentones-1)-1:1}
	wall_low_y += {centre_y - (radius^2 - (wall_low_x[k] - centre_x)^2)^0.5};

	If (wall_low_x[k] <= centre_x)
		theta_wall += {-Pi - Atan((wall_low_y[k] - centre_y)/(wall_low_x[k] - centre_x))};
	EndIf
	If (wall_low_x[k] > centre_x)
		theta_wall +=     {- Atan((wall_low_y[k] - centre_y)/(wall_low_x[k] - centre_x))};
	EndIf
EndFor

wall_top_x  = {};
wall_top_y  = {};
For k In {0:2*(no_placentones-1)-1:1}
	wall_top_x += {wall_low_x[k] - wall_height[Floor(k/2)]*Cos(theta_wall[k])};
	wall_top_y += {wall_low_y[k] + wall_height[Floor(k/2)]*Sin(theta_wall[k])};
EndFor

///////////////////////////
// Placentone separators //
///////////////////////////
separator_low_x  = {};
separator_low_y  = {};
separator_high_x = {};
separator_high_y = {};
theta_separator  = {};

For k In {0:no_placentones-2:1}
	separator_low_x += {(wall_top_x[2*k] + wall_top_x[2*k+1])/2};
	separator_low_y += {(wall_top_y[2*k] + wall_top_y[2*k+1])/2};

	If (separator_low_x[k] == centre_x)
		theta_separator += {0};
	EndIf
	If (separator_low_x[k] < centre_x)
		theta_separator += {Atan((separator_low_x[k] - centre_x)/(separator_low_y[k] - centre_y))};
	EndIf
	If (separator_low_x[k] > centre_x)
		theta_separator += {Atan((separator_low_x[k] - centre_x)/(separator_low_y[k] - centre_y))};
	EndIf

	// separator_high_y[k] = (radius-placenta_height)*Cos(theta_separator[k]+Pi) + centre_y;
	separator_high_y += {placenta_height};
	separator_high_x += {(separator_high_y[k] - separator_low_y[k])*Tan(theta_separator[k]) + separator_low_x[k]};
EndFor

///////////////////////////////////////////
// inlets and outlet locations and sizes //
///////////////////////////////////////////
location_1_y   = {};
location_1_y_1 = {};
location_1_y_2 = {};
location_2_y   = {};
location_2_y_1 = {};
location_2_y_2 = {};
location_3_y   = {};
location_3_y_1 = {};
location_3_y_2 = {};

location_1_x_1 = {};
location_1_x_2 = {};
location_2_x_1 = {};
location_2_x_2 = {};
location_3_x_1 = {};
location_3_x_2 = {};

For k In {0:no_placentones-1:1}
	location_1_y += {centre_y - (radius^2 - (location_1_x[k]                - centre_x)^2)^0.5};
	location_2_y += {centre_y - (radius^2 - (location_2_x[k]                - centre_x)^2)^0.5};
	location_3_y += {centre_y - (radius^2 - (location_3_x[k]                - centre_x)^2)^0.5};
EndFor

theta_pipe = {};
For k In {0:no_placentones-1:1}
	theta_pipe += {- Atan((location_1_y[k] - centre_y)/(location_1_x[k] - centre_x))};
	theta_pipe += {- Atan((location_2_y[k] - centre_y)/(location_2_x[k] - centre_x))};
	theta_pipe += {- Atan((location_3_y[k] - centre_y)/(location_3_x[k] - centre_x))};

	If (no_placentones % 2 == 0)
		If (k <= (no_placentones-1)/2)
			theta_pipe[k*3]   = theta_pipe[k*3]   + Pi;
			theta_pipe[k*3+1] = theta_pipe[k*3+1] + Pi;
			theta_pipe[k*3+2] = theta_pipe[k*3+2] + Pi;
		EndIf
	Else
		If (k == (no_placentones-1)/2)
			theta_pipe[k*3]   = theta_pipe[k*3]   + Pi;
			theta_pipe[k*3+1] = theta_pipe[k*3+1] + Pi;
			theta_pipe[k*3+2] = theta_pipe[k*3+2];
		ElseIf (k <= (no_placentones-1)/2)
			theta_pipe[k*3]   = theta_pipe[k*3]   + Pi;
			theta_pipe[k*3+1] = theta_pipe[k*3+1] + Pi;
			theta_pipe[k*3+2] = theta_pipe[k*3+2] + Pi;
		EndIf
	EndIf
EndFor

For k In {0:no_placentones-1:1}
	location_1_x_1 += {centre_x + radius*Cos(theta_pipe[k*3]   + (vein_width/2)/radius)};
	location_1_y_1 += {centre_y - radius*Sin(theta_pipe[k*3]   + (vein_width/2)/radius)};
	location_1_x_2 += {centre_x + radius*Cos(theta_pipe[k*3]   - (vein_width/2)/radius)};
	location_1_y_2 += {centre_y - radius*Sin(theta_pipe[k*3]   - (vein_width/2)/radius)};

	location_2_x_1 += {centre_x + radius*Cos(theta_pipe[k*3+1] + (artery_width/2)/radius)};
	location_2_y_1 += {centre_y - radius*Sin(theta_pipe[k*3+1] + (artery_width/2)/radius)};
	location_2_x_2 += {centre_x + radius*Cos(theta_pipe[k*3+1] - (artery_width/2)/radius)};
	location_2_y_2 += {centre_y - radius*Sin(theta_pipe[k*3+1] - (artery_width/2)/radius)};

	location_3_x_1 += {centre_x + radius*Cos(theta_pipe[k*3+2] + (vein_width/2)/radius)};
	location_3_y_1 += {centre_y - radius*Sin(theta_pipe[k*3+2] + (vein_width/2)/radius)};
	location_3_x_2 += {centre_x + radius*Cos(theta_pipe[k*3+2] - (vein_width/2)/radius)};
	location_3_y_2 += {centre_y - radius*Sin(theta_pipe[k*3+2] - (vein_width/2)/radius)};
EndFor

/////////////////////
// Bottom of pipes //
/////////////////////
location_1_x_pipe1 = {};
location_1_x_pipe2 = {};
location_2_x_pipe1 = {};
location_2_x_pipe2 = {};
location_3_x_pipe1 = {};
location_3_x_pipe2 = {};

location_1_y_pipe1 = {};
location_1_y_pipe2 = {};
location_2_y_pipe1 = {};
location_2_y_pipe2 = {};
location_3_y_pipe1 = {};
location_3_y_pipe2 = {};

For k In {0:no_placentones-1:1}
	location_1_x_pipe1 += {location_1_x_1[k] + vein_length*Cos(theta_pipe[k*3])};
	location_1_y_pipe1 += {location_1_y_1[k] - vein_length*Sin(theta_pipe[k*3])};
	location_2_x_pipe1 += {centre_x + radius*Cos(theta_pipe[k*3+1] + (artery_width_sm/2)/radius) + artery_length*Cos(theta_pipe[k*3+1])};
	location_2_y_pipe1 += {centre_y - radius*Sin(theta_pipe[k*3+1] + (artery_width_sm/2)/radius) - artery_length*Sin(theta_pipe[k*3+1])};
	location_3_x_pipe1 += {location_3_x_1[k] + vein_length*Cos(theta_pipe[k*3+2])};
	location_3_y_pipe1 += {location_3_y_1[k] - vein_length*Sin(theta_pipe[k*3+2])};

	location_1_x_pipe2 += {location_1_x_2[k] + vein_length*Cos(theta_pipe[k*3])};
	location_1_y_pipe2 += {location_1_y_2[k] - vein_length*Sin(theta_pipe[k*3])};
	location_2_x_pipe2 += {centre_x + radius*Cos(theta_pipe[k*3+1] - (artery_width_sm/2)/radius) + artery_length*Cos(theta_pipe[k*3+1])};
	location_2_y_pipe2 += {centre_y - radius*Sin(theta_pipe[k*3+1] - (artery_width_sm/2)/radius) - artery_length*Sin(theta_pipe[k*3+1])};
	location_3_x_pipe2 += {location_3_x_2[k] + vein_length*Cos(theta_pipe[k*3+2])};
	location_3_y_pipe2 += {location_3_y_2[k] - vein_length*Sin(theta_pipe[k*3+2])};
EndFor

// Mid-points of arteries //
location_2_x_pipe1_mid = {};
location_2_y_pipe1_mid = {};
location_2_x_pipe2_mid = {};
location_2_y_pipe2_mid = {};

For k In {0:no_placentones-1:1}
	location_2_x_pipe1_mid += {centre_x + radius*Cos(theta_pipe[k*3+1] + (artery_width_sm/2)/radius) + artery_length_diverge*Cos(theta_pipe[k*3+1])};
	location_2_y_pipe1_mid += {centre_y - radius*Sin(theta_pipe[k*3+1] + (artery_width_sm/2)/radius) - artery_length_diverge*Sin(theta_pipe[k*3+1])};
	location_2_x_pipe2_mid += {centre_x + radius*Cos(theta_pipe[k*3+1] - (artery_width_sm/2)/radius) + artery_length_diverge*Cos(theta_pipe[k*3+1])};
	location_2_y_pipe2_mid += {centre_y - radius*Sin(theta_pipe[k*3+1] - (artery_width_sm/2)/radius) - artery_length_diverge*Sin(theta_pipe[k*3+1])};
EndFor

///////////////////////////
// Central cavity points //
///////////////////////////
cavity_x_1 = {};
cavity_x_2 = {};
cavity_x_3 = {};

cavity_y_1 = {};
cavity_y_2 = {};
cavity_y_3 = {};

For k In {0:no_placentones-1:1}
	cavity_x_2 += {(location_2_x_1[k] + location_2_x_2[k])/2};
	cavity_y_2 += {centre_y - (radius^2 - (centre_x - cavity_x_2[k])^2)^0.5};

	cavity_x_1 += {centre_x + radius*Cos(theta_pipe[k*3+1] + ((central_cavity_widths[k] + central_cavity_transition)/2)/radius)};
	cavity_y_1 += {centre_y - radius*Sin(theta_pipe[k*3+1] + ((central_cavity_widths[k] + central_cavity_transition)/2)/radius)};

	cavity_x_3 += {centre_x + radius*Cos(theta_pipe[k*3+1] - ((central_cavity_widths[k] + central_cavity_transition)/2)/radius)};
	cavity_y_3 += {centre_y - radius*Sin(theta_pipe[k*3+1] - ((central_cavity_widths[k] + central_cavity_transition)/2)/radius)};
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
Point(1000) = {centre_x,                       centre_y,                                                  0, h};
Point(1001) = {0,                              centre_y - (radius^2 - centre_x^2)^0.5,                    0, h_refine};
Point(1002) = {placenta_width,                 centre_y - (radius^2 - (placenta_width - centre_x)^2)^0.5, 0, h_refine};

If (ms_2 == 1)
	Point(1004) = {placenta_width + ms_pipe_width, placenta_height - ms_pipe_width,                           0, h_refine};
	Point(1005) = {placenta_width + ms_pipe_width, placenta_height,                                           0, h_refine};
EndIf
Point(1006)   = {placenta_width,                 placenta_height,                                           0, h_refine};
Point(1007)   = {0,                              placenta_height,                                           0, h_refine};
If (ms_1 == 1)
	Point(1008) = {-ms_pipe_width,                 placenta_height,                                           0, h_refine};
	Point(1009) = {-ms_pipe_width,                 placenta_height - ms_pipe_width,                           0, h_refine};
EndIf

// Placentones.
vein_1 = {};
vein_2 = {};
artery = {};
For k In {1:no_placentones:1}
	vein_1 += {vein~{10*k+1}};
	vein_2 += {vein~{10*k+2}};
	artery += {artery~{10*k+1}};
EndFor
For k In {0:no_placentones-1:1}
	If (vein_1[k] == 1)
		Point(numbering_start + k*placentone_step + 1)   = {location_1_x_1[k],     location_1_y_1[k],     0, h_refine/10};
		Point(numbering_start + k*placentone_step + 2)   = {location_1_x_pipe1[k], location_1_y_pipe1[k], 0, h_refine/10};
		Point(numbering_start + k*placentone_step + 3)   = {location_1_x_pipe2[k], location_1_y_pipe2[k], 0, h_refine};
		Point(numbering_start + k*placentone_step + 4)   = {location_1_x_2[k],     location_1_y_2[k],     0, h_refine/10};
	EndIf
	If (artery[k] == 1)
		Point(numbering_start + k*placentone_step + 5)   = {location_2_x_1[k],     location_2_y_1[k],     0, h_refine/2};
		Point(numbering_start + k*placentone_step + 6)   = {location_2_x_pipe1[k], location_2_y_pipe1[k], 0, h_refine/10};
		Point(numbering_start + k*placentone_step + 7)   = {location_2_x_pipe2[k], location_2_y_pipe2[k], 0, h_refine/10};
		Point(numbering_start + k*placentone_step + 8)   = {location_2_x_2[k],     location_2_y_2[k],     0, h_refine/2};

		Point(numbering_start + k*placentone_step + 23)  = {location_2_x_pipe1_mid[k], location_2_y_pipe1_mid[k], 0, h_refine/10};
		Point(numbering_start + k*placentone_step + 24)  = {location_2_x_pipe2_mid[k], location_2_y_pipe2_mid[k], 0, h_refine/10};
	EndIf
	If (vein_2[k] == 1)
		Point(numbering_start + k*placentone_step + 9)   = {location_3_x_1[k],     location_3_y_1[k],     0, h_refine/10};
		Point(numbering_start + k*placentone_step + 10)  = {location_3_x_pipe1[k], location_3_y_pipe1[k], 0, h_refine};
		Point(numbering_start + k*placentone_step + 11)  = {location_3_x_pipe2[k], location_3_y_pipe2[k], 0, h_refine/10};
		Point(numbering_start + k*placentone_step + 12)  = {location_3_x_2[k],     location_3_y_2[k],     0, h_refine/10};
	EndIf
EndFor

// Walls.
For k In {0:no_placentones-2:1}
	Point(numbering_start + k*placentone_step + 13) = {wall_low_x[2*k+0], wall_low_y[2*k+0], 0, h};
	Point(numbering_start + k*placentone_step + 14) = {wall_top_x[2*k+0], wall_top_y[2*k+0], 0, h};
	Point(numbering_start + k*placentone_step + 16) = {wall_top_x[2*k+1], wall_top_y[2*k+1], 0, h};
	Point(numbering_start + k*placentone_step + 17) = {wall_low_x[2*k+1], wall_low_y[2*k+1], 0, h};
EndFor

// Placentone separators.
For k In {0:no_placentones-2:1}
	Point(numbering_start + k*placentone_step + 15) = {separator_low_x[k],  separator_low_y[k],  0, h};
	Point(numbering_start + k*placentone_step + 18) = {separator_high_x[k], separator_high_y[k], 0, h};
EndFor

// Central cavities.
For k In {0:no_placentones-1:1}
	offset = numbering_start + k*placentone_step;

	theta1 = - Atan((cavity_y_1[k] - centre_y)/(cavity_x_1[k] - centre_x));
	theta2 = - Atan((cavity_y_2[k] - centre_y)/(cavity_x_2[k] - centre_x));
	theta3 = - Atan((cavity_y_3[k] - centre_y)/(cavity_x_3[k] - centre_x));

	If (k <= Floor(no_placentones/2)-1)
		theta1 = theta1 + Pi;
		theta2 = theta2 + Pi;
		theta3 = theta3 + Pi;
	EndIf
	
	// theta1 = theta_pipe[3*k+1];

	If (no_placentones % 2 != 0 && k == Floor(no_placentones/2))
		Point(offset + 19) = {cavity_x_1[k], cavity_y_1[k], 0, h_refine};
		Point(offset + 42) = {cavity_x_1[k] - (central_cavity_transition/2)*Sin(theta1), cavity_y_1[k] - (central_cavity_transition/2)*Cos(theta1), 0, h_refine/10};
		Point(offset + 43) = {cavity_x_1[k] - (central_cavity_transition)  *Sin(theta1), cavity_y_1[k] - (central_cavity_transition)  *Cos(theta1), 0, h_refine/2};
	Else
		Point(offset + 19) = {cavity_x_1[k], cavity_y_1[k], 0, h_refine/2};
		Point(offset + 42) = {cavity_x_1[k] + (central_cavity_transition/2)*Sin(theta1), cavity_y_1[k] + (central_cavity_transition/2)*Cos(theta1), 0, h_refine/10};
		Point(offset + 43) = {cavity_x_1[k] + (central_cavity_transition)  *Sin(theta1), cavity_y_1[k] + (central_cavity_transition)  *Cos(theta1), 0, h_refine/2};
	EndIf

	Point(offset + 22) = {cavity_x_2[k], cavity_y_2[k], 0, h_refine/2};
	Point(offset + 21) = {cavity_x_3[k], cavity_y_3[k], 0, h_refine/2};
	Point(offset + 44) = {cavity_x_3[k] - (central_cavity_transition/2)*Sin(theta3), cavity_y_3[k] - (central_cavity_transition/2)*Cos(theta3), 0, h_refine/10};
	Point(offset + 45) = {cavity_x_3[k] - (central_cavity_transition)  *Sin(theta3), cavity_y_3[k] - (central_cavity_transition)  *Cos(theta3), 0, h_refine/2};
	If (artery[k] == 1)
		If (no_placentones % 2 != 0 && k == Floor(no_placentones/2))
			Point(offset + 20) = {cavity_x_2[k] + (central_cavity_heights[k]/2 + central_cavity_transition)*Cos(theta2), cavity_y_2[k] - (central_cavity_heights[k]/2 + central_cavity_transition)*Sin(theta2), 0, h_refine};
			Point(offset + 25) = {cavity_x_2[k] + (central_cavity_heights[k]/2                            )*Cos(theta2), cavity_y_2[k] - (central_cavity_heights[k]/2                            )*Sin(theta2), 0, h_refine/10};
			Point(offset + 26) = {cavity_x_2[k] + (central_cavity_heights[k]/2 - central_cavity_transition)*Cos(theta2), cavity_y_2[k] - (central_cavity_heights[k]/2 - central_cavity_transition)*Sin(theta2), 0, h_refine/2};
		Else
			Point(offset + 20) = {cavity_x_2[k] - (central_cavity_heights[k]/2 + central_cavity_transition)*Cos(theta2), cavity_y_2[k] + (central_cavity_heights[k]/2 + central_cavity_transition)*Sin(theta2), 0, h_refine/2};
			Point(offset + 25) = {cavity_x_2[k] - (central_cavity_heights[k]/2                            )*Cos(theta2), cavity_y_2[k] + (central_cavity_heights[k]/2                            )*Sin(theta2), 0, h_refine/10};
			Point(offset + 26) = {cavity_x_2[k] - (central_cavity_heights[k]/2 - central_cavity_transition)*Cos(theta2), cavity_y_2[k] + (central_cavity_heights[k]/2 - central_cavity_transition)*Sin(theta2), 0, h_refine/2};
		EndIf
	EndIf
EndFor

// Septal veins.
septal_vein_1          = {};
septal_vein_2          = {};
septal_vein_3          = {};
septal_vein_position_1 = {};
septal_vein_position_2 = {};
septal_vein_position_3 = {};
For k In {1:no_placentones-1:1}
	septal_vein_1          += {septal_vein~{10*k+1}};
	septal_vein_2          += {septal_vein~{10*k+2}};
	septal_vein_3          += {septal_vein~{10*k+3}};
	septal_vein_position_1 += {septal_vein_position~{10*k+1}};
	septal_vein_position_2 += {septal_vein_position~{10*k+2}};
	septal_vein_position_3 += {septal_vein_position~{10*k+3}};
EndFor
For k In {0:no_placentones-2:1}
	offset = numbering_start + k*placentone_step;
	If (septal_vein_1[k] == 1)
		vein_x = wall_low_x[2*k] + septal_vein_position_1[k]*(wall_top_x[2*k] - wall_low_x[2*k]);
		vein_y = wall_low_y[2*k] + septal_vein_position_1[k]*(wall_top_y[2*k] - wall_low_y[2*k]);

		Point(offset + 30) = {vein_x - (vein_width/2)*Cos(theta_wall[2*k]),                                   vein_y + (vein_width/2)*Sin(theta_wall[2*k]),                                   0, h_refine};
		Point(offset + 31) = {vein_x - (vein_width/2)*Cos(theta_wall[2*k]) + vein_width*Sin(theta_wall[2*k]), vein_y + (vein_width/2)*Sin(theta_wall[2*k]) + vein_width*Cos(theta_wall[2*k]), 0, h_refine};
		Point(offset + 32) = {vein_x + (vein_width/2)*Cos(theta_wall[2*k]) + vein_width*Sin(theta_wall[2*k]), vein_y - (vein_width/2)*Sin(theta_wall[2*k]) + vein_width*Cos(theta_wall[2*k]), 0, h_refine};
		Point(offset + 33) = {vein_x + (vein_width/2)*Cos(theta_wall[2*k]),                                   vein_y - (vein_width/2)*Sin(theta_wall[2*k]),                                   0, h_refine};
	EndIf
	If (septal_vein_2[k] == 1)
		vein_x = wall_top_x[2*k] + septal_vein_position_2[k]*(wall_top_x[2*k+1] - wall_top_x[2*k]);
		vein_y = wall_top_y[2*k] + septal_vein_position_2[k]*(wall_top_y[2*k+1] - wall_top_y[2*k]);

		Point(offset + 34) = {vein_x - (vein_width/2)*Sin(theta_wall[2*k]),                                       vein_y - (vein_width/2)*Cos(theta_wall[2*k]),                                       0, h_refine};
		Point(offset + 35) = {vein_x - (vein_width/2)*Sin(theta_wall[2*k])   + vein_width*Cos(theta_wall[2*k]),   vein_y - (vein_width/2)*Cos(theta_wall[2*k])   - vein_width*Sin(theta_wall[2*k]),   0, h_refine};
		Point(offset + 36) = {vein_x + (vein_width/2)*Sin(theta_wall[2*k+1]) + vein_width*Cos(theta_wall[2*k+1]), vein_y + (vein_width/2)*Cos(theta_wall[2*k+1]) - vein_width*Sin(theta_wall[2*k+1]), 0, h_refine};
		Point(offset + 37) = {vein_x + (vein_width/2)*Sin(theta_wall[2*k+1]),                                     vein_y + (vein_width/2)*Cos(theta_wall[2*k+1]),                                     0, h_refine};
	EndIf
	If (septal_vein_3[k] == 1)
		vein_x = wall_low_x[2*k+1] + septal_vein_position_3[k]*(wall_top_x[2*k+1] - wall_low_x[2*k+1]);
		vein_y = wall_low_y[2*k+1] + septal_vein_position_3[k]*(wall_top_y[2*k+1] - wall_low_y[2*k+1]);

		Point(offset + 38) = {vein_x - (vein_width/2)*Cos(theta_wall[2*k+1]),                                     vein_y + (vein_width/2)*Sin(theta_wall[2*k+1]),                                     0, h_refine};
		Point(offset + 39) = {vein_x - (vein_width/2)*Cos(theta_wall[2*k+1]) - vein_width*Sin(theta_wall[2*k+1]), vein_y + (vein_width/2)*Sin(theta_wall[2*k+1]) - vein_width*Cos(theta_wall[2*k+1]), 0, h_refine};
		Point(offset + 40) = {vein_x + (vein_width/2)*Cos(theta_wall[2*k+1]) - vein_width*Sin(theta_wall[2*k+1]), vein_y - (vein_width/2)*Sin(theta_wall[2*k+1]) - vein_width*Cos(theta_wall[2*k+1]), 0, h_refine};
		Point(offset + 41) = {vein_x + (vein_width/2)*Cos(theta_wall[2*k+1]),                                     vein_y - (vein_width/2)*Sin(theta_wall[2*k+1]),                                     0, h_refine};
	EndIf

EndFor

/////////////////
// Placentones //
/////////////////
For k In {0:no_placentones-1:1}
	offset_prev = numbering_start + (k-1)*placentone_step;
	offset = numbering_start      + k*placentone_step;

	If (k == 0)
		If (vein_1[k] == 1)
			Circle(offset + 1) = {1001, 1000, offset + 1};
			Circle(offset + 5) = {offset + 4,  1000, offset + 19};
		Else
			Circle(offset + 1) = {1001, 1000, offset + 19};
		EndIf
	EndIf
	If (k != 0)
		If (vein_1[k] == 1)
			Circle(offset + 1) = {offset_prev + 17, 1000, offset + 1};
			Circle(offset + 5)  = {offset + 4,  1000, offset + 19};
		Else
			Circle(offset + 1) = {offset_prev + 17, 1000, offset + 19};
		EndIf
	EndIf

	If (artery[k] == 1)
		Circle(offset + 23) = {offset + 43, 1000, offset + 5};
		Circle(offset + 26) = {offset + 8,  1000, offset + 45};
	Else
		Circle(offset + 23) = {offset + 43, 1000, offset + 22};
		Circle(offset + 26) = {offset + 22, 1000, offset + 45};
	EndIf
	Circle(offset + 53) = {offset + 19, 1000, offset + 42};
	Circle(offset + 54) = {offset + 42, 1000, offset + 43};
	Circle(offset + 55) = {offset + 45, 1000, offset + 44};
	Circle(offset + 56) = {offset + 44, 1000, offset + 21};

	If (k != no_placentones-1)
		If (vein_2[k] == 1)
			Circle(offset + 9)  = {offset + 21, 1000, offset + 9};
			Circle(offset + 13)  = {offset + 12, 1000, offset + 13};
		Else
			Circle(offset + 9)  = {offset + 21, 1000, offset + 13};
		EndIf
	EndIf
	If (k == no_placentones-1)
		If (vein_2[k] == 1)
			Circle(offset + 9)  = {offset + 21, 1000, offset + 9};
			Circle(offset + 13)  = {offset + 12, 1000, 1002};
		Else
			Circle(offset + 9)  = {offset + 21, 1000, 1002};
		EndIf
	EndIf
EndFor

///////////
// Pipes //
///////////
For k In {0:no_placentones-1:1}
	offset = numbering_start + k*placentone_step;

	If (vein_1[k] == 1)
		Line(offset + 2)   = {offset + 1,  offset + 2};
		Line(offset + 3)   = {offset + 2,  offset + 3};
		Line(offset + 4)   = {offset + 3,  offset + 4};

		Circle(offset + 18) = {offset + 4,  1000, offset + 1};
	EndIf
	If (artery[k] == 1)
		Line(offset + 6)   = {offset + 5,  offset + 23};
		Line(offset + 27)  = {offset + 23, offset + 6};
		Line(offset + 7)   = {offset + 6,  offset + 7};
		Line(offset + 28)  = {offset + 7,  offset + 24};
		Line(offset + 8)   = {offset + 24, offset + 8};
	
		Circle(offset + 24) = {offset + 22, 1000, offset + 5};
		Circle(offset + 25) = {offset + 8,  1000, offset + 22};
	EndIf
	If (vein_2[k] == 1)
		Line(offset + 10)  = {offset + 9,  offset + 10};
		Line(offset + 11)  = {offset + 10, offset + 11};
		Line(offset + 12)  = {offset + 11, offset + 12};
	
		Circle(offset + 20) = {offset + 12, 1000, offset + 9};
	EndIf
EndFor

///////////
// Walls //
///////////
For k In {0:no_placentones-2:1}
	offset = numbering_start + k*placentone_step;

	If (septal_vein_1[k] == 1)
		Line(offset + 30) = {offset + 13, offset + 33};

		Line(offset + 31) = {offset + 33, offset + 32};
		Line(offset + 32) = {offset + 32, offset + 31};
		Line(offset + 33) = {offset + 31, offset + 30};
		Line(offset + 34) = {offset + 30, offset + 33};

		Line(offset + 35) = {offset + 30, offset + 14};
	Else
		Line(offset + 14) = {offset + 13, offset + 14};
	EndIf
	If (septal_vein_2[k] == 1)
		Line(offset + 36) = {offset + 14, offset + 34};

		Line(offset + 37) = {offset + 34, offset + 35};
		Line(offset + 38) = {offset + 35, offset + 36};
		Line(offset + 39) = {offset + 36, offset + 37};
		Line(offset + 40) = {offset + 37, offset + 15};
		Line(offset + 41) = {offset + 15, offset + 34};

		Line(offset + 42) =  {offset + 37, offset + 16};
	Else
		Line(offset + 15) = {offset + 14, offset + 15};
		Line(offset + 16) = {offset + 15, offset + 16};
	EndIf
	If (septal_vein_3[k] == 1)
		Line(offset + 43) = {offset + 16, offset + 38};

		Line(offset + 44) = {offset + 38, offset + 39};
		Line(offset + 45) = {offset + 39, offset + 40};
		Line(offset + 46) = {offset + 40, offset + 41};
		Line(offset + 47) = {offset + 41, offset + 38};

		Line(offset + 48) = {offset + 41, offset + 17};
	Else
		Line(offset + 17) = {offset + 16, offset + 17};
	EndIf

EndFor

/////////////////
// Fetal plate //
/////////////////
For k In {1:no_placentones:1}
	If (k == 1)
		Line(300 + k) = {1006, numbering_start + (no_placentones-2)*placentone_step + 18};
	ElseIf (k == no_placentones)
		Line(300 + k) = {numbering_start + 0*placentone_step + 18, 1007};
	Else
		Line(300 + k) = {numbering_start + (no_placentones-k)*placentone_step + 18, numbering_start + (no_placentones-k-1)*placentone_step + 18};
	EndIf
EndFor


// Circle(301) = {1006,                                     1000, numbering_start + 4*placentone_step + 18};
// Circle(302) = {numbering_start + 4*placentone_step + 18, 1000, numbering_start + 3*placentone_step + 18};
// Circle(303) = {numbering_start + 3*placentone_step + 18, 1000, numbering_start + 2*placentone_step + 18};
// Circle(304) = {numbering_start + 2*placentone_step + 18, 1000, numbering_start + 1*placentone_step + 18};
// Circle(305) = {numbering_start + 1*placentone_step + 18, 1000, numbering_start + 0*placentone_step + 18};
// Circle(306) = {numbering_start + 0*placentone_step + 18, 1000, 1007};

///////////////////////////
// Placentone separators //
///////////////////////////
For k In {1:no_placentones-1:1}
	Line(200 + k) = {numbering_start + (k-1)*placentone_step + 15, numbering_start + (k-1)*placentone_step + 18};
EndFor

//////////////////////
// Marginal sinuses //
//////////////////////
If (ms_2 == 1)
	Line(1003) = {1002, 1004};
	Line(1004) = {1004, 1005};
	Line(1005) = {1005, 1006};
EndIf
Line(1006) = {1006, 1002};

If (ms_1 == 1)
	Line(1007) = {1007, 1008};
	Line(1008) = {1008, 1009};
	Line(1009) = {1009, 1001};
EndIf
Line(1010) = {1001, 1007};

//////////////////////
// Central cavities //
//////////////////////
For k In {0:no_placentones-1:1}
	offset = numbering_start + k*placentone_step;

	If (artery[k] == 1)
		Ellipse(offset + 21) = {offset + 19, offset + 22, offset + 22, offset + 20};
		Ellipse(offset + 22) = {offset + 20, offset + 22, offset + 22, offset + 21};

		Ellipse(offset + 49) = {offset + 42, offset + 22, offset + 22, offset + 25};
		Ellipse(offset + 50) = {offset + 25, offset + 22, offset + 22, offset + 44};

		Ellipse(offset + 51) = {offset + 43, offset + 22, offset + 22, offset + 26};
		Ellipse(offset + 52) = {offset + 26, offset + 22, offset + 22, offset + 45};
	EndIf
EndFor

//////////////////////////////////
// Physical curves and surfaces //
//////////////////////////////////
// Initial setup of the "ordinary" boundary.
Physical Curve(100) = {};

// Walls and septal veins.
For k In {0:no_placentones-2:1}
	offset = numbering_start + k*placentone_step;

	If (septal_vein_1[k] == 1)
		Physical Curve(100) += {offset + 30, offset + 31, offset + 33, offset + 35};
		Physical Curve(240 + k*10 + 1) = {offset + 32};
	Else
		Physical Curve(100) += {offset + 14};
	EndIf
	If (septal_vein_2[k] == 1)
		Physical Curve(100) += {offset + 36, offset + 37, offset + 39, offset + 42};
		Physical Curve(240 + k*10 + 2) = {offset + 38};
	Else
		Physical Curve(100) += {offset + 15, offset + 16};
	EndIf
	If (septal_vein_3[k] == 1)
		Physical Curve(100) += {offset + 43, offset + 44, offset + 45, offset + 46, offset + 48};
		Physical Curve(240 + k*10 + 3) = {offset + 45};
	Else
		Physical Curve(100) += {offset + 17};
	EndIf
EndFor

// Pipe sides.
For k In {0:no_placentones-1:1}
	offset = numbering_start + k*placentone_step;

	If (vein_1[k] == 1)
		Physical Curve(100) += {offset + 2, offset + 4};
	EndIf
	If (artery[k] == 1)
		Physical Curve(100) += {offset + 6, offset + 27, offset + 28, offset + 8};
	EndIf
	If (vein_2[k] == 1)
		Physical Curve(100) += {offset + 10, offset + 12};
	EndIf
EndFor

// Marginal sinus sides.
If (ms_1 == 1)
	Physical Curve(100) += {1007, 1009};
EndIf
If (ms_2 == 1)
	Physical Curve(100) += {1003, 1005};
EndIf

// Side walls of entire placenta.
If (ms_1 == 0)
	Physical Curve(100) += {1010};
EndIf
If (ms_2 == 0)
	Physical Curve(100) += {1006};
EndIf

// Basal plate.
For k In {1:no_placentones:1}
	Physical Curve(100) += {300 + k};
EndFor

// Curved boundary.
Physical Curve(101) = {};
For k In {0:no_placentones-1:1}
	offset = numbering_start + k*placentone_step;

	Physical Curve(101) += {offset + 1};
	If (vein_1[k] == 1)
		Physical Curve(101) += {offset + 5};
	EndIf
	Physical Curve(101) += {offset + 53, offset + 54, offset + 23, offset + 26, offset + 55, offset + 56};
	Physical Curve(101) += {offset + 9};
	If (vein_2[k] == 1)
		Physical Curve(101) += {offset + 13};
	EndIf
EndFor

// Inlets and outlets.
For k In {0:no_placentones-1:1}
	offset = numbering_start + k*placentone_step;
	
	If (vein_1[k] == 1)
		Physical Curve(211 + 2*k) = {offset + 3};
	EndIf
	If (vein_2[k] == 1)
		Physical Curve(212 + 2*k) = {offset + 11};
	EndIf

	If (artery[k] == 1)
		Physical Curve(111 + k)   = {offset + 7};
	EndIf
EndFor

// Margin sinuses.
If (ms_1 == 1)
	Physical Curve(230) = {1008};
EndIf
If (ms_2 == 1)
	Physical Curve(231) = {1004};
EndIf

//////////////
// Surfaces //
//////////////
// Placentones.
For k In {0:no_placentones-1:1}
	offset_prev = numbering_start + (k-1)*placentone_step;
	offset      = numbering_start + k    *placentone_step;

	placentone_list[] = {};
	placentone_list += {offset + 1};
	If (vein_1[k] == 1)
		placentone_list += {-(offset + 18), offset + 5};
	EndIf
	
	If (artery[k] == 1)
		placentone_list += {offset + 21, offset + 22};
	Else
		placentone_list += {offset + 53, offset + 54, offset + 23, offset + 26, offset + 55, offset + 56};
	EndIf

	placentone_list += {offset + 9};
	If (vein_2[k] == 1)
		placentone_list += {-(offset + 20), offset + 13};
	EndIf
	
	If (k == no_placentones-1)
		placentone_list += {-1006};
	EndIf
	If (k != no_placentones-1)
		If (septal_vein_1[k] == 1)
			placentone_list += {offset + 30, -(offset + 34), offset + 35};
		Else
			placentone_list += {offset + 14};
		EndIf
		If (septal_vein_2[k] == 1)
			placentone_list += {offset + 36, -(offset + 41)};
		Else
			placentone_list += {offset + 15};
		EndIf
		placentone_list += {201 + k};
	EndIf
	placentone_list += {300 + no_placentones - k};
	If (k == 0)
		placentone_list += {-1010};
	EndIf
	If (k != 0)
		placentone_list += {-(200 + k)};
		If (septal_vein_2[k-1] == 1)
			placentone_list += {-(offset_prev + 40), offset_prev + 42};
		Else
			placentone_list += {offset_prev + 16};
		EndIf
		If (septal_vein_3[k-1] == 1)
			placentone_list += {offset_prev + 43, -(offset_prev + 47), offset_prev + 48};
		Else
			placentone_list += {offset_prev + 17};
		EndIf
	EndIf

	Curve Loop(k + 1) = placentone_list[];

	// Printf("Placentone %d: ", k);
	// For i In {0:#placentone_list[]:1}
	// 	Printf("%f", placentone_list[i]);
	// EndFor
	// Printf("");
EndFor

For k In {1:no_placentones:1}
	Plane Surface(k) = {k};
	Physical Surface(300 + k) = {k};	
EndFor

// Pipes.
For k In {0:no_placentones-1:1}
	offset = numbering_start + k*placentone_step;

	If (vein_1[k] == 1)
		Curve Loop      (111 + k*10) = {offset + 2, offset + 3, offset + 4, offset + 18};
		Plane Surface   (111 + k*10) = {111 + k*10};
		Physical Surface(411 + k*10) = {111 + k*10};
	EndIf
	If (artery[k] == 1)
		Curve Loop      (112 + k*10) =  {offset + 6, offset + 27, offset + 7, offset + 28, offset + 8, offset + 25, offset + 24};
		Plane Surface   (112 + k*10) = {112 + k*10};
		Physical Surface(412 + k*10) = {112 + k*10};
	EndIf
	If (vein_2[k] == 1)
		Curve Loop      (113 + k*10) = {offset + 10, offset + 11, offset + 12, offset + 20};
		Plane Surface   (113 + k*10) = {113 + k*10};
		Physical Surface(413 + k*10) = {113 + k*10};
	EndIf
EndFor

// Plane Surface(111)                   = {111};
// Plane Surface(112)                   = {112};
// Plane Surface(113)                   = {113};
// Plane Surface(121)                   = {121};
// Plane Surface(122)                   = {122};
// Plane Surface(123)                   = {123};
// Plane Surface(131)                   = {131};
// Plane Surface(132)                   = {132};
// Plane Surface(133)                   = {133};
// Plane Surface(141)                   = {141};
// Plane Surface(142)                   = {142};
// Plane Surface(143)                   = {143};
// Plane Surface(151)                   = {151};
// Plane Surface(152)                   = {152};
// Plane Surface(153)                   = {153};
// Plane Surface(161)                   = {161};
// Plane Surface(162)                   = {162};
// Plane Surface(163)                   = {163};
// Physical Surface("flow-out_11", 411) = {111};
// Physical Surface("flow-out_12", 412) = {112};
// Physical Surface("flow-out_13", 413) = {113};
// Physical Surface("flow-out_21", 421) = {121};
// Physical Surface("flow-out_22", 422) = {122};
// Physical Surface("flow-out_23", 423) = {123};
// Physical Surface("flow-out_31", 431) = {131};
// Physical Surface("flow-out_32", 432) = {132};
// Physical Surface("flow-out_33", 433) = {133};
// Physical Surface("flow-out_41", 441) = {141};
// Physical Surface("flow-out_42", 442) = {142};
// Physical Surface("flow-out_43", 443) = {143};
// Physical Surface("flow-out_51", 451) = {151};
// Physical Surface("flow-out_52", 452) = {152};
// Physical Surface("flow-out_53", 453) = {153};
// Physical Surface("flow-out_61", 461) = {161};
// Physical Surface("flow-out_62", 462) = {162};
// Physical Surface("flow-out_63", 463) = {163};

If (ms_1 == 1)
	Curve Loop(201) = {1007, 1008, 1009, 1010};
	Plane Surface(201) = {201};
	Physical Surface(401) = {201};
EndIf
If (ms_2 == 1)
	Curve Loop(202) = {1003, 1004, 1005, 1006};
	Plane Surface(202) = {202};
	Physical Surface(402) = {202};
EndIf

For k In {0:no_placentones-2:1}
	offset = numbering_start + k*placentone_step;

	If (septal_vein_1[k] == 1)
		Curve Loop      (471 + k) = {offset + 31, offset + 32, offset + 33, offset + 34};
		Plane Surface   (471 + k) = {471 + k};
		Physical Surface(471 + k) = {471 + k};
	EndIf
	If (septal_vein_2[k] == 1)
		Curve Loop      (481 + k) = {offset + 37, offset + 38, offset + 39, offset + 40, offset + 41};
		Plane Surface   (481 + k) = {481 + k};
		Physical Surface(481 + k) = {481 + k};
	EndIf
	If (septal_vein_3[k] == 1)
		Curve Loop      (491 + k) = {offset + 44, offset + 45, offset + 46, offset + 47};
		Plane Surface   (491 + k) = {491 + k};
		Physical Surface(491 + k) = {491 + k};
	EndIf
EndFor

// Central cavities.
For k In {0:no_placentones-1:1}
	offset = numbering_start + k*placentone_step;

	If (artery[k] == 1)
		Curve Loop      (501 + k) = {offset + 23, -(offset + 24), -(offset + 25), offset + 26, -(offset + 52), -(offset + 51)};
		Plane Surface   (501 + k) = {501 + k};
		Physical Surface(501 + k) = {501 + k};

		Curve Loop      (511 + k) = {offset + 54, offset + 51, offset + 52, offset + 55, -(offset + 50), -(offset + 49)};
		Plane Surface   (511 + k) = {511 + k};
		Physical Surface(511 + k) = {511 + k};

		Curve Loop      (521 + k) = {offset + 53, offset + 49, offset + 50, offset + 56, -(offset + 22), -(offset + 21)};
		Plane Surface   (521 + k) = {521 + k};
		Physical Surface(521 + k) = {521 + k};
	EndIf
EndFor

// Plane Surface(51)                = {51};
// Plane Surface(52)                = {52};
// Plane Surface(53)                = {53};
// Plane Surface(54)                = {54};
// Plane Surface(55)                = {55};
// Plane Surface(56)                = {56};
// Physical Surface("cavity1", 501) = {51};
// Physical Surface("cavity2", 502) = {52};
// Physical Surface("cavity3", 503) = {53};
// Physical Surface("cavity4", 504) = {54};
// Physical Surface("cavity5", 505) = {55};
// Physical Surface("cavity6", 506) = {56};