include <scad_libs/roundedcube.scad>

kc_inner_size = 13.8;
kc_outer_size = 15;
kc_shell_width = 0.6;
kc_height = 1.5;
kc_radius = 0.6;
kc_dx_supports = 9.18;
kc_dy_supports = 12.7;
kc_support_height = 1.5;
kc_support_inset_depth = 0.2;
kc_support_inset_height = 1.1;
kc_support_inset_width = 1.91;
kc_support_inset_bevel_height = 0.56;
kc_support_bevel_x_angle = 37;
kc_support_bevel_x_height = 0.69;
kc_support_bevel_y_angle = 45;
kc_support_bevel_y_height = 1.25;

kc_homing = false;
kc_homing_length = 4;
kc_homing_width = .6;
kc_homing_pos = .3;

// base positioning

kc_base_pos_x = 0;
kc_base_pos_y = 0;
kc_margin = 18;

// labels

kc_label_top_left = "";
kc_label_top_center = "";
kc_label_top_right = "";
kc_label_middle_left = "";
kc_label_middle_center = "";
kc_label_middle_right = "";
kc_label_bottom_left = "";
kc_label_bottom_center = "";
kc_label_bottom_right = "";

// labels settings

kc_label_font = "DejaVu Sans:style=Bold";
kc_center_label_relative_size = .35;
kc_label_relative_size = .22;
kc_label_positioning = .4;

// Parts to save. Must be "keycap", "labels" or "all"
kc_part = "keycap";

module support() {
    difference() {
        // Support base
        translate([kc_dx_supports/2,
                   kc_dy_supports/2,
                   kc_height - kc_support_height]) {
            difference() {
                difference() {
                    // support shape
                    cube(
                        [(kc_inner_size - kc_dx_supports)/2,
                         (kc_inner_size - kc_dy_supports)/2,
                         kc_support_height
                         ],
                         center=false
                    );
                    
                    // Support X bevel
                    translate([0, 0, kc_support_height - kc_support_bevel_x_height ]) {
                        rotate([0, 180, 0]) {
                            rotate([0, -kc_support_bevel_x_angle, 0]) {
                                cube(
                                    [kc_support_height - kc_support_bevel_x_height,
                                     (kc_inner_size - kc_dy_supports)/2,
                                     (kc_inner_size - kc_dx_supports)/2
                                     ]
                                );
                            }
                        }
                    }
                } // end X bevel

                // Support Y bevel
                translate([(kc_inner_size - kc_dx_supports)/2,
                           0,
                           kc_support_height - kc_support_bevel_y_height
                           ]) {
                    rotate([0, 180, 0]) {
                        rotate([kc_support_bevel_y_angle, 0, 0]) {
                            cube(
                                  [(kc_inner_size - kc_dx_supports)/2,
                                   kc_support_bevel_y_height,
                                   kc_support_bevel_y_height
                                   ]
                            );
                        }
                    }
                }
            } // end y bevel
        }
        // Support inset
        translate([kc_inner_size/2 - kc_support_inset_width,
                   kc_dy_supports/2,
                   kc_height - kc_support_inset_height]) {

            difference() {
                cube(
                    [kc_support_inset_width, kc_support_inset_depth, kc_support_inset_height],
                    center=false
                );    

                // Support bevel
                translate([0, 0, kc_support_inset_height - kc_support_inset_bevel_height ]) {
                    rotate([0, 180, 0]) {
                        rotate([0, -kc_support_bevel_x_angle, 0]) {
                            cube(
                                [kc_support_height - kc_support_bevel_x_height,
                                 (kc_inner_size - kc_dy_supports)/2,
                                 (kc_inner_size - kc_dx_supports)/2
                                 ]
                            );
                        }
                    }
                }

            }
        }
    }
}

module label(x, y, char) { 
        
    translate([x, y, kc_height]) {
        linear_extrude(height=kc_shell_width) {
            text(char,
                 font=kc_label_font,
                 halign="center",
                 valign="center",
                 size=kc_outer_size* (((x==0)&&(y==0)) ? kc_center_label_relative_size : kc_label_relative_size)
            );
        }
    }
}

