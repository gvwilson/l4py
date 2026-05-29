cd "$(dirname "$0")" \
  && lake env lean --run code.lean 2 3 5 1.0 1.5 20240101 \
  && echo "---" \
  && lake env lean --run code.lean params.json
