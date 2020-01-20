// This model may take a couple of minutes to render
// but the preview should still be acceptable

// Diameter of the rod used as linear guide
ROD_DIAMETER = 25; // [5:0.01:600]

// Thickness of the walls of the part
WALL = 3;

// How tight the bearings fit into the housing
CLEARANCE = 1; // [0.6:Snug, 1:Default, 1.4:Loose]

// Type of bearing
BEARING = 4; // [ 0:623, 1:624, 2:625, 3:626, 4:628, 5:6200, 6:6201 ]

// Mounting hole diameter
BOLT_DIAMETER = 6; // [2.5:0.01:12.5]

// Amount of wall to use as fillet or chamfer
FILLET_PERCENTAGE = 67; // [0:100]

// the amount of bearings to be placed
BEARING_COUNT = 3; // [2:6]

// Make following globals private
module dummy() {};

$fa = $preview? 20 : 6;
$fs = $preview? 3 : 0.2;

EPS = 0.01;
ANGLES = [for(a = [360/BEARING_COUNT:360/BEARING_COUNT:360]) a];

BEARINGS = [
    // outer diameter, inner_diameter, height
    [10,3,4],   // 623
    [13,4,5],   // 624
    [16,5,5],   // 625
    [19,6,6],   // 626
    [22,8,7],   // 628
    [30,10,9],  // 6200
    [32,12,10], // 6201
];

module roller_perpendicular(
    rod_diameter=ROD_DIAMETER,
    wall=WALL,
    clearance=CLEARANCE,
    bearing=BEARINGS[BEARING],
    bolt_diameter=BOLT_DIAMETER,
    fillet=WALL * FILLET_PERCENTAGE / 100,
    angles=ANGLES
) {

    // Don't remove walls if using fillets
    assert(wall >= fillet);
    // Make sure you can put the bearings in the housing
    assert(rod_diameter >= bearing[0]);

    bearing_outer_radius = bearing[0] / 2;
    bearing_inner_radius = bearing[1] / 2;
    bearing_height = bearing[2];
    
    
    height = (bearing_outer_radius + clearance + wall) * 2;
    bearing_axle_radius = rod_diameter/2 + bearing_outer_radius;
    outer_radius = rod_diameter/2 + bearing_outer_radius * 2 + clearance +
                   wall + fillet;
    bolt_radius = outer_radius - fillet - wall - bolt_diameter/2;
  
    module bearing_cutout() {
        h = bearing_height + 2 * clearance;
        r = bearing_outer_radius+clearance;
        a = bearing_inner_radius; //axle
        
        rotate([90,0]) difference() {
            // main housing cutout
            union() {
                translate([-r/2,0]) cube([r, 2*r, h], center=true);
                cylinder(h, r=r, center=true);
            }
            
            // bearing support rings
            translate([0,0, (h-clearance)/2+EPS])
                cylinder(clearance, r2=a+2*clearance, r1=a+clearance,
                         center=true);
            translate([0,0, -(h-clearance)/2-EPS])
                cylinder(clearance, r1=a+2*clearance, r2=a+clearance,
                         center=true);
        }
    };
    
    module main_body_sketch() {
        offset(r=-fillet) offset(delta=fillet) {
            circle(r=rod_diameter/2+clearance+wall);
            for(a=angles)
                rotate(a) translate([bearing_axle_radius,0])
                    square([2*bearing_outer_radius+clearance+wall,
                            bearing_height + 2*clearance + wall], center=true);
        }
    };

    difference() {
        union() {
            // main body
            linear_extrude(height, center=true) main_body_sketch();

            // bottom chamfer
            translate([0,0, -height/2+wall]) minkowski() {
                linear_extrude(EPS) main_body_sketch();
                cylinder(fillet, r1=fillet, r2=0);
            }
            
            // flange
            translate([0,0,-height/2]) cylinder(wall, r=outer_radius);
        }
        
        
        // bearing housing cutouts
        for(a=angles) {
            rotate(a) translate([rod_diameter/2 + bearing_outer_radius,0]) {
                bearing_cutout();
                // axle cutout
                rotate([90,0]) cylinder(2*(wall+clearance+EPS)+bearing_height,
                                        r=bearing_inner_radius, center=true);
            }
        }
        
        // rod cutout
        cylinder(height + 2*EPS, r=rod_diameter/2 + clearance, center=true);

        // rod chamfers
        translate([0,0,(height - fillet) / 2 + EPS])
            cylinder(fillet, r1=rod_diameter/2 + clearance,
                             r2=rod_diameter/2 + clearance + fillet,
                             center=true);
        translate([0,0,-(height - fillet) / 2 - EPS])
            cylinder(fillet, r2=rod_diameter/2 + clearance,
                             r1=rod_diameter/2 + clearance + fillet,
                             center=true);
         
        // mounting holes
        for(a=angles)
            rotate(a + 360 / (2 * len(angles)))
                translate([bolt_radius, 0, -height/2-EPS])
                    cylinder(wall + 2*EPS, r=bolt_diameter/2);
    }
}

roller_perpendicular();