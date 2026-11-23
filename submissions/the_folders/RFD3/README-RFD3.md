# Dossier RFD3 — à quoi sert chaque fichier

Cible : microcystine-LR. Outil : RFdiffusion3, sur le cluster RCP de l'EPFL.

---

## La chaîne, en une ligne

```
mclr_lig_1fjm.pdb → mclr_unl.pdb → [gen_cif.py] → mclr_unl.cif → RFD3 → designs/
```

---

## Les fichiers de la toxine

| Fichier | À quoi ça sert |
|---|---|
| `mclr_lig_1fjm.pdb` | La microcystine telle qu'elle est dans la structure 1FJM, c'est-à-dire dans la pose qu'elle adopte quand elle est liée. C'est notre point de départ. |
| `mclr_unl.pdb` | Le même fichier, avec la toxine renommée. Le nom qu'on utilisait avant était déjà pris par une autre molécule dans les bases de données, ce qui faisait planter RFD3. |
| `mclr_unl.cif` | **Le fichier que RFD3 lit réellement.** Même molécule, mais dans un format qui précise la nature de chaque liaison chimique. Sans ça, le modèle ne comprend pas la molécule. |
| `mclr_lig_1lcm.pdb` | La toxine en forme libre, sans partenaire. Gardé comme référence, pas utilisé pour les designs. |

## Les outils

| Fichier | À quoi ça sert |
|---|---|
| `gen_cif.py` | Fabrique `mclr_unl.cif` à partir de `mclr_unl.pdb`. À relancer uniquement si on change le fichier de départ. |

## La configuration

| Fichier | À quoi ça sert |
|---|---|
| `mclr_d1.json` | Les instructions données à RFD3 : quelle molécule cibler, quelle longueur de binder, et surtout **quels atomes de la toxine enfouir et lesquels laisser exposés**. C'est le cœur de notre stratégie de design. |

## Les résultats

| Fichier | À quoi ça sert |
|---|---|
| `designs/d1_run1.cif.gz` | Premier binder produit. Obtenu avant qu'on corrige la description chimique de la toxine — gardé pour comparaison. |
| `designs/d1_run2.cif.gz` | Deuxième binder, sur une chimie correcte. Enfouit 81 % de la surface de la toxine. |

---

## Ce qu'il faut retenir

Un design RFdiffusion est un **squelette** : la forme de la protéine, sans
séquence d'acides aminés. L'attribution des acides aminés vient ensuite, avec
LigandMPNN.

RFdiffusion est **aléatoire** : la même configuration relancée donne une
structure différente. Il faut donc une vingtaine de designs avant de pouvoir
conclure quoi que ce soit.

---

*Détail technique complet, pièges et messages d'erreur : voir
`rfd3-procedure-et-premier-design.md` dans le dossier projet.*
