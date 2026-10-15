-- SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
-- Copyright (c) 2026 Ahmad Ali Parr. All rights reserved.
-- Authored by Ahmad Ali Parr.
-- Database Schema: Protein Folding Bifurcation
-- Tables for theorems, axioms, invariants, drug discovery, and verification.
-- SQLite-compatible DDL.

-- =====================================================================
-- THEOREMS: Lean theorems (proved by kernel)
-- =====================================================================
CREATE TABLE IF NOT EXISTS theorems (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  file TEXT NOT NULL,                    -- ProteinFoldingBifurcation.lean | BifurcationTheorem.lean
  statement TEXT NOT NULL,              -- Theorem statement (Lean)
  proof_method TEXT NOT NULL,           -- 'kernel' | 'axiom' | 'sorry'
  sorry_count INTEGER NOT NULL DEFAULT 0,
  axioms_used TEXT,                     -- Comma-separated axiom names (NULL if none)
  verified_at TEXT NOT NULL             -- ISO 8601 timestamp
);

-- =====================================================================
-- AXIOMS: Lean axioms (Alloy-verified invariants)
-- =====================================================================
CREATE TABLE IF NOT EXISTS axioms (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,            -- axiomEnergyBounded, axiomMinimaCount, ...
  alloy_invariant TEXT NOT NULL,        -- Corresponding Alloy check name
  alloy_result TEXT NOT NULL,           -- 'UNSAT' (no counterexample)
  description TEXT NOT NULL
);

-- =====================================================================
-- INVARIANTS: Alloy invariants
-- =====================================================================
CREATE TABLE IF NOT EXISTS invariants (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,            -- EnergyBounded, MinimaCountCorrect, ...
  alloy_check TEXT NOT NULL,            -- Alloy check command
  result TEXT NOT NULL,                 -- 'UNSAT' | 'SAT'
  interpretation TEXT NOT NULL         -- What UNSAT/SAT means
);

-- =====================================================================
-- CONFORMATIONS: Folding states
-- =====================================================================
CREATE TABLE IF NOT EXISTS conformations (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,            -- Unfolded, Folded, Misfolded, Barrier
  regime TEXT NOT NULL,                 -- Neg | Zero | Pos
  energy REAL NOT NULL,                 -- 0 = minimum, 2 = barrier
  minima_count INTEGER NOT NULL,        -- 1 or 2
  drug_bound INTEGER NOT NULL DEFAULT 0 -- 0 = False, 1 = True
);

-- =====================================================================
-- DRUG_STRATEGIES: Drug discovery strategies from theorems
-- =====================================================================
CREATE TABLE IF NOT EXISTS drug_strategies (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,            -- Misfolding, Allosteric, Cryptic, Corrector, Aggregation
  theorem_name TEXT NOT NULL,           -- Theorem that justifies it
  mechanism TEXT NOT NULL,              -- How the drug works
  target_diseases TEXT,                 -- Comma-separated diseases
  barrier_effect TEXT                   -- How it affects barrier (raise/lower/tilt)
);

-- =====================================================================
-- VERIFICATION: Verification runs (Lean, Alloy, Agda, Liquid, Curry-Howard)
-- =====================================================================
CREATE TABLE IF NOT EXISTS verification (
  id INTEGER PRIMARY KEY,
  tool TEXT NOT NULL,                   -- Lean | Alloy | Agda | Liquid | CurryHoward
  file TEXT NOT NULL,
  result TEXT NOT NULL,                 -- 'PASS' | 'FAIL' | 'UNVERIFIED'
  details TEXT,
  verified_at TEXT NOT NULL
);

-- =====================================================================
-- SEED DATA
-- =====================================================================

