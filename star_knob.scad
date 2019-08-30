use <utils.scad>

module star_knob_2d(radius, sides=6) {
    inner_r = 0.85 * radius; // radius of the knob
    outer_r = 0.15 * radius; // radius of the fillet
    
    minkowski() { // fillet
        // star shape
        difference() {
            regular_polygon(sides, inner_r, "circumscribed");
            circular_pattern(sides, inner_r, "circumscribed") circle(inner_r/sides*2.75);
        }
        circle(outer_r); // fillet radius
    }
}

module star_knob(radius=20, height=10, sides=6, wrench_width=10, socket_depth=4, bolt_diameter=6) {
    top = height / 5;
    body = height / 2 - top;
    
    translate([0, 0, height / 2]) difference() { // cutout the bolt cover and bolt socket
        
        symmetry([0,0,1]) { // the star knob
            linear_extrude(body) star_knob_2d(radius, sides); // body
            translate([0,0,body]) linear_extrude(top, scale=(radius-top)/radius) star_knob_2d(radius, sides); // top chamfer
        }
   
        translate([0,0,body]) cylinder(top, r= 0.5 * radius); // bolt cover
        translate([0,0,body-socket_depth]) prism(socket_depth, 6, wrench_width / 2, false); // bolt socket
    }
    
  
}

module star_knob_bolt_cover(radius=20, height=10, bolt_diameter=6) {
    h = height / 5;
    difference() { // bolt cover
            cylinder(h, r= 0.5 * radius);
            cylinder(h, d=bolt_diameter);
    }
}


module star_knob_and_bolt_cover(radius=20, height=10, sides=6, wrench_width=10, socket_depth=4, bolt_diameter=6) {
    star_knob(radius, height, sides, wrench_width, socket_depth, bolt_diameter);
    translate([radius * 1.5, 0 , 0]) star_knob_bolt_cover(radius, height, bolt_diameter);
}

star_knob_and_bolt_cover(sides=5);