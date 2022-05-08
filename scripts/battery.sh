#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $current_dir/utils.sh

linux_acpi() {
  arg=$1
  BAT=$(ls -d /sys/class/power_supply/BAT* | head -1)
  if [ ! -x "$(which acpi 2> /dev/null)" ];then
    case "$arg" in
      status)
        cat $BAT/status
        ;;

      percent)
        cat $BAT/capacity
        ;;

      *)
        ;;
    esac
  else
    case "$arg" in
      status)
        acpi | cut -d: -f2- | cut -d, -f1 | tr -d ' '
        ;;
      percent)
        acpi | cut -d: -f2- | cut -d, -f2 | tr -d '% '
        ;;
      *)
        ;;
    esac
  fi
}

battery_icon() {
  $bat_perc=$1
  $bat_stat=$2

  battery_0=''
  battery_10=''
  battery_20=''
  battery_30=''
  battery_40=''
  battery_50=''
  battery_60=''
  battery_70=''
  battery_80=''
  battery_90=''
  battery_100=''

  battery_charging_0=''
  battery_charging_10=''
  battery_charging_20=''
  battery_charging_30=''
  battery_charging_40=''
  battery_charging_50=''
  battery_charging_60=''
  battery_charging_70=''
  battery_charging_80=''
  battery_charging_90=''
  battery_charging_100=''


  if [[ (($bat_perc -ge 0) && ($bat_perc -lt 10)) ]]; then
    if [ "$bat_stat" = "AC" ]; then echo $battery_charging_0; else echo $battery_0; fi
  elif [[ (($bat_perc -ge 10) && ($bat_perc -lt 20)) ]]; then
    if [ "$bat_stat" = "AC" ]; then echo $battery_charging_10; else echo $battery_10; fi
  elif [[ (($bat_perc -ge 20) && ($bat_perc -lt 30)) ]]; then
    if [ "$bat_stat" = "AC" ]; then echo $battery_charging_20; else echo $battery_20; fi
  elif [[ (($bat_perc -ge 30) && ($bat_perc -lt 40)) ]]; then
    if [ "$bat_stat" = "AC" ]; then echo $battery_charging_30; else echo $battery_30; fi
  elif [[ (($bat_perc -ge 40) && ($bat_perc -lt 50)) ]]; then
    if [ "$bat_stat" = "AC" ]; then echo $battery_charging_40; else echo $battery_40; fi
  elif [[ (($bat_perc -ge 50) && ($bat_perc -lt 60)) ]]; then
    if [ "$bat_stat" = "AC" ]; then echo $battery_charging_50; else echo $battery_50; fi
  elif [[ (($bat_perc -ge 60) && ($bat_perc -lt 70)) ]]; then
    if [ "$bat_stat" = "AC" ]; then echo $battery_charging_60; else echo $battery_60; fi
  elif [[ (($bat_perc -ge 70) && ($bat_perc -lt 80)) ]]; then
    if [ "$bat_stat" = "AC" ]; then echo $battery_charging_70; else echo $battery_70; fi
  elif [[ (($bat_perc -ge 80) && ($bat_perc -lt 90)) ]]; then
    if [ "$bat_stat" = "AC" ]; then echo $battery_charging_80; else echo $battery_80; fi
  elif [[ (($bat_perc -ge 90) && ($bat_perc -lt 100)) ]]; then
    if [ "$bat_stat" = "AC" ]; then echo $battery_charging_90; else echo $battery_90 ; fi
  else
    if [ "$bat_stat" = "AC" ]; then echo $battery_charging_100; else echo $battery_100; fi
  fi
}

battery_percent()
{
  # Check OS
  case $(uname -s) in
    Linux)
      percent=$(linux_acpi percent)
      [ -n "$percent" ] && echo " $percent"
      ;;

    Darwin)
      echo $(pmset -g batt | grep -Eo '[0-9]?[0-9]?[0-9]%')
      ;;

    FreeBSD)
      echo $(apm | sed '8,11d' | grep life | awk '{print $4}')
      ;;

    CYGWIN*|MINGW32*|MSYS*|MINGW*)
      # leaving empty - TODO - windows compatability
      ;;

    *)
      ;;
  esac
}

battery_status()
{
  # Check OS
  case $(uname -s) in
    Linux)
      status=$(linux_acpi status)
      ;;

    Darwin)
      status=$(pmset -g batt | sed -n 2p | cut -d ';' -f 2 | tr -d " ")
      ;;

    FreeBSD)
      status=$(apm | sed '8,11d' | grep Status | awk '{printf $3}')
      ;;

    CYGWIN*|MINGW32*|MSYS*|MINGW*)
      # leaving empty - TODO - windows compatability
      ;;

    *)
      ;;
  esac

  case $status in
    discharging|Discharging)
      echo ''
      ;;
    high)
      echo ''
      ;;
    charging)
      echo 'AC'
      ;;
    *)
      echo 'AC'
      ;;
  esac
  ### Old if statements didn't work on BSD, they're probably not POSIX compliant, not sure
  # if [ $status = 'discharging' ] || [ $status = 'Discharging' ]; then
  # 	echo ''
  # # elif [ $status = 'charging' ]; then # This is needed for FreeBSD AC checking support
  # 	# echo 'AC'
  # else
  #  	echo 'AC'
  # fi
}

main()
{
  bat_label=$(get_tmux_option "@dracula-battery-label" "♥")
  bat_stat=$(battery_status)
  bat_perc=$(battery_percent)

  bat_label=$(battery_icon $bat_perc $bat_stat)

  if [ -z "$bat_stat" ]; then # Test if status is empty or not
    echo "$bat_label $bat_perc%"
  elif [ -z "$bat_perc" ]; then # In case it is a desktop with no battery percent, only AC power
    echo "$bat_label $bat_stat"
  else
    # echo "$bat_label $bat_stat $bat_perc%"
    echo "$bat_label $bat_perc%"
  fi
}

#run main driver program
main
