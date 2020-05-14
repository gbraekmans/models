// The outer diameter of the bushing
DIAMETER = 30;

// The height of the bushing
HEIGHT = 50;

BORE_DIAMETER = 25;

// How high the pins should be (0 to disable)
PIN_HEIGHT = 1.25;

// The amount of pins connecting to the rod
PINS = 12; // [3:100]

// Percentage of bore covered by pins (if PIN WIDTH = 0)
PIN_BORE_COVERAGE = 0.5; // [0:0.01:1.01]

// The distance which should be chamfered
CHAMFER = 1.25;

include <../globals.scad>;
use <bushing_common.scad>;

module bsc(
            bushing_radius=DIAMETER/2,
            bore_radius=BORE_DIAMETER/2,
            height=HEIGHT,
            pin_count=PINS,
            pin_bore_coverage=PIN_BORE_COVERAGE,
            pin_height=PIN_HEIGHT,
            chamfer=CHAMFER
           ) {
               
    assert(bushing_radius > bore_radius + pin_height);
               
    difference() {
        cylinder(height, r=bushing_radius, center=true);
        
        bushing_bore(
            inner_radius=bore_radius,
            outer_radius=bore_radius + pin_height,
            height=HEIGHT + 2 * EPS,
            pin_count=pin_count,
            pin_bore_coverage=pin_bore_coverage,
            chamfer=chamfer
        );
    }
}

bsc();