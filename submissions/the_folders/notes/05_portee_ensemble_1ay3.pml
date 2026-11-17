# =====================================================================
# 05_portee_ensemble_1ay3.pml
# Distribution de la portee phenyle -> carboxylates sur les 27 conformeres
# PDB 1AY3 (nodularine)
# Equipe : the-folders   Date : 2026-11-17
# Usage : File > Run Script...
#
# POURQUOI
# La portee de 15,4 A mesuree sur 1LCM vaut pour UN conformere. Or le RMSF
# du phenyle atteint 7,6 A : cette distance varie donc fortement d'un
# conformere a l'autre. Le design d1 demande de tenir le phenyle ET le
# carboxylate simultanement -- il faut donc savoir quelles portees la
# molecule visite reellement.
#
# CE QUE CA DONNE
# La plage physiquement plausible. Elle devient un SEUIL DE FILTRAGE :
# si un design impose au ligand une portee hors de cette plage, c'est que
# la conformation retenue n'est pas peuplee en solution, et aucune metrique
# standard ne le signalera.
#
# NOTE : une distance intramoleculaire ne depend pas de la superposition.
# Aucun intra_fit n'est necessaire ici.
# =====================================================================

reinitialize
fetch 1ay3, async=0
remove solvent
remove hydro

python
import math

obj = "1ay3"
n = cmd.count_states(obj)

# --- on recupere les atomes par (resi, name), sans passer par des
# --- selections texte : les noms primes (C1') posent probleme en syntaxe.
models = [cmd.get_model(obj, state=s) for s in range(1, n + 1)]

def noms_du_residu(resi):
    return sorted(set(a.name for a in models[0].atom if int(a.resi) == resi))

print("")
print("=== ATOMES DISPONIBLES ===")
for r in sorted(set(int(a.resi) for a in models[0].atom)):
    resn = [a.resn for a in models[0].atom if int(a.resi) == r][0]
    print("resi %d (%s) : %s" % (r, resn, " ".join(noms_du_residu(r))))

# --- groupes ---
# Adda = resi 3 (MFD) : phenyle = les noms primes
phe = [(3, nm) for nm in noms_du_residu(3) if nm.endswith("'") and nm.startswith("C")]
# carboxylates libres = alpha-carboxyles (C, O, OXT quand present)
glu = [(4, nm) for nm in noms_du_residu(4) if nm in ("C", "O", "OXT")]
mea = [(1, nm) for nm in noms_du_residu(1) if nm in ("C", "O", "OXT")]

print("")
print("=== GROUPES UTILISES ===")
print("Phenyle (resi 3)     : %s" % " ".join(nm for _, nm in phe))
print("COO D-Glu (resi 4)   : %s" % " ".join(nm for _, nm in glu))
print("COO D-MeAsp (resi 1) : %s" % " ".join(nm for _, nm in mea))

def centroide(model, groupe):
    cs = [a.coord for a in model.atom if (int(a.resi), a.name) in groupe]
    k = len(cs)
    if k == 0:
        return None
    return (sum(c[0] for c in cs)/k, sum(c[1] for c in cs)/k, sum(c[2] for c in cs)/k)

def d(a, b):
    return math.sqrt(sum((a[i]-b[i])**2 for i in range(3)))

gphe, gglu, gmea = set(phe), set(glu), set(mea)

d_glu, d_mea, d_cc = [], [], []
for m in models:
    cp, cg, cm = centroide(m, gphe), centroide(m, gglu), centroide(m, gmea)
    d_glu.append(d(cp, cg))
    d_mea.append(d(cp, cm))
    d_cc.append(d(cg, cm))

def stats(nom, v):
    mu = sum(v)/len(v)
    sd = math.sqrt(sum((x-mu)**2 for x in v)/len(v))
    print("%-24s  min %5.1f   max %5.1f   moy %5.1f   ecart-type %4.1f   amplitude %4.1f"
          % (nom, min(v), max(v), mu, sd, max(v)-min(v)))

print("")
print("=== PORTEE PAR CONFORMERE (A) ===")
print("%6s %12s %14s %14s" % ("etat", "Phe-COO(Glu)", "Phe-COO(MeAsp)", "COO-COO"))
for i in range(n):
    print("%6d %12.1f %14.1f %14.1f" % (i+1, d_glu[i], d_mea[i], d_cc[i]))

print("")
print("=== DISTRIBUTION ===")
stats("Phenyle - COO(D-Glu)", d_glu)
stats("Phenyle - COO(D-MeAsp)", d_mea)
stats("COO(Glu) - COO(MeAsp)", d_cc)

print("")
print("=== LECTURE ===")
print("--- COO-COO : controle interne. Les deux carboxylates sont sur le")
print("--- macrocycle rigide : leur distance doit etre quasi constante.")
print("--- Si son ecart-type est petit et celui des deux autres grand,")
print("--- la variation vient bien de la queue, pas du bruit global.")
print("")
print("--- Les portees Phe-COO donnent la PLAGE PLAUSIBLE. Un design qui")
print("--- impose au ligand une portee hors de cette plage construit une")
print("--- poche complementaire d'une geometrie que la molecule ne visite")
print("--- pas. A transformer en seuil de filtrage.")
print("=== SCRIPT TERMINE ===")
python end
