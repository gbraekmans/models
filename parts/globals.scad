$fa = $preview? 12 : 6;
$fs = $preview? 2 : 0.2;

EPS = 1/128;

LAYER_HEIGHT = 0.2;

function default(v, d) = is_undef(v)? d : v;

// For engraving in all planes except those parrallel to XY.
module v_engrave(t, size=10) {
    translate([0, 0.3, 0])
    rotate([90,0,0])
    linear_extrude(0.3 + EPS)
    text(t, size=size, font="DejaVu Sans:style=Book", valign="center", halign="center");
}

// For engraving in all planes parrallel to XY.
module h_engrave(t, size=10) {
    translate([0, 0, -0.7])
    linear_extrude(0.7 + EPS)
    text(t, size=size, font="DejaVu Sans:style=Book", valign="center", halign="center");
}