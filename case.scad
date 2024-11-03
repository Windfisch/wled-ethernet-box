inch = 25.4;

wall = 1.6;
board_x = 1*inch + 0.6;
board_y = 2.3*inch + 0.3;
board_z = 15.2;
board_standoff = 3.5;

cable_compartment_y = 20;
antipull_compartment_y = 5;

case_x = board_x;
case_y = board_y + wall + cable_compartment_y + wall + antipull_compartment_y;
case_z = 25;

bottom_y = 16;

rj45_back = 16.4;
rj45_xlen = 16;
rj45_zlen = 13.6;


inf = 200;

eps=0.01;


module chamfered_rect(xlen, ylen, chamfer) {
	polygon([
		[0, chamfer], [chamfer, 0],
		[xlen-chamfer, 0], [xlen, chamfer],
		[xlen, ylen-chamfer], [xlen-chamfer, ylen],
		[chamfer, ylen], [0, ylen-chamfer]
	]);
}

module chamfered_cube(xlen, ylen, zlen, chamfer) {
	intersection() {
		linear_extrude(zlen) chamfered_rect(xlen, ylen, chamfer);
		rotate([90,0,90]) linear_extrude(xlen) chamfered_rect(ylen, zlen, chamfer);
		mirror([0,1,0]) rotate([90,0,0]) linear_extrude(ylen) chamfered_rect(xlen, zlen, chamfer);
	}
}

module case() {
	difference() {
		union() {
			difference() {
				translate([-wall, -wall, -wall]) chamfered_cube(case_x + 2*wall,case_y + 2*wall,case_z + 2*wall, 1.5);
				cube([case_x, case_y, case_z]);
				
				translate([board_x/2, 0, board_standoff + rj45_zlen/2])
					cube([rj45_xlen, 3*wall, rj45_zlen], center=true);
				
				translate([case_x, 71, bottom_y/2]) rotate([0,90,0])
					cylinder(3*wall, d=11.33, center=true);
			}
			
			translate([0, board_y-wall, 0]) cube([board_x, wall, board_standoff]);
			translate([0, board_y, 0]) cube([board_x, wall, board_standoff + 2.5]);
			
			translate([0, case_y-antipull_compartment_y-wall, 0]) cube([board_x, wall, bottom_y-0.01]);
		}
		
		cable_slot_zlen = 7;
		translate([case_x/2 - 4/2,case_y-antipull_compartment_y-eps-wall, bottom_y - cable_slot_zlen+eps])
			cube([4, antipull_compartment_y+2*wall+0.1, cable_slot_zlen]);
	}
}

module clip(l) {
	clip_wall = 1;
	clip_height = 5.5;
	
	translate([0,l,bottom_y])
	rotate([90,0,0])
	
	linear_extrude(l)
		polygon([
			[0, -3],
			[1, 0],
			[1, clip_height],
			[0, clip_height],
		]);
}

module clip_left(l, y0) {
	translate([0,y0,0]) clip(l);
}

module clip_right(l, y0) {
	translate([case_x, y0, 0]) mirror([1,0,0]) clip(l);
}

module clip_front(l, x0) {
	translate([l+x0,0,0]) rotate([0,0,90]) clip(l);
}

module clip_back(l, x0) {
	translate([x0,case_y,0]) rotate([0,0,-90]) clip(l);
}


module top() {
	intersection() {
		case();
		translate([-inf/2, -inf/2, bottom_y]) cube([inf, inf, inf]);
	}
	holder_size = 10;
	
	holder_height = case_z - (board_standoff + rj45_zlen) +eps;
	translate([case_x/2, rj45_back - holder_size/2, board_standoff + rj45_zlen ]) {
		
		translate([-wall/2, -holder_size/2,0])
			cube([wall,holder_size,holder_height]);
		translate([-holder_size/2, -wall/2,0])
			cube([holder_size,wall,holder_height]);
	}
}

module bottom() {
	difference() {
		case();
		translate([-inf/2, -inf/2, bottom_y]) cube([inf, inf, inf]);
	}
	
	clip_back(case_x / 2 - 8/2, 1);
	clip_back(case_x / 2 - 8/2, case_x/2 + 8/2 -1);
	clip_front(case_x / 2 - rj45_xlen / 2 - 0.5, 0.5);
	clip_front(case_x / 2 - rj45_xlen / 2 - 0.5, case_x / 2 + rj45_xlen / 2);
	clip_left(12, 2);
	clip_right(12, 2);
	clip_left(15, case_y-15-2);
	clip_right(7, case_y-7-2);
}

rotate([180,0,0]) translate([5+3*wall+case_x,-wall - case_y,-wall - case_z])  top();
translate([wall,wall,wall]) bottom();