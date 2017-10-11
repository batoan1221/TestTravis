#!/bin/sh

# The script exits immediately if any statement or command returns non-true value
echo "---------"

set -e
set -o pipefail

echo "----+----"

if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  echo "This is a pull request. No deployment."
  exit 0
fi

echo "-----++----"

if [[ "$TRAVIS_BRANCH" != "$TRAGET_BRANCH" ]]; then
  echo "Building on a branch other than master. No deployment."
  exit 0
fi

echo "----++++---"

if [ -z "$APP_MANAGER_API_TOKEN" ]; then
  echo "App Manager API token is missing. Abort deployment."
  exit 0
fi

echo "----*----"

PLIST_BUDDY="/usr/libexec/PlistBuddy"

echo ""
echo "************************************************************************"
echo "*                                Archive                               *"
echo "************************************************************************"
echo ""

echo ""
echo "************************************************************************"
echo "*                      Export Archive to IPA File                      *"
echo "************************************************************************"
echo ""

echo "=======$PROFILE_NAME====="

xcodebuild -exportArchive \
 -exportFormat IPA \
 -archivePath "$APP_NAME.xcarchive" \
 -exportPath "$APP_NAME.ipa" \
 -exportOptionsPlist "./exportOptions.plist" \
 -exportProvisioningProfile "$PROFILE_NAME"

echo ""
echo "************************************************************************"
echo "*         Upload IPA File to 2359 Media Enterprise App Manager         *"
echo "************************************************************************"
echo ""

VERSION_NUMBER=`$PLIST_BUDDY -c "Print CFBundleShortVersionString" "$INFO_PLIST_PATH"`
BUILD_NUMBER=`$PLIST_BUDDY -c "Print CFBundleVersion" "$INFO_PLIST_PATH"`
COMMIT=`echo $TRAVIS_COMMIT
VERSION="$VERSION_NUMBER ($BUILD_NUMBER) #$COMMIT "
curl https://app.2359media.net/api/v1/apps/$APP_ID/versions \
  -F binary="@$APP_NAME.ipa" \
  -F api_token="$APP_MANAGER_API_TOKEN" \
  -F platform="iOS" \
  -F version_number="$VERSION"
echo "\n"