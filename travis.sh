clean () {
  rm -rf *.tar.gz;
  rm -rf build;
  rm -rf dist;
  mkdir build;
}

compress () {
  raco distribute dist build/infornography;
  tar -czf infornography-$PLATFORM-$TAG.tar.gz dist;
  echo 'Building successful';
}

build_darwin () {
  raco exe -o build/infornography infornography-macos.rkt;
  export PLATFORM="darwin"
  export TAG=$(git describe --tags --long | sed -r -e 's,^[^0-9]*,,;s,([^-]*-g),r\1,;s,[-_],.,g')
}

build_linux () {
  raco exe -o build/infornography infornography.rkt;
  export PLATFORM="linux"
  export TAG=$(git describe --tags --long | sed -E -e 's,^[^0-9]*,,;s,([^-]*-g),r\1,;s,[-_],.,g')
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
