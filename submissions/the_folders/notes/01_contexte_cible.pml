# =====================================================================
# 01_contexte_cible.pml
# Inventaire structural de la microcystine-LR (PDB 1LCM)
# Equipe : The Folders   Auteur : Anis   Date : 2026-10-10
# Usage : dans PyMOL -> @/chemin/vers/01_contexte_cible.pml
# NOTE : en .pml un commentaire occupe toute sa ligne, jamais une fin de ligne.
# =====================================================================


# =====================================================================
# 1. CHARGEMENT
# =====================================================================

reinitialize
fetch 1lcm, async=0


# =====================================================================
# 2. SELECTIONS
# 1 DAL = D-Alanine    conserve, neutre
# 2 LEU = Leucine      VARIABLE
# 3 ACB = D-MeAsp      conserve, carboxylate
# 4 ARG = Arginine     VARIABLE
# 5 1ZN = Adda         conserve, hydrophobe
# 6 FGA = D-Glu        conserve, carboxylate
# 7 DAM = Mdha         conserve, ELECTROPHILE
# =====================================================================

select dala,    resn DAL
select var_leu, resn LEU
select measp,   resn ACB
select var_arg, resn ARG
select adda,    resn 1ZN
select dglu,    resn FGA
select mdha,    resn DAM

select variables, resn LEU+ARG
select conserve,  resn DAL+ACB+1ZN+FGA+DAM
select carboxyl,  resn ACB+FGA


# =====================================================================
# 3. MISE EN FORME
# Les carbones portent l'identite du residu,
# les heteroatomes gardent le code couleur conventionnel.
# =====================================================================

hide everything
show sticks
hide everything, hydro
set stick_radius, 0.18

color grey60, elem C

color orange, adda    and elem C
color red,    dglu    and elem C
color salmon, measp   and elem C
color yellow, mdha    and elem C
color marine, var_leu and elem C
color purple, var_arg and elem C
color white,  dala    and elem C

color firebrick, elem O
color skyblue,   elem N
color yellow,    elem S

bg_color white
set ray_opaque_background, 1
set antialias, 2
deselect
orient
zoom all, 2


# =====================================================================
# 4. MESURES
# Les resultats s'affichent dans la console en bas de PyMOL.
# =====================================================================

pseudoatom c_adda,  selection=adda
pseudoatom c_dglu,  selection=dglu
pseudoatom c_measp, selection=measp
pseudoatom c_leu,   selection=var_leu
pseudoatom c_arg,   selection=var_arg
hide everything, c_*

print("=== DISTANCES ENTRE CENTROIDES (A) ===")
print("Adda - D-Glu   : %.1f" % cmd.get_distance("c_adda","c_dglu"))
print("Adda - D-MeAsp : %.1f" % cmd.get_distance("c_adda","c_measp"))
print("Adda - Leu     : %.1f" % cmd.get_distance("c_adda","c_leu"))
print("Adda - Arg     : %.1f" % cmd.get_distance("c_adda","c_arg"))
print("Leu  - Arg     : %.1f" % cmd.get_distance("c_leu","c_arg"))

set dot_solvent, 1
print("=== SASA (A2) ===")
print("Molecule entiere : %.0f" % cmd.get_area("1lcm"))
print("Adda             : %.0f" % cmd.get_area("adda"))
print("Carboxylates     : %.0f" % cmd.get_area("carboxyl"))
print("Positions var.   : %.0f" % cmd.get_area("variables"))


print("=== SCRIPT TERMINE ===")