-- Theorems (ProteinFoldingBifurcation.lean — 11, zero axioms)
INSERT OR IGNORE INTO theorems (name, file, statement, proof_method, sorry_count, axioms_used, verified_at) VALUES
  ('pitchfork_identity', 'ProteinFoldingBifurcation.lean', 'E + lam^2/4 = (x^2 - lam/2)^2', 'kernel', 0, NULL, '2026-10-14'),
  ('pitchfork_lower_bound', 'ProteinFoldingBifurcation.lean', 'E >= -lam^2/4 for lam > 0', 'kernel', 0, NULL, '2026-10-14'),
  ('pitchfork_min_pos', 'ProteinFoldingBifurcation.lean', 'E(sqrt(lam/2), lam) = -lam^2/4', 'kernel', 0, NULL, '2026-10-14'),
  ('pitchfork_min_neg', 'ProteinFoldingBifurcation.lean', 'E(-sqrt(lam/2), lam) = -lam^2/4', 'kernel', 0, NULL, '2026-10-14'),
  ('pitchfork_zero_not_min', 'ProteinFoldingBifurcation.lean', 'E(0, lam) = 0 > -lam^2/4', 'kernel', 0, NULL, '2026-10-14'),
  ('pitchfork_neg_unique_min', 'ProteinFoldingBifurcation.lean', 'E(0, lam) <= E(x, lam) for lam < 0', 'kernel', 0, NULL, '2026-10-14'),
  ('pitchfork_minima_distinct', 'ProteinFoldingBifurcation.lean', 'sqrt(lam/2) != -sqrt(lam/2)', 'kernel', 0, NULL, '2026-10-14'),
  ('pitchfork_bifurcation_count', 'ProteinFoldingBifurcation.lean', 'Two minima, equal energy, distinct', 'kernel', 0, NULL, '2026-10-14'),
  ('ramachandran_four_minima', 'ProteinFoldingBifurcation.lean', '4 minima in 2D', 'kernel', 0, NULL, '2026-10-14'),
  ('ramachandran_lower_bound', 'ProteinFoldingBifurcation.lean', 'E >= -(lam1^2 + lam2^2)/4', 'kernel', 0, NULL, '2026-10-14'),
  ('ramachandran_bifurcation', 'ProteinFoldingBifurcation.lean', 'Unique min at (0,0) for lam1,lam2 < 0', 'kernel', 0, NULL, '2026-10-14');

-- Theorems (BifurcationTheorem.lean — 9, built on axioms)
INSERT OR IGNORE INTO theorems (name, file, statement, proof_method, sorry_count, axioms_used, verified_at) VALUES
  ('bifurcationInvariant', 'BifurcationTheorem.lean', '0 <= energy AND minima correct', 'axiom', 0, 'axiomEnergyBounded,axiomMinimaCount', '2026-10-14'),
  ('posRegimeBounded', 'BifurcationTheorem.lean', 'Pos: energy >= 0, minima = 2', 'axiom', 0, 'axiomEnergyBounded,axiomMinimaCount', '2026-10-14'),
  ('pathwayPreservesEqual', 'BifurcationTheorem.lean', 'Folded energy = Misfolded energy', 'axiom', 0, 'axiomEqualMinima', '2026-10-14'),
  ('drugBoundValid', 'BifurcationTheorem.lean', 'Drug-bound folded is valid', 'axiom', 0, 'axiomDrugPreserves', '2026-10-14'),
  ('noDirectNegPos', 'BifurcationTheorem.lean', 'No Neg -> Pos skip', 'axiom', 0, 'axiomNoSkip', '2026-10-14'),
  ('barrierHeight', 'BifurcationTheorem.lean', 'Barrier = lam^2/4', 'kernel', 0, NULL, '2026-10-14'),
  ('barrierRaising', 'BifurcationTheorem.lean', 'lam < lam'' => barrier < barrier''', 'kernel', 0, NULL, '2026-10-14'),
  ('allostericSwitch', 'BifurcationTheorem.lean', 'Pos minima = Neg minima + 1', 'axiom', 0, 'axiomMinimaCount', '2026-10-14'),
  ('fullBifurcationInvariant', 'BifurcationTheorem.lean', 'All axioms combined', 'axiom', 0, 'axiomEnergyBounded,axiomMinimaCount,axiomNoSkip', '2026-10-14');

