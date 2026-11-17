# Inventaire structural de la cible — microcystine-LR

**Structure :** PDB 1LCM — « NMR minimized average structure of microcystin-LR »
**Méthode :** RMN en solution, modèle moyen minimisé (1 seul conformère)
**Organisme :** *Microcystis aeruginosa*
**Masse :** 1.01 kDa · 7 résidus · chaîne A
**Référence :** Trogen et al., *Biochemistry* 1996, 35:3197-3205
**Consulté le :** 2026-10-10 · **Révisé le :** 2026-11-17
**Script de génération :** `01_contexte_cible.pml`

> **Choix de structure — à trancher.** 1LCM est la toxine **libre**, non
> complexée. 1FJM est la toxine en conformation **liée** à PP1.
> `RATIONALE.md` annonce actuellement l'usage de la pose de 1FJM, alors que
> cet inventaire est bâti sur 1LCM. Les deux sont défendables, mais la
> décision doit être unique et justifiée (critère de notation
> « method justification »). Mesures d'enfouissement sur 1FJM :
> `02_enfouissement_pp1.pml`.

---

## Les sept positions

| # | Code PDB | Nom réel | Conservation | Caractère chimique |
|---|----------|----------|--------------|--------------------|
| 1 | `DAL` | D-Alanine | Conservé | Petit, neutre |
| 2 | `LEU` | Leucine | **Variable** | Hydrophobe — le « L » de LR |
| 3 | `ACB` | D-MeAsp (β-méthyl-aspartate) | Conservé | Carboxylate (−) |
| 4 | `ARG` | Arginine | **Variable** | Chargé (+) — le « R » de LR |
| 5 | `1ZN` | **Adda** (C20 H29 N O3) | Conservé | Très hydrophobe, phényle + diène |
| 6 | `FGA` | D-Glu (γ-glutamate) | Conservé | Carboxylate (−) |
| 7 | `DAM` | Mdha (N-méthyl-déhydroalanine) | Conservé | **Électrophile** |

Plus le squelette cyclique lui-même, conservé, en forme de selle.

**Note sur l'affichage PyMOL :** Leu et Arg apparaissent en code à 1 lettre
car ce sont des acides aminés standards ; les cinq autres sont des résidus
non standards affichés par leur code PDB à 3 caractères. Conséquence
technique importante : les cinq non standards sont des enregistrements
`HETATM`, que PyMOL exclut par défaut des calculs de surface (voir plus bas).

---

## Topologie des liaisons — quels carboxylates sont libres

Vérifié dans `struct_conn` du fichier `1lcm.cif` :

| Liaison | Conséquence |
|---|---|
| `ACB 3 CG → ARG 4 N` | Le D-MeAsp est relié au cycle **par sa chaîne latérale** |
| `FGA 6 CD → DAM 7 N` | Le D-Glu est relié au cycle **par sa chaîne latérale** |

Les deux résidus sont donc en liaison **iso-peptidique**, ce qui laisse leur
**α-carboxyle libre**. Les atomes porteurs de la charge négative visée par le
design sont :

| Groupe | Atomes | À ne pas confondre avec |
|---|---|---|
| COO⁻ du D-Glu6 | `C`, `O` (`OXT` non modélisé dans 1LCM) | `CD`/`OE1` = amide vers le Mdha |
| COO⁻ du D-MeAsp3 | `C`, `O`, `OXT` | `CG`/`OD2` = amide vers l'Arg |

Cohérent avec le brief de l'édition, qui parle explicitement du
**« D-Glu α-carboxyl »**.

---

## Correspondance des atomes d'Adda (composant 1ZN)

Établie à partir de `chem_comp_bond` du `.cif` (connectivité officielle),
et non d'une lecture visuelle.

