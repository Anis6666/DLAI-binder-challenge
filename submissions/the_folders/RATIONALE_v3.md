<!-- ============================================================
     RATIONALE.md — team the-folders — Binder Challenge 2026
     Target: microcystin-LR

     FORMAT (submission spec):
       - The five "##" sections below are REQUIRED, with these exact names.
       - 500-800 words total. Current draft: ~770.
       - "What would prove us wrong" is written BEFORE any data exists.

     TO FILL BEFORE THE FIRST DESIGN RUN: every "____" in Filtering,
     plus the dates. Those thresholds are the graded point and they
     cannot be set honestly once results exist.
     ============================================================ -->

# RATIONALE — the-folders — microcystin-LR

## Target face

**Decision (2026-11-02): target the conserved face of MC-LR, anchoring on Adda, with complementary contacts on the D-Glu carboxylate and the cyclic peptide backbone.**

We selected Adda as the main recognition site because of its extended hydrophobic and aromatic structure, which offers opportunities for favorable van der Waals interactions, hydrophobic packing, and shape complementarity within the protein binding pocket. Moreover, Adda is conserved across many microcystin congeners, making it a relevant structural feature for molecular recognition.

D-Glu was selected as a complementary recognition site because its negatively charged carboxylate group could establish favorable electrostatic interactions and hydrogen bonds with appropriately positioned residues in the binder. Additional contacts with the cyclic peptide backbone could further contribute to molecular recognition, thus increasing binding specificity for MC-LR.

We did not prioritize the variable amino acid positions (2 and 4), as targeting them could favor congener-specific recognition and potentially limit the detection of other microcystins. Furthermore, given the relatively small size of our binder, we favored a single contiguous interface along Adda rather than attempting to recognize multiple distant regions of the ligand.

This strategy aims to achieve favorable binding to MC-LR while potentially allowing broader recognition of microcystin congeners. However, cross-reactivity with other microcystin congeners (such as MC-RR and MC-YR) and related toxins (ex: nodularins which have an Adda group) remains possible, and binding specificity will require experimental validation.

## Approach

Backbones come from **RFdiffusion3**, which models the ligand explicitly and samples its conformation jointly with the protein. Because RF3 specifies burial atom by atom, our design variable is not *which segment* to target but *which atoms to bury*: the three designs are three burial maps on one face, not competing strategies.

MC-LR is placed in the PP1-bound conformation (PDB 1FJM, 2.1 Å): our binding mode mirrors PP1's — a hydrophobic groove along Adda with polar contacts on the conserved edge — so the conformation Adda adopts in such a groove is the relevant one. 1LCM is an NMR minimized average whose single conformer may not be populated in the flexible distal segment. **No distal atom is fixed**, so RF3 samples the tail.

Geometry follows the energy budget: ≈ −12.3 kcal/mol at 1 nM, which no single segment supplies. The distal segment carries the most apolar surface but also every rotatable bond, whereas the diene and proximal segments are already ordered within the macrocycle — extending the groove there adds surface at no conformational cost. We bury the length of Adda and add one polar contact for specificity, since the hydrophobic effect cannot discriminate the toxin from the hydrophobic background of lake water.

The device is **single-use**, allowing an extended groove but not full encapsulation: the competitive readout needs the tracer displaced within the assay, so one face stays exposed.

Sequences come from **LigandMPNN**, cysteine excluded globally to prevent Michael addition to Mdha and any disulfide. Designs are co-folded with and without ligand in **Boltz**, then re-predicted in **AlphaFold 3** so two predictors must agree. Pseudocycle scaffolds (An et al. 2024) were tried and dropped: they need a resampling round we cannot test in one round.

## Filtering

Thresholds were set before any design was generated.

| Metric | Threshold | Date | Reason |
|---|---|---|---|
| Cysteine count | 0 | ____ | Electrophilic Mdha; no covalent trap |
| Cys S → `DAM 7 CB` | ____ Å | ____ | `CB` is the Michael-acceptor carbon |
| Ligand SASA in complex | **> ____ Å²** | ____ | Encapsulated ligand cannot be loaded; undetected by standard metrics |
| Adda buried fraction | ____ % | ____ | Burial is the dominant affinity term |
| D-Glu carboxylate contact | ____ | ____ | Sole directional filter vs hydrophobic false positives |
| ipTM / pTM | ____ | ____ | Interface confidence, both predictors |
| Ligand RMSD, Boltz vs AF3 | ____ Å | ____ | Tail unfixed; predictors may diverge |
| Shape complementarity | ____ | ____ | Required by the brief |
| Length | ____–____ aa | ____ | |

Metrics that eliminated designs are reported in `metrics.csv`, unflattering ones included.

## The three

The three differ by burial map, not by target segment.

| Rank | design_id | Burial map | Hypothesis tested |
|---|---|---|---|
| 1 | `the-folders_d1` | Full Adda length buried on three faces, fourth exposed; one carboxylate contacted | Affinity from surface, specificity from one directional contact |
| 2 | `the-folders_d2` | Distal buried, C9 methoxy H-bonded, macrocycle exposed | Designability first — the fallback |
| 3 | `the-folders_d3` | Proximal and diene buried, distal partly exposed, both carboxylates contacted | Specificity first, with enough surface to stay viable |

## What would prove us wrong

**Micromolar affinity despite high computed burial** would mean our surface budget overestimated what buried area buys, or underestimated the cost of ordering the distal tail. **Equal binding to an Adda-free hydrophobic control** would mean we built a grease trap and the carboxylate discriminates nothing. **No tracer displacement despite measurable affinity** would mean the pocket is kinetically closed and one exposed face was not enough. **Affinity collapsing between buffer and lake water** would mean ionic strength screens the polar contact, and we should have rested on shape rather than charge.

---

<!-- Hard constraints from the brief — final check -->

- [ ] Buried pocket, shape complementarity and buried SASA reported
- [ ] No cysteine near the ligand
- [ ] Stable and soluble in *E. coli*, no disulfide bonds
- [ ] One free site for signal output / split
- [ ] Sequences with no tag, no `X`, no non-standard residue
- [ ] Exactly three designs, `design_id` consistent across all files
- [ ] 500–800 words
