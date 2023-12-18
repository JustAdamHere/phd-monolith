If (!Exists(h))
  h=2;
EndIf

Point(1) = {0.0, 0.0, 0.0, h};
Point(2) = {1.0, 0.0, 0.0, h};
Point(3) = {1.0, 1.0, 0.0, h};
Point(4) = {0.0, 1.0, 0.0, h};

Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};

Line Loop(1) = {4, 1, 2, 3};
Plane Surface(1) = {1};

// Physical Curve(101) = {1}; // Bottom.
// Physical Curve(201) = {2}; // Right.
// Physical Curve(202) = {3}; // Top.
// Physical Curve(102) = {4}; // Left.

Physical Curve(101) = {1}; // Bottom.
Physical Curve(202) = {2}; // Right.
Physical Curve(103) = {3}; // Top.
Physical Curve(204) = {4}; // Left.

Physical Surface(300) = {1}; // The whole domain.