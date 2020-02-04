/* 
 * The defaults give you a DIN 6336 compatible star knob for M6 bolts
 *
 * I usually go for 5 handles, with a metal (DIN 9021) washer.
 * I also tend to go for about 40mm in diameter.
 *
 */

// In general you'll want to print the knob
PRINT_KNOB = true;

// If you're out of metal ones, print a plastic one
PRINT_WASHER = false;

/* [Knob] */

// The value of the knob's largest cross-section
DIAMETER = 32;

// The height of the knob
HEIGHT = 10;

// Generally unchecked for usage with bolts, checked for usage with nuts
THROUGH_BORE = false;

// The number of places where you can put your fingers
HANDLE_COUNT = 7; // [4:8]

/* [Bolt] */

// The diameter of the shaft, add some clearance for a loose fit
BOLT_DIAMETER = 6.4;

// The diameter of the inscribed circle, or the size of wrench you need
// Add some clearance if you're glueing the bolt
BOLT_HEAD_DIAMETER = 10.4;

// How high the head is, and half a layer clearance so you're sure it fits
BOLT_HEAD_HEIGHT = 5.1;

/* [Washer] */

// The diameter of the washer
WASHER_DIAMETER = 18.2;

// The height of the washer
WASHER_HEIGHT = 1.6;

// The diameter of the bushing
WASHER_BUSHING_DIAMETER = 14;

// The height of a optional bushing
WASHER_BUSHING_HEIGHT = 10;

// Hide the next globals
module dummy() {};
EPS = 0.01;

$fa = $preview? 12 : 6;
$fs = $preview? 2 : 0.2;

// moves an object to the bolt cutout surface
module star_knob_place_at_bolt(bolt_head_height=BOLT_HEAD_HEIGHT) {
    translate([0,0, -bolt_head_height / 2]) children();
}

module star_knob(
    diameter=DIAMETER,
    through_bore=THROUGH_BORE,
    height=HEIGHT,
    bolt_diameter=BOLT_DIAMETER,
    bolt_head_diameter=BOLT_HEAD_DIAMETER,
    bolt_head_height=BOLT_HEAD_HEIGHT,
    washer_diameter=WASHER_DIAMETER,
    washer_height=WASHER_HEIGHT,
    handle_count=HANDLE_COUNT,
    cutout_diameter=undef // depth of the cutouts
) {

    function apply_default(v, d) = is_undef(v)? d : v;

    cutout_diameter = apply_default(cutout_diameter,
                                    1.8 * diameter / handle_count);

    fillet = cutout_diameter / 4;
    chamfer = min( diameter / 20, height / 7.5);
    
    // make sure the washer fits the knob and there is a 1 unit wall
    assert(diameter - washer_diameter - cutout_diameter >= 2);

    module body_sketch() {
        offset(r=fillet) offset(delta=-fillet)
        difference() {
            circle(r=diameter/2);
            for(a=[0:360/handle_count:360])
                rotate(a)
                translate([diameter/2, 0])
                circle(r=cutout_diameter/2);
        }
    }
    
    module body(s) {

        module double_cone(r) {
            cylinder(r, r1=r, r2=0);
            rotate([180,0]) cylinder(r, r1=r, r2=0);
        }

        minkowski() {
            linear_extrude(height - 2 * chamfer,
                           center=true)
                body_sketch();
            
            double_cone(chamfer);
        }
    }
    
    difference() {
        body();
        
        // bolt head cutout
        translate([0,0,height/2 - washer_height - bolt_head_height]) cylinder(bolt_head_height + EPS, r=bolt_head_diameter/2,
                 $fn=6);
 
        // washer cutout
        if(washer_height > 0)
            translate([0,0,(height - washer_height) / 2])
                cylinder(washer_height + 2*EPS,
                         r=washer_diameter/2,
                         center=true);
        
        // through cut
        if(through_bore)
            cylinder(height + 2*EPS, r=bolt_diameter/2, center=true);
    }
}

module star_knob_washer(
                        washer_diameter=WASHER_DIAMETER,
                        washer_height=WASHER_HEIGHT,
                        washer_bushing_diameter=WASHER_BUSHING_DIAMETER,
                        washer_bushing_height=WASHER_BUSHING_HEIGHT,
                        bolt_diameter=BOLT_DIAMETER
                        ) {
    
    assert(washer_bushing_diameter > bolt_diameter);
    assert(washer_diameter >= washer_bushing_diameter);                        
    
    difference() {
        union() {
            cylinder(washer_height, r=washer_diameter/2);
            translate([0,0,washer_height]) cylinder(washer_bushing_height, r=washer_bushing_diameter/2);
        }
        translate([0,0,-EPS]) cylinder(washer_height + washer_bushing_height + 2*EPS, r=bolt_diameter/2);
    }
}

// Make sure there is a wall
assert(HEIGHT >= BOLT_HEAD_HEIGHT + 2*WASHER_HEIGHT);

if(PRINT_KNOB)
    translate([0,0,HEIGHT/2]) star_knob();
if(PRINT_WASHER)
    translate([DIAMETER,0,0]) star_knob_washer();