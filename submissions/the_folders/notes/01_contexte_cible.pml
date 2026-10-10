# =====================================================================
# 01_contexte_cible.pml
# Inventaire structural de la microcystine-LR (PDB 1LCM)
# Equipe : The Folders   Auteur : Anis   Date : 2026-10-10
# IMPORTANT : en .pml, un commentaire doit occuper toute sa ligne.
# =====================================================================

reinitialize
fetch 1lcm, async=0

# ---------------------------------------------------------------------
# Definition des 7 residus
# 1 DAL = D-Alanine        conserve, neutre
# 2 LEU = Leucine          VARIABLE
# 3 ACB = D-MeAsp          conserve, carboxylate
# 4 ARG = Arginine         VARIABLE
# 5 1ZN = Adda             conserve, hydrophobe
# 6 FGA = D-Glu            conserve, carboxylate
# 7 DAM = Mdha             conserve, ELECTROPHILE
# ---------------------------------------------------------------------

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

# ---------------------------------------------------------------------
# Mise en forme
# ---------------------------------------------------------------------

hide everything
show sticks
hide everything, hydro
set stick_radius, 0.18

# Base : tous les carbones en gris
color grey60, elem C

# Carbones colores par residu
color orange, adda    and elem C
color red,    dglu    and elem C
color salmon, measp   and elem C
color yellow, mdha    and elem C
color marine, var_leu and elem C
color purple, var_arg and elem C
color white,  dala    and elem C

# Heteroatomes : code couleur conventionnel conserve
color firebrick, elem O
color skyblue,   elem N
color yellow,    elem S

bg_color white
set ray_opaque_background, 1
set antialias, 2
deselect
orient
zoom all, 2