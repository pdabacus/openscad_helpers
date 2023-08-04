/*
fillet and bevel extrusion from 2d shapes using $fn circular steps between faces
v1.0.0
Pavan Dayal

example:
*/
linear_extrude(1) square(2, center=true);
translate([0,0,1]) fillet_extrude(1, 1.5, 0.5, $fn=2) square(1, center=true);
translate([0,0,2]) extrude_bevel(1, 1.5, 0.25, $fn=1) square(1, center=true);

translate([3,0,0]) {
    linear_extrude(1) circle(1.5, $fn=12);
    translate([0,0,1]) fillet_extrude(1, 1.5, 0.5, $fn=10) circle(1,  $fn=6);
    translate([0,0,2]) extrude_bevel(1, 0.8, 0.2, $fn=8) circle(1, $fn=6);
}


module fillet_extrude(extrude, fillet=1.1, fillet_height=0.1, $fn=8) {
    let (
        scale_curve = function(t, f) (1+f)-f*sin(t*90),
        height_curve = function(t, fh) fh-fh*cos(t*90)
    ) union() {
        for (j=[1:$fn]) let (
            t0 = (j-1)/$fn,
            t1 = j/$fn,
            scale0 = scale_curve(t0, fillet-1),
            scale1 = scale_curve(t1, fillet-1),
            height0 = height_curve(t0, fillet_height),
            height1 = height_curve(t1, fillet_height),
            delta_h = height1 - height0,
            factor_scale = scale1/scale0
        ) translate([0,0,height0])
            linear_extrude(delta_h, scale=factor_scale)
                scale([scale0, scale0, 1])
                    children();

        translate([0,0,fillet_height])
            linear_extrude(extrude-fillet_height)
                children();
    }
}

module extrude_bevel(extrude, bevel=0.9, bevel_height=0.1, $fn=8) {
    let (
        scale_curve = function(t, f) (1-f)+f*cos(t*90),
        height_curve = function(t, fh) extrude-fh + fh*sin(t*90)
    ) union() {
        linear_extrude(extrude-bevel_height) children();

        for (j=[1:$fn]) let (
            t0 = (j-1)/$fn,
            t1 = j/$fn,
            scale0 = scale_curve(t0, 1-bevel),
            scale1 = scale_curve(t1, 1-bevel),
            height0 = height_curve(t0, bevel_height),
            height1 = height_curve(t1, bevel_height),
            delta_h = height1 - height0,
            factor_scale = scale1/scale0
        ) translate([0,0,height0])
            linear_extrude(delta_h, scale=factor_scale)
                scale([scale0, scale0, 1])
                    children();
    }
}
