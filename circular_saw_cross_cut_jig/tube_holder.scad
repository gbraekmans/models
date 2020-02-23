/*
 *
 *  You might need supports for this model if your printer or
 *  filament is not so suited for printing bridges.
 *
 */


/* [Tube holder] */

// the size of the vertical posts
BEAM = 45.1;

// the size of the horizontal steel square tubing
TUBE = 30.2;

// wall size of the printed plastic holder
WALL = 3.5;

// diameter of the screws
SCREW = 4; // [2:0.1:6]

module dummy() {};

$fa = $preview? 12 : 4;
$fs = $preview? 2 : 0.2;

EPS = 0.01;

module tube_holder(
    beam=BEAM,
    tube=TUBE,
    wall=WALL,
    screw=SCREW) {

    beam_cutout_height = wall + 2 * screw + wall;
    height = beam_cutout_height + wall + tube + wall;
    width = max(tube, beam) + 2 * wall;

    chamfer = wall / 2;
        
    assert(wall >= screw / 2);

    module body() {
        hull() {
            cube([width, width - 2 * chamfer, height - 2 * chamfer], center=true);
            cube([width - 2 * chamfer, width, height - 2 * chamfer], center=true);
            cube([width - 2 * chamfer, width - 2 * chamfer, height], center=true);
        }
    }
    
    module screw(r, l) {
        assert(r <= l);
        translate([0,0,-l/2]) cylinder(r, r1=2*r, r2=r);
        cylinder(l, r=r, center=true);
    }
    
    difference() {
        body();
        
        // tube cutout
        translate([0,wall/2+EPS,height/2 - tube/2 - wall]) cube([tube,width-wall,tube], center=true);
        
        // beam cutout
        translate([0,0, -height/2 + beam_cutout_height/2 - EPS]) cube([beam, beam, beam_cutout_height], center=true);
        
        // screw holes
        for(a=[0:90:360])
            rotate(a) translate([width/2 - wall/2,0, -height/2 + wall + screw])
                rotate([0,-90,0])screw(screw/2, wall + 2*EPS);
    }

}

rotate([180,0]) tube_holder();