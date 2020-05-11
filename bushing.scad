
/* [Bushing] */

// The outer diameter of the bushing
DIAMETER = 33.15;

// The height of the bushing
HEIGHT = 50;

// Radius of the chamfer
CHAMFER = 2;

/* [Rod] */

// Diameter of the linear smooth rod
ROD_DIAMETER = 25.15;

// The amount of pins connecting to the rod
PINS = 12; // [3:100]

// How high the pins should be
PIN_HEIGHT = 2;

// Percentage of rod circumference covered by pins
PIN_COVERAGE = 0.5; // [0:0.01:1.01]

module dummy() {};
$fa = $preview? 12 : 6;
$fs = $preview? 2 : 0.2;
EPS = 0.01;

module rod_sketch(
    inner_radius=ROD_DIAMETER/2,
    outer_radius=1.2 * ROD_DIAMETER/2,
    pins=PINS,
    pin_coverage=1-PIN_COVERAGE
) {
    assert(pin_coverage <= 1);
    assert(pin_coverage >= 0);
    assert(pins >= 3);
    
    pin_width = 2 * PI * inner_radius * pin_coverage / pins;
    pin_length = outer_radius;
   
    // create the rod
    circle(r=inner_radius);
    
    if(outer_radius > inner_radius) {
        // create the pins
        intersection() {
            // pins
            for(a=[0:360/pins:360])
                rotate(a)
                    translate([0,-pin_width/2])
                        square([pin_length, pin_width]);
            // round over pin ends
            circle(outer_radius);
        }
    }
}

module bushing_sketch(
    outer_radius=DIAMETER/2,
    inner_radius=ROD_DIAMETER/2,
    pins=PINS,
    pin_height=PIN_HEIGHT,
    pin_coverage=PIN_COVERAGE
) {

    assert(inner_radius + pin_height < outer_radius);

    difference() {
        
        // the bushing
        circle(outer_radius);
        
        // the rod cutout
        rod_sketch(
            inner_radius=inner_radius,
            outer_radius=inner_radius + pin_height,
            pins=pins,
            pin_coverage=1-pin_coverage);
    }
}

module bushing(
    outer_radius=DIAMETER/2,
    inner_radius=ROD_DIAMETER/2,
    height=HEIGHT,
    pins=PINS,
    pin_height=PIN_HEIGHT,
    pin_coverage=PIN_COVERAGE,
    chamfer_height=CHAMFER
) {
    
    module chamfer_cone() {
        cylinder(chamfer_height, r1=chamfer_height + inner_radius, r2=inner_radius);    
    }
    
    difference() {
        // the bushing
        linear_extrude(height, center=true)
            bushing_sketch(
                outer_radius=outer_radius,
                inner_radius=inner_radius,
                pins=pins,
                pin_height=pin_height,
                pin_coverage=pin_coverage    
            );
        
        // bottom chamfer
        translate([0,0,-height/2-EPS]) chamfer_cone();

        // top chamfer
        translate([0,0,height/2+EPS]) rotate([180,0,0]) chamfer_cone();
    }
    
}


bushing();