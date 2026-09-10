#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	fluidsynth		   \
	hicolor-icon-theme \
	libsamplerate	   \
	pipewire-audio 	   \
	pipewire-jack  	   \
	sdl2_mixer	   	   \
	sdl2_net

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano libdecor-mini

echo "Building Crispy Doom..."
echo "---------------------------------------------------------------"
REPO="https://github.com/fabiangreffrath/crispy-doom"
if [ "${DEVEL_RELEASE-}" = 1 ]; then
    echo "Making nightly build of Crispy Doom..."
    echo "---------------------------------------------------------------"
    VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
    git clone --depth 1 "$REPO" ./crispy-doom
else
	echo "Making stable build of Crispy Doom..."
	VERSION="$(git ls-remote --tags --sort="v:refname" "$REPO" | grep 'refs/tags/crispy-doom-[0-9]' | grep -v '\^{}' | tail -n1 | sed 's/.*\///; s/^crispy-doom-//')"
	git clone --branch "crispy-doom-$VERSION" --single-branch --depth 1 "$REPO" ./crispy-doom
fi
echo "$VERSION" > ~/version

cd ./crispy-doom
autoreconf -fi
./configure --prefix=/usr
make -j$(nproc)
make install
