cd "$(dirname "$0")" && lake build 2>&1 && lake env lean lake_env.lean 2>&1
