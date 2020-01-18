// This is something quick and specific to my cirucular saw.
// The code you'll find is not very polished.

WALL = 3;
WIDTH = 10;
LEVER = 10;
CUTOUT = 3.5;
HEIGHT = 20;

x = LEVER+WIDTH;
y = WALL + CUTOUT + WALL;
z = HEIGHT + WALL;

module xz_sketch() {
    offset(delta=-WALL/2, chamfer=true) offset(delta=WALL/2) difference() {
        square([x,z]);
        translate([WIDTH,0]) square([LEVER,HEIGHT]);
    } 
}

module yz_sketch() {
    offset(r=-WALL/2) offset(delta=WALL/2) {
        square([WALL,LEVER]);
        translate([WALL,0]) square([CUTOUT, WALL]);
        translate([WALL+CUTOUT,0]) square([WALL, z]);
    }
}

$fa = 6;
$fs = 0.2;

intersection() {
    translate([0,WALL+CUTOUT+WALL,0]) rotate([90,0])
        linear_extrude(WALL+CUTOUT+WALL) xz_sketch();
    rotate([90,0,90])linear_extrude(LEVER+WIDTH) yz_sketch();
}
translate([WIDTH,WALL+CUTOUT+WALL,HEIGHT]) {
    cube([LEVER,WALL*2,WALL]);
    linear_extrude(WALL) polygon([[-2*WALL,0], [0,0], [0,2*WALL]]);
}