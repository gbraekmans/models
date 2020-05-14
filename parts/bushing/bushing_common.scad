include <../globals.scad>

// The drawing of bushing bore
module bushing_bore_sketch(
    inner_radius,
    outer_radius,
    pin_count=12,
    pin_bore_coverage=0.5
) {
    assert(pin_bore_coverage >= 0);
    assert(pin_bore_coverage <= 1);
    assert(pin_count >= 3);
    
    pin_width =  (1 - pin_bore_coverage) * 2 * PI * inner_radius / pin_count;
    pin_length = outer_radius;
   
    // create the rod
    circle(r=inner_radius);
    
    if(outer_radius > inner_radius) {
        // create the pins
        intersection() {
            // pins
            for(a=[0:360/pin_count:360])
                rotate(a)
                    translate([0,-pin_width/2])
                        square([pin_length, pin_width]);
            // round over pin ends
            circle(outer_radius);
        }
    }
}

// The bore as a volume
module bushing_bore(
    inner_radius,
    outer_radius,
    height,
    pin_count,
    pin_bore_coverage,
    chamfer
) {
    chamfer = default(chamfer, outer_radius - inner_radius);

    // Bore body
    linear_extrude(height, center=true)
        bushing_bore_sketch(
            inner_radius=inner_radius,
            outer_radius=outer_radius,
            pin_count=pin_count,
            pin_bore_coverage=pin_bore_coverage
        );
    
    if(chamfer > 0) {
        // Lower chamfer
        translate([0,0, - height / 2])
        cylinder(chamfer, r1=inner_radius + chamfer, r2=inner_radius);
        
        // Upper chamfer
        rotate([180,0,0])
        translate([0,0, - height / 2])
        cylinder(chamfer, r1=inner_radius + chamfer, r2=inner_radius);
    }
}