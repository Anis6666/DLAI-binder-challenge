# =====================================================================
# 01_contexte_cible.pml
# Inventaire structural de la microcystine-LR (PDB 1LCM, toxine libre)
# Equipe : the-folders   Auteur : Anis   Version corrigee : 2026-11-17
# Usage : dans PyMOL -> @/chemin/vers/01_contexte_cible.pml
# NOTE : en .pml un commentaire occupe toute sa ligne, jamais une fin de ligne.
#
# CORRECTIONS par rapport a la v1 :
#  1. "flag ignore, all, clear" ajoute  -> sans cette ligne, PyMOL EXCLUT
#     tous les HETATM du calcul de surface. Adda, les carboxylates et le
#     Mdha sont des HETATM : ils ressortaient a 0 A2. C'est la cause des
#     valeurs SASA fausses de la v1.
#  2. "remove hydro" ajoute -> SASA sur atomes lourds, comparable aux
#     valeurs de la litterature.
#  3. Carboxylates corriges : dans la microcystine, D-MeAsp3 et D-Glu6
#     sont relies au cycle PAR LEUR CHAINE LATERALE (liaison iso-peptidique,
#     verifie dans struct_conn du .cif : ACB CG -> ARG N, FGA CD -> DAM N).
#     Leur carboxylate LIBRE est donc l'ALPHA-carboxyle = atomes C, O, OXT.
#     Ce n'est PAS OD1/OD2 ni OE1/OE2.
#  4. Decoupage d'Adda en trois segments (proximal / diene / distal),
#     verifie atome par atome sur chem_comp_bond du composant 1ZN.
#  5. Mesures ajoutees : portee phenyle -> carboxylates, SASA par segment.
# =====================================================================


# =====================================================================
# 1. CHARGEMENT
# =====================================================================

reinitialize
fetch 1lcm, async=0

# --- LES DEUX LIGNES CRITIQUES -------------------------------------
flag ignore, all, clear
remove hydro
# -------------------------------------------------------------------


# =====================================================================
# 2. SELECTIONS PAR RESIDU
# 1 DAL = D-Alanine    conserve, neutre
# 2 LEU = Leucine      VARIABLE  (le "L" de LR)
# 3 ACB = D-MeAsp      conserve, carboxylate
# 4 ARG = Arginine     VARIABLE  (le "R" de LR)
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


# =====================================================================
# 3. GROUPES FONCTIONNELS  (atomes verifies)
# =====================================================================

# --- Carboxylates LIBRES (alpha-carboxyles) ---
# Ce sont eux qui portent la charge negative visee par le design.
select coo_glu,   resi 6 and name C+O+OXT
select coo_measp, resi 3 and name C+O+OXT
select carboxyl,  coo_glu or coo_measp

# --- Carbone electrophile du Mdha ---
# CA=CB est le methylene exocyclique : CB est l'accepteur de Michael.
# C'est de CET atome qu'aucune cysteine ne doit s'approcher.
select mdha_elec, resi 7 and name CB


# =====================================================================
# 4. DECOUPAGE D'ADDA EN TROIS SEGMENTS
#
# Correspondance nom PDB (composant 1ZN) <-> numerotation chimique :
#   PROXIMAL : C = C1 (carboxyle) | C18 = C2 | C19 = methyle en C2
#              CA = C3 (porte l'amine) | N = amine | O = carbonyle
#   DIENE    : C16 = C4 | C15 = C5 | C13 = C6 | C14 = methyle en C6
#              C12 = C7      (doubles liaisons C16=C15 et C13=C12)
#   DISTAL   : C10 = C8 | C11 = methyle en C8 | C2 = C9
#              O1 = oxygene du methoxy | C1 = methyle du methoxy
#              C3 = C10 | C4..C9 = cycle phenyle
#
# ATTENTION au piege : dans le residu 5, les atomes PDB nommes C4..C9
# sont le CYCLE PHENYLE, et non les carbones 4 a 9 de la chaine.
# Toujours prefixer par "resi 5".
# =====================================================================

select prox,   resi 5 and name C+O+C18+C19+CA+N
select diene,  resi 5 and name C16+C15+C13+C14+C12
select distal, resi 5 and name C10+C11+C2+O1+C1+C3+C4+C5+C6+C7+C8+C9

