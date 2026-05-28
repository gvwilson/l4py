tmp=$(mktemp -d) && cp "$(dirname "$0")/add_dep.lean" "$tmp/lakefile.lean" && cd "$tmp" && echo "def main : IO Unit := pure ()" > Main.lean && lake update 2>&1
