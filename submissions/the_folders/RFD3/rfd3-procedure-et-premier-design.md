# RFdiffusion3 — procédure de lancement, correctifs et premiers designs

**Équipe the-folders · GASPAR `aaakrout` · groupe `g13`**
**Première exécution réussie : 23.11.2026 · deux designs produits**

> Document technique. Pour le récit destiné à l'équipe, voir
> `point-equipe-2026-11-23.md`.
> **Rien ici n'est à redécouvrir.**

---

## 1. Les deux correctifs qui débloquent la microcystine

Aucun des deux n'est documenté nulle part. Ce sont les deux heures de débogage
de la soirée.

### 1.1 Le nom de résidu : `LIG` → `UNL`

**Symptôme :**
```
ValueError: Transforms failed at stage `CreateDesignReferenceFeatures`:
could not broadcast input array from shape (17,3) into shape (71,3)
```
précédé de `Atom C1 not found in conformer for residue LIG`.

**Cause :** RFD3 cherche une géométrie de référence dans le dictionnaire
chimique du PDB (la CCD). `LIG` **est un code CCD déjà attribué**, à une
molécule de 17 atomes. Notre résidu en a 71.

**Correctif :** un code inconnu de la CCD. `UNL` est explicitement prévu
(`atomworks/ml/transforms/af3_reference_molecule.py`, l. 293-306) :

```python
# ... generate conformers for CCD codes that are unknown (including UNL)
if not all(res_name in get_known_ccd_codes() for res_name in res_stoichiometry):
    conf_i, mol_i = sample_rdkit_conformer_for_atom_array(...)
```

Pour un code inconnu, atomworks construit la référence **avec RDKit à partir des
atomes du fichier fourni**.

### 1.2 Les ordres de liaison : PDB → CIF

**Symptôme :** des centaines de `Encountered BondType.ANY. Interpreting as
single bond.`, puis `Failed to generate 1 conformers for UNL. Falling back to
zeros.` Le run aboutit, mais sur une référence vide.

**Cause — attention, le piège :** notre PDB **contenait déjà des CONECT**. Le
problème n'est pas l'absence de liaisons mais l'absence de leur **ordre**. Le
format PDB ne sait pas dire « cette liaison est double ». Biotite, qu'utilise
atomworks, crée donc toutes les liaisons avec le type `ANY`, et RDKit ne peut
pas générer de conformère sans savoir où sont les doubles liaisons.

**Aucune retouche du PDB ne corrige ça.** Il faut un CIF avec une catégorie
`chem_comp_bond`.

### 1.3 Les trois erreurs successives du CIF

Écrire le CIF à la main échoue trois fois de suite. Dans l'ordre :

| Erreur | Cause | Remède |
|---|---|---|
| `KeyError: 'pdbx_PDB_model_num'` | colonne manquante dans `atom_site` | — |
| `KeyError: 'pdbx_PDB_ins_code'` | encore une autre colonne manquante | — |
| `KeyError: 9` dans `BIOTITE_BOND_TYPE_TO_RDKIT` | type 9 = `AROMATIC` générique, **inconnu d'atomworks** | alterner `SING`/`DOUB` sur le cycle avec le drapeau aromatique `Y`, ce qui donne les types 5 et 6 qu'il connaît |

**La leçon :** ne pas écrire `atom_site` à la main. Laisser **biotite** l'écrire
(`set_structure`), et n'ajouter à la main que le bloc `chem_comp_bond`.

---

## 2. Le script générateur du CIF

À lancer dans le conteneur. Lit `mclr_unl.pdb`, écrit `mclr_unl.cif`.

