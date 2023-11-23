/*
dovetail joint generator
v1.0.0
Pavan Dayal

example:

H = 2;
board1 = 0.6;
board2 = 0.4;
dove_extr1 = 0.41;
dove_extr2 = 0.61;

dove_h = 0.5;
dove_H2 = H-2*0.2 - 2*dove_h;
dove_h2 = dove_H2 - 2*1/5*board2;
contour = function(x, r=1/5) r*x;

union() { //dovetails
    translate([board2,0,0]) cube([3,board1,H]);
    translate([board2,0,dove_h/2+0.2]) rotate([90,0,180])
        translate([0,0,0]) linear_extrude(board1)
            dovetail(dove_extr1,dove_h,"x", contour, $fn=5);
    translate([board2,0,H-dove_h/2-0.2]) rotate([90,0,180])
        translate([0,0,0]) linear_extrude(board1)
            dovetail(dove_extr1,0.5,"x", contour, $fn=5);
}

#difference() {
union() { //pins
    translate([0,board1,0]) cube([board2,3,H]);
    translate([0,board1,H/2]) rotate([90,0,0])
        linear_extrude(dove_extr2)
                dovetail(board2,dove_h2,"x", contour, $fn=5);
    translate([0,board1,-dove_H2/2+0.2]) rotate([90,0,0])
        linear_extrude(dove_extr2)
                dovetail(board2,dove_h2,"x", contour, $fn=5);
    translate([0,board1,H+dove_H2/2-0.2]) rotate([90,0,0])
        linear_extrude(dove_extr2)
                dovetail(board2,dove_h2,"x", contour, $fn=5);
}
    translate([0,0,-2-0.001]) cube([4,4,4], center=true);
    translate([0,0,2+H+0.001]) cube([4,4,4], center=true);
}
*/

module dovetail(
        w=1,
        l=1,
        axis="x",
        contour=function(x,r=1/5) r*x,
        $fn=10
    ) {
    // create a symmetric polygon based on a contour
    // interpolated from [0,1] along an axis
    //    w = 1; //width along x
    //    l = 0.9; //length along y
    //    axis = "x"; //which axis interpolated along
    //    r = 1/5; //dovetail ratio 1/5, 1/6, or 1/8
    //    contour = (x) => 1+r*x; //interpolate [0,1]

    polygon (
        (axis == "x")
        ?
        concat(
            [[0,0]],
            [ for (x=[0:1.0/$fn:1.0])
                [w*x, -l/2-w*contour(x)]
            ],
            [[w,0]],
            [ for (x=[1.0:-1.0/$fn:0.0])
                [w*x, l/2+w*contour(x)]
            ]
        )
        :
        concat(
            [[0,0]],
            [ for (y=[0:1.0/$fn:1.0])
                [w/2+l*contour(y), l*y]
            ],
            [[0,l]],
            [ for (y=[1.0:-1.0/$fn:0.0])
                [-w/2-l*contour(y), l*y]
            ]
        )
    );
}
