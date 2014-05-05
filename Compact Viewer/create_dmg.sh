#!/bin/bash

dir="$TEMP_FILE_DIR/disk"
dmg="$HOME/Desktop/$PROJECT_NAME.dmg"

rm -rf "$dir"
mkdir "$dir"
cp -R "$ARCHIVE_PRODUCTS_PATH/Applications/$PROJECT_NAME.app" "$dir"
ln -s "/Applications" "$dir/Applications"
rm -f "$dmg"
hdiutil create -srcfolder "$dir" -volname "$PROJECT_NAME" "$dmg"
rm -rf "$dir"

