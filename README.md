NOTE: tpacpi-bat superseded by thinkpad_acpi
============================================
As of Linux v5.17, the thinkpad_acpi kernel module has support for battery start/stop thresholds, inhibit charge and force discharge.

These are rough equivalents of tpacpi-bat userspace commands in thinkpad_acpi.
```
# tpacpi-bat -s ST 1 90   =>   echo 90 | sudo tee /sys/class/power_supply/BAT0/charge_control_start_threshold
# tpacpi-bat -s SP 1 90   =>   echo 90 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold

# tpacpi-bat -s ST 2 90   =>   echo 90 | sudo tee /sys/class/power_supply/BAT1/charge_control_start_threshold
# tpacpi-bat -s SP 2 90   =>   echo 90 | sudo tee /sys/class/power_supply/BAT1/charge_control_end_threshold

# tpacpi-bat -s FD 1 1    =>   echo force-discharge | sudo tee /sys/class/power_supply/BAT0/charge_behaviour
# tpacpi-bat -s FD 1 0    =>   echo auto            | sudo tee /sys/class/power_supply/BAT0/charge_behaviour
# tpacpi-bat -s IC 1 1    =>   echo inhibit-charge  | sudo tee /sys/class/power_supply/BAT0/charge_behaviour
# tpacpi-bat -s IC 1 1    =>   echo auto            | sudo tee /sys/class/power_supply/BAT0/charge_behaviour

# tpacpi-bat -g ST 1      =>   cat /sys/class/power_supply/BAT0/charge_control_start_threshold
# tpacpi-bat -g SP 1      =>   cat /sys/class/power_supply/BAT0/charge_control_end_threshold

# tpacpi-bat -g FD 1      =>   grep -q '\[force-discharge\]' /sys/class/power_supply/BAT0/charge_behaviour && echo yes || echo no
# tpacpi-bat -g IC 1      =>   grep -q '\[inhibit-charge\]'  /sys/class/power_supply/BAT0/charge_behaviour && echo yes || echo no
```

There may be differences in implementation between tpacpi-bat and thinkpad_acpi. In general, instead of using tpacpi-bat + acpi_call, users should prefer using the thinkpad_acpi kernel module.
The `acbreak` parameter to FD appears to be missing in thinkpad_acpi, but it usually doesn't work properly in tpacpi-bat anyway due to bugs or changes in the firmware driver.

----

tpacpi-bat - ThinkPad ACPI Battery Util
=======================================

Exposes ACPI interface for battery controls.
- force discharge
- inhibit charge
- start charge threshold
- stop charge threshold

This project is licensed under the GPLv3. See COPYING for details.

Copyright 2011-2016 Elliot Wolk

Installation
------------

- `install.pl` installs `acpi_call` from git and copies `tpacpi-bat` to /usr/bin
- `acpi_call` is required (https://github.com/teleshoes/acpi_call.git)
- `tpacpi-bat` has no other requirements besides perl; put it where you like

Startup systemd service
-----------------------

- Edit desired thresholds in `examples/tpacpi.conf.d`
- Copy `examples/tpacpi.service` to systemd unit dir (`/usr/lib/systemd/system`)
- Copy `tpacpi.conf.d` to `/etc/conf.d/tpacpi`

Supported Hardware
------------------
There is an unofficial, community-maintained list of supported ThinkPads here:
[Supported Hardware](../../wiki/Supported-Hardware)

Usage
-----

```
Usage:
  Show this message:
    tpacpi-bat [-h|--help]

  Get charge thresholds / inhibit charge / force discharge:
    tpacpi-bat [-v] -g ST <bat{1,2}>
    tpacpi-bat [-v] -g SP <bat{1,2}>
    tpacpi-bat [-v] -g IC <bat{1,2,0}>
    tpacpi-bat [-v] -g FD <bat{1,2}>

  Set charge thresholds / inhibit charge / force discharge:
    tpacpi-bat [-v] -s ST <bat{1,2,0}> <percent{0,1-99}>
    tpacpi-bat [-v] -s SP <bat{1,2,0}> <percent{0,1-99}>
    tpacpi-bat [-v] -s IC <bat{1,2,0}> <inhibit{1,0}> [<min{0,1-720,65535}>]
    tpacpi-bat [-v] -s FD <bat{1,2}> <discharge{1,0}> [<acbreak{1,0}>]

  Set peak shift state, which is mysterious and inhibits charge:
    tpacpi-bat [-v] -s PS <inhibit{1,0}> [<min{0,1-1440,65535}>]


  Synonyms:
    ST -> --st|--startThreshold|--start|st|startThreshold|start
    SP -> --sp|--stopThreshold|--stop|sp|stopThreshold|stop
    IC -> --ic|--inhibitCharge|--inhibit|ic|inhibitCharge|inhibit
    FD -> --fd|--forceDischarge|fd|forceDischarge
    PS -> --ps|--peakShiftState|ps|peakShiftState

  Options:
    -v           show ASL call and response
    <bat>        1 for main, 2 for secondary, 0 for either/both
    <min>        number of minutes, or 0 for never, or 65535 for forever
    <percent>    0 for default, 1-99 for percentage
    <inhibit>    1 for inhibit charge, 0 for stop inhibiting charge
    <discharge>  1 for force discharge, 0 for stop forcing discharge
    <acbreak>    1 for stop forcing when AC is detached, 0 for do not
    [] means optional: sets value to 0
```
