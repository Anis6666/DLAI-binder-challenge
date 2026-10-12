# Inventaire structural de la cible — microcystine-LR

**Structure :** PDB 1LCM — « NMR minimized average structure of microcystin-LR »
**Méthode :** RMN en solution, modèle moyen minimisé
**Organisme :** *Microcystis aeruginosa*
**Masse :** 1.01 kDa · 7 résidus · chaîne A
**Référence :** Trogen et al., *Biochemistry* 1996, 35:3197-3205
**Consulté le :** 2026-10-10
**Script de génération :** `01_contexte_cible.pml`

> Choix de structure : 1LCM est la toxine **libre**, non complexée. C'est la
> forme pertinente pour construire une poche autour de la molécule.

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
non standards affichés par leur code PDB à 3 caractères.

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

## Surface accessible au solvant (Å²)

| Élément | SASA |
|---------|------|
| Molécule entière | 662 |
| Adda | 0 |
| Carboxylates (D-Glu + D-MeAsp) | 0 |
| Positions variables (Leu + Arg) | 662 |

---

## Contraintes du brief à garder en vue

- Poche enfouie et complémentaire ; reporter shape complementarity et buried SASA
- Aucune cystéine près du ligand (le Mdha réagit avec les thiols)
- Stable et soluble en *E. coli*, sans pont disulfure
- Laisser un site pour la sortie de signal ou un split
- Affinité visée ≈ 1 nM (valeur guide OMS 1 µg/L, M ≈ 995 Da)

---

## Statut

Inventaire factuel. **Aucun choix de face n'est encore fait.**
Décision prévue : semaine du 20 octobre.