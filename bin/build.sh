#!/bin/bash
# Guess name of Isabelle/UTP home directory unless already set.
ISABELLE_UTP=${ISABELLE_UTP:-$(readlink -f $(dirname $0))/..}

# Directory for scripts and binary executables.
BIN_DIR=$ISABELLE_UTP/bin
CONTRIB_DIR=$ISABELLE_UTP/contrib
OPTICS_DIR=$ISABELLE_UTP/optics

# Check for Isabelle/UTP dependencies
bash "$BIN_DIR/utp_deps.sh"

ROOT=$ISABELLE_UTP

# Build all heap images of Isabelle/UTP

printf "\nBuilding Isabelle/UTP sessions... \n\n"

dirs=( "toolkit" "utp" "theories/kleene" "theories/designs" "theories/reactive" "theories/rea_designs" "theories/sf_rdes" "theories/circus" "tutorial" )
heaps=( "UTP-Toolkit" "UTP" "UTP-KAT" "UTP-Designs" "UTP-Reactive" "UTP-Reactive-Designs" "UTP-Stateful-Failures" "UTP-Circus" "UTP-Tutorial" )

for ((i=0;i<${#heaps[@]};++i));
do
	isabelle build -d $ROOT -d $OPTICS_DIR -d $CONTRIB_DIR -b "${heaps[i]}" || break
        if [ -f "$ISABELLE_UTP/${dirs[i]}/output/document.pdf" ]; then
                echo "Installing ${heaps[i]} documentation to doc/${heaps[i]}.pdf..."
		cp "$ISABELLE_UTP/${dirs[i]}/output/document.pdf" "$ISABELLE_UTP/doc/${heaps[i]}.pdf"
        fi

done
