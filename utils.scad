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