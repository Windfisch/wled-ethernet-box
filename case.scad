inch = 25.4;

// wall thickness
wall = 1.6;

// width of the PCB (short side)
board_x = 25.4 + 0.6;

// CHANGE ME!
// the length of the WT32-ETH01's PCB (long side). Note that there are different variants around, so you'll have to customize this.
board_y = 55 + 0.3;
//board_y = 2.3*inch + 0.3;

// how much room is needed below bottom side of the PCB (for soldered-on cables etc)
board_standoff = 3.5;

// length of the cable compartment; the 5.5mm socket and its cabling must fit there.
cable_compartment_y = 20;

// put the thickness of the cable tie's head plus some 0.5 tolerance here.
antipull_compartment_y = 5;

// more than enough
cable_slot_zlen = 7;

// CHANGE ME!
// approx 1.75mm per output cable seem like a good fit here.
cable_slot_xlen = 4;


case_x = board_x;
case_y = board_y + wall + cable_compartment_y + wall + antipull_compartment_y;
case_z = 25;

// height at which the bottom half and the top half are cut apart from each other
bottom_z = 16;

rj45_back = 16.4;
rj45_xlen = 16;
rj45_zlen = 13.7;

module _fnord() {}

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
				
				a = case_y-antipull_compartment_y - wall;
				b = board_y + wall;
				translate([case_x, (a+b)/2, bottom_z/2]) rotate([0,90,0])
					cylinder(3*wall, d=11.33, center=true);
			}
			
			translate([0, board_y-wall, 0]) cube([board_x, wall, board_standoff]);
			translate([0, board_y, 0]) cube([board_x, wall, board_standoff + 2.5]);
			
			translate([0, case_y-antipull_compartment_y-wall, 0]) cube([board_x, wall, bottom_z-0.01]);
		}
		
		translate([case_x/2 - cable_slot_xlen/2,case_y-antipull_compartment_y-eps-wall, bottom_z - cable_slot_zlen+eps])
			cube([cable_slot_xlen, antipull_compartment_y+2*wall+0.1, cable_slot_zlen]);
	}
}

module clip(l) {
	clip_wall = 1;
	clip_height = 5.5;
	
	translate([0,l,bottom_z])
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
		translate([-inf/2, -inf/2, bottom_z]) cube([inf, inf, inf]);
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
		translate([-inf/2, -inf/2, bottom_z]) cube([inf, inf, inf]);
	}
	
	back_clip_distance = max(6, cable_slot_xlen);
	clip_back(case_x / 2 - back_clip_distance/2 - 1, 1);
	clip_back(case_x / 2 - back_clip_distance/2 - 1, case_x/2 + back_clip_distance/2);
	clip_front(case_x / 2 - rj45_xlen / 2 - 0.5, 0.5);
	clip_front(case_x / 2 - rj45_xlen / 2 - 0.5, case_x / 2 + rj45_xlen / 2);
	clip_left(12, 2);
	clip_right(12, 2);
	clip_left(15, case_y-15-2);
	clip_right(7, case_y-7-2);
}

rotate([0,0,180]) rotate([180,0,0]) translate([5+wall,wall,-wall - case_z])  top();
translate([wall,wall,wall]) bottom();
