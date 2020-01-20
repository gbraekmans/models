// cross-section of the rod
ROD_DIAMETER = 8; // [4:0.01:80]

// minimum thickness of the walls
WALL = 2; // [1:0.1:3]

// the size of the clamping cutout
CUTOUT = 1; // [0:0.1:4]

// keep this smaller than the extrusion width
ENGRAVE_DEPTH = 0.3; // [0.1:0.05:1]

// Make the following globals private
module dummy() {};

EPS = 0.01;

SIZE = 2 * WALL + ROD_DIAMETER;
TEXT_SIZE = 0.9 *  SIZE / len(str(ROD_DIAMETER));

$fa = $preview? 12 : 6;
$fs = $preview? 2 : 0.2;

difference() {
    cube([SIZE, SIZE, SIZE], center=true); // the fixture

    cylinder(SIZE + EPS, r=ROD_DIAMETER/2, center=true); // hole for the rod
    translate([0,0, SIZE/2 - WALL/4 + EPS])  // top chamfer
        cylinder(WALL/2, r1=ROD_DIAMETER/2, r2=(ROD_DIAMETER + WALL) / 2,
                 center=true);
    translate([0,0, -SIZE/2 + WALL/4 - EPS]) // bottom chamfer
        cylinder(WALL/2, r2=ROD_DIAMETER/2, r1=(ROD_DIAMETER + WALL) / 2,
                 center=true);
    
    rotate([0,90]) // square drilling cutout
        cylinder(SIZE + EPS, r=ROD_DIAMETER/2, $fn=4); 
    
    translate([SIZE/2,0]) // clamping cutout
        cube([SIZE, CUTOUT, SIZE + EPS], center=true);
    
    translate([0,-SIZE/2]) rotate([90,0,0]) // size engraving
        linear_extrude(2 * ENGRAVE_DEPTH, center=true)
            text(str(ROD_DIAMETER), size=TEXT_SIZE,
                 valign="center", halign="center");
}