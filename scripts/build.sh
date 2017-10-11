#!/bin/sh

# The script exits immediately if any statement or command returns non-true value
set -e
set -o pipefail

DESTINATION="platform=iOS Simulator,name=iPhone Retina (4-inch)"

echo ""
echo "************************************************************************"
echo "*                                Build                                 *"
echo "************************************************************************"
echo ""

cd ./ios
xcodebuild \
 -project "$PROJECT_NAME" \
 -scheme "$APP_NAME" \
 -destination "$DESTINATION" build | xcpretty -c 
cd ../