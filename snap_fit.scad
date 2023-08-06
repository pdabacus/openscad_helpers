/*
snap fit joint generator male and female parts
v1.0.0
Pavan Dayal
*/
include<bezier.scad>


#linear_extrude(2)
    snap_male(
        width = 8,
        base_height = 1,
        wall = 0.3,
        guide_width = 1,
        guide_height = 6,
        snap_height = 3,
        snap_top_rounding = 0.2,
        snap_angle = 30,
        snap_width = 0.5,
        snap_dx = 0.2,
        $fn=5
    );

linear_extrude(2)
    snap_female(
        width = 8,
        base_height = 1,
        slop = 0.1,
        guide_width = 1,
        guide_height = 6,
        snap_height = 3,
        snap_top_rounding = 0.2,
        snap_angle = 30,
        snap_width = 0.5,
        snap_dx = 0.2,
        $fn=5
    );



//notched snap joint made3 to fit a clip
module snap_female(
        width = 6,
        base_height = 1,
        slop = 0.1,
        guide_width = 1,
        guide_height = 6,
        snap_height = 3,
        snap_top_rounding = 0.2,
        snap_angle = 30,
        snap_width = 0.5,
        snap_dx = 0.2,
    ) {
    snap_dy = (snap_dx+snap_width-snap_top_rounding) / tan(snap_angle);
    resolution = $fn;

    contour = let (
            w2 = width / 2,
            bh = base_height,
            sh = snap_height,
            sw = snap_width,
            sddx = snap_top_rounding,
            sdx = snap_dx,
            sdy = snap_dy,
            gw = guide_width,
            gw2 = guide_width / 2,
            gh = guide_height,
            S = slop
        ) bezier_poly([
            [gw2+S,0                     ],
            [w2-sw-S,0                   ],
            [w2-sw-S,sh-sdy-S            ],
            [w2-sw-sdx-S,sh-sdy-S        ],
            [w2-sddx-S,sh-S              ],
            [w2-sw-S,sh-S                ],
            [w2-sw-S,sh+S                ],
            [w2-sw-S,gh+bh               ],
            [-w2+sw+S,gh+bh              ],
            [-w2+sw+S,sh+S               ],
            [-w2+sw+S,sh-S               ],
            [-w2+sddx+S,sh-S             ],
            [-w2+sw+sdx+S,sh-sdy-S       ],
            [-w2+sw+S,sh-sdy-S           ],
            [-w2+sw+S,0                  ],
            [-gw2-S/2,0                  ],
            [-gw2-S/2,gh-bh              ],
            [-S/2,gh                     ],
            [S/2,gh                      ],
            [gw2+S/2,gh-bh               ]
        ], basic=true);

    polygon(points=contour);
}




// trident shaped clip that slides into female snap joint
module snap_male(
        width = 6,
        base_height = 1,
        wall = 0.3,
        guide_width = 1,
        guide_height = 6,
        snap_height = 3,
        snap_top_rounding = 0.2,
        snap_angle = 30,
        snap_width = 0.5,
        snap_dx = 0.2,
    ) {
    snap_dy = (snap_dx+snap_width-snap_top_rounding) / tan(snap_angle);

    resolution = $fn;

    outside = let (
            w2 = width / 2,
            bh = base_height,
            sh = base_height + snap_height,
            sw = snap_width,
            sddx = snap_top_rounding,
            sdx = snap_dx,
            sdy = snap_dy,
            gw = guide_width,
            gw2 = guide_width / 2,
            gh = guide_height
        ) bezier_poly([
            [0,0                         ],
            [w2,0                        ],
            [w2,bh,                      ],
            [w2,sh,                      ],
            [w2-sddx,sh                  ],
            [w2-sw-sdx,sh-sdy            ],
            [w2-sw,sh-sdy                ],
            [w2-sw,bh                    ],
            [gw2, bh                     ],
            [gw2, gh                     ],
            [0, bh+gh                    ],
            [-gw2, gh                    ],
            [-gw2, bh                    ],
            [-w2+sw,bh                   ],
            [-w2+sw,sh-sdy               ],
            [-w2+sw+sdx,sh-sdy           ],
            [-w2+sddx,sh                 ],
            [-w2,sh,                     ],
            [-w2,bh,                     ],
            [-w2,0                       ]
        ], basic=true);
    outside_N = len(outside);

    hole1 = let (
            w2 = width / 2,
            bh = base_height,
            bh2 = base_height / 2,
            bh4 = base_height / 4,
            W = wall,
            W2 = wall / 2
        ) bezier_poly([
            [W,bh2,          0,-bh4   ],
            [W+bh4,W                  ],
            [w2-W-bh4,W               ],
            [w2-W,bh2,        0,bh4   ],
            [w2-W-bh4,bh-W            ],
            [W2+bh4,bh-W              ],
            [W,bh2,          0,-bh4   ]
        ], $fn=resolution);
    hole1_N = len(hole1);

    hole2 = [ for (p=hole1) [-p[0], p[1]] ];
    hole2_N = len(hole2);

    hole3 = let (
            w2 = width / 2,
            bh = base_height,
            gw = guide_width,
            gw2 = guide_width / 2,
            gw4 = guide_width / 4,
            gh = guide_height,
            W = wall,
            W2 = wall / 2
        ) bezier_poly([
            [0,bh,          gw4,0   ],
            [gw2-W,bh+gw4           ],
            [gw2-W,gh-W             ],
            [0,gh-W+gw4,   -gw4,0   ],
            [-gw2+W,gh-W            ],
            [-gw2+W,bh+gw4          ],
            [0,bh,          gw4,0   ]
        ], $fn=resolution);
    hole3_N = len(hole3);

    translate([0,-base_height,0]) polygon(
        points=concat(
            outside,
            hole1,
            hole2,
            hole3
        )
        , paths=[
            [ for (j=[0:1:outside_N-1]) j ],
            [ for (j=[outside_N:1:outside_N+hole1_N-1]) j ],
            [ for (j=[outside_N+hole1_N:1:outside_N+hole1_N+hole2_N-1]) j ],
            [ for (j=[outside_N+hole1_N+hole2_N:1:outside_N+hole1_N+hole2_N+hole3_N-1]) j ]
        ]);
}
