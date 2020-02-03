// A fancier alternative to the star knob, having a bit less grip

// In general you'll want to print the knob
PRINT_KNOB = true;

// If you're out of metal ones, print a plastic one
PRINT_WASHER = false;

/* [Knob] */

// The value of the knob's largest cross-section
DIAMETER = 35;

// Height of the knob
HEIGHT = 12;

// Amount of cutouts in the knob
HANDLES = 5;

// The angle of the chamfer
CHAMFER_ANGLE = 15; // [0:45]

// The depth of the chamfer into the knob
CHAMFER_DISTANCE = 6;

// The depth of the handle cutouts into the knob
CUTOUT_DEPTH = 4;

// Generally unchecked for usage with bolts, checked for usage with nuts
THROUGH_BORE = false;

/* [Bolt] */

// The diameter of the shaft, add some clearance for a loose fit
BOLT_DIAMETER = 6.4;

// The diameter of the inscribed circle, or the size of wrench you need
// Add some clearance if you're glueing the bolt
BOLT_HEAD_DIAMETER = 10.2;

// How high the head is, and half a layer clearance so you're sure it fits
BOLT_HEAD_HEIGHT = 5.1;

/* [Washer] */

// The diameter of the washer
WASHER_DIAMETER = 18.2;

// The height of the washer
WASHER_HEIGHT = 1.6;

// The diameter of the bushing
WASHER_BUSHING_DIAMETER = 10;

// The height of a optional bushing
WASHER_BUSHING_HEIGHT = 1;

module dummy() {};

$fa = $preview? 12 : 6;
$fs = $preview? 2 : 0.2;

EPS = 0.01;

module star_knob_fancy(
    radius=DIAMETER / 2,
    height=HEIGHT,
    chamfer_radius=DIAMETER / 2 - CHAMFER_DISTANCE,
    chamfer_height=tan(CHAMFER_ANGLE) * CHAMFER_DISTANCE,
    handles=HANDLES,
    cutout_depth=CUTOUT_DEPTH,
    bolt_radius=BOLT_DIAMETER/2,
    bolt_head_radius=BOLT_HEAD_DIAMETER/2,
    bolt_head_height=BOLT_HEAD_HEIGHT,
    washer_radius = WASHER_DIAMETER/2,
    washer_height = WASHER_HEIGHT,
    through_bore = THROUGH_BORE
      ) {

    cutout_radius = PI * radius / handles;

    hull_center = radius - cutout_radius;

    cutout_center = radius - cutout_depth + cutout_radius;

    difference() {
        hull() {
                // the rounded polygon
                for(a=[0:360/handles:360])
                    rotate(a) translate([hull_center, 0])
                        cylinder(height - 2 * chamfer_height, r=cutout_radius, center=true);
            // top & bottom chamfer
            cylinder(height, r=chamfer_radius, center=true);
        }
        // handle cutouts
        for(a=[180/handles:360/handles:360])
            rotate(a) translate([cutout_center, 0])
                cylinder(height + 2 * EPS, r=cutout_radius, center=true);
        
        // washer cutout
        translate([0,0, height/2 - washer_height]) cylinder(washer_height + EPS, r=washer_radius);
        
        // bolt head cutout
        translate([0,0, height/2 - washer_height - bolt_head_height]) cylinder(bolt_head_height + EPS, r=bolt_head_radius, $fn=6);
        
        // bolt cutout
        if(through_bore)
            translate([0,0, height/2 - washer_height - bolt_head_height + EPS]) rotate([180,0]) cylinder(height, r=bolt_radius);
    }    
}

module star_knob_fancy_washer(
                        washer_radius=WASHER_DIAMETER/2,
                        washer_height=WASHER_HEIGHT,
                        washer_bushing_radius=WASHER_BUSHING_DIAMETER/2,
                        washer_bushing_height=WASHER_BUSHING_HEIGHT,
                        bolt_radius=BOLT_DIAMETER/2
                        ) {
    chamfer_r = (washer_radius - washer_bushing_radius) / 2;
    
    rotate_extrude() offset(delta=-chamfer_r, chamfer=true) offset(delta=chamfer_r) {
        translate([bolt_radius,0]) square([washer_radius - bolt_radius, washer_height]);
        translate([bolt_radius,0]) square([washer_bushing_radius - bolt_radius, washer_bushing_height + washer_height]);
    }
}

if (PRINT_KNOB) translate([0,0,HEIGHT/2]) star_knob_fancy();
if (PRINT_WASHER) translate([DIAMETER,0,0]) star_knob_fancy_washer();