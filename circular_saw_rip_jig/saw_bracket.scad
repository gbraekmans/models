LENGTH = 30;
WIDTH = 9;
HEIGHT = 12;
WALL = 12;
CHAMFER = 2;

// Shank diameter of the flathead screw
SCREW = 4;

MIRRORED = false;

module dummy() {};

$fa = $preview? 12 : 4;
$fs = $preview? 2 : 0.2;
EPS = 0.01;

// makes coordinates more readable
x = 0;
y = 1;

// makes parameters more readable
length = 0;
width = 1;
wall = 2;
height = 3;
chamfer = 4;
screw = 5;

function saw_bracket(
    length = LENGTH,
    width = WIDTH,
    wall = WALL,
    height = HEIGHT,
    chamfer = CHAMFER,
    screw=SCREW
) = [length, width, wall, height, chamfer, screw];

module sketch_saw_bracket(p) {
    translate([ -p[wall], -p[wall] ]) difference() {
        square([ p[length] + p[wall],
                 p[width] + p[wall] ]);
        translate([ p[wall]+EPS, p[wall]+EPS ])
            square([ p[length], p[width] ]);
    }
}

module place_saw_bracket_screws(p) {
    delta = p[chamfer] + (p[wall] - p[chamfer]) / 2;
    translate([-delta, -delta]) {
        children();
        translate([ p[length], 0 ]) children();
        translate([ 0, p[width] ]) children();
    }
}

module make_saw_bracket(p) {
    
    module screw_hole() {
        translate([ 0, 0, (p[height] - p[screw]) / 2 ])
        cylinder(p[screw]/2+EPS, r1=p[screw]/2, r2=p[screw]);
        cylinder(p[height]+2*EPS, r=p[screw]/2, center=true);
    }
    
    difference() {
        // the body
        minkowski() {
            linear_extrude(p[height] - p[chamfer], center=true)
                translate([ -p[chamfer], -p[chamfer] ])
                    sketch_saw_bracket(p);
            
            linear_extrude(p[chamfer], scale=0, center=true) square(p[chamfer]);
        }
        
        place_saw_bracket_screws(p) screw_hole();
    }
}

b = saw_bracket();
if(MIRRORED)
    mirror([1,0,0]) make_saw_bracket(b);
else
    make_saw_bracket(b);