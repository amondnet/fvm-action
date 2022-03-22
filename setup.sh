#!/bin/bash

$OS=$(echo "$RUNNER_OS" | awk '{print tolower($0)}')
VERSION="2.2.6"
RELEASE_BASE_URL="https://github.com/leoafarias/fvm/releases/download/${VERSION}"

ARCHIVE="fvm-${VERSION}-${$OS}-x64.tar.gz"
if [[ $OS == windows ]]; then
  ARCHIVE="fvm-${VERSION}-${$OS}-x64.zip"
fi
ARCHIVE_URL="${RELEASE_BASE_URL}/${ARCHIVE}"

download_archive() {
  archive_url="$ARCHIVE_URL"
  archive_name=$(basename $ARCHIVE)
  archive_local="$RUNNER_TEMP/$archive_name"

  echo "Downloading ${archive_url}..."
  curl --connect-timeout 15 --retry 5 $archive_url >$archive_local

  # Create the target folder
  echo "Create the target folder"
  mkdir -p "$1"

  if [[ $archive_name == *zip ]]; then
    unzip -q -o "$archive_local" -d "$RUNNER_TEMP"  > /dev/null
    # Remove the folder again so that the move command can do a simple rename
    # instead of moving the content into the target folder.
    # This is a little bit of a hack since the "mv --no-target-directory"
    # linux option is not available here
    rm -r "$1"
    mv ${RUNNER_TEMP}/flutter "$1"
  else
    tar xf "$archive_local" -C "$1" --strip-components=1
  fi
  if [ $? -ne 0 ]; then
    echo -e "::error::Download failed! Please check passed arguments."
    exit 1
  fi

  rm $archive_local
}

transform_path() {
  if [[ $OS == windows ]]; then
    echo $1 | sed -e 's/^\///' -e 's/\//\\/g'
  else
    echo $1
  fi
}

download_archive ./tmp

# Configure pub to use a fixed location.
echo "PUB_CACHE=${PUBCACHE}" >> $GITHUB_ENV
echo "Pub cache set to: ${PUBCACHE}"