select phenyl,  resi 5 and name C4+C5+C6+C7+C8+C9
select methoxy, resi 5 and name O1+C1

# Controle : 6 + 5 + 12 = 23 atomes, soit tout Adda.


# =====================================================================
# 5. MISE EN FORME
# =====================================================================

hide everything
show sticks
set stick_radius, 0.18

color grey60, elem C

color orange,    adda    and elem C
color red,       dglu    and elem C
color salmon,    measp   and elem C
color yellow,    mdha    and elem C
color marine,    var_leu and elem C
color purple,    var_arg and elem C
color white,     dala    and elem C

color firebrick, elem O
color skyblue,   elem N

bg_color white
set ray_opaque_background, 1
set antialias, 2
deselect
orient
zoom all, 2


# =====================================================================
# 6. MESURES
# Les resultats s'affichent dans la console en bas de PyMOL.
# =====================================================================

set dot_solvent, 1
set dot_density, 4

pseudoatom c_adda,   selection=adda
pseudoatom c_dglu,   selection=dglu
pseudoatom c_measp,  selection=measp
pseudoatom c_leu,    selection=var_leu
pseudoatom c_arg,    selection=var_arg
pseudoatom c_phenyl, selection=phenyl
pseudoatom c_cooglu, selection=coo_glu
pseudoatom c_coomea, selection=coo_measp
hide everything, c_*

print("")
print("=== DISTANCES ENTRE CENTROIDES DE RESIDUS (A) ===")
print("Adda - D-Glu   : %.1f" % cmd.get_distance("c_adda","c_dglu"))
print("Adda - D-MeAsp : %.1f" % cmd.get_distance("c_adda","c_measp"))
print("Adda - Leu     : %.1f" % cmd.get_distance("c_adda","c_leu"))
print("Adda - Arg     : %.1f" % cmd.get_distance("c_adda","c_arg"))
print("Leu  - Arg     : %.1f" % cmd.get_distance("c_leu","c_arg"))

print("")
print("=== PORTEE DE LA GOUTTIERE (A) ===")
print("--- distance phenyle -> charge : c'est la longueur que doit")
print("--- couvrir le binder pour tenir l'ancre ET un contact polaire.")
print("Phenyle - COO(D-Glu)   : %.1f" % cmd.get_distance("c_phenyl","c_cooglu"))
print("Phenyle - COO(D-MeAsp) : %.1f" % cmd.get_distance("c_phenyl","c_coomea"))
print("COO(Glu) - COO(MeAsp)  : %.1f" % cmd.get_distance("c_cooglu","c_coomea"))

print("")
print("=== SASA PAR ELEMENT (A2, atomes lourds) ===")
print("Molecule entiere : %.0f" % cmd.get_area("1lcm"))
print("Adda (total)     : %.0f" % cmd.get_area("adda"))
print("Carboxylates     : %.0f" % cmd.get_area("carboxyl"))
print("Positions var.   : %.0f" % cmd.get_area("variables"))

print("")
print("=== SASA PAR SEGMENT D'ADDA (A2) ===")
print("            total   apolaire(C)")
print("Proximal : %6.0f   %6.0f" % (cmd.get_area("prox"),   cmd.get_area("prox and elem C")))
print("Diene    : %6.0f   %6.0f" % (cmd.get_area("diene"),  cmd.get_area("diene and elem C")))
print("Distal   : %6.0f   %6.0f" % (cmd.get_area("distal"), cmd.get_area("distal and elem C")))
print("  dont phenyle : %.0f" % cmd.get_area("phenyl"))
print("  dont methoxy : %.0f" % cmd.get_area("methoxy"))

print("")
print("=== CONTROLE DE COHERENCE ===")
print("--- Si 'Molecule entiere' vaut exactement 'Positions var.',")
print("--- le flag ignore n'a PAS ete leve : le calcul est faux.")
print("--- Adda doit etre de loin le plus gros contributeur.")
print("Somme des 3 segments : %.0f" % (cmd.get_area("prox")+cmd.get_area("diene")+cmd.get_area("distal")))
print("Adda mesure direct   : %.0f" % cmd.get_area("adda"))

print("")
print("=== SCRIPT TERMINE ===")
