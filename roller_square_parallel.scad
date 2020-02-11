/*
 *  A linear guide on a square tube
 * 
 *  Should be used in combination with a downward force on the
 *  upper bearing. You may need to tweak the parameters to get
 *  the right tension on the bearings.
 *
 *  By default this model should be used with:
 *  
 *  - M8 x 30 DIN 912 Socket cap screws
 *  - M8 DIN 985 Nylon insert nuts
 *  - 608-2rs bearings
 *  - 4 x ? Countersunk screws
 *
 */
 
 // TODO: Add the option to add fourth bearing below

/* [Roller] */

// The height of the square tube
TUBE_SIZE = 29.95;

// Thickness of the walls
WALL = 3.5;

// Clearance between the tube and printed part
CLEARANCE = 1; // [0.6:Snug, 1:Default, 1.4:Loose]

// The width of the housing that supports the bearing axle
HOUSING_WIDTH = 22;

/* [Mounting screws] */

// Diameter of the screw shaft
SCREW = 4;
// Height of the plastic mounting tabs
SCREW_WING_HEIGHT = 5;
// Prepare for use with countersunk screws
SCREW_COUNTERSINK = true;

/* [Bearings] */

// Diameter of a 608 diameter
BEARING_OUTER_DIAMETER = 22;
// Diamater of the axle of 608 bearing
BEARING_AXLE_DIAMETER = 8;
// Height of a 608 bearing + some clearance
BEARING_HEIGHT = 7.25;

// Needed for the check that nothing sticks out
AXLE_LENGTH = 38;
// Needed for the check that the axle is mountable
AXLE_HEAD_DIAMETER = 13;

module dummy() {};

$fa = $preview? 12 : 6;
$fs = $preview? 2 : 0.2;

EPS = 0.01;

module roller_square_parallel(
    tube_size=TUBE_SIZE,
    wall=WALL,
    clearance=CLEARANCE,
    bearing=[BEARING_OUTER_DIAMETER, BEARING_AXLE_DIAMETER, BEARING_HEIGHT],
    screw=SCREW,
    housing_width=HOUSING_WIDTH,
    screw_wing_height=SCREW_WING_HEIGHT,
    screw_countersink=SCREW_COUNTERSINK
) {

    assert(housing_width <= tube_size + 2 * (clearance + wall));

    module reflect(v) {
        children();
        mirror(v) children();
    }

    // the (1+sqrt(2))*r is a bit of math
    // this ensures that the maximum angle
    // remains at 45 degrees
    // it is derived by figuring out the length
    // of the long side of the triangle given the 
    // radius of the inscribed circle of the triangle

    function bearing_housing_size(r) = [2*(1+sqrt(2))*r, 2*r];

    module bearing_housing(r) {
        s = bearing_housing_size(r);
        hull() {
            translate([0,r]) circle(r);
            square([s[0],EPS], center=true);
        }
    }

    function screw_wing_size(r) = [(1+sqrt(2))*r + r, 2*r];

    module screw_wing(r) { 
        
        s = screw_wing_size(r);
        
        translate([0,-r])
        hull() {
            translate([0,r]) circle(r=r);
            translate([-r, -EPS]) square([s.x, EPS]);
            translate([-r,0]) square([EPS, s.y]);
        }
    }

    module bearing_cutout(axle_extra_length = wall + clearance + EPS) {
        c_dia = bearing[0] + 2*clearance;
        c_hei = bearing[2] + 2*clearance;
        
        axle_radius = bearing[1] / 2;

        reflect([0,0,1]) {
            difference() {
                translate([0,0,-EPS]) union() { // the body
                    cylinder(c_hei/2+EPS, r=c_dia/2);
                    translate([0, -c_dia/2])
                        cube([c_dia/2, c_dia, c_hei/2+EPS]);
                }
                // support ring
                translate([0,0,bearing[2]/2])
                    cylinder(clearance+EPS, r=axle_radius + 1);
                // support ring chamfer
                translate([0,0,bearing[2]/2])
                    cylinder(clearance+EPS, r1=axle_radius + 1,
                             r2=axle_radius + 1 + clearance);
            }
            // axle
            cylinder(c_hei + axle_extra_length, r=axle_radius);
        }
    }
 
    housing_r = (bearing[0] / 2 + bearing[1] / 2 + wall)/2;
    width = bearing_housing_size(housing_r)[0] + wall + screw*2+wall;
    t_hei = tube_size + 2 * clearance;   
    
    module place_around_tube() {
        for(a=[0,90,180])
            rotate([a,0]) translate([0,tube_size/2]) children();
    }

    screw_wing_r = (screw_countersink? screw : (screw / 2)) + wall;
    
    module place_screw_wings() {
        reflect([1,0,0]) reflect([0,1,0]) 
            translate([-width/2+screw_wing_r,
                       screw_wing_r+t_hei/2+wall, -t_hei/2 - wall]) children();
    }

    difference() {
        union() {
            // main body
            cube([width, t_hei + 2* wall, t_hei+ 2*wall], center=true);
            
            // bearing housings
            place_around_tube() linear_extrude(housing_width, center=true)
                bearing_housing(housing_r);
            
            // screw wings
            place_screw_wings() linear_extrude(screw_wing_height)
                screw_wing(screw_wing_r);
        }
        
        // tube cutout
        cube([width+2*EPS, t_hei, t_hei], center=true);
        
        // bearing cutouts
        place_around_tube() translate([0,bearing[0]/2]) rotate(-90)
            bearing_cutout(housing_width);
        
        // screw cutouts
        place_screw_wings() translate([0,0,-EPS])
            cylinder(h=screw_wing_height + 2*EPS, r=screw/2);
        
        if(screw_countersink)
            place_screw_wings()
                translate([0,0,-EPS + screw_wing_height - screw/2])
                    cylinder(h=screw/2 + 2*EPS, r1=screw/2, r2=screw);
    }
    
    
    
}

// Make sure the mounting screws fit
max_wall = (BEARING_OUTER_DIAMETER - AXLE_HEAD_DIAMETER) / 2;
echo("CLEARANCE + WALL (", CLEARANCE + WALL, 
     ") should be smaller or equal than ", max_wall);
assert(WALL + CLEARANCE <= max_wall);

// Make sure the bolts aren't sticking out
body_height = TUBE_SIZE + 2 * (CLEARANCE + WALL);
echo("TUBE_SIZE + 2 * (CLEARANCE + WALL) (", body_height,
     ") should be larger or equal than AXLE_LENGTH ", AXLE_LENGTH);
assert(AXLE_LENGTH <= body_height);

roller_square_parallel();