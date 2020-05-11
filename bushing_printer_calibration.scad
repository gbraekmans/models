/* [Calibration Test] */

// The increase in diameter each hole
HOLE_INCREMENT = 0.1; //[0.05:0.01:1]

// The amount of holes
HOLES = 3;

// The height of the piece
HEIGHT = 10;

// Thickness of the wall
WALL = 10;

/* [Rod] */

// Diameter of the linear smooth rod
ROD_DIAMETER = 25.1;

// The amount of pins connecting to the rod
PINS = 12; // [3:100]

// Percentage of rod circumference covered by pins
PIN_COVERAGE = 0.5; // [0:0.01:1.01]

// How long the pins should be
PIN_HEIGHT = 2;

module dummy() {};
$fa = $preview? 12 : 6;
$fs = $preview? 2 : 0.2;
EPS = 0.01;

MAX_R = (ROD_DIAMETER + (HOLES - 1) * HOLE_INCREMENT) / 2;
OUTER_R = MAX_R + PIN_HEIGHT / 2;
WIDTH = OUTER_R * 2 + 2 * WALL;
LENGTH = (HOLES+1) * WALL + HOLES * OUTER_R * 2;

use <bushing.scad>;

function x_pos(n) = OUTER_R + WALL + (n-1) * (WALL + OUTER_R * 2);

difference() {
    // The main body
    linear_extrude(HEIGHT, center=true)
    square([LENGTH, WIDTH]);

    for(n=[1:HOLES])
        let(
            r = ROD_DIAMETER/2 + (n - 1) * HOLE_INCREMENT / 2
            ) {
            
            // Bushing hole
            translate([x_pos(n), WIDTH/2])
            linear_extrude(HEIGHT + 2*EPS, center=true)
            rod_sketch(
                outer_radius = r + PIN_HEIGHT,
                inner_radius = r,
                pins = PINS,
                pin_coverage = PIN_COVERAGE
            );
            
            // Text
            translate([x_pos(n), 0])
            rotate([90,0,0])
            linear_extrude(0.6, center=true)
            text(str(r * 2), size=0.7*HEIGHT, valign="center", halign="center");
        }
    }