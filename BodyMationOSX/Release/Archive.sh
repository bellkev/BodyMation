# Remove old dmg if it exists
rm BodyMation.dmg
# Make a temporary directory to mount the dmg
mkdir dmgdir
# Mount
hdiutil attach BodyMationTemplate.dmg -noautoopen -mountpoint dmgdir
# Copy in newest BodyMation app
rm -rf dmgdir/BodyMation.app
ditto BodyMation.app dmgdir/BodyMation.app
# Eject
hdiutil detach dmgdir -force
# Create compressed copy
hdiutil convert  BodyMationTemplate.dmg -format UDZO -o BodyMation.dmg
# Cleanup
rm -rf dmgdir