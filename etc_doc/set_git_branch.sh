branch_file="/chemotion/BRANCH.txt"

if [ -f "$branch_file" ]; then
  ELN_BRANCH=$(head -n 1 "$branch_file" | tr -d '[:space:]')
else
  echo "main" > "$branch_file"
  ELN_BRANCH="main"
fi
export ELN_BRANCH=${ELN_BRANCH:-"main"}