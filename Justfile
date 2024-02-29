alias b := build

luajit_dir := `nix path-info nixpkgs#luajit`

default:
  @just --choose

build:
  rm -rf build
  mkdir build
  cd src && luastatic \
    nd.lua \
    nd/*.lua \
    {{luajit_dir}}/lib/libluajit-5.1.a \
    -I{{luajit_dir}}/include/luajit-2.1 \
    -no-pie \
    -o ../build/nd
  mv src/nd.luastatic.c build/

install: build
  cp ./build/nd ~/.local/bin/nd

test:
  busted ./

[confirm("Wipe build artefacts and installed binaries?")]
clear:
  rm -rf build
  -rm ~/.local/bin/nd
