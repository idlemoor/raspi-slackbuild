config() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "$(cat $OLD | md5sum)" = "$(cat $NEW | md5sum)" ]; then
    # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}

# Start with a wild guess
rootdev='mmcblk0p2'
if [ -L dev/root ]; then
  rootdev=/dev/$(readlink dev/root)
elif [ -f /tag/README ]; then
  rootdev=$(awk '{if ($2=="/mnt") print $1}' /proc/mounts)
elif [ -f proc/partitions ]; then
  # even wilder guesses :-(
  if grep -q mmcblk0p2 proc/partitions; then
    rootdev=/dev/mmcblk0p2
  elif grep -q mmcblk0p5 proc/partitions; then
    rootdev=/dev/mmcblk0p5
  fi
fi

sed -i -e "s:@ROOTDEV@:${rootdev}:" boot/cmdline.txt.new

config boot/cmdline.txt.new
