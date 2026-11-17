# =====================================================================
# 03_visu_enfouissement.pml
# Visualiser l'enfouissement de la microcystine par la PP1 (1FJM)
# Equipe : the-folders   Date : 2026-11-17
#
# A LANCER APRES 02_enfouissement_pp1.pml (il reutilise les objets
# LIG et CPLX crees par ce script).
#   @/chemin/vers/02_enfouissement_pp1.pml
#   @/chemin/vers/03_visu_enfouissement.pml
#
# PRINCIPE
# get_area(..., load_b=1) ecrit l'aire de CHAQUE atome dans son champ
# b-factor. On la calcule une fois sur le ligand libre, une fois dans
# le complexe, et on stocke la difference (= surface cachee par PP1)
# dans le b du ligand. Un degrade de couleur rend le resultat lisible.
# =====================================================================

python
# --- aire par atome, ligand libre ---
cmd.get_area("LIG", load_b=1)
aire_libre = {}
cmd.iterate("LIG", "aire_libre[(resi, name)] = b", space={'aire_libre': aire_libre})

# --- aire par atome, ligand dans le complexe ---
cmd.get_area("CPLX", load_b=1)
aire_cplx = {}
cmd.iterate("CPLX and chain M", "aire_cplx[(resi, name)] = b", space={'aire_cplx': aire_cplx})

# --- enfoui = libre - complexe, stocke dans le b du ligand ---
cmd.alter("LIG",
          "b = aire_libre.get((resi, name), 0.0) - aire_cplx.get((resi, name), 0.0)",
          space={'aire_libre': aire_libre, 'aire_cplx': aire_cplx})
cmd.sort("LIG")

# --- recapitulatif des atomes les plus enfouis ---
tops = []
cmd.iterate("LIG", "tops.append((b, resi, resn, name))", space={'tops': tops})
tops.sort(reverse=True)
print("")
print("=== LES 15 ATOMES LES PLUS ENFOUIS PAR LA PP1 ===")
print("%6s  %5s %5s %6s" % ("A2", "resi", "resn", "atome"))
for b, resi, resn, name in tops[:15]:
    print("%6.1f  %5s %5s %6s" % (b, resi, resn, name))
print("")
print("--- Ces atomes sont les candidats naturels pour select_buried.")
python end


# =====================================================================
# RENDU : blanc = expose au solvant, rouge = enfoui par la PP1
# =====================================================================

hide everything
show surface, LIG
set surface_quality, 1
set transparency, 0.0
spectrum b, white_red, LIG

# La PP1 en ruban translucide, pour situer la poche.
show cartoon, CPLX and polymer
color grey80, CPLX and polymer
set cartoon_transparency, 0.75, CPLX

bg_color white
set ray_opaque_background, 1
orient LIG
zoom LIG, 3
deselect

print("")
print("=== LECTURE DE L'IMAGE ===")
print("--- ROUGE  = surface que la PP1 enterre   -> candidat select_buried")
print("--- BLANC  = surface laissee au solvant   -> candidat select_exposed")
print("--- Tourne la molecule : tu verras que l'enfouissement n'est pas")
print("--- uniforme autour de la chaine. C'est exactement l'idee de la")
print("--- gouttiere : enfoui sur certaines faces, ouvert sur une autre.")
print("")
print("--- Pour cacher la PP1 et ne voir que la toxine coloree :")
print("---     hide cartoon")
print("--- Pour sauvegarder une image :")
print("---     ray 1600, 1200")
print("---     png enfouissement_pp1.png, dpi=300")
print("=== SCRIPT TERMINE ===")
