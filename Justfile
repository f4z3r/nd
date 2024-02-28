alias b := build

luajit_dir := `nix path-info nixpkgs#luajit`

build:
  rm -rf build
  mkdir build
  luastatic \
    end.lua \
    end/*.lua \
    {{luajit_dir}}/lib/libluajit-5.1.a \
    -I{{luajit_dir}}/include/luajit-2.1 \
    -no-pie \
    -o build/end
  mv end.luastatic.c build/

