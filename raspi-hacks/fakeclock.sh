#!/bin/sh

# fakeclock.sh
# Script to save and restore system clock if there's no hardware clock
#
# Copyright 2012 David Spencer, Baildon, West Yorkshire, U.K.
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# NOTES:
#
# This script is a limited drop-in replacement of util-linux's hwclock, for use
# on systems that don't have a proper hardware clock.  It is intended to be
# called from Slackware's rc scripts by moving /sbin/hwclock to hwclock.orig
# and replacing hwclock with a symlink to this script; the Slackware rc scripts
# do not need to be modified.
#
# The only control argument recognised is --hctosys.  All other arguments
# are ignored.  If --hctosys is present, the date/time is restored from
# /etc/fakeclock or the newest entry in /var/log (whichever is newer).
# Otherwise, the date/time is saved to /etc/fakeclock.  
#
# The script will only set the system clock when the system clock currently is
# before the year 1971.  This permits the safe use of this script if an RTC is
# present but unreliable (e.g. a failing battery).

action='save'
while [ "$#" != 0 ]
do
  case "$1"
  in
    "--hctosys") action='restore' ;;
    *) ;;
  esac
  shift
done

if [ "$action" = 'restore' ]; then
  if [ $(date '+%Y') -lt '1971' ]; then
    mydate="19900101000000"
    if [ -f /etc/fakeclock ]; then
      mydate=$(TZ=0 stat -c %y /etc/fakeclock | cut -c '1-4,6-7,9-10,12-13,15-16,18-19')
    fi
    if [ -d /var/log ]; then
      vldate=0
      newest=$(ls -t /var/log 2>/dev/null | head -1)
      [ -n "$newest" ] && vldate=$(TZ=0 stat -c %y /var/log/"$newest" | cut -c '1-4,6-7,9-10,12-13,15-16,18-19')
      [ "$vldate" -gt "$mydate" ] && mydate="$vldate"
    fi
    date --utc "${mydate:4:8}${mydate:0:4}.${mydate:12:2}"
  fi
  # We still need the original hwclock to set the system timezone.
  /sbin/hwclock.orig --systz
else
  # save
  touch /etc/fakeclock
fi

exit 0
