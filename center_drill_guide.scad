// Width of the stock to drill
WIDTH = 45;
// Height of the drill bushing
HEIGHT = 10;
// Minimum wall thickness
WALL = 2;

// Height of the flanges, 0 to disable
FLANGE = 5;

// Diameter of the bushing
BORE_DIAMETER = 4;

module dummy() {};

EPS = 0.01;
ENGRAVE_DEPTH = 0.3;

$fa = $preview? 12 : 4;
$fs = $preview? 2 : 0.2;

alignment_space = (WIDTH - BORE_DIAMETER) / 2;
alignment_size = 0.9 * (alignment_space - 2*WALL) / sqrt(2);

module letters(d) {
    translate([0,-d])
        rotate([90,0,0]) rotate(180)
            linear_extrude(ENGRAVE_DEPTH * 2, center=true)
                text(str(BORE_DIAMETER, "/", WIDTH), size=0.75 * HEIGHT, halign="center", valign="center");
}

difference() {
    union() {
        // body
        cube([WIDTH, WIDTH, HEIGHT], center=true);

        // right flange
        if(FLANGE)
        translate([(WIDTH + WALL)/2, 0 , FLANGE/2])
            cube([WALL, WIDTH, HEIGHT+FLANGE], center=true);

        // left flange
        if(FLANGE)
        translate([-(WIDTH + WALL)/2, 0 , FLANGE/2])
            cube([WALL, WIDTH, HEIGHT+FLANGE], center=true);
    }
    // bore
    cylinder(HEIGHT + 2*EPS, r=BORE_DIAMETER/2, center=true);

    // alignment holes    
    if(alignment_size > 0) {
        translate([(BORE_DIAMETER + alignment_space) / 2, 0, 0])
            rotate([0,0,45])
                cube([alignment_size, alignment_size, HEIGHT+2*EPS], center=true);
        translate([-(BORE_DIAMETER + alignment_space) / 2, 0, 0])
            rotate([0,0,45])
                cube([alignment_size, alignment_size, HEIGHT+2*EPS], center=true);
        translate([0, (BORE_DIAMETER + alignment_space) / 2, 0])
            rotate([0,0,45])
                cube([alignment_size, alignment_size, HEIGHT+2*EPS], center=true);
        translate([0, -(BORE_DIAMETER + alignment_space) / 2, 0])
            rotate([0,0,45])
                cube([alignment_size, alignment_size, HEIGHT+2*EPS], center=true);
    }
    
    //Engrave
    letters(WIDTH/2);
    rotate(90) letters(WIDTH/2 + (FLANGE > 0? WALL : 0));
    rotate(180) letters(WIDTH/2);
    rotate(270) letters(WIDTH/2 + (FLANGE > 0? WALL : 0));

}