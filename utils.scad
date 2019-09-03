/**
 * Generate an array containing the end points of a regular polygon
 *
 * @param number n           amount of sides / corners
 * @param number r           radius of the polygon
 * @param string radius_type either "inscribed" or "circumscribed"
*/
function regular_polygon_points(n, r=1, radius_type="inscribed") =
    [for(a = [0:360/n:360]) 
        [cos(a) * (radius_type == "inscribed" ? r : r / cos(180 / n)),
         sin(a) * (radius_type == "inscribed" ? r : r / cos(180 / n))]
    ];

/**
 * Repeat a shape over a pattern. Shape is placed on the corners
 *
 * @param number h           height of the prism
 * @param number n           amount of sides / corners
 * @param number r           radius of the polygon
 * @param string radius_type either "inscribed" or "circumscribed"
 */
module circular_pattern(n, r=1, radius_type="inscribed") {
    points = regular_polygon_points(n, r, radius_type);
    for(p=[0:len(points) - 1]) {
        translate([points[p][0], points[p][1], 0])
        for(i=[0,$children-1]){
            children(i);
         }
    }
}

/**
 * Like mirror, but keeps the original shape
 * 
 * @param vector v The normal vector on the mirror plane. See mirror()
 */
module symmetry(v=[0,0,0]) 
{ 
    children(); 
    mirror(v) children(); 
}

/**
 * Skew an object over six angles:
 *
 * @param array angles 6 angles in the following order:
 *        x along y
 *        x along z
 *        y along x
 *        y along z
 *        z along x
 *        z along y
 */
module skew(angles) {
matrix = [
	[ 1, tan(angles[0]), tan(angles[1]), 0 ],
	[ tan(angles[2]), 1, tan(angles[3]), 0 ],
	[ tan(angles[4]), tan(angles[5]), 1, 0 ],
	[ 0, 0, 0, 1 ]
];
multmatrix(matrix)
children();
}

/**
 * Moves an object up the Z-axis
 *
 * @param number distance The distance it should be moved
 */
module up(distance = 0) {
	translate([0,0,distance]) children();
}

/**
 * Moves an object down the Z-axis
 *
 * @param number distance The distance it should be moved
 */
module down(distance = 0) {
	translate([0,0,-distance]) children();
}

/**
 * Moves an object up the X-axis
 *
 * @param number distance The distance it should be moved
 */
module right(distance = 0) {
	translate([distance,0,0]) children();
}

/**
 * Moves an object down the X-axis
 *
 * @param number distance The distance it should be moved
 */
module left(distance = 0) {
	translate([-distance,0,0]) children();
}
/**
 * Moves an object up the Y-axis
 *
 * @param number distance The distance it should be moved
 */
module back(distance = 0) {
	translate([0,distance,0]) children();
}

/**
 * Moves an object down the Y-axis
 *
 * @param number distance The distance it should be moved
 */
module front(distance = 0) {
	translate([0,-distance,0]) children();
}

/**
 * Applies a minkowski with a sphere to the object
 *
 * @param number r Radius of the sphere
 */
module smooth(r = 0) {
    for(i = [0:$children - 1]) minkowski() {
        children(i);
        sphere(r);
    }
}