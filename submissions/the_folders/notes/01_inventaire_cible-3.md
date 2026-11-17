# Inventaire structural de la cible — microcystine-LR

**Équipe :** the-folders
**Dernière mesure :** 2026-11-17 · **Scripts :** `01_contexte_cible.pml`, `02_enfouissement_pp1.pml`, `03_visu_enfouissement.pml`

> **Ce document contient toutes les mesures. Elles n'ont pas à être refaites.**
> Si un chiffre est contesté, relancer le script nommé en regard plutôt que
> d'improviser une nouvelle mesure.

## Structures utilisées

| PDB | Rôle | Méthode |
|---|---|---|
| **1FJM** | **Structure de design** (pose liée, entrée RF3) | Rayons X, 2,1 Å, complexe PP1 + MC-LR |
| 1LCM | Référence de la forme libre + données de flexibilité | RMN, moyenne minimisée, 1 conformère |

**Décision (2026-11-17) : 1FJM est la structure de design.** Notre mode de
liaison reproduit celui de PP1 (gouttière hydrophobe le long d'Adda + contacts
polaires sur le bord conservé) ; la conformation pertinente est donc celle
qu'Adda adopte *dans* une gouttière. 1LCM reste la source des données de
flexibilité (Trogen et al., *Biochemistry* 1996, 35:3197-3205).

Fichier d'entrée RF3 : `mclr_ligand_1fjm.pdb` (chaîne M de 1FJM, 70 atomes lourds, 7 résidus).

---

## Les sept positions

| # | Code PDB | Nom réel | Conservation | Caractère chimique |
|---|----------|----------|--------------|--------------------|
| 1 | `DAL` | D-Alanine | Conservé | Petit, neutre |
| 2 | `LEU` | Leucine | **Variable** | Hydrophobe — le « L » de LR |
| 3 | `ACB` | D-MeAsp | Conservé | Carboxylate (−) |
| 4 | `ARG` | Arginine | **Variable** | Chargé (+) — le « R » de LR |
| 5 | `1ZN` | **Adda** (C20 H29 N O3) | Conservé | Très hydrophobe, phényle + diène |
| 6 | `FGA` | D-Glu | Conservé | Carboxylate (−) |
| 7 | `DAM` | Mdha | Conservé | **Électrophile** |

Les cinq résidus non standards sont des `HETATM` : PyMOL les exclut par défaut
des calculs de surface. **`flag ignore, all, clear` est obligatoire** avant
toute mesure de SASA (c'est l'erreur de la v1 de ce document).

---

## Groupes fonctionnels — atomes vérifiés

Topologie établie depuis `struct_conn` du `.cif` : `ACB CG → ARG N` et
`FGA CD → DAM N`. Les deux résidus carboxylés sont liés au macrocycle **par
leur chaîne latérale**, ce qui laisse leur **α-carboxyle libre**.

| Groupe | Atomes | À ne pas confondre avec |
|---|---|---|
| COO⁻ libre du D-Glu6 | `resi 6` : `C`, `O` | `CD`/`OE1` = amide vers le Mdha |
| COO⁻ libre du D-MeAsp3 | `resi 3` : `C`, `O`, `OXT` | `CG`/`OD2` = amide vers l'Arg |
| Carbone électrophile | `resi 7` : `CB` | **zone interdite aux cystéines** |

## Correspondance des atomes d'Adda (composant 1ZN)

Depuis `chem_comp_bond` du `.cif`.

