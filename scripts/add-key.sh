#!/bin/sh

# The script exits immediately if any statement or command returns non-true value
set -e

if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  echo "This is a pull request. Code signing isn't required."
  exit 0
fi
if [[ "$TRAVIS_BRANCH" != "$TRAGET_BRANCH" ]]; then
  echo "Building on a branch other than master. Code signing isn't required."
  exit 0
fi
if [ "$TRAVIS_REPO_SLUG" != "$REPO_SLUG" ]; then
  echo "It's not the main repo. Code signing isn't required."
fi

KEY_CHAIN=ios-build.keychain
security create-keychain -p travis $KEY_CHAIN
# Make the keychain the default so identities are found
security default-keychain -s $KEY_CHAIN
# Unlock the keychain
security unlock-keychain -p travis $KEY_CHAIN
# Set keychain locking timeout to 3600 seconds
security set-keychain-settings -t 3600 -u $KEY_CHAIN

security import ./scripts/certs/apple.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign
security import ./scripts/certs/ios_dist.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign
security import ./scripts/certs/ios_dist.p12 -k ~/Library/Keychains/ios-build.keychain -P '' -T /usr/bin/codesign

mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp ./scripts/profile/* ~/Library/MobileDevice/Provisioning\ Profiles/
ls ~/Library/MobileDevice/Provisioning\ Profiles/