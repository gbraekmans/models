BEAM = 45;

TUBE = 30;

WALL = 3;

SCREW = 4;

EPS = 0.01;

module mounting_bracket(
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

mounting_bracket();