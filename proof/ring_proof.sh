cd "$(dirname "$0")" && lake update 2>&1 && lake exe cache get 2>&1 && lake build ProofFiles 2>&1 && lake env lean ring_proof.lean 2>&1
