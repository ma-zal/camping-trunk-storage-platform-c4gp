// =====================================================================
//  Nasouvací držák na dřevěný profil 19 x 43 mm
//  ------------------------------------------------------------------
//  Souřadný systém:
//    X = šířka (vodorovně napříč), model je vycentrovaný na X = 0
//    Y = výška (svisle), Y = 0 je dole, profil stojí vyšší stranou nahoru
//    Z = směr nasunutí profilu (tunel je v ose Z průchozí)
// =====================================================================

// ---------- Parametry profilu a nasunutí ----------
inner_x = 19.6;   // vnitřní šířka tunelu (kratší strana profilu + vůle)
inner_y = 43.6;   // vnitřní výška tunelu (delší strana profilu + vůle)
insert_len = 20;  // délka nasouvací části (hloubka tunelu v ose Z)
wall = 3;         // tloušťka pláště

// ---------- Parametry základny a výztuh ----------
base_w = 60;      // celková šířka základny (shodná se šířkou jazýčku)
base_t = wall;    // tloušťka horní desky základny
rib_depth = 10;   // hloubka bočních výztuh v ose Z (není potřeba celých 20)

// ---------- Parametry jazýčku (háčku) ----------
tongue_w = 60;       // šířka jazýčku
tongue_thick = 4;    // tloušťka stěny jazýčku (v ose Z)
tongue_depth = 10;   // hloubka jazýčku (jak daleko směřuje dolů, osa Y)
tongue_round = 1.8;  // poloměr zaoblení koncových hran jazýčku

// ---------- Odvozené vnější rozměry ----------
outer_x = inner_x + 2 * wall;   // 25.6 mm
outer_y = inner_y + 2 * wall;   // 49.6 mm

// Jemnost zaoblení
$fn = 48;

// ---------- Výchozí pohled kamery (aby model nebyl mimo záběr) ----------
// Model je v ose Y posunutý nahoru (Y ≈ 0–53), proto kamera míří na jeho
// střed, ne na počátek [0,0,0].
$vpt = [0, 20, 10];     // bod, na který se kamera dívá (střed modelu)
$vpr = [60, 0, 25];    // rotace pohledu (sklon a natočení)
$vpd = 200;            // vzdálenost kamery (zoom)

// =====================================================================
//  Hlavní sestava
// =====================================================================
module drzak() {
    union() {
        // Nasouvací tunel (s průchozím otvorem)
        insert_tunnel();

        // Horní základna + boční výztuhy + jazýček
        top_base();
        side_ribs();
        tongue();
    }
}

// ---------------------------------------------------------------------
//  Nasouvací tunel – obdélníkový průchozí tunel otevřený na obou stranách
// ---------------------------------------------------------------------
module insert_tunnel() {
    difference() {
        // Vnější těleso, vycentrované na X = 0
        translate([-outer_x / 2, 0, 0])
            cube([outer_x, outer_y, insert_len]);

        // Vnitřní průchozí otvor (přesah 0.1 na obou koncích kvůli čistému řezu)
        translate([-inner_x / 2, wall, -0.1])
            cube([inner_x, inner_y, insert_len + 0.2]);
    }
}

// ---------------------------------------------------------------------
//  Horní základna – plochá deska 60 mm široká přes horní stranu tunelu
//  Drží profil na středu, aby se nepřeklápěl na žádnou stranu.
//  Vepředu přečnívá o tloušťku jazýčku (přesah), aby z ní mohl jazýček
//  viset směrem od modelu pryč (mimo těleso).
// ---------------------------------------------------------------------
module top_base() {
    translate([-base_w / 2, outer_y, -tongue_thick])
        cube([base_w, base_t, insert_len + tongue_thick]);
}

// ---------------------------------------------------------------------
//  Boční výztuhy – plné trojúhelníkové výztuhy, které rozšiřují základnu
//  a plynule navazují směrem k horní části nasunu. Hloubka rib_depth.
// ---------------------------------------------------------------------
module side_ribs() {
    // Výška svahu výztuhy – pro plynulý přechod (cca 45°) od hrany
    // základny dolů k boku tunelu.
    rib_height = base_w / 2 - outer_x / 2;   // 17.2 mm

    for (mx = [1, -1]) {              // pravá (+X) a levá (-X) strana
        scale([mx, 1, 1])
        linear_extrude(height = rib_depth)
            polygon(points = [
                [outer_x / 2, outer_y],                // horní roh tunelu
                [base_w / 2,  outer_y],                // hrana základny
                [outer_x / 2, outer_y - rib_height],   // svah k boku tunelu
            ]);
    }
}

// ---------------------------------------------------------------------
//  Jazýček (háček) – visí z předního přesahu základny směrem dolů,
//  ven od modelu (mimo těleso tunelu). Šířka 60, tloušťka stěny 4,
//  hloubka 10. Zaoblené jsou koncové (boční) hrany, ne podélné.
//  Zapadne do vodorovného otvoru a zajistí profil proti vysunutí.
// ---------------------------------------------------------------------
module tongue() {
    // Spodní hrana jazýčku (kam až sahá směrem dolů)
    y_bottom = outer_y + base_t - tongue_depth;

    // Profil leží v rovině šířka (X) × hloubka (Y) a vytlačí se v ose Z
    // (tloušťka). Tím se zaoblí koncové hrany běžící napříč tloušťkou.
    translate([0, y_bottom, -tongue_thick])
        linear_extrude(height = tongue_thick)
            tongue_profile();
}

// 2D profil jazýčku v rovině (X = šířka, Y = hloubka).
// Zaoblené rohy (koncové hrany) se vytvoří obalením (hull) čtyř kruhů.
module tongue_profile() {
    w = tongue_w;
    d = tongue_depth;
    r = tongue_round;

    hull() {
        for (x = [-w / 2 + r, w / 2 - r], y = [r, d - r])
            translate([x, y]) circle(r = r);
    }
}

// =====================================================================
//  Render
// =====================================================================
drzak();
