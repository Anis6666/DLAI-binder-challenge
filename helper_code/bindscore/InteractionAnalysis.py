from PDBFetcher import fetch_pdb_data
from ProteinParser import Protein_Structure
from InteractionFinder import Interaction
import os
import sys
from pymol import cmd


def analyze_interactions(
    pdb_file,
    chain1,
    chain2,
    residues=None,
    threshold=5.0
):
    """
    Analyze interactions between two chains.

    Parameters
    ----------
    pdb_file : str
        Path to a PDB/CIF file or a 4-character PDB ID.

    chain1 : str
        First chain.

    chain2 : str
        Second chain.

    residues : list[int] or None
        Residues from chain1 to specifically analyze.
        Example: [23, 24, 25]

        If None, all residues in chain1 are analyzed.

    threshold : float
        Maximum atom-atom distance considered by InteractionFinder.
        Default = 5.0 Å.
    """

    # ---------------------------------------------------------
    # Load and parse structure
    # ---------------------------------------------------------

    pdb_data = fetch_pdb_data(pdb_file)
    protein = Protein_Structure(pdb_data)

    # ---------------------------------------------------------
    # Check chains
    # ---------------------------------------------------------

    if chain1 not in protein.chains():
        raise ValueError(
            f"Chain '{chain1}' not found. "
            f"Available chains: {sorted(protein.chains())}"
        )

    if chain2 not in protein.chains():
        raise ValueError(
            f"Chain '{chain2}' not found. "
            f"Available chains: {sorted(protein.chains())}"
        )

    # ---------------------------------------------------------
    # Find all interactions between the two chains
    # ---------------------------------------------------------

    interaction = Interaction(
        protein,
        chain1,
        chain2,
        threshold=threshold
    )

    # ---------------------------------------------------------
    # Filter by selected residues
    # ---------------------------------------------------------

    if residues is not None:
        residues = {str(r) for r in residues}

        filtered = []

        for interaction_data in interaction.interactions:

            atom1 = interaction_data["atom1"]
            atom2 = interaction_data["atom2"]

            # We want selected residues specifically from chain1
            if (
                atom1["chain"] == chain1
                and atom1["residue_seq"] in residues
            ):
                filtered.append(interaction_data)

        interactions = filtered

    else:
        interactions = interaction.interactions

    # ---------------------------------------------------------
    # Remove unclassified contacts
    # ---------------------------------------------------------

    interactions = [
        x for x in interactions
        if x["type"] is not None
    ]

    # ---------------------------------------------------------
    # Print summary
    # ---------------------------------------------------------

    print("\n" + "=" * 70)
    print("INTERACTION SUMMARY")
    print("=" * 70)

    print(f"PDB:       {pdb_file}")

    if residues is not None:
        print(f"Residues:  {sorted(residues, key=lambda x: int(x))}")

    print(f"Threshold: {threshold:.1f} Å")

    print("-" * 70)

    if not interactions:
        print("No interactions found.")
        return []

    # ---------------------------------------------------------
    # Print every interaction
    # ---------------------------------------------------------

    for i, interaction_data in enumerate(interactions, 1):

        atom1 = interaction_data["atom1"]
        atom2 = interaction_data["atom2"]

        residue1 = (
            f"{atom1['residue_name']}"
            f"{atom1['residue_seq']}"
        )

        residue2 = (
            f"{atom2['residue_name']}"
            f"{atom2['residue_seq']}"
        )

        print(
            f"{i:3d}. "
            f"{residue1:8s} "
            f"{atom1['atom_name']:5s}  --  "
            f"{residue2:8s} "
            f"{atom2['atom_name']:5s}  |  "
            f"{interaction_data['type']:20s}  |  "
            f"{interaction_data['distance']:.2f} Å"
        )

    # ---------------------------------------------------------
    # Count interaction types
    # ---------------------------------------------------------

    print("\n" + "-" * 70)
    print("COUNTS BY INTERACTION TYPE")
    print("-" * 70)

    counts = {}

    for x in interactions:
        interaction_type = x["type"]
        counts[interaction_type] = counts.get(interaction_type, 0) + 1

    for interaction_type, count in sorted(counts.items()):
        print(f"{interaction_type:25s}: {count}")

    print("=" * 70)

    return interactions


# CHANGE THESE TO YOUR SESSION FILE AND DESIRED OUTPUT LOCATIONS

SESSION_FILE = "path/to/session.pse"
OUT_DIR = "path/to/output/pair_pdbs"

ANALYSIS_DIR = "path/to/analysis_modules"
INTERACTION_THRESHOLD = 4.0

sys.path.append(ANALYSIS_DIR)

os.makedirs(OUT_DIR, exist_ok=True)

# Every extracted pair gets rewritten to these two chain IDs so there is
# never a collision, regardless of what the source chain letters were.
CHAIN_ID_1 = "Z"
CHAIN_ID_2 = "Y"

# (label, object_1, chain_1, object_2, chain_2)
# Built automatically below: one chain of every object in the session
# (except the reference object itself) vs the listed chains of the reference object.
REFERENCE_OBJ = "reference"
SOURCE_CHAIN = "C"
REFERENCE_CHAINS = ["C", "D"]

cmd.load(SESSION_FILE)

PAIRS = []
for obj in cmd.get_object_list():
    if obj == REFERENCE_OBJ:
        continue

    obj_chains = cmd.get_chains(obj)
    if SOURCE_CHAIN not in obj_chains:
        print(f"[skip] {obj} has no chain {SOURCE_CHAIN} (chains: {obj_chains})")
        continue

    for ref_chain in REFERENCE_CHAINS:
        label = f"{obj}_{SOURCE_CHAIN}_vs_{REFERENCE_OBJ}_{ref_chain}"
        PAIRS.append((label, obj, SOURCE_CHAIN, REFERENCE_OBJ, ref_chain))

print(f"\nBuilt {len(PAIRS)} pairs:")
for label, *_ in PAIRS:
    print(f"  - {label}")

for label, obj1, ch1, obj2, ch2 in PAIRS:

    tmp1, tmp2, tmp = f"_t1_{label}", f"_t2_{label}", f"_pair_{label}"
    for name in (tmp1, tmp2, tmp):
        cmd.delete(name)

    # Pull out just the first chain, relabel it
    cmd.create(tmp1, f"{obj1} and chain {ch1}")
    cmd.alter(tmp1, f"chain='{CHAIN_ID_1}'")
    cmd.alter(tmp1, f"segi='{CHAIN_ID_1}'")

    # Pull out just the second chain, relabel it
    cmd.create(tmp2, f"{obj2} and chain {ch2}")
    cmd.alter(tmp2, f"chain='{CHAIN_ID_2}'")
    cmd.alter(tmp2, f"segi='{CHAIN_ID_2}'")

    # Merge both into one clean two-chain object
    cmd.create(tmp, f"{tmp1} or {tmp2}")
    cmd.sort(tmp)

    out_path = os.path.join(OUT_DIR, f"{label}.pdb")
    cmd.save(out_path, tmp, state=1)
    print(f"[{label}] wrote {out_path}  "
          f"({obj1}/{ch1} -> chain {CHAIN_ID_1}, "
          f"{obj2}/{ch2} -> chain {CHAIN_ID_2})")

    cmd.delete(tmp1)
    cmd.delete(tmp2)
    cmd.delete(tmp)

    # Run the interaction analysis on the extracted pair
    analyze_interactions(
        pdb_file=out_path,
        chain1=CHAIN_ID_1,
        chain2=CHAIN_ID_2,
        residues=None,
        threshold=INTERACTION_THRESHOLD,
    )
