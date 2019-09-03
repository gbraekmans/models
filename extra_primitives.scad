use <utils.scad>

/**
 * A regular 2d polygon
 *
 * @param number n           amount of sides / corners
 * @param number r           radius of the polygon
 * @param string radius_type either "inscribed" or "circumscribed"
*/
module regular_polygon(n, r=1, radius_type="inscribed") {
    polygon(regular_polygon_points(n, r, radius_type));
}

/**
 * A 2-d regular polygon extruded to a height
 *
 * @param number h           height of the prism
 * @param number n           amount of sides / corners
 * @param number r           radius of the polygon
 * @param string radius_type either "inscribed" or "circumscribed"
*/
module prism(h, n, r=1, radius_type="inscribed") {
    linear_extrude(h) regular_polygon(n, r, radius_type);
}

/**
 * A square with rounded corners
 *
 * @param vector  v      the same vector a square (width, depth, height)
 * @param number  r      the rounding radius
 * @param boolean center centers the rectangle
 */
module rounded_square(v, r=1, center = false){
	assert(len(v) == 2);
	rv = [v[0] - 2 * r, v[1] - 2 * r];
	
	t = center? [-rv[0] / 2,-rv[1] / 2,] : [r, r];
	
	translate(t) union() {
		square(rv);
		circle(r=r);
		translate([rv[0], 0,0]) circle(r=r);
		translate([0 , rv[1],0]) circle(r=r);
		translate([rv[0], rv[1],0]) circle(r=r);
		
		translate([0,-r,0]) square([rv[0], r]);
		translate([0,rv[1],0]) square([rv[0], r]);
		translate([-r,0,0]) square([r, rv[1]]);
		translate([rv[0],0,0]) square([r, rv[1]]);
	}
}

/**
 * A square/rectangle with a fully rounded short side
 *
 * @param vector  v      the same vector a square (width, depth, height)
 * @param boolean center centers the rectangle
 */
module slot(v, center) {
	d = min(v[0], v[1]);
	rounded_square(v, r=d/2, center=center);
}

/**
 * Extruded rounded_square
 */
module plate(v, r=1, center=false) {
	assert(len(v) == 3);
	dist = center? v[2] / 2 : 0;
	down(dist) linear_extrude(v[2]) rounded_square([v[0], v[1]],r=r, center=center);
}


/**
 * A plate without any sharp edges
 */
module rounded_plate(v, r=undef, center=false) {
	assert( (len(v) == 2 && ! is_undef(r)) || (len(v) == 3 && is_undef(r)));
	radius = r == undef ? v[2] / 2 : r;
	rv = [v[0] / 2 - radius,  v[1] / 2 - radius, 2*radius];
    t = center ? [0, 0, 0] : [v[0]  / 2, v[1] / 2, radius];
    translate(t) symmetry([1,0,0]) symmetry([0,1,0]) {
        translate([rv[0], rv[1], 0]) sphere(radius);
        right(rv[0]) rotate([270, 0,0]) cylinder(rv[1], r=radius);
        back(rv[1]) rotate([0, 90,0]) cylinder(rv[0], r=radius);
        down(radius) cube(rv);
    }
}

/**
 * Extruded slot
 */
module bar(v, center=false) {
	assert(len(v) == 3);
	dist = center? v[2] / 2 : 0;
	down(dist) linear_extrude(v[2]) slot([v[0], v[1]], center=center);
}

/**
 * A bar without any sharp edges
 */
module rounded_bar(v, center=false) {
    rounded_plate(v, center);
}

/**
 * A cylinder without any sharp edges
 */
module rounded_cylinder(h, r, center=false) {
    t = center ? [0, 0, -h/2] : [0, 0, 0];
    translate(t) {
        up(r) sphere(r=r);
        up(r) cylinder(h=h-2*r,r=r);
        up(h - r) sphere(r=r);
    }
}

/**
 *  A cube without sharp edges
 */
module rounded_cube(v, r=1, center=false) {
    assert(r <= min(v) / 2);
    t = center? [-v[0]/2,-v[1]/2,-v[2]/2]: [0,0,0];
    translate(t) {
        rounded_plate([v[0], v[1]], r=r);
        up(r) plate([v[0], v[1], v[2] - 2 * r], r);
        up(v[2] - 2 * r) rounded_plate([v[0], v[1]], r=r);
   }
}

/**
 * A 2 cylinder difference
 */
module tube(h , ir=undef, or=undef, id=undef, od=undef, t = 1) {
     ir = is_undef(ir)? id / 2 : ir;
    or = is_undef(or)? od/ 2 : or;
    
    r = is_undef(or)? ir + t : or;
    assert(! is_undef(r));
    
    difference() {
        cylinder(h, r=r);
        down($preview? 0.05 : 0) cylinder($preview? h+0.1: h, r=r - t);
    }
}

/**
 * A donut-shaped object
 */
module torus(h, ir=undef, or=undef, id=undef, od=undef) {
    ir = is_undef(ir)? id / 2 : ir;
    or = is_undef(or)? od/ 2 : or;
    
    r = is_undef(ir)? or - h/2 : ir + h/2;
    
    assert(! is_undef(r));
    rotate_extrude() right(r) circle(r=h/2);
}

/**
 * An ellipsiod, filleted
 */
module bulge(r=1, slope=45) {
   rotate_extrude() scale( 1 / (2 * sin(slope))) {
       intersection() {translate([0,-cos(slope)]) circle(1); square([1,1]);}
       difference() {
            translate([0, - 1 + cos(slope)])square([2*sin(slope), 1 - cos(slope)]);
            translate([2*sin(slope),cos(slope)])circle(1);
       }
   }
}

//bar([10, 2, 1], true);
$fn = 60;
bulge(slope=20);
//back(10) bar([10, 2, 1]);
//rounded_bar([10, 2, 1]);
//rounded_cube([30,20,10], 4, true);
