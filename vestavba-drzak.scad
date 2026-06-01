// Vnitřní průřez profilu
inner_x = 19.6;
inner_y = 43.6;

// Délka nasunutí držáku na profil
insert_len = 20;

// Tloušťka pláště
wall = 3;

// Odvozené vnější rozměry
outer_x = inner_x + 2 * wall;   // 25.6 mm
outer_y = inner_y + 2 * wall;   // 49.6 mm
outer_z = insert_len;           // 20 mm

difference() {
    // Vnější těleso nasouvací části
    cube([outer_x, outer_y, outer_z]);

    // Vnitřní otvor je průchozí skrz (otevřený na obou stranách)
    translate([wall, wall, -0.1])
        cube([inner_x, inner_y, outer_z + 0.2]);
}
