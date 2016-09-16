TAG=$(git describe --tags --long | sed -E -e 's,^[^0-9]*,,;s,([^-]*-g),r\1,;s,[-_],.,g')

clean () {
  rm -rf *.tar.gz;
  rm -rf build;
  rm -rf dist;
  mkdir build;
}

compress () {
  raco distribute dist build/infornography && echo 'Building successful';
  tar -czf infornography-$PLATFORM-$TAG.tar.gz dist && echo 'Compressed';
}

test_darwin () {
  racket infornography-macos.rkt
}

test_linux () {
  racket infornoraphy.rkt
}

build_darwin () {
  test_darwin;
  raco exe -o build/infornography infornography-macos.rkt;
  export PLATFORM="darwin"
}

build_linux () {
  test_linux;
  raco exe -o build/infornography infornography.rkt;
  export PLATFORM="linux"
}

build () {
  clean;

  if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    echo 'Building Darwin binaries...';
    build_darwin;
  else
    echo 'Building Linux binaries...';
    build_linux;
  fi

  compress;
}

build;