| Segment | Position chimique | Nom PDB (dans `resi 5`) |
|---|---|---|
| **Proximal** | C1 (carboxyle → D-Glu6) | `C` (+ `O`) |
| | C2 + méthyle | `C18` + `C19` |
| | C3 (porte l'amine → D-MeAsp3) | `CA` (+ `N`) |
| **Médian (diène)** | C4=C5 | `C16`, `C15` |
| | C6 + méthyle | `C13` + `C14` |
| | C7 | `C12` |
| **Distal** | C8 + méthyle | `C10` + `C11` |
| | C9 + méthoxy | `C2` + `O1`(O) `C1`(méthyle) |
| | C10 (porte le phényle) | `C3` |
| | cycle phényle | `C4 C5 C6 C7 C8 C9` |

Doubles liaisons du diène : `C16=C15` et `C13=C12`.

> ⚠️ **Piège de nommage.** Dans le résidu 5, les atomes PDB `C4`…`C9` sont le
> **cycle phényle**, pas les carbones 4 à 9 de la chaîne. Toujours préfixer
> les sélections par `resi 5`.

**Atome électrophile du Mdha :** `DAM 7 CB` (le méthylène exocyclique du
couple CA=CB). C'est l'atome dont aucune cystéine ne doit s'approcher.

---

## Données de la littérature (Trogen et al. 1996)

- L'anneau peptidique adopte une **forme en selle**, essentiellement identique
  en solution aqueuse et dans le DMSO/eau.
- La chaîne latérale de l'**Arg est très flexible**.
- La chaîne latérale de la **Leu est bien définie**.
- La chaîne latérale d'**Adda**, essentielle à la toxicité, est **contrainte
  près du squelette mais flexible dans sa partie distale**.
- Le segment Mdha–Ala–Leu est absent de la nodularine.

---

## Mesures géométriques (centroïdes, Å)

| Paire | Distance |
|-------|----------|
| Adda – D-Glu | 10.7 |
| Adda – D-MeAsp | 9.5 |
| Adda – Leu (variable) | 13.3 |
| Adda – Arg (variable) | 7.2 |
| Leu – Arg | 10.2 |

> Ces valeurs sont des distances **centroïde de résidu à centroïde de résidu**.
> Le centroïde d'Adda est tiré par sa longue queue : ces chiffres ne donnent
> donc pas la portée que doit couvrir la gouttière. La mesure pertinente est
> **phényle → α-carboxyle**, ajoutée au script corrigé.

## Portée de la gouttière (Å) — *à remplir après relance du script*

| Paire | Distance |
|-------|----------|
| Phényle – COO⁻(D-Glu6) | _______ |
| Phényle – COO⁻(D-MeAsp3) | _______ |
| COO⁻(Glu) – COO⁻(MeAsp) | _______ |

---

## Surface accessible au solvant (Å²) — *à remplir après relance du script*

> ⚠️ **Les valeurs de la v1 de ce document étaient fausses et ont été retirées.**
> Elles donnaient Adda = 0 Å² et carboxylates = 0 Å², avec
> « molécule entière » = « positions variables » = 662 Å².
>
> **Cause :** PyMOL applique automatiquement le flag `ignore` aux
> enregistrements `HETATM`, et `get_area` exclut les atomes portant ce flag.
> Seuls Leu et Arg étant des `ATOM`, le script ne mesurait qu'eux — et les
> comptait deux fois.
>
> **Correctif :** `flag ignore, all, clear` avant toute mesure (présent dans
> la v2 du script), plus `remove hydro` pour des valeurs sur atomes lourds.

| Élément | SASA |
|---------|------|
| Molécule entière | _______ |
| Adda (total) | _______ |
| Carboxylates libres | _______ |
| Positions variables (Leu + Arg) | _______ |

### SASA par segment d'Adda (Å²)

| Segment | Total | Apolaire (C seuls) |
|---------|-------|--------------------|
| Proximal | _______ | _______ |
| Diène | _______ | _______ |
| Distal | _______ | _______ |
| — dont phényle | _______ | — |
| — dont méthoxy | _______ | — |

**Contrôle de cohérence :** si « molécule entière » vaut exactement
« positions variables », le flag n'a pas été levé et le calcul est encore
faux. Adda doit être de loin le premier contributeur.

---

## Contraintes du brief à garder en vue

- Poche enfouie et complémentaire ; reporter shape complementarity et buried SASA
- Aucune cystéine près du ligand (le Mdha réagit avec les thiols) — atome de
  référence : `DAM 7 CB`
- Stable et soluble en *E. coli*, sans pont disulfure
- Laisser un site pour la sortie de signal ou un split
- Affinité visée ≈ 1 nM (valeur guide OMS 1 µg/L, M ≈ 995 Da)

---

## Statut

Inventaire factuel révisé. **Face ciblée : décidée le 2026-11-02** — face
conservée, ancrage principal sur Adda, contacts complémentaires sur le
D-Glu et le squelette cyclique (voir `RATIONALE.md`).

**Reste à mesurer :**
1. Relancer `01_contexte_cible.pml` corrigé → SASA et portées réelles.
2. Lancer `02_enfouissement_pp1.pml` → ce que PP1 enfouit réellement.
3. Mobilité du segment distal sur **1AY3** (nodularine, 27 conformères) —
   désigné comme le critère le plus discriminant de l'arbitrage.
