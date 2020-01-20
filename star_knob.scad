// The value of the knob's largest cross-section
DIAMETER = 45; // [10:90]

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

// The thickness of the walls
WALL = 3; // [2:4]

// Hide the next globals
module dummy() {};
EPS = 0.01;

$fa = $preview? 12 : 6;
$fs = $preview? 2 : 0.2;

function star_knob_washer_height(wall=WALL) = wall;
function star_knob_washer_diameter(wall=WALL,
                                   bolt_head_diameter=BOLT_HEAD_DIAMETER) =
    bolt_head_diameter + 4 * wall;

function star_knob_height(wall=WALL, bolt_head_height=BOLT_HEAD_HEIGHT) =
    bolt_head_height + 2 * wall;

// moves an object to washer cutout center
module star_knob_place_at_washer(wall=WALL, bolt_head_height=BOLT_HEAD_HEIGHT){
translate([0,0, (bolt_head_height + wall) / 2]) children();
}

// moves an object to the bolt cutout surface
module star_knob_place_at_bolt(bolt_head_height=BOLT_HEAD_HEIGHT) {
    translate([0,0, -bolt_head_height / 2]) children();
}

module star_knob(
    diameter=DIAMETER,
    cut_through=CUT_THROUGH,
    wall=WALL,
    bolt_diameter=BOLT_DIAMETER,
    bolt_head_diameter=BOLT_HEAD_DIAMETER,
    bolt_head_height=BOLT_HEAD_HEIGHT,
    handle_count=HANDLE_COUNT,
    cutout_diameter=undef // depth of the cutouts
) {

    function apply_default(v, d) = is_undef(v)? d : v;

    cutout_diameter = apply_default(cutout_diameter,
                                    1.8 * diameter / handle_count);

    height = star_knob_height(wall, bolt_head_height);
    fillet = cutout_diameter / 4;
    chamfer = min( diameter / 20, height / 7.5);
    
    // make sure the washer fits the knob
    assert(diameter - star_knob_washer_diameter(wall, bolt_head_diameter) -
           cutout_diameter >= 2 * wall);

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
        cylinder(bolt_head_height, r=bolt_head_diameter/2, center=true,
                 $fn=6);
 
        // washer cutout
        star_knob_place_at_washer(wall, bolt_head_height)
            cylinder(wall + 2*EPS,
                     r=star_knob_washer_diameter(wall, bolt_head_diameter)/2,
                     center=true);
        
        // through cut
        cylinder(height + 2*EPS, r=bolt_diameter/2, center=cut_through);
    }
}

module star_knob_washer(wall=WALL, bolt_diameter=BOLT_DIAMETER, 
                        bolt_head_diameter=BOLT_HEAD_DIAMETER) {
    difference() {
        cylinder(wall, r=star_knob_washer_diameter(wall, bolt_head_diameter)/2,
                 center=true);
        cylinder(wall + 2*EPS, r=bolt_diameter/2, center=true);
    }
}

translate([0,0,star_knob_height()/2]) star_knob();
translate([DIAMETER,0,star_knob_washer_height()/2]) star_knob_washer();