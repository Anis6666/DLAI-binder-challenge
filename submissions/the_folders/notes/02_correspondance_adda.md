# Correspondance des atomes d'Adda — table de référence

Remplace l'ancien `02_atoms_Adda.md` (qui n'était qu'un vidage brut de la
console PyMOL, sans traduction).

**Source :** `chem_comp_bond` du composant **1ZN** dans `1lcm.cif` —
la connectivité chimique officielle du PDB, pas une lecture visuelle.
**Établie le :** 2026-11-17

---

## Pourquoi cette table

Les noms d'atomes du PDB ne suivent **pas** la numérotation chimique d'Adda
(acide 3-amino-9-méthoxy-2,6,8-triméthyl-10-phényldéca-4,6-diénoïque).
Sans cette traduction, impossible d'écrire une carte d'enfouissement correcte
pour RF3.

> ⚠️ **Le piège.** Dans le résidu 5, les atomes PDB `C4`…`C9` sont le
> **cycle phényle**. Les carbones 4 à 9 de la chaîne chimique portent des
> noms PDB complètement différents. Toute sélection doit être préfixée
> par `resi 5`.

---

## Table complète (23 atomes)

| Nom PDB | Position chimique | Segment | Nature |
|---|---|---|---|
| `N` | amine (sur C3) | Proximal | liaison amide → D-MeAsp3 |
| `CA` | **C3** | Proximal | porte l'amine |
| `C18` | **C2** | Proximal | porte un méthyle |
| `C19` | méthyle en C2 | Proximal | apolaire |
| `C` | **C1** | Proximal | carboxyle → amide vers D-Glu6 |
| `O` | O du carbonyle | Proximal | accepteur |
| `C16` | **C4** | Diène | `C16=C15` |
| `C15` | **C5** | Diène | |
| `C13` | **C6** | Diène | `C13=C12`, porte un méthyle |
| `C14` | méthyle en C6 | Diène | apolaire |
| `C12` | **C7** | Diène | |
| `C10` | **C8** | Distal | porte un méthyle |
| `C11` | méthyle en C8 | Distal | apolaire |
| `C2` | **C9** | Distal | porte le méthoxy |
| `O1` | O du méthoxy | Distal | **accepteur de liaison H, non chargé** |
| `C1` | méthyle du méthoxy | Distal | apolaire |
| `C3` | **C10** | Distal | porte le phényle |
| `C4` | phényle | Distal | aromatique |
| `C5` | phényle | Distal | aromatique |
| `C6` | phényle | Distal | aromatique |
| `C7` | phényle | Distal | aromatique |
| `C8` | phényle | Distal | aromatique |
| `C9` | phényle | Distal | aromatique |

Contrôle : 6 (proximal) + 5 (diène) + 12 (distal) = **23 atomes**.

---

## Sélections prêtes à l'emploi

### PyMOL

```python
select prox,    resi 5 and name C+O+C18+C19+CA+N
select diene,   resi 5 and name C16+C15+C13+C14+C12
select distal,  resi 5 and name C10+C11+C2+O1+C1+C3+C4+C5+C6+C7+C8+C9
select phenyl,  resi 5 and name C4+C5+C6+C7+C8+C9
select methoxy, resi 5 and name O1+C1
```

### Listes d'atomes pour RF3

Le ligand est **`1ZN`** (code à 3 lettres à passer en argument `ligand`).

| Groupe | Atomes |
|---|---|
| Proximal | `N, CA, C18, C19, C, O` |
| Diène | `C16, C15, C13, C14, C12` |
| Distal | `C10, C11, C2, O1, C1, C3, C4, C5, C6, C7, C8, C9` |
| Phényle seul | `C4, C5, C6, C7, C8, C9` |
| Méthoxy (accepteur H) | `O1, C1` |

---

## Les autres groupes fonctionnels de la cible

| Groupe | Résidu | Atomes | Rôle dans le design |
|---|---|---|---|
| COO⁻ libre du D-Glu6 | `FGA` resi 6 | `C`, `O` (`OXT` absent de 1LCM) | charge conservée, contact polaire visé |
| COO⁻ libre du D-MeAsp3 | `ACB` resi 3 | `C`, `O`, `OXT` | charge conservée, contact polaire visé |
| Carbone électrophile | `DAM` resi 7 | `CB` | **zone interdite aux cystéines** |

> Les deux résidus carboxylés sont liés au macrocycle **par leur chaîne
> latérale** (`ACB CG → ARG N`, `FGA CD → DAM N`). Leur α-carboxyle est donc
> libre. Ne pas viser `OE1` ni `OD1`/`OD2` : ce sont des oxygènes d'amide
> internes au cycle, pas les charges.

---

## Squelette de configuration RF3

À compléter une fois les trois cartes d'enfouissement arrêtées. L'assignation
enfoui/exposé est une **décision de design** (voir l'analyse de la face Adda),
pas une donnée structurale.

```json
{
  "design_1_gouttiere": {
    "input": "./mclr_ligand.pdb",
    "ligand": "1ZN",
    "length": "__-__",
    "select_buried":  { "1ZN": "" },
    "select_exposed": { "1ZN": "" },
    "select_hbond_acceptor": { "1ZN": "O1" }
  }
}
```

> **Garde-fou à ne pas oublier.** RF3 construit la protéine autour d'un ligand
> déjà posé, sans raison de ménager un chemin d'entrée. Il faut donc
> (a) déclarer explicitement des atomes en `select_exposed`, et
> (b) rejeter en aval tout design dont la SASA du ligand dans le complexe est
> strictement nulle — un ligand encapsulé sans issue passe toutes les
> métriques standard sans être chargeable.
