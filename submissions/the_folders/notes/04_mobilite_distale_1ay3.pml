# =====================================================================
# 04_mobilite_distale_1ay3.pml
# Mobilite conformationnelle du segment distal d'Adda
# PDB 1AY3 : nodularine, RMN, 27 conformeres, meme groupe Adda
# Equipe : the-folders   Date : 2026-11-17
# Usage : File > Run Script...   (ou @/chemin/vers/ce_fichier.pml)
#
# POURQUOI CETTE MESURE
# C'est la derniere mesure manquante, et l'analyse d'Adda la designe comme
# le critere le plus discriminant de l'arbitrage : gouttiere longue ou courte.
#   - dispersion distale LARGE -> figer cette zone coute cher en entropie
#                                 -> gouttiere plus courte, rien de fige
#   - dispersion FAIBLE        -> gouttiere longue pleinement justifiee
#
# 1LCM ne permet pas cette mesure : c'est une moyenne minimisee a UN seul
# conformere. 1AY3 depose les 27, d'ou le recours a la nodularine, dont le
# groupe Adda est chimiquement identique.
#
# METHODE
# 1. Superposition des 27 etats sur le SQUELETTE peptidique (le macrocycle,
#    partie rigide). Sans cette etape on mesurerait des rotations globales.
# 2. RMSF par atome = ecart quadratique moyen a sa position moyenne.
#    Petit = atome bien determine. Grand = atome qui se promene.
# =====================================================================

reinitialize
fetch 1ay3, async=0
remove solvent
remove hydro

python
import math

obj = "1ay3"
n = cmd.count_states(obj)

print("")
print("=== STRUCTURE CHARGEE ===")
print("Nombre de conformeres : %d" % n)

# --- composition : on ne suppose aucun nom de residu ---
comp = {}
cmd.iterate(obj, "comp.setdefault((int(resi), resn), []).append(name)",
            space={'comp': comp, 'int': int})
print("")
print("=== COMPOSITION DE LA NODULARINE ===")
print("%5s %6s %8s" % ("resi", "resn", "atomes"))
for (resi, resn) in sorted(comp):
    print("%5d %6s %8d" % (resi, resn, len(comp[(resi, resn)])))

# Adda = le residu qui porte le plus d'atomes (C20, loin devant les autres)
adda_key = max(comp, key=lambda k: len(comp[k]))
adda_resi, adda_resn = adda_key
print("")
print("--- Residu le plus gros = Adda : resi %d, resn %s, %d atomes"
      % (adda_resi, adda_resn, len(comp[adda_key])))
python end


# =====================================================================
# SUPERPOSITION sur le squelette peptidique (macrocycle rigide)
# =====================================================================

intra_fit 1ay3 and name N+CA+C, 1


# =====================================================================
# CALCUL DU RMSF PAR ATOME
# =====================================================================

python
models = [cmd.get_model(obj, state=s) for s in range(1, n + 1)]
atoms = models[0].atom
rmsf = []

for i in range(len(atoms)):
    coords = [m.atom[i].coord for m in models]
    mx = sum(c[0] for c in coords) / n
    my = sum(c[1] for c in coords) / n
    mz = sum(c[2] for c in coords) / n
    msd = sum((c[0]-mx)**2 + (c[1]-my)**2 + (c[2]-mz)**2 for c in coords) / n
    a = atoms[i]
    rmsf.append((math.sqrt(msd), int(a.resi), a.resn, a.name, i))

# --- stocker le RMSF dans le b-factor pour la coloration ---
vals = {}
for r, resi, resn, name, i in rmsf:
    vals[(resi, name)] = r
cmd.alter(obj, "b = vals.get((int(resi), name), 0.0)",
          space={'vals': vals, 'int': int})
cmd.sort(obj)

# --- moyenne par residu ---
print("")
print("=== RMSF MOYEN PAR RESIDU (A) ===")
print("%5s %6s %9s" % ("resi", "resn", "RMSF"))
par_res = {}
for r, resi, resn, name, i in rmsf:
    par_res.setdefault((resi, resn), []).append(r)
for k in sorted(par_res):
    v = par_res[k]
    print("%5d %6s %9.2f" % (k[0], k[1], sum(v)/len(v)))

# --- detail du residu Adda, du plus mobile au plus fige ---
print("")
print("=== RMSF PAR ATOME DU RESIDU ADDA (resi %d) ===" % adda_resi)
print("--- trie du plus mobile au plus fige")
print("%8s %10s" % ("atome", "RMSF (A)"))
adda_atoms = sorted([x for x in rmsf if x[1] == adda_resi], reverse=True)
for r, resi, resn, name, i in adda_atoms:
    print("%8s %10.2f" % (name, r))

# --- synthese : mobile vs rigide ---
autres = [r for r, resi, resn, name, i in rmsf if resi != adda_resi]
adda_vals = [r for r, resi, resn, name, i in adda_atoms]
ref = sum(autres)/len(autres) if autres else 0.0
top3 = sum(adda_vals[:3])/3.0

print("")
print("=== SYNTHESE ===")
print("RMSF moyen du macrocycle (hors Adda) : %.2f A" % ref)
print("RMSF moyen de tout Adda              : %.2f A" % (sum(adda_vals)/len(adda_vals)))
print("RMSF des 3 atomes les plus mobiles   : %.2f A" % top3)
if ref > 0:
    print("Rapport mobile / rigide              : %.1f x" % (top3/ref))
print("")
print("--- LECTURE")
print("--- RMSF < 0.5 A  : atome bien determine, figer coute peu")
print("--- 0.5 - 1.5 A   : mobilite moderee")
print("--- > 1.5 A       : reellement mobile, le figer coute cher")
print("--- Un rapport mobile/rigide > 3 signe un vrai gradient le long")
print("--- de la chaine : la base est tenue, la queue s'evente.")
python end


# =====================================================================
# RENDU : les 27 conformeres superposes, colores par mobilite
# bleu = fige   /   rouge = mobile
# =====================================================================

hide everything
show sticks
set all_states, on
spectrum b, blue_white_red
bg_color white
set ray_opaque_background, 1
orient
zoom all, 2
deselect

print("")
print("=== IMAGE ===")
print("--- Les 27 conformeres sont affiches superposes.")
print("--- BLEU = atome fige d'un conformere a l'autre")
print("--- ROUGE = atome qui se promene")
print("--- Tu dois voir le macrocycle net et la queue en eventail.")
print("--- Pour n'en voir qu'un seul :  set all_states, off")
print("=== SCRIPT TERMINE ===")
