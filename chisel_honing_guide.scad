ANGLE = 25;

LENGTH = 40;
HEIGHT = 25;

ENGRAVE_DEPTH = 1;

module dummy() {};

EPS = 0.01;
$fa = $preview? 12 : 6;
$fs = $preview? 2 : 0.2;

// Make it fit 4 608-bearings
assert(LENGTH > 22 + 8 + 4);

module reflect(v=[0,1,0]) 
{ 
    children(); 
    mirror(v) children(); 
}

module letters() {
    translate([LENGTH/2, 6])
    linear_extrude(ENGRAVE_DEPTH)
    text(str(ANGLE, "°"), valign="center", halign="center", size=8);
}

difference() {
    linear_extrude(HEIGHT) difference() {
        union() {
            square([LENGTH, 12]);
            
            translate([0,12])
            polygon([ [0,0], [LENGTH, 0], [LENGTH, tan(ANGLE) * LENGTH] ]);
        }

        translate([6,6])
        circle(4);

        translate([LENGTH - 6,6])
        circle(4);
    }
    
    translate([0,0,HEIGHT - ENGRAVE_DEPTH + EPS])
    letters();
    
    translate([LENGTH,0,ENGRAVE_DEPTH - EPS])
    rotate([0,180])
    letters();
}