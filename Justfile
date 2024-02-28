alias b := build

luajit_dir := `nix path-info nixpkgs#luajit`

default:
  @just --choose

build:
  rm -rf build
  mkdir build
  cd src && luastatic \
    end.lua \
    end/*.lua \
    {{luajit_dir}}/lib/libluajit-5.1.a \
    -I{{luajit_dir}}/include/luajit-2.1 \
    -no-pie \
    -o ../build/end
  mv src/end.luastatic.c build/

test:
  busted ./

[confirm("Wipe build artefacts?")]
clear:
  rm -rf build
