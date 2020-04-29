/* 
 * The defaults give you a DIN 6336 compatible star knob for M6 bolts
 *
 * I usually go for 5 handles, with a metal (DIN 9021) washer.
 * I also tend to go for about 40mm in diameter.
 *
 */

// In general you'll want to print the knob
PRINT_KNOB = true;

// The type of knob to print
KNOB_TYPE = "Modern"; // ["Modern", "Classic"]

// If you're out of metal ones, print a plastic one
PRINT_WASHER = false;

/* [Knob] */

// The value of the knob's largest cross-section
DIAMETER = 35;

// The largest circle which can fit inside the knob
INNER_DIAMETER = 22;

// The height of the knob
HEIGHT = 12;

// The number of places where you can put your fingers
HANDLES = 5; // [4:8]

// Generally unchecked for usage with bolts, checked for usage with nuts
THROUGH_BORE = false;

/* [Bolt] */

// The diameter of the shaft, add some clearance for a loose fit
BOLT_DIAMETER = 6.25;

// The diameter of the inscribed circle, or the size of wrench you need
// Add some clearance if you're glueing the bolt
BOLT_HEAD_DIAMETER = 10.25;

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
WASHER_BUSHING_HEIGHT = 1;

// Hide the next globals
module dummy() {};
EPS = 0.01;

$fa = $preview? 12 : 6;
$fs = $preview? 2 : 0.2;

// moves an object to the bolt cutout surface
module star_knob_place_at_bolt(bolt_head_height=BOLT_HEAD_HEIGHT) {
    translate([0,0, -bolt_head_height / 2]) children();
}

module star_knob_classic_body(
    radius=DIAMETER/2,
    inner_radius = INNER_DIAMETER / 2,
    height=HEIGHT,
    handles=HANDLES
) {
    assert(radius > inner_radius);
    
    cutout_radius = radius - inner_radius;
    fillet = cutout_radius / 2;
    chamfer = min( radius / 10, height / 7.5);

    module body_sketch() {
        offset(r=fillet) offset(delta=-fillet)
        difference() {
            circle(r=radius - chamfer);
            for(a=[0:360/handles:360])
                rotate(a)
                    translate([radius, 0])
                        circle(r=cutout_radius);
        }
    }

    module double_cone(r) {
        cylinder(r, r1=r, r2=0);
        rotate([180,0]) cylinder(r, r1=r, r2=0);
    }

    rotate(-90) minkowski() {
        linear_extrude(height - 2 * chamfer,
                       center=true)
            body_sketch();
        
        double_cone(chamfer);
    }

}

module star_knob_modern_body(
    radius=DIAMETER / 2,
    inner_radius=INNER_DIAMETER/2,
    height=HEIGHT,
    handles=HANDLES,
) {

    cutout_depth_pct=2/3;
    chamfer_angle=15;

    chamfer_distance = radius - inner_radius;
    cutout_depth = cutout_depth_pct * chamfer_distance;
    chamfer_radius = radius - chamfer_distance;
    chamfer_height = tan(chamfer_angle) * chamfer_distance;
    cutout_radius = PI * radius / handles;
    hull_center = radius - cutout_radius;
    cutout_center = radius - cutout_depth + cutout_radius;

    rotate(90) difference() {
        hull() {
                // the rounded polygon
                for(a=[0:360/handles:360])
                    rotate(a) translate([hull_center, 0])
                        cylinder(height - 2 * chamfer_height, r=cutout_radius,
                                 center=true);
            // top & bottom chamfer
            cylinder(height, r=chamfer_radius, center=true);
        }
        // handle cutouts
        for(a=[180/handles:360/handles:360])
            rotate(a) translate([cutout_center, 0])
                cylinder(height + 2 * EPS, r=cutout_radius, center=true);
    }

}

module star_knob_bolt_and_washer_cutout(
    height=HEIGHT,
    through_bore=THROUGH_BORE,
    bolt_diameter=BOLT_DIAMETER,
    bolt_head_diameter=BOLT_HEAD_DIAMETER,
    bolt_head_height=BOLT_HEAD_HEIGHT,
    washer_diameter=WASHER_DIAMETER,
    washer_height=WASHER_HEIGHT
) {
    difference() {
        union() {
            children();
        }
        
        // bolt head cutout
        translate([0,0,height/2 - washer_height - bolt_head_height])
            cylinder(bolt_head_height + EPS, r=bolt_head_diameter/2/cos(180/6),
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
                        washer_radius=WASHER_DIAMETER/2,
                        washer_height=WASHER_HEIGHT,
                        washer_bushing_radius=WASHER_BUSHING_DIAMETER/2,
                        washer_bushing_height=WASHER_BUSHING_HEIGHT,
                        bolt_radius=BOLT_DIAMETER/2
                        ) {
    chamfer_r = (washer_radius - washer_bushing_radius) / 2;
    
    rotate_extrude()
        offset(delta=-chamfer_r, chamfer=true) offset(delta=chamfer_r) {
            translate([bolt_radius,0])
                square([washer_radius - bolt_radius, washer_height]);
            translate([bolt_radius,0])
                square([washer_bushing_radius - bolt_radius,
                        washer_bushing_height + washer_height]);
    }
}

translate([0,0,HEIGHT/2])
if(PRINT_KNOB) {
    if(KNOB_TYPE == "Classic")
        star_knob_bolt_and_washer_cutout() star_knob_classic_body();
    if(KNOB_TYPE == "Modern")
        star_knob_bolt_and_washer_cutout() star_knob_modern_body();
}
    
if(PRINT_WASHER)
    translate([DIAMETER,0,0]) star_knob_washer();