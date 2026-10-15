-- SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
-- Copyright (c) 2026 Ahmad Ali Parr. All rights reserved.
-- Authored by Ahmad Ali Parr.
import Lake
open Lake DSL

package «bifurcation-invariant-verify» where
  leanOptions := #[⟨`autoImplicit, false⟩]

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.9.0"

@[default_target]
lean_lib «BifurcationTheorem» where
  roots := #[`BifurcationTheorem]
