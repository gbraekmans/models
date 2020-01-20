# OpenSCAD models

**The files in this repository are stand-alone,
  just copy them in your projects.**

This is a collection of stuff I've used in things I made. Most are
compatible with the customizer, so you don't need any knowledge of OpenSCAD to
use them.

# Common design challenges when using OpenSCAD

Some simple stuff I've used but seem to forget after some time. This is mainly
used as a reference for when I am trying to make new objects.

## Loft

This can be done using ``hull`` if the shape is convex.

```openscad
hull() {
    cube([10,10,10], center=true);
    cylinder(20, r=5);
}
```

## Reflection / Mirror / Symmetry

Make one side and just copy it using something like this:

```openscad
module reflect(v=[0,1,0]) 
{ 
    children(); 
    mirror(v) children(); 
}
```

## Creating surfaces (ie: a bowl)

Just subtract the outer shape with a smaller outer shape.

```openscad
module bowl_exterior(r, eps=0.01) {
    difference() {
        sphere(r);
        cylinder(r+eps, r=r+eps);
    }
}

difference() {
    bowl_exterior(10);
    translate([0,0,0.01]) bowl_exterior(8);
}
```

## 2d circular hull (fidget spinner, wrench handles, ...)

Usually you'd use ``hull`` for that, however in some cases you can use
``offset`` to create a smooth transition.

```
offset(r=-20) offset(r=20) {
    translate([-20,0]) circle(10);
    translate([20,0]) circle(10);
}
```


## Chamfers, tapers, fillets and roundovers

Some general tips:

* Work in 2d as much as possible and use the ``offset`` command.
* Use ``hull`` and ``minkowski``, especially on models with few vertices.
* Minkowski-chamfers in the XY-plane only work when using right angles. In 2d
  and using ``offset`` works on all angles.  

### Roundover in XY and taper over Z

```openscad
module double_cone(r) {
    cylinder(r, r1=r, r2=0);
    rotate([180,0]) cylinder(r, r1=r, r2=0);
}

minkowski() {
    cube([10,10,10]);
    double_cone(2);
}
```

### Chamfer or fillet extrude a 2d object

This method is only useful if the chamfered / filleted object is placed on a
flat surface.

General chamfer of a 2d object:

```openscad
module chamfer(r, eps=0.01) {
    for(i = [0:$children - 1])
        translate([0,0,-r/2]) minkowski() {
                linear_extrude(eps) children(i);
                cylinder(r - eps, r1=r, r2=0); // cone
            }
}

module taper(r) {
    chamfer(r) offset(delta=-r) children();
}
```

For fillets replace the cone with a pin, for roundovers with a half-sphere:

```openscad
module pin(r, eps=0.01) {
    difference() {
        translate([0,0,r/2])
            cylinder(r, r=r, center=true);
        rotate_extrude() translate([r,r])
            circle(r - eps);
    }
}

module half_sphere(r, eps=0.01) {
    difference() {
        sphere(r);
        translate([0,0,-r-eps]) cylinder(r+eps, r=r+eps);
    }
}
```

For chamfering/tapering convex 2d objects this is usually faster to render:

```openscad
module convex_chamfer(r) {
    EPS = 0.01;
    for(i = [0:$children-1])
        hull() {
            translate([0,0, r/2-EPS]) linear_extrude(EPS)
                children(i);
            translate([0,0, -r/2+EPS]) linear_extrude(EPS)
                offset(r=r) children(i);
        }
}
```

## Skewing

```openscad
module skew(
            x_over_y=0,
            x_over_z=0,
            y_over_x=0,
            y_over_z=0,
            z_over_x=0,
            z_over_y=0
    ) {
    matrix = [
        [ 1            , tan(x_over_y), tan(x_over_z), 0 ],
        [ tan(y_over_x), 1            , tan(y_over_z), 0 ],
        [ tan(z_over_x), tan(z_over_y), 1            , 0 ],
        [ 0            , 0            , 0            , 1 ]
    ];

    multmatrix(matrix)
    children();
}
```

## Default parameters based on other parameters

Make the parameter equal undef and use something like this:

```openscad
function apply_default(v, d) = is_undef(v)? d : v;
```

to overwrite the parameter in the module body.