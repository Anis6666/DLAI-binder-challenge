# Cartes d'enfouissement — fiche de travail

Équipe the-folders · mesures du 2026-11-17 intégrées

Une carte d'enfouissement = **deux listes d'atomes** par design : enfouis
(`select_buried`) et exposés (`select_exposed`). Les atomes non listés sont
laissés libres au générateur.

> ⚠️ **Syntaxe RF3 à confirmer.** La microcystine est un peptide de 7 résidus
> (DAL, LEU, ACB, ARG, 1ZN, FGA, DAM), pas un ligand à code unique. La façon
> de la déclarer en entrée est **la première question à poser à Tuna quand le
> tutoriel sort**. Les listes ci-dessous n'en dépendent pas.

---

## Référence empirique — ce que PP1 enfouit (mesuré sur 1FJM)

| | libre | enfoui | % |
|---|---|---|---|
| Proximal | 77 | 74 | **96 %** |
| Diène | 88 | 48 | 54 % |
| Distal | 289 | **205** | 71 % |
| — phényle | 151 | 132 | **87 %** |
| — méthoxy | 63 | 38 | 60 % |
| COO⁻ D-Glu6 | 65 | 61 | **94 %** |
| COO⁻ D-MeAsp3 | 45 | 29 | 66 % |

**SASA du ligand laissée accessible par PP1 : 493 Å² sur 1176 (42 %).**
→ plancher défendable pour le seuil `Ligand SASA in complex`.
**Adda enfouie par PP1 : 327 Å² sur 454, soit 72 %.**

### Les 15 atomes les plus enfouis — et pourquoi on ne les copie pas

| Å² | resi | atome | Statut |
|---|---|---|---|
| 49,7 | 2 LEU | CD1 | ❌ position variable |
| 45,2 | 5 1ZN | **C19** | ✅ méthyle en C2 |
| 44,3 | 7 DAM | CB | ❌ **carbone électrophile** |
| 43,0 | 5 1ZN | **C1** | ✅ méthyle du méthoxy |
| 41,2 | 6 FGA | O | ✅ carboxylate D-Glu (contact polaire) |
| 38,2 | 5 1ZN | **C11** | ✅ méthyle en C8 |
| 38,2 | 7 DAM | CM | ❌ Mdha |
| 34,8 | 5 1ZN | **C7** | ✅ phényle |
| 32,8 | 5 1ZN | **C8** | ✅ phényle |
| 31,1 | 2 LEU | CD2 | ❌ position variable |
| 30,2 | 5 1ZN | **C6** | ✅ phényle |
| 29,9 | 5 1ZN | **C14** | ✅ méthyle en C6 |
| 27,0 | 7 DAM | O | ❌ Mdha |
| 25,1 | 5 1ZN | O | ~ jonction vers le cycle |
| 24,9 | 4 ARG | O | ❌ position variable |

> La carte de la nature contient **deux pièges qui correspondent exactement à
> ce que notre stratégie refuse** : la Leucine variable (perte de couverture
> des congénères) et le carbone électrophile du Mdha (binder covalent,
> irréversible, inutilisable dans un capteur).

**Graine filtrée, utilisable telle quelle :**
```
1ZN : C19, C1, C11, C7, C8, C6, C14
```
Soit les **méthyles** (C19, C1, C11, C14) et le **phényle** (C7, C8, C6) :
les groupes qui dépassent et que la poche vient empaqueter.

---

## Rappel des segments (noms PDB dans `resi 5`)

| Segment | Atomes | SASA libre | dont apolaire |
|---|---|---|---|
| Proximal | `N, CA, C18, C19, C, O` | 76 | 50 |
| Diène | `C16, C15, C13, C14, C12` | 73 | 73 |
| Distal | `C10, C11, C2, O1, C1, C3, C4…C9` | 287 | 286 |
| — phényle | `C4, C5, C6, C7, C8, C9` | 156 | — |
| — méthoxy | `O1` (accepteur H), `C1` | 57 | — |

Carboxylates libres : `resi 6` → `C, O` · `resi 3` → `C, O, OXT`
Interdit aux cystéines : `resi 7` → `CB`
**Portée phényle → COO⁻(D-Glu) : 15,4 Å**

---

## d1 — Gouttière + contact polaire  *(rang 1)*

**Hypothèse :** l'affinité vient de la surface étendue, la spécificité d'un
seul contact directionnel.

| | Atomes |
|---|---|
| **Enfouis — graine PP1** | `C19, C1, C11, C7, C8, C6, C14` |
| **Enfouis — extension distale** | `C10, C2, C3, C4, C5, C9` |
| **Enfouis — diène** | `C16, C15, C13, C12` |
| **Enfouis — proximal apolaire** | `C18, CA` |
| **Accepteur H** | `O1` (méthoxy) |
| **Contact polaire** | `resi 6` : `C, O` (α-carboxyle du D-Glu) |
| **Exposés** | `resi 5` : `N, C, O` + macrocycle : `resi 1, 2, 4, 7` |

