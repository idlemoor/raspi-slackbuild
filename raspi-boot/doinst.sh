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
