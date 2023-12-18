If (!Exists(h))
  h=2;
EndIf

Point(1) = { 0.0,  0.0, 0.0, h};
Point(2) = { 1.0,  0.0, 0.0, h};
Point(3) = { 1.0,  1.0, 0.0, h};
Point(4) = {-1.0,  1.0, 0.0, h};
Point(5) = {-1.0, -1.0, 0.0, h};
Point(6) = { 0.0, -1.0, 0.0, h};

Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 5};
Line(5) = {5, 6};
Line(6) = {6, 1};

Line Loop(1) = {1, 2, 3, 4, 5, 6};
Plane Surface(1) = {1};

Physical Curve(101) = {1}; // Bottom right.
Physical Curve(202) = {2}; // Right.
Physical Curve(103) = {3}; // Top.
Physical Curve(104) = {4}; // Left.
Physical Curve(105) = {5}; // Bottom left.
Physical Curve(106) = {6}; // Vertical.

// Physical Curve(1) = {1}; // Bottom right.
// Physical Curve(102) = {2}; // Right.
// Physical Curve(3) = {3}; // Top.
// Physical Curve(4) = {4}; // Left.
// Physical Curve(5) = {5}; // Bottom left.
// Physical Curve(6) = {6}; // Vertical.

Physical Surface(300) = {1}; // The whole domain.