```python
from biotite.structure.io.pdb import PDBFile
from biotite.structure.io.pdbx import CIFFile, set_structure
src = "/scratch/aaakrout/mclr/mclr_unl.pdb"
dst = "/scratch/aaakrout/mclr/mclr_unl.cif"
arr = PDBFile.read(src).get_structure(model=1, include_bonds=True)
arr.res_name[:] = "UNL"
arr.hetero[:] = True
f = CIFFile()
set_structure(f, arr)          # atom_site ecrit par biotite -> toutes les colonnes
f.write(dst)
DOUB = [("C3","O1"),("C5","O2"),("C10","O3"),("C13","O5"),("C16","O6"),("C20","N6"),
        ("C32","C33"),("C35","C36"),("C40","O8"),("C42","O9"),("C45","O10"),
        ("C47","C48"),("C49","O11")]
RING = {("C24","C25"):"DOUB", ("C25","C26"):"SING", ("C26","C27"):"DOUB",
        ("C27","C28"):"SING", ("C28","C29"):"DOUB", ("C24","C29"):"SING"}
D = {frozenset(p) for p in DOUB}
R = {frozenset(k): v for k, v in RING.items()}
nm = arr.atom_name
lines = ["#", "loop_", "_chem_comp_bond.comp_id", "_chem_comp_bond.atom_id_1",
         "_chem_comp_bond.atom_id_2", "_chem_comp_bond.value_order",
         "_chem_comp_bond.pdbx_aromatic_flag", "_chem_comp_bond.pdbx_stereo_config"]
nd = na = 0
for i, j, _t in arr.bonds.as_array():
    k = frozenset((nm[i], nm[j]))
    if k in R:   v, fl = R[k], "Y"; na += 1
    elif k in D: v, fl = "DOUB", "N"; nd += 1
    else:        v, fl = "SING", "N"
    lines.append("UNL %-4s %-4s %s %s N" % (nm[i], nm[j], v, fl))
lines.append("#")
txt = open(dst).read().rstrip("\n").split("\n")
if txt[-1].strip() == "#": txt = txt[:-1]
open(dst, "w").write("\n".join(txt + lines) + "\n")
print("OK: %d atomes, %d liaisons (%d doubles, %d aromatiques)"
      % (arr.array_length(), arr.bonds.as_array().shape[0], nd, na))
```

Sortie attendue : `OK: 71 atomes, 72 liaisons (13 doubles, 6 aromatiques)`.

**Validation de la chimie (faite dans RDKit) :** formule brute **C₄₉H₇₄N₁₀O₁₂**,
celle de la microcystine-LR à l'atome près · 2 cycles (macrocycle + phényle) ·
sanitisation et génération de conformère réussies.

Les 13 doubles liaisons : `C3=O1, C5=O2, C10=O3, C13=O5, C16=O6, C20=N6,
C32=C33, C35=C36, C40=O8, C42=O9, C45=O10, C47=C48, C49=O11`.

---

## 3. Schéma d'entrée RFD3 — ce qui est vérifié

Lu dans `rfd3/inference/input_parsing.py`, classe `DesignInputSpecification`.
**Plus fiable que toute documentation** : il n'en existe aucune sur ce point,
et `/shared/examples/rfd3-examples/` ne contient qu'un cas protéine–protéine.

| Fait établi | Conséquence |
|---|---|
| `extra="forbid"` | **Toute clé inconnue lève une erreur.** Pas d'échec silencieux |
| `ligand` satisfait seul le contrôle « input utilisé » (l. ~249) | **Pas besoin de `contig`** pour un petit ligand |
| `dialect: int = Field(2, ...)` | vaut 2 par défaut, inutile de l'écrire |
| `length` = « Constrains length of contig if provided » | ce n'est pas l'équivalent de `contig` |
| `select_buried` = `rasa_bin 0/3` · `select_partially_buried` = bin 1 · `select_exposed` = bin 2 | **trois** classes. `select_exposed` est déjà le signal le plus fort pour garder une face ouverte — passer à `partially_buried` demanderait *plus* d'enfouissement |
| Clés des sélections = **chaîne + numéro de résidu** | `A1`, pas `LIG` |

Champs disponibles : `input`, `contig`, `unindex`, `length`, `ligand`,
`cif_parser_args`, `extra`, `dialect`, `select_fixed_atoms`,
`select_unfixed_sequence`, `select_buried`, `select_partially_buried`,
`select_exposed`, `select_hbond_acceptor`, `select_hbond_donor`,
`select_hotspots`, `redesign_motif_sidechains`, `symmetry`, `ori_token`,
`infer_ori_strategy`, `plddt_enhanced`, `is_non_loopy`, `partial_t`.

