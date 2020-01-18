// How high your spacer should be
HEIGHT = 10; // [0.2:0.1:100]

// How wide your spacer should be
WIDTH = 15; // [10:50]

// How long your spcer should be
LENGTH = 40; // [40:120]

// Hide these globals from the customizer
module dummy() {};
EPS = 0.01;

module spacer(height=HEIGHT, width=WIDTH, length=LENGTH) {

    fillet = min(width, length) / 3;
    chamfer = min(1, height / 3);
    engrave_depth = min(1, height/2);
    
    module spacer_sketch() {
        offset(r=fillet)
            square([length-fillet, width-fillet], center=true);
    }
    
    difference() {
        hull() { // the spacer
            translate([0,0, -height/2 + EPS]) linear_extrude(EPS)
                offset(delta=-chamfer) spacer_sketch(); // bottom chamfer
            linear_extrude(height-2*chamfer, center=true)
                spacer_sketch(); // main body
            translate([0,0, height/2 - EPS]) linear_extrude(EPS)
                offset(delta=-chamfer) spacer_sketch(); // top chamfer
        }

        // text to engrave in the spacer
        translate([0,0, height/2-engrave_depth])
            linear_extrude(engrave_depth + EPS)
                text(str(height), size=width * 2 / 3,
                     halign="center", valign="center",
                     font="sans"); 
    }
    
}

spacer();