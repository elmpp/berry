die() {
  echo "${1}"
  exit 1
}

if [ $# -lt 1 ]; then echo "Path to VSCode working copy required (or desired location if first time)"; exit 1; fi

set -e
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
VSCODE_DIR=$(realpath "${1}")
YARN2_DIR=$(realpath "${CURRENT_DIR}/../")

STEP_ID=0
step() {
  STEP_ID=$(($STEP_ID + 1))
  printf '%d. %s' "$STEP_ID" "$1"
  read
}


VSCODE_PID=
open_vscode() {
  checkout_vscode
  if [[ "$VSCODE_PID" != "" ]]; then
    kill -9 "$VSCODE_PID" >& /dev/null || true
    wait "$VSCODE_PID" >& /dev/null || true
  fi
  if [ $# -gt 1 ]; then
    step "VSCode (with zipfs extension) will open when you press enter. Working dir: '${1}'"
    "$VSCODE_DIR"/scripts/code.sh "$1" --install-extension "${VSCODE_DIR}/packages/vscode-zipfs/vscode-zipfs-0.1.1-3.vsix" >& /dev/null &
  else
    step "VSCode will open when you press enter. Working dir: '${1}'"
    "$VSCODE_DIR"/scripts/code.sh "$1" >& /dev/null &
  fi
  VSCODE_PID=$!
}

checkout_vscode() {
  if ! [[ -d "${VSCODE_DIR}" ]]; then
    git clone --depth 1 git@github.com:elmpp/vscode.git -b elmpp/yarn2-vscode-36943 "${VSCODE_DIR}" >& /dev/null
    (cd "${VSCODE_DIR}" && yarn set version (cd "$(realpath "$(mktemp -d)")" && yarn --version))
  fi
}

setup() {
  PM="$1"
  if [ "${PM}" = "yarn" ]; then yarn set version berry || true; fi
  shift

  echo
  echo 'Preparing a temporary folder...'

  cd "$(realpath "$(mktemp -d)")"
  "$PM" "$@" >& /dev/null
  "$PM" add @sindresorhus/slugify >& /dev/null

  cat > tsconfig.json <<EOF
{
  "compilerOptions": {
    "esModuleInterop": true,
    "moduleResolution": "node"
  }
}
EOF

  cat > index.ts <<EOF
import slugify from "@sindresorhus/slugify";
const x: number = slugify("foobar");
EOF
}

echo "This script will execute everything automatically; just follow the step"
echo "and press enter once you have checked the step works. If you wish to abort,"
echo "just press ctrl-c in this terminal."


## Tests regarding the feature itself

setup npm init -y
open_vscode "$(pwd)"

step "Open index.ts, check that 'x' has an error"
step "Remove the ': number', the error should disappear"
step "Command-click on '@sindresorhus/slugify' from 'import slugify', you should see a file open"


setup npm init -y
npm install typescript@2.9 >& /dev/null
open_vscode "$(pwd)"

step "Press Command+Shift+P, 'Select TypeScript version', 'Use workspace version'"
step "Check that 'Typescript 2.9' appears in the bottom-right of the window"
step "Check that 'x' has an error"
step "Remove the ': number', the error should disappear"
step "Command-click on '@sindresorhus/slugify', a tab should open on '.../slugify/index.d.ts'"
step "Going back to the previous file, command-click on 'slugify' from 'import slugify', you should see a bubble open"
step "Check that clicking on both 'namespace slugify {' and 'function slugify {' print more details in the bubble"
step "Check that double-clicking on both 'namespace slugify {' and 'function slugify {' leads you to the right symbols"


setup yarn init -2y
open_vscode "$(pwd)"

step "Open index.ts, check that '@sindresorhus/slugify' has an error (cannot find module)"
step "Open index.ts, check that 'x' has an error"
step "Check that 'Typescript 3.8.3' (or some other recent version) appears in the bottom-right of the window"
step "Remove the ': number', the error should disappear"
step "Command-click on '@sindresorhus/slugify', a tab should open on '.../slugify/index.d.ts'"
step "Going back to the previous file, command-click on 'slugify' from 'import slugify', you should see a bubble open"
step "Check that clicking on both 'namespace slugify {' and 'function slugify {' print more details in the bubble"
step "Check that double-clicking on both 'namespace slugify {' and 'function slugify {' leads you to the right symbols"


setup yarn init -2y
echo 'nodeLinker: node-modules' >> .yarnrc.yml
yarn add typescript@2.7.1 >& /dev/null
open_vscode "$(pwd)" 1

step "Open index.ts"
step "Press Command+Shift+P, 'Select TypeScript version', 'Use workspace version'"
step "Check that 'Typescript 2.7.1' appears in the bottom-right of the window"
step "Check that 'x' has an error"
step "Remove the ': number', the error should disappear"
step "Command-click on '@sindresorhus/slugify', a tab should open on '.../slugify/index.d.ts'"
step "Going back to the previous file, command-click on 'slugify' from 'import slugify', you should see a bubble open"
step "Check that clicking on both 'namespace slugify {' and 'function slugify {' print more details in the bubble"
step "Check that double-clicking on both 'namespace slugify {' and 'function slugify {' leads you to the right symbols"


setup yarn init -2y
echo 'nodeLinker: node-modules' >> .yarnrc.yml
yarn add typescript@3.5.1 >& /dev/null
open_vscode "$(pwd)" 1

step "Open index.ts"
step "Press Command+Shift+P, 'Select TypeScript version', 'Use workspace version'"
step "Check that 'Typescript 3.5.1' appears in the bottom-right of the window"
step "Check that 'x' has an error"
step "Remove the ': number', the error should disappear"
step "Command-click on '@sindresorhus/slugify', a tab should open on '.../slugify/index.d.ts'"
step "Going back to the previous file, command-click on 'slugify' from 'import slugify', you should see a bubble open"
step "Check that clicking on both 'namespace slugify {' and 'function slugify {' print more details in the bubble"
step "Check that double-clicking on both 'namespace slugify {' and 'function slugify {' leads you to the right symbols"


setup yarn init -2y
yarn add typescript@3.8 >& /dev/null
yarn node "${YARN2_DIR}/packages/yarnpkg-pnpify/sources/boot-cli-dev.js" --sdk
open_vscode "$(pwd)" 1

step "Open index.ts"
step "Press Command+Shift+P, 'Select TypeScript version', 'Use workspace version'"
step "Check that 'Typescript 3.8-pnpify' appears in the bottom-right of the window"
step "Check that 'x' has an error"
step "Remove the ': number', the error should disappear"
step "Command-click on '@sindresorhus/slugify', a tab should open on '.../slugify/index.d.ts' (you shouldn't see any error in the lower corner!)"
step "Going back to the previous file, command-click on 'slugify' from 'import slugify', you should see a bubble open"
step "Check that clicking on both 'namespace slugify {' and 'function slugify {' print more details in the bubble"
step "Check that double-clicking on both 'namespace slugify {' and 'function slugify {' leads you to the right symbols. Note here intellisense is not apparent (https://github.com/microsoft/vscode/issues/59650)"