translate([kc_base_pos_x * kc_margin, kc_base_pos_y * kc_margin, 0]) {  // position offset for each key
    rotate([180, 0, 0]) {  // face down
        if(kc_part != "labels") {
            difference() {

                union() {
                
                    color("gray") {

                        // Top layer
                        intersection() {
                            translate([0, 0, kc_height]) {
                                roundedcube(
                                    [kc_outer_size, kc_outer_size, kc_shell_width*2],
                                    center=true,
                                    radius=kc_radius
                                );
                            }
                            
                            translate([0, 0, kc_height + kc_shell_width/2]) {
                                cube(
                                    [kc_outer_size, kc_outer_size, kc_shell_width],
                                    center=true
                                );
                            }
                        }

                        // homing
                        if(kc_homing) {
                            translate([0, -(kc_outer_size*kc_homing_pos)/2, kc_height + kc_shell_width/2 + kc_homing_width/2]) {
                                roundedcube(
                                    [kc_homing_length, kc_homing_width, kc_homing_width],
                                    center=true,
                                    radius=kc_homing_width/2
                                );
                            }
                        }

                        // Sides
                        translate([0, 0, kc_height / 2]) {
                            difference() {
                                roundedcube(
                                    [kc_outer_size, kc_outer_size, kc_height],
                                    center=true,
                                    radius=kc_radius,
                                    apply_to="z"
                                );
                                roundedcube(
                                    [kc_inner_size, kc_inner_size, kc_height],
                                    center=true,
                                    radius=kc_radius,
                                    apply_to="z"
                                );
                            }
                        }
                        
                        support();
                        mirror([1, 0, 0]) {
                            support();
                        }
                        mirror([0, 1, 0]) {
                            support();
                        }
                        mirror([0, 1, 0]) {
                            mirror([1, 0, 0]) {
                                support();
                            }
                        }
                    }
                }

                // Labels pockets
                union() {
                    let(pos=(kc_outer_size - kc_outer_size * kc_label_positioning)/2) {
                        if(kc_label_top_left != undef) label(-pos, pos, kc_label_top_left);
                        if(kc_label_top_center != undef) label(0, pos, kc_label_top_center);
                        if(kc_label_top_right != undef) label(pos, pos, kc_label_top_right);
                        if(kc_label_middle_left != undef) label(-pos, 0, kc_label_middle_left);
                        if(kc_label_middle_center != undef) label(0, 0, kc_label_middle_center);
                        if(kc_label_middle_right != undef) label(pos, 0, kc_label_middle_right);
                        if(kc_label_bottom_left != undef)label(-pos, -pos, kc_label_bottom_left);
                        if(kc_label_bottom_center != undef) label(0, -pos, kc_label_bottom_center);
                        if(kc_label_bottom_right != undef) label(pos, -pos, kc_label_bottom_right);
                    }
                }
            }
        }

        if(kc_part != "keycap") {
            // Labels
            color("black") {
                union() {
                    let(pos=(kc_outer_size - kc_outer_size * kc_label_positioning)/2) {
                        if(kc_label_top_left != undef) label(-pos, pos, kc_label_top_left);
                        if(kc_label_top_center != undef) label(0, pos, kc_label_top_center);
                        if(kc_label_top_right != undef) label(pos, pos, kc_label_top_right);
                        if(kc_label_middle_left != undef) label(-pos, 0, kc_label_middle_left);
                        if(kc_label_middle_center != undef) label(0, 0, kc_label_middle_center);
                        if(kc_label_middle_right != undef) label(pos, 0, kc_label_middle_right);
                        if(kc_label_bottom_left != undef)label(-pos, -pos, kc_label_bottom_left);
                        if(kc_label_bottom_center != undef) label(0, -pos, kc_label_bottom_center);
                        if(kc_label_bottom_right != undef) label(pos, -pos, kc_label_bottom_right);
                    }
                }
            }
        }
    }
}
