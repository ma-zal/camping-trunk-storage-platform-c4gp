// =====================================================================
//  Zadní držák – kruhová podložka na oko (přitlačení oka k trámu)
//  ------------------------------------------------------------------
//  Princip (viz README): zadní trám leží na okách na bočních stěnách
//  kufru. Tato podložka se položí na oko a přišroubuje se šroubem skrz
//  střed. Tím přitlačí prut oka k trámu a zároveň brání jeho posuvu –
//  prut oka sedí v lůžku na spodní straně podložky.
//
//  Tvar oka je U (půlkruh + dvě rovné nohy), proto lůžko kopíruje U
//  a samotná podložka je „půl kulatá, zbytek rovný". Tělo je tvořené
//  zespodu: tlustý blok se svislou stěnou + nahoře tenký širší lem.
//  Lůžko prutu NENÍ odebraná drážka – je to konkávní 90° zaoblení (R3)
//  PŘIDANÉ do rohu (stěna ↔ spodek lemu). Stěna pod lůžkem je proto
//  svislá a u dna ostrá, žádný obloukový převis.
//
//  Souřadný systém:
//    Z = tloušťka podložky, Z = 0 je dolní (dosedací) plocha
//    Lůžko pro prut je při spodní ploše (prut sedí zdola, vně stěny)
//    U se otevírá ve směru +Y, kulatá část je na straně -Y, střed na [0,0]
// =====================================================================

// ---------- Hlavní rozměry podložky ----------
thickness       = 9;    // celková tloušťka plného bloku, vcetne tloustky rozsirene casti.
shelf_thickness = 3;    // tloušťka rozsirene casti (lem za drážkou)

// ---------- Parametry oka a jeho drážky ----------
eye_rod_d   = 6;    // průměr prutu oka ("6mm OKO")
eye_pitch_inner_d = 29.8; // průměr vnitřní části U – osa prutu
leg_len     = 11;   // délka rovných nohou U (jak daleko pokračují rovně). Max 15mm.

eye_pitch_d = eye_pitch_inner_d + eye_rod_d;   // průměr kulaté části U – osa prutu

// ---------- Šířky lemu ----------
inner_margin = 0;   // jemný posun svislé stěny (0 = přesně na vnitřní tečně prutu)

// ---------- Otvor na šroub ----------
screw_d     = 5.2;    // průchozí otvor pro šroub skrz střed

// ---------- Odvozené hodnoty ----------
groove_r   = eye_rod_d / 2;          // poloměr lůžka = 3 mm (rádius z nákresu)
pitch_r    = eye_pitch_d / 2;        // poloměr osy prutu oka = 18 mm
full_r     = pitch_r - groove_r + inner_margin;  // svislá stěna na vnitřní tečně prutu
outer_r    = 46 / 2;             // vnější okraj lemu (polomer od stredu osy)
corner_z   = thickness - shelf_thickness;        // výška spodku lemu = výška rohu (lůžka)

eps = 0.01; // malý posun pro zajištění správného pořadí operací (rozdíl mezi "vnitřní" a "vnější" částí)

// Jemnost zaoblení
$fn = 128;

// ---------- Výchozí pohled kamery ----------
$vpt = [0, 8, 3];
$vpr = [60, 0, 25];
$vpd = 160;

// =====================================================================
//  Hlavní sestava
// =====================================================================
module podlozka() {
    difference() {
        union() {
            // tenký horní lem (širší), na opačné straně než lůžko
            translate([0, 0, corner_z])
                ushape_slab(outer_r, shelf_thickness, leg_len);
            // tlustý blok se svislou stěnou (vnitřní část)
            ushape_slab(full_r, thickness, leg_len);
            // aditivní zaoblené lůžko prutu v rohu (U: oblouk + nohy)
            eye_fillet();
        }
        screw_hole();       // průchozí otvor pro šroub
    }
}

// ---------------------------------------------------------------------
//  Tvar „U" jako plný blok dané tloušťky: půlkruh (poloměr r) na straně
//  -Y + obdélníková část pokračující rovně do +Y o délce L.
// ---------------------------------------------------------------------
module ushape_slab(r, t, L) {
    union() {
        // kulatá půlka (Y <= 0)
        intersection() {
            cylinder(r = r, h = t);
            translate([-r - 1, -2 * r - 1, -1])
                cube([2 * r + 2, 2 * r + 1, t + 2]);
        }
        // rovná část (Y = 0 .. L)
        translate([-r, 0, 0]) cube([2 * r, L, t]);
    }
}

// ---------------------------------------------------------------------
//  Lůžko prutu oka – kopíruje U: konkávní 90° zaoblení (R = groove_r)
//  PŘIDANÉ do rohu, kde se svislá stěna tlustého bloku (poloměr full_r)
//  potkává se spodkem horního lemu (výška corner_z). Prut sedí vně té
//  stěny, spodkem v rovině Z = 0; zaoblení vystředěné na osu prutu tvoří
//  jeho lůžko. Stěna pod lůžkem je svislá a u dna ostrá (nic se neodebírá).
// ---------------------------------------------------------------------
module eye_fillet() {
    // kulatá půlka lůžka (Y <= 0)
    rotate([0, 0, 180])
        rotate_extrude(angle = 180)
            fillet_profile();

    // rovné nohy podél obou stran U
    for (mx = [1, -1])
        scale([mx, 1, 1]) fillet_leg();
}

// 2D profil zaoblení rohu (x = radiála, y = výška): čtverec R×R v rohu
// mínus kružnice R vystředěná na osu prutu → konkávní čtvrtkruhové lůžko.
module fillet_profile() {
    difference() {
        // levá hrana posunutá o eps do středu (−x) → překryv s válcovou stěnou
        // (jinak se profil stěny jen tečně dotýká = čára nulové tloušťky)
        translate([full_r - eps, corner_z - groove_r]) square([groove_r + eps, groove_r]);
        translate([full_r + groove_r, corner_z - groove_r]) circle(r = groove_r);
    }
}

// 3D ekvivalent profilu pro rovnou nohu (+X strana): kvádr v rohu mínus
// válec (osa podél Y) = vytlačený fillet_profile. Přesah 0.1 na obou koncích.
module fillet_leg() {
    difference() {
        translate([full_r, -eps, corner_z - groove_r])
            cube([groove_r, leg_len + 2 * eps, groove_r]);
        translate([full_r + groove_r, -2 * eps, corner_z - groove_r])
            rotate([-90, 0, 0])
                cylinder(r = groove_r, h = leg_len + 4 * eps);
    }
}

// ---------------------------------------------------------------------
//  Průchozí otvor pro šroub ve středu kulaté části
//  Bez zaoblení - nepoužito pro maximální pevnost
// ---------------------------------------------------------------------
module screw_hole() {
    translate([0, 0, -eps])
        cylinder(h = thickness + 2 * eps, d = screw_d);
}


// =====================================================================
//  Render
// =====================================================================
podlozka();
