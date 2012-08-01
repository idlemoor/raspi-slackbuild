config() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "$(cat $OLD | md5sum)" = "$(cat $NEW | md5sum)" ]; then
    # toss the redundant copy
    rm $NEW
  elif [ -f /.installer-version ]; then
    # We're in the Installer, so overwrite the Installer-specific file
    mv $NEW $OLD
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}

config boot/config.txt.new

# Handle the start.elf file. It should be a copy of one of the previous
# arm*_start.elf files, but which one?
if [ ! -f boot/start.elf ]; then
  # Fresh or broken installation, so just deliver the default
  mv boot/start.elf.new boot/start.elf
elif [ -f var/lib/raspi-boot/startelf.md5 ]; then
  startmd5=$(md5sum boot/start.elf | sed 's/  .*//')
  armfile=$(grep $startmd5 var/lib/raspi-boot/startelf.md5 | sed 's/^.*  //')
  if [ -f boot/$armfile ]; then
    # Yay!  Copy the right one and toss the default
    cp boot/$armfile boot/start.elf
    rm boot/start.elf.new
  else
    # No match, or the previous choice was abolished, so just deliver the default.
    # Don't leave the .new for the admin to consider as this might leave the
    # system unbootable (since some kernels require new firmware).
    mv boot/start.elf.new boot/start.elf
  fi
else
  # No record of previous md5sums, so just deliver the default
  mv boot/start.elf.new boot/start.elf
fi
# Finally, save the new md5sums
mv \
  var/lib/raspi-boot/startelf.md5.new \
  var/lib/raspi-boot/startelf.md5

# /boot is a fat filesystem, so you can't be too careful
sync;sync
