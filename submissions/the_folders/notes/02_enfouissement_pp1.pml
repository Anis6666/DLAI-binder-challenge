# =====================================================================
# 02_enfouissement_pp1.pml
# "La reponse de la nature" : quelle part de chaque segment d'Adda
# la PP1 enfouit-elle reellement ?  (PDB 1FJM, complexe PP1 + MC-LR)
# Equipe : the-folders   Auteur : Anis   Date : 2026-11-17
# Usage : dans PyMOL -> @/chemin/vers/02_enfouissement_pp1.pml
#
# POURQUOI CE SCRIPT
# Le brief appelle 1FJM "the closest thing you have to a worked solution".
# Mesurer ce que PP1 enfouit donne une reference directe pour notre
# carte d'enfouissement RF3 : on voit quels atomes une poche naturelle
# a juge utile d'enterrer, et lesquels elle laisse au solvant.
#
# METHODE
# Surface enfouie = SASA(ligand seul) - SASA(ligand dans le complexe).
# =====================================================================

reinitialize
fetch 1fjm, async=0
remove solvent
remove hydro

# Sans cette ligne, tous les HETATM (donc toute la toxine) sortent a 0.
flag ignore, all, clear

# La microcystine est la chaine M (le cristal en contient deux copies,
# M et N : on n'en garde qu'une).
create LIG,  chain M
create CPLX, (chain M) or (polymer within 8 of chain M)

# Les flags doivent etre re-leves sur les objets nouvellement crees.
flag ignore, all, clear

set dot_solvent, 1
set dot_density, 4

python
segments = [
    ("Proximal",  "name C+O+C18+C19+CA+N"),
    ("Diene",     "name C16+C15+C13+C14+C12"),
    ("Distal",    "name C10+C11+C2+O1+C1+C3+C4+C5+C6+C7+C8+C9"),
    ("  phenyle", "name C4+C5+C6+C7+C8+C9"),
    ("  methoxy", "name O1+C1"),
]

print("")
print("=== ENFOUISSEMENT D'ADDA PAR LA PP1 (A2) ===")
print("%-10s %8s %9s %8s %6s" % ("Segment", "libre", "complexe", "enfoui", "%"))
for nom, sel in segments:
    libre = cmd.get_area("LIG and chain M and resi 5 and " + sel)
    cplx  = cmd.get_area("CPLX and chain M and resi 5 and " + sel)
    enfoui = libre - cplx
    pct = (100.0 * enfoui / libre) if libre > 0 else 0.0
    print("%-10s %8.0f %9.0f %8.0f %5.0f%%" % (nom, libre, cplx, enfoui, pct))

print("")
print("=== ENFOUISSEMENT DES CARBOXYLATES CONSERVES (A2) ===")
groupes = [
    ("COO D-Glu6",   "resi 6 and name C+O+OXT"),
    ("COO D-MeAsp3", "resi 3 and name C+O+OXT"),
]
for nom, sel in groupes:
    libre = cmd.get_area("LIG and chain M and " + sel)
    cplx  = cmd.get_area("CPLX and chain M and " + sel)
    enfoui = libre - cplx
    pct = (100.0 * enfoui / libre) if libre > 0 else 0.0
    print("%-13s %8.0f %9.0f %8.0f %5.0f%%" % (nom, libre, cplx, enfoui, pct))

print("")
print("=== TOTAL TOXINE ===")
libre = cmd.get_area("LIG and chain M")
cplx  = cmd.get_area("CPLX and chain M")
print("SASA libre     : %.0f" % libre)
print("SASA complexe  : %.0f" % cplx)
print("Surface enfouie: %.0f  (%.0f%%)" % (libre - cplx, 100.0*(libre-cplx)/libre))
python end

print("")
print("=== LECTURE ===")
print("--- Un segment fortement enfoui par PP1 est un segment qu'une")
print("--- poche naturelle a juge payant d'enterrer : argument direct")
print("--- pour le mettre en select_buried dans RF3.")
print("--- Un segment laisse expose indique soit un acces, soit une")
print("--- zone ou l'enfouissement ne rapporte pas.")
print("=== SCRIPT TERMINE ===")
