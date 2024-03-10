alias b := build

version := "0.1.0-12"

default:
  @just --choose

build:
  -mkdir build
  luarocks make nd-{{version}}.rockspec --tree build

test:
  busted ./

[confirm("Wipe build artefacts?")]
clear:
  rm -rf build
