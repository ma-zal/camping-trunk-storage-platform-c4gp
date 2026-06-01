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
insert_len = 30;  // délka nasouvací části (hloubka tunelu v ose Z)
wall = 3;         // tloušťka pláště

// ---------- Parametry základny a výztuh ----------
base_w = 60;      // celková šířka základny (shodná se šířkou jazýčku)
base_t = wall;    // tloušťka horní desky základny (zapuštěná do horní stěny tunelu)
rib_depth = 20;   // hloubka bočních výztuh v ose Z (není potřeba celých 20)
rib_wall = wall;  // tloušťka stěny (rámu) duté výztuhy

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
$vpr = [60, 0, 135];    // rotace pohledu (sklon a natočení)
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
//  Horní základna – plochá deska 60 mm široká přes horní stranu tunelu.
//  Je zapuštěná do horní stěny tunelu (horní plocha v rovině outer_y),
//  takže nad tunelem nevzniká dvojitá tloušťka – přes šířku tunelu se
//  jen překryje s jeho stěnou, navíc rozšiřuje horní plochu do stran.
// ---------------------------------------------------------------------
module top_base() {
    translate([-base_w / 2, outer_y - base_t, 0])
        cube([base_w, base_t, rib_depth]);
}

// ---------------------------------------------------------------------
//  Boční výztuhy – duté trojúhelníkové výztuhy (jen rám, ne plná výplň),
//  které rozšiřují základnu a plynule navazují k hornímu rohu tunelu.
//  Svah vede od hrany základny až ke spodnímu konci delší strany.
//  Hloubka rib_depth, tloušťka rámu rib_wall.
// ---------------------------------------------------------------------
module side_ribs() {
    rib_height = outer_y;   // 49.6 mm (až dolů)

    tri = [
        [outer_x / 2, outer_y],                // horní roh tunelu
        [base_w / 2,  outer_y],                // hrana základny
        [outer_x / 2, outer_y - rib_height],   // svah k patě tunelu
    ];

    for (mx = [1, -1]) {              // pravá (+X) a levá (-X) strana
        scale([mx, 1, 1])
        linear_extrude(height = rib_depth)
            difference() {
                polygon(points = tri);
                // odebráním zmenšeného trojúhelníku zůstane jen rám (dutý)
                offset(delta = -rib_wall)
                    polygon(points = tri);
            }
    }
}

// ---------------------------------------------------------------------
//  Jazýček (háček) – visí z předního přesahu základny směrem dolů,
//  ven od modelu (mimo těleso tunelu). Šířka 60, tloušťka stěny 4,
//  hloubka 10. Zaoblené jsou koncové (boční) hrany, ne podélné.
//  Zapadne do vodorovného otvoru a zajistí profil proti vysunutí.
// ---------------------------------------------------------------------
module tongue() {
    // Jazýček vychází z horní plochy (rovina outer_y)
    y_bottom = outer_y;

    // Profil leží v rovině šířka (X) × hloubka (Y) a vytlačí se v ose Z
    // (tloušťka). Tím se zaoblí koncové hrany běžící napříč tloušťkou.
    translate([0, y_bottom, 0])
        linear_extrude(height = tongue_thick)
            tongue_profile();
}

// 2D profil jazýčku v rovině (X = šířka, Y = hloubka).
// Zaoblené jsou jen dva vnější rohy (hrany mířící ven, y = d);
// strana přiléhající k držáku (y = 0) zůstává ostrá.
module tongue_profile() {
    w = tongue_w;
    d = tongue_depth;
    r = tongue_round;

    hull() {
        // tělo s ostrou hranou u držáku
        translate([-w / 2, 0]) square([w, d - r]);
        // zaoblené vnější rohy
        translate([-w / 2 + r, d - r]) circle(r = r);
        translate([ w / 2 - r, d - r]) circle(r = r);
    }
}

// =====================================================================
//  Render
// =====================================================================
drzak();
