OpenSCAD projekt – držáky dřevěného profilu pro vestavbu.

Rozměry a odvozené hodnoty jsou parametry na začátku každého `.scad` souboru. Sem patří jen účel a záměry, které z kódu nejsou na první pohled zřejmé.

## Přední držák

Soubor: `vestavba-drzak-predni.scad`

Účel: nasouvací držák na vodorovný dřevěný profil (vyšší stranou nahoru). Jazýček zapadne do vodorovného úzkém otvoru v automobilu (kterým se vysouvá bezpečnostní pás) a zajistí profil proti vysunutí.

Hlavní prvky a záměry:
- Průchozí obdélníkový tunel, otevřený na obou koncích (profil jím prochází).
- Jazýček (háček) na horní straně míří ven od těla a dolů do otvoru. Zaoblený je jen na svých dvou vnějších hranách, strana u těla zůstává ostrá.
- Horní základna rozšiřuje horní plochu do stran a drží profil na středu (proti překlápění). Je zapuštěná do horní stěny tunelu, aby nahoře nevznikala dvojitá tloušťka materiálu.
- Boční výztuhy: jen jedna šikmá deska na každé straně (úhlopříčka od hrany základny k patě tunelu), jejíž vnější hrana lícuje se základnou a nepřečnívá. Záměrně žádný plný ani dutý trojúhelník a žádné členy podél základny či tunelu.
- Volitelný otvor na šroubek skrz horní stěnu tunelu.

`is_poc = true` přepíná na mělčí zkušební variantu (pro rychlejší vytištění).

## Zadní držák

TODO later
