/*
bezier curve generator using $fn number of steps between points
v1.0.0
Pavan Dayal

example:
    pts = [
        [0,0],
        [1,0, 0.4,0.2],
        [1,5, 0,0.1, 2,-1],
        [2,7, 0,1],
        [1,9, -0.3,0.2],
        [0,9]
    ];

    translate([0,-12,0]) {
        translate([0,0,0]) polygon(bezier_poly(pts, $fn=12));
        translate([4,0,0]) polygon(bezier_poly(pts, basic=true));
    };

    echo(bezier_poly(pts, $fn=4));

    rotate_extrude($fn=60) polygon(bezier_poly(pts, $fn=12));
*/

function bezier_poly(points, basic=false) = (
    // array of points, each point has 2-6 items
    // which corresponds to 1, 2, or 3 (x,y) pairs
    // with optional points representing 1-2 handle ties in relative coordinates
    // basic=true just makes lines between each point no interpolation
    let (
        interpolate = function (p, q, t)
            let (
                qax = ((len(q) >= 4) ? ((len(q) >= 6) ? q[4] : -q[2]) : 0),
                qay = ((len(q) >= 4) ? ((len(q) >= 6) ? q[5] : -q[3]) : 0)
            ) [
            pow(1-t,3) * p[0]
                + 3 * pow(1-t,2) * t * (p[0] + ((len(p) >= 4) ? p[2] : 0))
                + 3 * (1-t) * pow(t,2) * (q[0] + qax)
                + pow(t,3) * q[0],
            pow(1-t,3) * p[1]
                + 3 * pow(1-t,2) * t * (p[1] + ((len(p) >= 4) ? p[3] : 0))
                + 3 * (1-t) * pow(t,2) * (q[1] + qay)
                +  pow(t,3) * q[1]
        ],

        make_points = function (p, q)
            concat(
                [[p[0],p[1]]],
                [
                    for (i=[1:$fn]) interpolate(p, q, i/($fn+1))
                ]
        )

    ) (basic) ?
        [
            for (p=points)
                [p[0],p[1]]
        ]
    :
        concat(
            [
                for (i=[0:len(points)-2])
                    each make_points(points[i], points[i+1])
            ],
            [[points[len(points)-1][0],points[len(points)-1][1]]]
        )
);

