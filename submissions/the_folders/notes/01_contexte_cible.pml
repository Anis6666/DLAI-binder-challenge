# =====================================================================
# 01_contexte_cible.pml
# Inventaire structural de la microcystine-LR (PDB 1LCM)
# Objectif : établir le contexte factuel avant tout choix de face.
# Equipe : <the folders>   Auteur : Anis   Date : 2026-10-10
# Usage : dans PyMOL -> @/chemin/vers/01_contexte_cible.pml
# =====================================================================

reinitialize

# --- Chargement ------------------------------------------------------
fetch 1lcm, async=0

# --- Definition des 7 residus ----------------------------------------
# Codes PDB observes dans le visualiseur de sequence de 1LCM
select dala,      resn DAL        # 1  D-Alanine            conserve
select var_leu,   resn LEU        # 2  Leucine              VARIABLE
select measp,     resn ACB        # 3  D-MeAsp              conserve, COO-
select var_arg,   resn ARG        # 4  Arginine             VARIABLE
select adda,      resn 1ZN        # 5  Adda                 conserve, hydrophobe
select dglu,      resn FGA        # 6  D-Glu                conserve, COO-
select mdha,      resn DAM        # 7  Mdha                 conserve, ELECTROPHILE

select variables, resn LEU+ARG
select conserve,  resn DAL+ACB+1ZN+FGA+DAM
select carboxyl,  resn ACB+FGA

# --- Mise en forme ---------------------------------------------------
hide everything
show sticks
hide everything, hydro
set stick_radius, 0.18
color grey70, 1lcm

color orange, adda
color red,    dglu
color salmon, measp
color yellow, mdha
color marine, variables
color white,  dala

bg_color white
set ray_opaque_background, 1
set antialias, 2
deselect
orient
zoom all, 2