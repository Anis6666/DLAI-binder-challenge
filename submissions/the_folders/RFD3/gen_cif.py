from biotite.structure.io.pdb import PDBFile
from biotite.structure.io.pdbx import CIFFile, set_structure
src = "/scratch/aaakrout/mclr/mclr_unl.pdb"
dst = "/scratch/aaakrout/mclr/mclr_unl.cif"
arr = PDBFile.read(src).get_structure(model=1, include_bonds=True)
arr.res_name[:] = "UNL"
arr.hetero[:] = True
f = CIFFile()
set_structure(f, arr)
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