---

## 4. Procédure de lancement

### 4.1 PVC
```bash
kubectl get pvc -n runai-make-dlai-aaakrout
```
→ `make-dlai-scratch-g13` et `make-dlai-shared-ro`.

### 4.2 Les deux noms du même stockage
`/mnt/make-dlai/rcp-caas-make-dlai-g13/scratch-g13/` depuis le jumphost,
`/scratch/` depuis le conteneur.

```bash
scp <fichier> aaakrout@jumphost.rcp.epfl.ch:/mnt/make-dlai/rcp-caas-make-dlai-g13/scratch-g13/aaakrout/mclr/
```
> Chemin distant contenant `*` : **entre guillemets**, sinon zsh tente de
> développer l'étoile localement et refuse.

### 4.3 Réserver un GPU
```bash
runai submit --name rfd3-d1 \
  -i registry.rcp.epfl.ch/proteindesign-containers/rfd3:2026.1 \
  --interactive --attach --node-pools default -g 1 \
  --existing-pvc claimname=make-dlai-scratch-g13,path=/scratch \
  --existing-pvc claimname=make-dlai-shared-ro,path=/shared \
  --command -- /bin/bash
```
Invite : `root@rfd3-d1-0-0:~#`. Vérifier `nvidia-smi` (A100 80 Go) et
`ls /shared`.

### 4.4 Lancer
```bash
rfd3 design \
  out_dir=/scratch/aaakrout/mclr/out_d1 \
  inputs=/scratch/aaakrout/mclr/mclr_d1.json \
  ckpt_path=/shared/weights/rfd3-weights/rfd3_latest.ckpt \
  n_batches=1 \
  diffusion_batch_size=1
```
**~25 s par design** sur A100. Sorties : `.cif.gz` + `.json`.

### 4.5 Libérer — systématiquement
```bash
exit
runai delete job rfd3-d1
```

---

## 5. Fichier d'entrée — d1 « gouttière + contact polaire »