| Segment | Position chimique | Nom PDB (dans `resi 5`) |
|---|---|---|
| **Proximal** | C1 (carboxyle → D-Glu6) | `C` (+ `O`) |
| | C2 + méthyle | `C18` + `C19` |
| | C3 (porte l'amine) | `CA` (+ `N`) |
| **Diène** | C4=C5 | `C16`, `C15` |
| | C6 + méthyle | `C13` + `C14` |
| | C7 | `C12` |
| **Distal** | C8 + méthyle | `C10` + `C11` |
| | C9 + méthoxy | `C2` + `O1`(O) `C1`(méthyle) |
| | C10 (porte le phényle) | `C3` |
| | cycle phényle | `C4 C5 C6 C7 C8 C9` |

> ⚠️ Dans `resi 5`, les atomes PDB `C4`…`C9` sont le **cycle phényle**.
> Toujours préfixer les sélections par `resi 5`.

---

# MESURES

## A. Géométrie — distances entre centroïdes (Å, 1LCM, atomes lourds)

| Paire | Distance |
|-------|----------|
| Adda – D-Glu | 10,7 |
| Adda – D-MeAsp | 9,0 |
| Adda – Leu (variable) | 12,9 |
| Adda – Arg (variable) | 7,0 |
| Leu – Arg | 9,3 |

> Valeurs recalculées sur atomes lourds (la v1 incluait les hydrogènes, d'où
> de légers écarts). Le centroïde d'Adda est tiré par sa queue : ces chiffres
> ne donnent pas la portée de la gouttière — voir ci-dessous.

## B. Portée de la gouttière (Å) — la mesure qui compte

| Paire | Distance |
|-------|----------|
| **Phényle – COO⁻(D-Glu6)** | **15,4** |
| Phényle – COO⁻(D-MeAsp3) | 13,1 |
| COO⁻(Glu) – COO⁻(MeAsp) | 6,2 |

**15,4 Å** est la longueur que le binder doit couvrir pour tenir l'ancre
hydrophobe **et** un contact polaire conservé.

## C. Surface accessible, toxine libre (Å², 1LCM, atomes lourds)

| Élément | SASA |
|---------|------|
| Molécule entière | **1207** |
| Adda (total) | **436** |
| Carboxylates libres | 110 |
| Positions variables (Leu + Arg) | 354 |

*Contrôle : 1207 ≠ 354 → le flag `ignore` est bien levé. Somme des trois
segments = 436 = Adda mesurée directement → partition exacte.*

### SASA par segment d'Adda

| Segment | Total | Apolaire (C) |
|---------|-------|--------------|
| Proximal | 76 | 50 |
| Diène | 73 | **73** |
| Distal | **287** | **286** |
| — dont phényle | 156 | — |
| — dont méthoxy | 57 | — |

**Adda apolaire totale = 50 + 73 + 286 = 409 Å².**

Le diène est intégralement apolaire, le distal quasi intégralement. Confrontation
aux estimations de l'analyse d'Adda : option A estimée 250–300 → **mesuré 287** ✓ ;
option C estimée 400–450 → **mesuré 436** ✓ ; option B estimée « moitié apolaire »
→ **mesuré 50 Å² apolaires sur 186, soit 27 %** ✗ (B est plus faible qu'estimé).

## D. Enfouissement par la PP1 (Å², 1FJM) — « la réponse de la nature »

| | libre | complexe | enfoui | % |
|---|---|---|---|---|
| Proximal | 77 | 3 | 74 | **96 %** |
| Diène | 88 | 40 | 48 | 54 % |
| Distal | 289 | 84 | **205** | 71 % |
| — dont phényle | 151 | 19 | 132 | **87 %** |
| — dont méthoxy | 63 | 25 | 38 | 60 % |
| COO⁻ D-Glu6 | 65 | 4 | 61 | **94 %** |
| COO⁻ D-MeAsp3 | 45 | 15 | 29 | 66 % |
| **Toxine entière** | **1176** | **493** | **683** | **58 %** |

Adda enfouie par PP1 : 74 + 48 + 205 = **327 Å² sur 454, soit 72 %**.

**Trois enseignements :**
1. **PP1 ne ferme pas sa poche** : elle laisse **493 Å² accessibles** (42 %).
   Une poche naturelle à très haute affinité reste largement ouverte.
2. **Le D-Glu est le bon carboxylate** : enfoui à 94 %, contre 66 % pour le
   D-MeAsp.
3. En relatif le proximal domine (96 %), mais **en absolu c'est le distal**
   qui apporte 205 des 327 Å² enfouis.

## E. Les 15 atomes les plus enfouis par la PP1

| Å² | resi | resn | atome | Traduction |
|---|---|---|---|---|
| 49,7 | 2 | LEU | CD1 | ⚠️ position **variable** |
| 45,2 | 5 | 1ZN | C19 | méthyle en C2 (proximal) |
| 44,3 | 7 | DAM | CB | ⚠️ **carbone électrophile** |
| 43,0 | 5 | 1ZN | C1 | méthyle du méthoxy (distal) |
| 41,2 | 6 | FGA | O | carboxylate du D-Glu |
| 38,2 | 5 | 1ZN | C11 | méthyle en C8 (distal) |
| 38,2 | 7 | DAM | CM | ⚠️ N-méthyle du Mdha |
| 34,8 | 5 | 1ZN | C7 | phényle |
| 32,8 | 5 | 1ZN | C8 | phényle |
| 31,1 | 2 | LEU | CD2 | ⚠️ position **variable** |
| 30,2 | 5 | 1ZN | C6 | phényle |
| 29,9 | 5 | 1ZN | C14 | méthyle en C6 (diène) |
| 27,0 | 7 | DAM | O | ⚠️ Mdha |
| 25,1 | 5 | 1ZN | O | carbonyle d'Adda (jonction) |
| 24,9 | 4 | ARG | O | position variable |

> ⚠️ **Cette liste ne se recopie pas telle quelle.** Elle contient deux pièges
> qui correspondent exactement à ce que notre stratégie refuse : les chaînes
> latérales de la **Leucine variable** (#1 et #10), et le **carbone électrophile
> du Mdha** (#3) que PP1 enterre parce qu'elle s'y lie de façon covalente.
>
> **Graine utilisable après filtrage (sur Adda) :**
> `1ZN : C19, C1, C11, C7, C8, C6, C14` — soit les méthyles et le phényle.

## F. Bilan énergétique avec les chiffres mesurés

Coefficient 25–30 cal/mol/Å² d'enfouissement apolaire :

Pénalité entropique prise **au plafond (≈ 4 kcal/mol)** : la mesure de mobilité
(section G) montre une queue distale qui explore plusieurs ångströms, donc un
coût de mise en ordre élevé.

| | Surface apolaire | Brut (kcal/mol) | − entropie | Net |
|---|---|---|---|---|
| Proximal + diène | 123 | 3,1 – 3,7 | ~0 | **3,1 – 3,7** |
| Distal seul (A) | 286 | 7,2 – 8,6 | ≈ 4 | **3,2 – 4,6** |
| Toute la longueur (C) | 409 | 10,2 – 12,3 | ≈ 4 | **6,2 – 8,3** |
| Proximal + bord (B) | 50 | 1,3 – 1,5 | ~0 | 1,3 – 1,5 |

Cible : **−12,3 kcal/mol** (K_d ≈ 1 nM).

**Deux conclusions :**

1. **Même la gouttière complète ne boucle pas le budget sur la seule surface.**
   Le contact polaire n'est pas un ornement de spécificité, il est **porteur**.
   Ce qui renforce le choix du D-Glu, celui que PP1 enfouit à 94 %.
2. **Le distal rapporte à peine plus que le proximal + diène réunis, alors
   qu'il porte 2,3 fois plus de surface** — toute sa recette passe dans
   l'entropie. Résultat contre-intuitif qui revalorise nettement les cartes
   courtes.

*(Barres d'erreur larges sur les coefficients — facilement un facteur deux.
Ces chiffres servent à comparer les options, pas à prédire une affinité.)*

---

## Seuils dérivables de ces mesures

| Seuil | Valeur proposée | Justification mesurée |
|---|---|---|
| `Ligand SASA in complex` | ≥ 200–250 Å² | PP1 en laisse 493 (42 %) |
| `Adda buried fraction` | ≥ 70 % | PP1 enfouit 72 % d'Adda |
| Contact COO⁻ D-Glu | ≥ 1 liaison H / pont salin | PP1 l'enfouit à 94 % |
| Longueur du binder | justifiée par 15,4 Å de portée | mesure directe |

---

## Contraintes du brief

- Poche enfouie et complémentaire ; reporter shape complementarity et buried SASA
- Aucune cystéine près du ligand — atome de référence : `resi 7` / `CB`
- Stable et soluble en *E. coli*, sans pont disulfure
- Laisser un site pour la sortie de signal ou un split
- Affinité visée ≈ 1 nM

## G. Mobilité conformationnelle d'Adda (1AY3, 27 conformères)

Nodularine : cyclo(ACB – ARG – **MFD = Adda** – FGA – MDH). L'Adda y fait
23 atomes, comme le 1ZN de la microcystine, et ses noms suivent directement
la numérotation chimique (plus lisibles que ceux de 1ZN).

Superposition des 27 états sur le squelette peptidique (RMSD 0,09–0,44 Å :
le macrocycle se superpose très bien, la dispersion mesurée est donc réelle).

### RMSF moyen par résidu (Å)

| resi | resn | RMSF |
|---|---|---|
| 1 | ACB (D-MeAsp) | 0,33 |
| 2 | ARG | **1,42** |
| 3 | MFD (**Adda**) | **2,53** |
| 4 | FGA (D-Glu) | 0,22 |
| 5 | MDH (Mdhb) | 0,09 |

> **Validation de la méthode :** ces chiffres reproduisent quantitativement
> Trogen 1996 — Arg très flexible, macrocycle rigide, Adda contrainte à la
> base et flexible en distal.

### Le gradient le long d'Adda

| Segment | Atomes (noms MFD) | RMSF | Moyenne |
|---|---|---|---|
| **Proximal** | `C, C1, CM2, CA, N, O` | 0,04 – 0,12 | **0,09** |
| **Diène** | `C4, C5, C6, CM6, C7` | 0,19 – 1,02 | **0,47** |
| **Distal** | `C8, CM8, C9, O9, CM9, C', C1'–C6'` | 1,52 – **7,62** | **4,61** |

**Facteur 50 entre le proximal et le distal.** Le phényle seul : 4,9 à 7,6 Å.
Rapport mobile/rigide global : **12,1×**.

### Ce que cette mesure tranche

1. **Le diène est entropiquement gratuit** (0,47 Å, quasi aussi rigide que le
   proximal) : 73 Å² de surface 100 % apolaire sans coût de mise en ordre.
   Meilleur rapport gain/coût de la molécule.
2. **L'entropie du distal est au plafond** de la fourchette (≈ 4 kcal/mol),
   d'où la révision du bilan en section F.
3. **Aucune pose d'entrée n'a de sens dans le distal.** Justifie
   `select_fixed_atoms` vide et le choix d'un générateur qui échantillonne
   la conformation du ligand (RF3 plutôt que RFdiffusionAA).
4. **Risque identifié pour la carte d1 :** elle veut tenir le phényle *et* le
   carboxylate du D-Glu simultanément, soit deux ancres aux extrémités d'une
   charnière molle. La portée de 15,4 Å vaut pour un seul conformère.

### Réserves

- **Effet de bras de levier** : le phényle est au bout d'une longue chaîne,
  une petite rotation à la base le déplace beaucoup. Dispersion réelle,
  magnitude à manier avec prudence.
- Un ensemble RMN peut surestimer le désordre là où les contraintes
  expérimentales sont rares.
- La nodularine n'a pas le segment Mdha–Ala–Leu de la microcystine ; l'Adda
  est chimiquement identique, son environnement de cycle diffère un peu.

## H. Distribution de la portée sur l'ensemble (1AY3, 27 conformères)

Script : `05_portee_ensemble_1ay3.pml`

| | min | max | moyenne | écart-type | amplitude |
|---|---|---|---|---|---|
| Phényle – COO(D-Glu) | 10,7 | 14,8 | **12,7** | **1,1** | 4,1 |
| Phényle – COO(D-MeAsp) | 4,7 | 11,9 | 8,8 | **2,6** | 7,2 |
| COO(Glu) – COO(MeAsp) *(contrôle interne)* | 7,2 | 8,6 | 7,7 | **0,3** | 1,4 |

**Le contrôle interne valide la mesure :** les deux carboxylates, portés par le
macrocycle rigide, gardent une distance quasi constante (σ = 0,3 Å) pendant que
les portées impliquant le phényle varient 4 à 9 fois plus. La variation vient
donc bien de la queue, pas d'un bruit global.

### Trois résultats

1. **La portée phényle→D-Glu est bien plus stable que le RMSF ne le laissait
   craindre** : σ = 1,1 Å seulement, pour des atomes de phényle à 7,6 Å de
   RMSF individuel. Le mouvement de la queue est largement un balancement qui
   conserve la distance mieux qu'il ne conserve la position, et le centroïde
   du cycle moyenne les excursions individuelles. **Le risque géométrique
   identifié pour d1 est donc réel mais modéré**, pas rédhibitoire.
2. **Le D-Glu est géométriquement le meilleur partenaire** : σ = 1,1 Å contre
   **2,6 Å** pour le D-MeAsp, soit une portée 2,4 fois moins variable. C'est
   un troisième argument indépendant en sa faveur, après l'enfouissement à
   94 % par PP1 et la mention explicite du brief.
3. **La géométrie visée par d3 est en béton** : contacter les deux
   carboxylates, c'est viser une distance de 7,7 ± 0,3 Å. Aucune incertitude
   conformationnelle. Argument de fiabilité de plus pour cette carte.

### Seuil de filtrage dérivé

Plage observée 10,7 – 14,8 Å ; moyenne ± 2σ = 10,5 – 14,9 Å. Les deux
convergent :

> **Rejeter tout design dont la pose du ligand implique une portée
> phényle→COO(D-Glu) hors de ~10,5 – 15 Å.** Au-delà, la poche est
> complémentaire d'une géométrie que la molécule ne visite pas, et aucune
> métrique standard ne le signale.

### Réserves

- Mesuré sur la **nodularine**, pas la microcystine (seul ensemble multi-
  conformères disponible). Les valeurs absolues peuvent se décaler de ~1 Å ;
  la dispersion relative, elle, transfère.
- Le groupe « phényle » du script inclut `C'` (le carbone benzylique), soit
  7 atomes au lieu de 6. Le centroïde est donc légèrement tiré vers la chaîne
  et les distances absolues un peu raccourcies. **Sans effet sur les
  écarts-types**, qui portent toute la conclusion.
- Pour mémoire, la portée mesurée sur 1LCM (microcystine, un conformère,
  phényle à 6 atomes) était de 15,4 Å — cohérent avec le haut de cette plage
  une fois les deux biais ci-dessus pris en compte.

**Toutes les mesures du projet sont faites.**
