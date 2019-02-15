#!/usr/bin/env bash

function configure_submodules()
{
  git submodule init
  git submodule update
  git submodule status
}
function configure_croaring()
{
  pushd .

  cd deps/CRoaring

  # generates header files
  ./amalgamation.sh

  # https://github.com/RoaringBitmap/CRoaring#building-with-cmake-linux-and-macos-visual-studio-users-should-see-below
#  rm -rf  build
  mkdir -p build
  cd build
  cmake -DBUILD_STATIC=ON -DCMAKE_BUILD_TYPE=Debug ..
  make

  popd
}
function configure_redis()
{
  cd deps/redis
  make
  cd -
}
function configure_hiredis()
{
  cd deps/hiredis
  make
  cd -
}
function build()
{
  mkdir -p build
  cd build
  cmake ..
  make
  local LIB=$(find libredis-roaring*)
  local DEP_LIB=$(find ../deps -type f -name libroaring.so)
  
  cd ..
  mkdir -p dist
  cp "build/$LIB" dist
  cp "build/$DEP_LIB" dist
  cp deps/redis/redis.conf dist
  cp deps/redis/src/{redis-benchmark,redis-check-aof,redis-check-rdb,redis-cli,redis-sentinel,redis-server} dist
  echo "loadmodule $(pwd)/dist/$LIB" >> dist/redis.conf
}
function instructions()
{
  echo ""
  echo "Start redis server with redis-roaring:"
  echo "./dist/redis-server ./dist/redis.conf"  
  echo "Connect to server:"
  echo "./dist/redis-cli"
}
function makedeb()
{
  echo "Making debian package with binary for amd64"
  mkdir -p libredis-roaring/usr/lib
  cp ./dist/libroaring.so ./dist/libredis-roaring.so ./libredis-roaring/usr/lib/
  dpkg-deb --build libredis-roaring
  mkdir -p dist
  mv libredis-roaring.deb dist/
}

configure_submodules
configure_croaring
configure_redis
configure_hiredis
build
makedeb
instructions