Format **JSON** (le seul dont on ait la preuve qu'il fonctionne). Créé dans le
conteneur par `cat > ... << 'EOF'`.

```json
{
  "mclr_gutter_polar": {
    "input": "/scratch/aaakrout/mclr/mclr_unl.cif",
    "ligand": "UNL",
    "length": "70-100",
    "select_buried": {
      "A1": "C30,C31,C22,O7,C21,C23,C24,C25,C26,C27,C28,C29,C36,C35,C33,C34,C32,C37,C38,C39,C40,C42,O9,O12"
    },
    "select_exposed": {
      "A1": "N1,C1,C2,C3,O1,N2,C4,C5,O2,C6,C7,C8,C9,C11,N3,C12,C13,C14,O5,N4,C15,C16,O6,C17,C18,C19,N5,C20,N6,N7,N8,O8,N9,C41,C43,C44,C45,O10,N10,C46,C47,C48,C49,O11,C10,O3,O4"
    },
    "select_hbond_acceptor": {
      "A1": "O9,O12,O7"
    }
  }
}
```

24 enfouis + 47 exposés = **71, aucun orphelin**.

> La première version n'en annotait que 63. Les 7 oubliés étaient le **segment
> proximal d'Adda** (`C37, C38, C39, C40`) et le **carboxylate du D-Glu**
> (`C42, O9, O12`) — deux des trois piliers de la carte d1. Ajoutés à
> `select_buried` : le proximal parce que d1 est la gouttière sur toute la
> longueur (PP1 l'enfouit à 96 %), le carboxylate parce qu'un contact
> directionnel exige la désolvatation (PP1 l'enfouit à 94 %) et que ses deux
> oxygènes sont déjà déclarés accepteurs, ce qui impose au modèle de fournir le
> donneur.

---

## 6. Résultats des deux designs

Protocole PyMOL identique à `02_enfouissement_pp1.pml` (`flag ignore, all,
clear` obligatoire, `dot_solvent 1`, `dot_density 3`).

| | Design 1 (chimie faussée) | Design 2 (chimie correcte) | PP1 |
|---|---|---|---|
| Toxine libre | 1177 Å² | 1177 Å² | 1176 Å² |
| Toxine dans le complexe | 326 Å² | **218 Å²** | 493 Å² |
| Enfouissement global | 72 % | **81 %** | 58 % |
| Groupe demandé **enfoui** | 87 % (17 at.) | **96,8 %** (24 at.) | — |
| Groupe demandé **exposé** | 65 % | 70 % | — |
| Écart entre groupes | 22 pts | **27 pts** | — |
| Atomes de squelette | 543 | 671 | — |

> **Contrôle de validité :** 1177 contre 1176 Å² pour la toxine libre. Les
> mesures partent du même conformère de 1FJM et tombent à un Å² près.

**Le conditionnement atome par atome fonctionne.** Sur le design 2, les 24
atomes désignés ne laissent que **15,9 Å² accessibles sur 500,1**. C'est la
démonstration expérimentale de l'argument central du RATIONALE.

**Mais la sur-fermeture est le vrai problème.** La face demandée exposée est
enfouie à 70 %, et la toxine ne laisse que 218 Å² accessibles — limite basse du
seuil d'équipe (≥ 200–250 Å²), celui qui garantit la lecture compétitive.

**Réserve majeure :** les deux designs n'ont pas la même taille (543 vs 671
atomes de squelette, même `length: "70-100"` — RFdiffusion est stochastique). Un
binder plus gros enveloppe mécaniquement davantage. **L'amélioration ne peut pas
être attribuée à la correction chimique.** Avec un design de chaque côté, la
comparaison ne prouve rien.

---

## 7. Prochaines étapes

**Le point de méthode qui conditionne tout :** comparer deux configurations avec
un design chacune n'a aucune valeur. Il faut d'abord connaître la dispersion à
l'intérieur d'une configuration.

1. **Dispersion** — 20 designs sur la configuration actuelle, inchangée
   (`n_batches=20 diffusion_batch_size=4`, ~10 min GPU). Donne moyenne et
   écart-type.
2. **Longueur** — 20 designs avec `length: "60-80"`. La longueur est le levier
   soupçonné contre la sur-fermeture (et non `select_partially_buried`, qui
   demanderait plus d'enfouissement).
3. **Les trois cartes** d1, d2, d3 — 20 designs chacune, dans un seul JSON à
   trois entrées.
4. **LigandMPNN** pour les séquences — RFD3 ne produit qu'un squelette.
   Conversion `.cif` → `.pdb` par
   `python /shared/usefull_code/transformer.py <cif_dir> <pdb_dir>`.
5. **AlphaFold / Boltz** pour vérifier le repliement.

> À partir de 20 sorties, la mesure manuelle dans PyMOL n'est plus tenable :
> écrire un script qui boucle sur le dossier et produit un tableau.

---

## 8. Pièges rencontrés

| Piège | Signature | Remède |
|---|---|---|
| Nom de résidu dans la CCD | `could not broadcast (17,3) into (71,3)` | `LIG` → `UNL` |
| Ordres de liaison absents | `BondType.ANY` en masse, puis `Falling back to zeros` | passer en CIF avec `chem_comp_bond` |
| Colonnes `atom_site` manquantes | `KeyError: 'pdbx_PDB_model_num'`, puis `'pdbx_PDB_ins_code'` | laisser biotite écrire `atom_site` |
| Aromatique générique | `KeyError: 9` | alterner `SING`/`DOUB` + drapeau `Y` |
| Étoile dans un chemin scp | `zsh: no matches found` | guillemets autour du chemin distant |
| Mauvais chemin local | `scp: stat local ...: No such file` | le fichier est dans le dépôt, pas sur le Bureau |
| `B` dans PyMOL | `'B' is a reserved keyword, appending underscore` | nommer la sélection autrement |
| HETATM exclus du SASA | Adda ressort à 0 Å² | `flag ignore, all, clear` |
| Commandes enchaînées trop vite | `ls` s'exécute avant la fin du run | attendre l'invite `root@...:~#` |