> La graine PP1 forme le cœur ; l'extension complète la gouttière sur toute la
> longueur. Le macrocycle laissé dehors, c'est la « quatrième face » : accès
> du ligand et place pour le rapporteur.
>
> **Budget :** 409 Å² apolaires → 10,2–12,3 kcal/mol bruts, moins ≈ 4 kcal/mol
> d'entropie (plafond, confirmé par la mesure de mobilité) = **net 6,2–8,3**.
> Ne boucle pas seul : le contact D-Glu est porteur, pas décoratif.
>
> ✅ **Risque géométrique mesuré, et il est modéré.** Malgré un RMSF du phényle
> à 7,6 Å, la *portée* phényle→COO(D-Glu) ne varie que de **12,7 ± 1,1 Å**
> (plage 10,7–14,8 sur les 27 conformères). Le balancement de la queue conserve
> la distance mieux que la position. Une poche dessinée autour de ~12,7 Å vise
> une géométrie que la molécule visite couramment.
>
> **Seuil associé :** rejeter les designs dont la pose du ligand implique une
> portée hors de ~10,5–15 Å.

---

## d2 — Poche distale  *(rang 2, option de repli)*

**Hypothèse :** la designabilité prime — enfouir un aromatique dans une cavité
hydrophobe est le cas le mieux établi de la littérature.

| | Atomes |
|---|---|
| **Enfouis** | `C10, C11, C2, C1, C3, C4, C5, C6, C7, C8, C9` |
| **Accepteur H** | `O1` |
| **Exposés** | diène + proximal + tout le macrocycle |

> Pas de contact carboxylate : assumé. **Budget : 286 Å² apolaires → brut
> 7,2–8,6, moins ≈ 4 d'entropie = net 3,2–4,6 kcal/mol**, soit du micromolaire.
> Cette carte teste l'ancre seule et sert de repli si les deux autres ne
> passent pas les filtres.

---

## d3 — Gouttière courte + deux contacts  *(rang 3)*

**Hypothèse :** la spécificité prime, avec assez de surface pour rester viable.

| | Atomes |
|---|---|
| **Enfouis — proximal** | `C18, C19, CA` |
| **Enfouis — diène** | `C16, C15, C13, C14, C12` |
| **Contacts polaires** | `resi 6` : `C, O` **et** `resi 3` : `C, O, OXT` |
| **Exposés** | distal partiellement : au minimum `C4…C9` (phényle) |

> ✅ **Géométrie la plus fiable des trois.** Les deux carboxylates sont distants
> de **7,7 ± 0,3 Å** sur les 27 conformères : aucune incertitude
> conformationnelle à absorber.

> C'est l'option B de l'analyse, corrigée de son défaut de surface par
> l'extension au diène. **Attention :** B seule n'offre que **50 Å² apolaires**
> (27 % de ses 186 Å²), bien moins que les « 50 % » estimés. Le diène
> (73 Å², 100 % apolaire) est indispensable à sa viabilité.
>
> ✅ **Cette carte a été revalorisée par la mesure de mobilité.** Proximal +
> diène = 123 Å² apolaires à coût entropique nul → **net 3,1–3,7 kcal/mol**,
> soit pratiquement autant que le distal seul (3,2–4,6) qui porte pourtant
> 2,3 fois plus de surface. Et sa géométrie est fiable : elle n'agrippe que
> la partie rigide de la molécule. Ce n'est plus l'option faible que
> l'analyse décrivait.

---

## Arbitrage — TRANCHÉ (2026-11-17)

Mesuré sur 1AY3 (27 conformères) : **la dispersion distale est large**.

| Segment | RMSF moyen |
|---|---|
| Proximal | 0,09 Å |
| Diène | 0,47 Å |
| **Distal** | **4,61 Å** (phényle jusqu'à 7,6) |

Facteur **50** entre les deux extrémités. Conséquences retenues :

1. **Garder d1 en gouttière longue.** Le distal reste la seule grosse surface
   apolaire disponible (286 des 409 Å²) ; s'en priver plafonne au micromolaire.
2. **Ne rien figer en distal** — aucune pose d'entrée n'y a de sens.
   `select_fixed_atoms` reste vide.
3. **Compter l'entropie au plafond** (≈ 4 kcal/mol), pas au plancher.
4. **d3 remonte dans l'estime** : surface quasi gratuite, géométrie fiable.

5. **Le D-Glu est confirmé comme le bon carboxylate**, pour la troisième fois
   et par un argument indépendant : la portée phényle→D-Glu varie 2,4 fois
   moins (σ 1,1 Å) que phényle→D-MeAsp (σ 2,6 Å).

**Toutes les mesures du projet sont faites.** Reste à verrouiller les seuils.

---

## Contrôle avant de lancer

- [ ] Chaque design a au moins un atome en `select_exposed`
- [ ] **Aucun atome de `resi 7` (Mdha) dans `select_buried`** — malgré le #3 de PP1
- [ ] Aucun atome de `resi 2` (Leu) ni `resi 4` (Arg) enfoui — positions variables
- [ ] `select_fixed_atoms` vide (décision : on ne fige pas le distal)
- [ ] Plage de longueur déclarée, cohérente avec les 15,4 Å de portée
- [ ] Les trois cartes diffèrent bien par la carte, pas par la face
