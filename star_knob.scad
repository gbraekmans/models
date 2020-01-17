

// If the next assertion fails, it is because your diameter was set too low.
// Assertion '(star_knob_get_washer_radius(s) >=
//            (star_knob_get_bolt_head_radius(s) + WALL))' failed
//

// The value of the knob's largest cross-section
DIAMETER = 35; // [10:80]

// Generally unchecked for usage with bolts, checked for usage with nuts
CUT_THROUGH = false;

// The diameter of the shaft, add some clearance for a loose fit
BOLT_DIAMETER = 6.5; // [2:0.1:20]

// The diameter of the inscribed circle, or the size of wrench you need
// Add some clearance if you're glueing the bolt
BOLT_HEAD_DIAMETER = 10.2; // [4:0.1:30]

// How high the head is, and half a layer clearance so you're sure it fits
BOLT_HEAD_HEIGHT = 5.1; // [1.5:0.1:20]

// The number of places where you can put your fingers
HANDLE_COUNT = 5; // [4:8]


/* [Hidden] */
EPS = 0.01;
WALL = 2;

function star_knob_new(
                       diameter=DIAMETER,
                       bolt_diameter=BOLT_DIAMETER,
                       bolt_head_diameter=BOLT_HEAD_DIAMETER,
                       bolt_head_height=BOLT_HEAD_HEIGHT,
                       handle_count=HANDLE_COUNT,
                       cut_through=CUT_THROUGH) =
    [
        handle_count,
        diameter,
        bolt_diameter,
        bolt_head_diameter,
        bolt_head_height,
        cut_through
    ];

function star_knob_get_handle_count(s) = s[0];
function star_knob_get_outer_radius(s) = s[1] / 2;
function star_knob_get_bolt_radius(s) = s[2] / 2;
function star_knob_get_bolt_head_radius(s) = s[3] / 2;
function star_knob_get_bolt_head_height(s) = s[4];
function star_knob_get_bolt_cut_through(s) = s[5];

function star_knob_get_height(s) = star_knob_get_bolt_head_height(s) + 2 * WALL;
function star_knob_get_cutout_radius(s) = 1.8 * star_knob_get_outer_radius(s) /
                                          star_knob_get_handle_count(s);
function star_knob_get_fillet_radius(s) = star_knob_get_cutout_radius(s) / 2;
function star_knob_get_chamfer_radius(s) = min(
        star_knob_get_outer_radius(s) / 10,
        star_knob_get_height(s) / 7.5);

function star_knob_get_washer_radius(s) = star_knob_get_outer_radius(s) -
    star_knob_get_cutout_radius(s) - WALL;

// 2D sketch modules

module star_knob_sketch(s) {
    offset(r=star_knob_get_fillet_radius(s))
    offset(delta=-star_knob_get_fillet_radius(s))
    difference() {
        circle(r=star_knob_get_outer_radius(s));
        for(a=[0:360/star_knob_get_handle_count(s):360])
            rotate(a)
            translate([star_knob_get_outer_radius(s), 0])
            circle(r=star_knob_get_cutout_radius(s));
    }
}

// 3D part modules

module star_knob_part_body(s) {

    module double_cone(r) {
        cylinder(r, r1=r, r2=0);
        rotate([180,0]) cylinder(r, r1=r, r2=0);
    }

    minkowski() {
        linear_extrude(star_knob_get_height(s) -
                          2 * star_knob_get_chamfer_radius(s),
                       center=true)
            star_knob_sketch(s);
        
        double_cone(star_knob_get_chamfer_radius(s));
    }
}

// Placement modules

module star_knob_place_at_washer(s) {
    translate([0,0,(star_knob_get_bolt_head_height(s) + WALL)/2]) children();
}

// 3D object modules

module star_knob(s) {

    assert(star_knob_get_washer_radius(s) >= 
           star_knob_get_bolt_head_radius(s) + WALL);

    difference() {
        star_knob_part_body(s);
        cylinder(star_knob_get_bolt_head_height(s),
                 r=star_knob_get_bolt_head_radius(s),
                 center=true,
                 $fn=6);
        star_knob_place_at_washer(s)
            cylinder(WALL + 2*EPS, r=star_knob_get_washer_radius(s), center=true);
        if (star_knob_get_bolt_cut_through(s))
            translate([0,0,-(star_knob_get_bolt_head_height(s) + WALL)/2])
                cylinder(WALL + 2*EPS, r=star_knob_get_bolt_radius(s), center=true);
    }
}

module star_knob_washer(s) {
    difference() {
        cylinder(WALL, r=star_knob_get_washer_radius(s), center=true);
        cylinder(WALL + 2*EPS, r=star_knob_get_bolt_radius(s), center=true);
    }
}

s = star_knob_new();

translate([0, 0, star_knob_get_height(s)/2]) star_knob(s);
translate([star_knob_get_outer_radius(s) * 2, 0, WALL/2]) star_knob_washer(s);