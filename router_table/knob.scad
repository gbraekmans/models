
/* [Handle] */
HANDLE_HEIGHT = 18;
HANDLE_DIAMETER = 60;
HANDLE_INNER_DIAMETER = 40;
HANDLE_ENGRAVE_DEPTH = 0.4;

/* [Lead Screw] */

LEAD_DIAMETER = 16;
LEAD_D_DEPTH = 3;
LEAD_HEIGHT = 10;

/* [Gripper] */
GRIPPER_HEIGHT = 12;
GRIPPER_DIAMETER = 26;
GRIPPER_CHAMFER = 2;

use <../star_knob.scad>;

module dummy() {};

HANDLE_CUTOUT_PCT = 0.4;

$fa = $preview? 12 : 6;
$fs = $preview? 2 : 0.2;
EPS = 0.01;

module handle() {

    module arrow_sketch() {
        s = HANDLE_INNER_DIAMETER * 0.4;
        
        polygon([[-s/2,0],[0,s],[s/2,0]]);
        translate([-s/8,-s + EPS]) square([s/4,s]);
    }

    rotate([180,0,0])
    translate([0,0,HANDLE_HEIGHT/2])
    difference() {
            star_knob_modern_body(
                radius=HANDLE_DIAMETER / 2,
                inner_radius=HANDLE_INNER_DIAMETER / 2,
                height=HANDLE_HEIGHT
            );
        
        translate([0,0,HANDLE_HEIGHT/2 - HANDLE_ENGRAVE_DEPTH])
        linear_extrude(HANDLE_ENGRAVE_DEPTH + EPS)
            arrow_sketch();
    }

}

module lead_screw() {
    intersection() {
        cylinder(LEAD_HEIGHT, r=LEAD_DIAMETER/2);
        translate([0,-LEAD_D_DEPTH,LEAD_HEIGHT/2])
            cube([LEAD_DIAMETER, LEAD_DIAMETER, LEAD_HEIGHT], center=true);
    }
}

module gripper() {
    difference() {
        union() {
            cylinder(GRIPPER_HEIGHT-GRIPPER_CHAMFER, r=GRIPPER_DIAMETER/2);
            translate([0,0,GRIPPER_HEIGHT-GRIPPER_CHAMFER])
                cylinder(GRIPPER_CHAMFER, r1=GRIPPER_DIAMETER/2, r2=GRIPPER_DIAMETER/2 - GRIPPER_CHAMFER);
            cylinder(GRIPPER_CHAMFER, r2=GRIPPER_DIAMETER/2, r1=GRIPPER_DIAMETER/2 + GRIPPER_CHAMFER);            
        }
        translate([0,0,GRIPPER_HEIGHT - LEAD_HEIGHT + EPS]) lead_screw();
    }
}

gripper();
handle();