-- Axioms
INSERT OR IGNORE INTO axioms (name, alloy_invariant, alloy_result, description) VALUES
  ('axiomEnergyBounded', 'EnergyBounded', 'UNSAT', 'Energy >= 0 in all valid states'),
  ('axiomMinimaCount', 'MinimaCountCorrect', 'UNSAT', '1 min (Neg/Zero), 2 mins (Pos)'),
  ('axiomEqualMinima', 'EqualMinima', 'UNSAT', 'Folded = Misfolded energy'),
  ('axiomNoSkip', 'NoSkipBifurcation', 'UNSAT', 'Cannot go Neg -> Pos without Zero'),
  ('axiomDrugPreserves', 'DrugPreservesInvariant', 'UNSAT', 'Drug binding preserves validity');

-- Invariants
INSERT OR IGNORE INTO invariants (name, alloy_check, result, interpretation) VALUES
  ('EnergyBounded', 'check EnergyBounded', 'UNSAT', 'No counterexample: energy always >= 0'),
  ('MinimaCountCorrect', 'check MinimaCountCorrect', 'UNSAT', 'No counterexample: minima count matches regime'),
  ('EqualMinima', 'check EqualMinima', 'UNSAT', 'No counterexample: Folded = Misfolded energy'),
  ('NoSkipBifurcation', 'check NoSkipBifurcation', 'UNSAT', 'No counterexample: cannot skip bifurcation'),
  ('DrugPreservesInvariant', 'check DrugPreservesInvariant', 'UNSAT', 'No counterexample: drug preserves invariant'),
  ('BifurcationInvariant', 'check BifurcationInvariant', 'UNSAT', 'No counterexample: combined invariant holds');

-- Conformations
INSERT OR IGNORE INTO conformations (name, regime, energy, minima_count, drug_bound) VALUES
  ('Unfolded', 'Neg', 0.0, 1, 0),
  ('Barrier', 'Zero', 2.0, 1, 0),
  ('Folded', 'Pos', 0.0, 2, 0),
  ('Misfolded', 'Pos', 0.0, 2, 0),
  ('Folded-DrugBound', 'Pos', 0.0, 2, 1);

-- Drug strategies
INSERT OR IGNORE INTO drug_strategies (name, theorem_name, mechanism, target_diseases, barrier_effect) VALUES
  ('Misfolding', 'pitchfork_min_pos + pitchfork_min_neg', 'Raise barrier or tilt landscape to favor folded', 'Alzheimer''s, Parkinson''s, Prions', 'Raise'),
  ('Allosteric', 'pitchfork_bifurcation_count', 'Shift lam across 0 to switch minima count 1->2', 'Various (allosteric targets)', 'Switch'),
  ('Cryptic Pocket', 'ramachandran_four_minima', 'Bind cryptic intermediate minimum', 'KRAS G12C, others', 'Stabilize intermediate'),
  ('Corrector', 'pitchfork_neg_unique_min', 'Shift lam negative->positive to create folded minimum', 'Cystic Fibrosis (CFTR)', 'Create minimum'),
  ('Aggregation Inhibitor', 'ramachandran_lower_bound', 'Lower folded energy below misfolded', 'Amyloidosis, others', 'Tilt');

-- Verification
INSERT OR IGNORE INTO verification (tool, file, result, details, verified_at) VALUES
  ('Lean', 'ProteinFoldingBifurcation.lean', 'PASS', '11 theorems, 0 sorry, 0 custom axioms', '2026-10-14'),
  ('Lean', 'BifurcationTheorem.lean', 'PASS', '9 theorems, 0 sorry, 5 axioms (Alloy-verified)', '2026-10-14'),
  ('Alloy', 'alloy/ProteinFoldingBifurcation.als', 'PASS', '6 invariants UNSAT, 2 witnesses SAT', '2026-10-14'),
  ('Alloy', 'alloy/AlloyAxiomsCounterexamples.als', 'PASS', '3 theorems UNSAT, 5 counterexample searches UNSAT', '2026-10-14'),
  ('Agda', 'agda/BifurcationInvariant.agda', 'UNVERIFIED', 'Agda not installed on VM', '2026-10-14'),
  ('Liquid Haskell', 'liquid/BifurcationLiquid.hs', 'UNVERIFIED', 'Liquid Haskell not installed on VM', '2026-10-14'),
  ('Curry-Howard', 'curry-howard/CurryHoward.hs', 'UNVERIFIED', 'GHC not installed on VM', '2026-10-14');
