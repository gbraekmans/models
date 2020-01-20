// I print the embossed text on the block in a different color

// Name of the power tool
TEXT = "Circular Saw";

// Thickness of the blade
KERF = 3; //[0.01:0.01:30]

// Distance of the "fence" to the blade
DISTANCE_TO_BLADE = 30; // [0:0.1:200]

// Hide the following globals from the customizer
module dummy() {};

FONTSIZE = min(10, DISTANCE_TO_BLADE / 2);
LENGTH = len(TEXT) * FONTSIZE;
HEIGHT = 15;
WIDTH = KERF + DISTANCE_TO_BLADE + 10;
TEXT_HEIGHT = 1;
CHAMFER = 1;
EPS = 0.02;

$fa = $preview? 12 : 6;
$fs = $preview? 2 : 0.2;

difference() {
    // Chamfered cube with embossed text
    translate([0,WIDTH/2]) {
        
        hull() { // chamfered cube
            cube([LENGTH, WIDTH, HEIGHT - 2 * CHAMFER], center=true);
            cube([LENGTH - 2*CHAMFER, WIDTH - 2*CHAMFER, HEIGHT], center=true);
        }
        
        // emboss
        translate([0,-(10 + KERF)/2, HEIGHT/2]) linear_extrude(TEXT_HEIGHT)
            text(TEXT, size=FONTSIZE, font="sans",
                 valign="center", halign="center");
    }

    // Left kerf
    translate([-LENGTH/2+LENGTH/8-EPS, KERF/2 + DISTANCE_TO_BLADE])
        cube([LENGTH/4, KERF, HEIGHT*2], center=true);
    
    // Right kerf
    translate([LENGTH/2-LENGTH/8+EPS, KERF/2 + DISTANCE_TO_BLADE])
        cube([LENGTH/4, KERF, HEIGHT*2], center=true);
}