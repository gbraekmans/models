// the size of the vertical posts
BEAM = 45;

// how long the drill must be guided
HEIGHT = 15;

// the ledge for finding te corner
LEDGE_HEIGHT = 5;

// strength of the ledge
WALL = 3;

// diameter of the pilot holes
SCREW = 2;

module dummy() {};

$fa = $preview? 12 : 4;
$fs = $preview? 2 : 0.2;

EPS = 0.01;

module drill_guide(
    beam=BEAM,
    height=HEIGHT,
    screw=SCREW,
    wall=WALL,
    ledge_height=LEDGE_HEIGHT
) {
    
    module ledge() {
        translate([beam/2+wall/2,wall/2,ledge_height/2])
            cube([wall,beam+wall,height+ledge_height], center=true);       
    }

    distance = beam / 4;

    difference() {
        cube([beam, beam, height], center=true);
        
        for(x=[1,-1])
            for(y=[1,-1])
                translate([x * distance, y * distance])
                    cylinder(height+EPS, r=screw/2, center=true);
    }

    ledge();
    rotate(90) mirror([0,1,0]) ledge();
}

drill_guide();