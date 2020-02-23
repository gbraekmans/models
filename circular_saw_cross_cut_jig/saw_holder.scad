/*
 *
 *  In general you'll need 4 of these to constrain the
 *  foot of your circular saw.
 *
 */

/* [Saw holder] */

HEIGHT = 10;
WIDTH = 10;
LENGTH = 50;

// Diameter of the screw
SCREW = 4;

module dummy() {};

$fa = $preview? 12 : 4;
$fs = $preview? 2 : 0.2;

EPS = 0.01; 

module saw_holder(
    length=LENGTH,
    width=WIDTH,
    height=HEIGHT,
    screw=SCREW
) {

    module reflect(v=[0,1,0]) 
    { 
        children(); 
        mirror(v) children(); 
    }    

    module body() {
        rotate([0,-90]) linear_extrude(length/2) hull() {
            square([width/2, height]);
            square([width, height/2]);
        }
    }
    
    reflect([1,0,0]) 
    difference() {
        body();
        translate([-length/2 -EPS,-EPS,height/2]) cube([width,width + 2 * EPS, height/2+EPS]);
        translate([-length/2 + width/2, width/2, -EPS]) cylinder(height, r=screw/2);
        translate([-length/2 + width/2, width/2, height/2 - screw/2 + EPS]) cylinder(screw/2, r1=screw/2, r2=screw);
    }
}

assert(WIDTH >= 2 * SCREW);

saw_holder();