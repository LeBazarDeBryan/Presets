#!/usr/bin/env bash
# https://privacy.sexy — v0.13.6 — Sat, 16 Nov 2024 09:19:06 GMT
if [ "$EUID" -ne 0 ]; then
  script_path=$([[ "$0" = /* ]] && echo "$0" || echo "$PWD/${0#./}")
  sudo "$script_path" || (
    echo 'Administrator privileges are required.'
    exit 1
  )
  exit 0
fi
export HOME="/home/${SUDO_USER:-${USER}}" # Keep `~` and `$HOME` for user not `/root`.


# ----------------------------------------------------------
# ------------------Disable .NET telemetry------------------
# ----------------------------------------------------------
echo '--- Disable .NET telemetry'
variable='DOTNET_CLI_TELEMETRY_OPTOUT'
value='1'
declaration_file='/etc/environment'
if ! [ -f "$declaration_file" ]; then
  echo "\"$declaration_file\" does not exist."
  sudo touch "$declaration_file"
  echo "Created $declaration_file."
fi
assignment_start="$variable="
assignment="$variable=$value"
if ! grep --quiet "^$assignment_start" "${declaration_file}"; then
  echo "Variable \"$variable\" was not configured before."
  echo -n $'\n'"$assignment" | sudo tee -a "$declaration_file" > /dev/null
  echo "Successfully configured ($assignment)."
else
  if grep --quiet "^$assignment$" "${declaration_file}"; then
    echo "Skipping. Variable \"$variable\" is already set to value \"$value\"."
  else
    if ! sudo sed --in-place "/^$assignment_start/d" "$declaration_file"; then
      >&2 echo "Failed to delete assignment starting with \"$assignment_start\"."
    else
      echo "Successfully deleted unexpected assignment of \"$variable\"."
      if ! echo -n $'\n'"$assignment" | sudo tee -a "$declaration_file" > /dev/null; then
        >&2 echo "Failed to add assignment \"$assignment\"."
      else
        echo "Successfully reconfigured ($assignment)."
      fi
    fi
  fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------------Clear Wine cache---------------------
# ----------------------------------------------------------
echo '--- Clear Wine cache'
# Temporary Windows files for global prefix
rm -rfv ~/.wine/drive_c/windows/temp/*
# Wine cache:
rm -rfv ~/.cache/wine/
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------------Clear Winetricks cache------------------
# ----------------------------------------------------------
echo '--- Clear Winetricks cache'
rm -rfv ~/.cache/winetricks/
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------Clear Visual Studio Code crash reports----------
# ----------------------------------------------------------
echo '--- Clear Visual Studio Code crash reports'
# Crash\ Reports: Global installation (also Snap with --classic)
rm -rfv ~/.config/Code/Crash\ Reports/*
# Crash\ Reports: Flatpak installation
rm -rfv ~/.var/app/com.visualstudio.code/config/Code/Crash\ Reports/*
# exthost\ Crash\ Reports: Global installation (also Snap with --classic)
rm -rfv ~/.config/Code/exthost\ Crash\ Reports/*
# exthost\ Crash\ Reports: Flatpak installation
rm -rfv ~/.var/app/com.visualstudio.code/config/Code/exthost\ Crash\ Reports/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Clear Visual Studio Code logs---------------
# ----------------------------------------------------------
echo '--- Clear Visual Studio Code logs'
# logs: Global installation (also Snap with --classic)
rm -rfv ~/.config/Code/logs/*
# logs: Flatpak installation
rm -rfv ~/.var/app/com.visualstudio.code/config/Code/logs/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Clear Azure CLI telemetry data--------------
# ----------------------------------------------------------
echo '--- Clear Azure CLI telemetry data'
rm -rfv ~/.azure/telemetry
rm -fv ~/.azure/telemetry.txt
rm -fv ~/.azure/logs/telemetry.txt
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------------Clear Azure CLI logs-------------------
# ----------------------------------------------------------
echo '--- Clear Azure CLI logs'
rm -rfv ~/.azure/logs
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------------Clear Azure CLI cache-------------------
# ----------------------------------------------------------
echo '--- Clear Azure CLI cache'
if ! command -v 'az' &> /dev/null; then
  echo 'Skipping because "az" is not found.'
else
  az cache purge
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------------Clear Firefox cache--------------------
# ----------------------------------------------------------
echo '--- Clear Firefox cache'
# Global installation
rm -rfv ~/.cache/mozilla/*
# Flatpak installation
rm -rfv ~/.var/app/org.mozilla.firefox/cache/*
# Snap installation
rm -rfv ~/snap/firefox/common/.cache/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------Clear Firefox crash reports----------------
# ----------------------------------------------------------
echo '--- Clear Firefox crash reports'
# Global installation
rm -fv ~/.mozilla/firefox/Crash\ Reports/*
# Flatpak installation
rm -rfv ~/.var/app/org.mozilla.firefox/.mozilla/firefox/Crash\ Reports/*
# Snap installation
rm -rfv ~/snap/firefox/common/.mozilla/firefox/Crash\ Reports/*
# Delete files matching pattern: "~/.mozilla/firefox/*/crashes/*"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.mozilla/firefox/*/crashes/*'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/crashes/*"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/crashes/*'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/snap/firefox/common/.mozilla/firefox/*/crashes/*"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/snap/firefox/common/.mozilla/firefox/*/crashes/*'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/.mozilla/firefox/*/crashes/events/*"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.mozilla/firefox/*/crashes/events/*'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/crashes/events/*"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/crashes/events/*'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/snap/firefox/common/.mozilla/firefox/*/crashes/events/*"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/snap/firefox/common/.mozilla/firefox/*/crashes/events/*'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------------Remove old Snap packages-----------------
# ----------------------------------------------------------
echo '--- Remove old Snap packages'
if ! command -v 'snap' &> /dev/null; then
  echo 'Skipping because "snap" is not found.'
else
  snap list --all | while read name version rev tracking publisher notes; do
  if [[ $notes = *disabled* ]]; then
    sudo snap remove "$name" --revision="$rev";
  fi
done
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Remove orphaned Flatpak runtimes-------------
# ----------------------------------------------------------
echo '--- Remove orphaned Flatpak runtimes'
if ! command -v 'flatpak' &> /dev/null; then
  echo 'Skipping because "flatpak" is not found.'
else
  flatpak uninstall --unused --noninteractive
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------Clear obsolete APT packages----------------
# ----------------------------------------------------------
echo '--- Clear obsolete APT packages'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  sudo apt-get autoclean
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------Clear orphaned APT package dependencies----------
# ----------------------------------------------------------
echo '--- Clear orphaned APT package dependencies'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  sudo apt-get -y autoremove --purge
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------Disable participation in Popularity Contest--------
# ----------------------------------------------------------
echo '--- Disable participation in Popularity Contest'
config_file='/etc/popularity-contest.conf'
if [ -f "$config_file" ]; then
  sudo sed -i '/PARTICIPATE/c\PARTICIPATE=no' "$config_file"
else
  echo "Skipping because configuration file at ($config_file) is not found. Is popcon installed?"
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------Disable weekly `pkgstats` submission-----------
# ----------------------------------------------------------
echo '--- Disable weekly `pkgstats` submission'
if ! command -v 'systemctl' &> /dev/null; then
  echo 'Skipping because "systemctl" is not found.'
else
  service='pkgstats.timer'
if systemctl list-units --full -all | grep --fixed-strings --quiet "$service"; then # service exists
  if systemctl is-enabled --quiet "$service"; then
    if systemctl is-active --quiet "$service"; then
      echo "Service $service is running now, stopping it."
      if ! sudo systemctl stop "$service"; then
        >&2 echo "Could not stop $service."
      else
        echo 'Successfully stopped'
      fi
    fi
    if sudo systemctl disable "$service"; then
      echo "Successfully disabled $service."
    else
      >&2 echo "Failed to disable $service."
    fi
  else
    echo "Skipping, $service is already disabled."
  fi
else
  echo "Skipping, $service does not exist."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---Disable participation in metrics reporting in Ubuntu---
# ----------------------------------------------------------
echo '--- Disable participation in metrics reporting in Ubuntu'
if ! command -v 'ubuntu-report' &> /dev/null; then
  echo 'Skipping because "ubuntu-report" is not found.'
else
  if ubuntu-report -f send no; then
  echo 'Successfully opted out.'
else
  >&2 echo 'Failed to opt out.'
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------------Disable Apport service------------------
# ----------------------------------------------------------
echo '--- Disable Apport service'
if ! command -v 'systemctl' &> /dev/null; then
  echo 'Skipping because "systemctl" is not found.'
else
  service='apport'
if systemctl list-units --full -all | grep --fixed-strings --quiet "$service"; then # service exists
  if systemctl is-enabled --quiet "$service"; then
    if systemctl is-active --quiet "$service"; then
      echo "Service $service is running now, stopping it."
      if ! sudo systemctl stop "$service"; then
        >&2 echo "Could not stop $service."
      else
        echo 'Successfully stopped'
      fi
    fi
    if sudo systemctl disable "$service"; then
      echo "Successfully disabled $service."
    else
      >&2 echo "Failed to disable $service."
    fi
  else
    echo "Skipping, $service is already disabled."
  fi
else
  echo "Skipping, $service does not exist."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# --Disable participation in Apport error messaging system--
# ----------------------------------------------------------
echo '--- Disable participation in Apport error messaging system'
if [ -f /etc/default/apport ]; then
  sudo sed -i 's/enabled=1/enabled=0/g' /etc/default/apport
  echo 'Successfully disabled apport.'
else
  echo 'Skipping, apport is not configured to be enabled.'
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------------Disable Whoopsie service-----------------
# ----------------------------------------------------------
echo '--- Disable Whoopsie service'
if ! command -v 'systemctl' &> /dev/null; then
  echo 'Skipping because "systemctl" is not found.'
else
  service='whoopsie'
if systemctl list-units --full -all | grep --fixed-strings --quiet "$service"; then # service exists
  if systemctl is-enabled --quiet "$service"; then
    if systemctl is-active --quiet "$service"; then
      echo "Service $service is running now, stopping it."
      if ! sudo systemctl stop "$service"; then
        >&2 echo "Could not stop $service."
      else
        echo 'Successfully stopped'
      fi
    fi
    if sudo systemctl disable "$service"; then
      echo "Successfully disabled $service."
    else
      >&2 echo "Failed to disable $service."
    fi
  else
    echo "Skipping, $service is already disabled."
  fi
else
  echo "Skipping, $service does not exist."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Disable crash report submissions-------------
# ----------------------------------------------------------
echo '--- Disable crash report submissions'
if [ -f /etc/default/whoopsie ] ; then
  sudo sed -i 's/report_crashes=true/report_crashes=false/' /etc/default/whoopsie
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------Disable Visual Studio Code telemetry-----------
# ----------------------------------------------------------
echo '--- Disable Visual Studio Code telemetry'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'telemetry.telemetryLevel'
target = json.loads('"off"')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'telemetry.enableTelemetry'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'telemetry.enableCrashReporter'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# Disable online experiments by Microsoft in Visual Studio Code
echo '--- Disable online experiments by Microsoft in Visual Studio Code'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'workbench.enableExperiments'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------Enable Firefox tracking protection------------
# ----------------------------------------------------------
echo '--- Enable Firefox tracking protection'
pref_name='privacy.trackingprotection.enabled'
pref_value='true'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# Disable WebRTC exposure of your private IP address in Firefox
echo '--- Disable WebRTC exposure of your private IP address in Firefox'
pref_name='media.peerconnection.ice.default_address_only'
pref_value='true'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# Disable collection of technical and interaction data in Firefox
echo '--- Disable collection of technical and interaction data in Firefox'
pref_name='datareporting.healthreport.uploadEnabled'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----Disable detailed telemetry collection in Firefox-----
# ----------------------------------------------------------
echo '--- Disable detailed telemetry collection in Firefox'
pref_name='toolkit.telemetry.enabled'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------Disable archiving of Firefox telemetry----------
# ----------------------------------------------------------
echo '--- Disable archiving of Firefox telemetry'
pref_name='toolkit.telemetry.archive.enabled'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------Disable Firefox unified telemetry-------------
# ----------------------------------------------------------
echo '--- Disable Firefox unified telemetry'
pref_name='toolkit.telemetry.unified'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Clear Firefox telemetry user ID--------------
# ----------------------------------------------------------
echo '--- Clear Firefox telemetry user ID'
pref_name='toolkit.telemetry.cachedClientID'
pref_value='""'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------Disable Firefox Pioneer study monitoring---------
# ----------------------------------------------------------
echo '--- Disable Firefox Pioneer study monitoring'
pref_name='toolkit.telemetry.pioneer-new-studies-available'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Clear Firefox pioneer program ID-------------
# ----------------------------------------------------------
echo '--- Clear Firefox pioneer program ID'
pref_name='toolkit.telemetry.pioneerId'
pref_value='""'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------Enable dynamic First-Party Isolation (dFPI)--------
# ----------------------------------------------------------
echo '--- Enable dynamic First-Party Isolation (dFPI)'
pref_name='network.cookie.cookieBehavior'
pref_value='5'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------Enable Firefox network partitioning------------
# ----------------------------------------------------------
echo '--- Enable Firefox network partitioning'
pref_name='privacy.partition.network_state'
pref_value='true'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------Minimize Firefox telemetry logging verbosity-------
# ----------------------------------------------------------
echo '--- Minimize Firefox telemetry logging verbosity'
pref_name='toolkit.telemetry.log.level'
pref_value='"Fatal"'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------Disable Firefox telemetry log output-----------
# ----------------------------------------------------------
echo '--- Disable Firefox telemetry log output'
pref_name='toolkit.telemetry.log.dump'
pref_value='"Fatal"'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------Disable pings to Firefox telemetry server---------
# ----------------------------------------------------------
echo '--- Disable pings to Firefox telemetry server'
pref_name='toolkit.telemetry.server'
pref_value='""'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Disable Firefox shutdown ping---------------
# ----------------------------------------------------------
echo '--- Disable Firefox shutdown ping'
pref_name='toolkit.telemetry.shutdownPingSender.enabled'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
pref_name='toolkit.telemetry.shutdownPingSender.enabledFirstSession'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
pref_name='toolkit.telemetry.firstShutdownPing.enabled'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Disable Firefox new profile ping-------------
# ----------------------------------------------------------
echo '--- Disable Firefox new profile ping'
pref_name='toolkit.telemetry.newProfilePing.enabled'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------Disable Firefox update ping----------------
# ----------------------------------------------------------
echo '--- Disable Firefox update ping'
pref_name='toolkit.telemetry.updatePing.enabled'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------------Disable Firefox prio ping-----------------
# ----------------------------------------------------------
echo '--- Disable Firefox prio ping'
pref_name='toolkit.telemetry.prioping.enabled'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------------------Empty trash------------------------
# ----------------------------------------------------------
echo '--- Empty trash'
# Empty global trash
rm -rfv ~/.local/share/Trash/*
sudo rm -rfv /root/.local/share/Trash/*
# Empty Snap trash
rm -rfv ~/snap/*/*/.local/share/Trash/*
# Empty Flatpak trash (apps may not choose to use Portal API)
rm -rfv ~/.var/app/*/data/Trash/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Clear global temporary folders--------------
# ----------------------------------------------------------
echo '--- Clear global temporary folders'
sudo rm -rfv /tmp/*
sudo rm -rfv /var/tmp/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------------Clear user-specific cache-----------------
# ----------------------------------------------------------
echo '--- Clear user-specific cache'
rm -rfv ~/.cache/*
sudo rm -rfv root/.cache/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------------Clear system-wide cache------------------
# ----------------------------------------------------------
echo '--- Clear system-wide cache'
rm -rf /var/cache/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Clear Flatpak application cache--------------
# ----------------------------------------------------------
echo '--- Clear Flatpak application cache'
rm -rfv ~/.var/app/*/cache/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------Clear Snap application cache---------------
# ----------------------------------------------------------
echo '--- Clear Snap application cache'
rm -fv ~/snap/*/*/.cache/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Clear thumbnails (icon cache)---------------
# ----------------------------------------------------------
echo '--- Clear thumbnails (icon cache)'
rm -rfv ~/.thumbnails/*
rm -rfv ~/.cache/thumbnails/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------Clear GTK recently used files list------------
# ----------------------------------------------------------
echo '--- Clear GTK recently used files list'
# From global installations
rm -fv /.recently-used.xbel
rm -fv ~/.local/share/recently-used.xbel*
# From snap packages
rm -fv ~/snap/*/*/.local/share/recently-used.xbel
# From Flatpak packages
rm -fv ~/.var/app/*/data/recently-used.xbel
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------Clear KDE-tracked recently used items list--------
# ----------------------------------------------------------
echo '--- Clear KDE-tracked recently used items list'
# From global installations
rm -rfv ~/.local/share/RecentDocuments/*.desktop
rm -rfv ~/.kde/share/apps/RecentDocuments/*.desktop
rm -rfv ~/.kde4/share/apps/RecentDocuments/*.desktop
# From snap packages
rm -fv ~/snap/*/*/.local/share/*.desktop
# From Flatpak packages
rm -rfv ~/.var/app/*/data/*.desktop
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Clear system crash report files--------------
# ----------------------------------------------------------
echo '--- Clear system crash report files'
sudo rm -rfv /var/crash/*
sudo rm -rfv /var/lib/systemd/coredump/
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Clear system logs (`journald`)--------------
# ----------------------------------------------------------
echo '--- Clear system logs (`journald`)'
if ! command -v 'journalctl' &> /dev/null; then
  echo 'Skipping because "journalctl" is not found.'
else
  sudo journalctl --vacuum-time=1s
fi
sudo rm -rfv /run/log/journal/*
sudo rm -rfv /var/log/journal/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------Clear Zeitgeist data (activity logs)-----------
# ----------------------------------------------------------
echo '--- Clear Zeitgeist data (activity logs)'
sudo rm -rfv {/root,/home/*}/.local/share/zeitgeist
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------Clear Firefox autocomplete history------------
# ----------------------------------------------------------
echo '--- Clear Firefox autocomplete history'
# Delete files matching pattern: "~/.mozilla/firefox/*/formhistory.sqlite"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.mozilla/firefox/*/formhistory.sqlite'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/formhistory.sqlite"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/formhistory.sqlite'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# Delete files matching pattern: "~/snap/firefox/common/.mozilla/firefox/*/formhistory.sqlite"
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
import glob
import os
path = '~/snap/firefox/common/.mozilla/firefox/*/formhistory.sqlite'
expanded_path = os.path.expandvars(os.path.expanduser(path))
print(f'Deleting files matching pattern: {expanded_path}')
paths = glob.glob(expanded_path)
if not paths:
  print('Skipping, no paths found.')
for path in paths:
  if not os.path.isfile(path):
    print(f'Skipping folder: "{path}".')
    continue
  os.remove(path)
  print(f'Successfully delete file: "{path}".')
print(f'Successfully deleted {len(paths)} file(s).')
EOF
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------------Clear GNOME Web cache-------------------
# ----------------------------------------------------------
echo '--- Clear GNOME Web cache'
# Global installation
rm -rfv /.cache/epiphany/*
# Flatpak installation
rm -rfv ~/.var/app/org.gnome.Epiphany/cache/*
# Snap installation
rm -rfv ~/~/snap/epiphany/common/.cache/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Clear GNOME Web browsing history-------------
# ----------------------------------------------------------
echo '--- Clear GNOME Web browsing history'
# ephy-history.db: Global installation
rm -fv ~/.local/share/epiphany/ephy-history.db
# ephy-history.db: Flatpak installation
rm -fv ~/.var/app/org.gnome.Epiphany/data/epiphany/ephy-history.db
# ephy-history.db: Snap installation
rm -fv ~/snap/epiphany/*/.local/share/epiphany/ephy-history.db
# ephy-history.db-shm: Global installation
rm -fv ~/.local/share/epiphany/ephy-history.db-shm
# ephy-history.db-shm: Flatpak installation
rm -fv ~/.var/app/org.gnome.Epiphany/data/epiphany/ephy-history.db-shm
# ephy-history.db-shm: Snap installation
rm -fv ~/snap/epiphany/*/.local/share/epiphany/ephy-history.db-shm
# ephy-history.db-wal: Global installation
rm -fv ~/.local/share/epiphany/ephy-history.db-wal
# ephy-history.db-wal: Flatpak installation
rm -fv ~/.var/app/org.gnome.Epiphany/data/epiphany/ephy-history.db-wal
# ephy-history.db-wal: Snap installation
rm -fv ~/snap/epiphany/*/.local/share/epiphany/ephy-history.db-wal
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------Clear privacy.sexy script history-------------
# ----------------------------------------------------------
echo '--- Clear privacy.sexy script history'
# Clear directory contents: "$HOME/.config/privacy.sexy/runs"
glob_pattern="$HOME/.config/privacy.sexy/runs/*"
rm -rfv $glob_pattern
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Clear privacy.sexy activity logs-------------
# ----------------------------------------------------------
echo '--- Clear privacy.sexy activity logs'
# Clear directory contents: "$HOME/.config/privacy.sexy/logs"
glob_pattern="$HOME/.config/privacy.sexy/logs/*"
rm -rfv $glob_pattern
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------------Clear Steam cache---------------------
# ----------------------------------------------------------
echo '--- Clear Steam cache'
# Global installation
rm -rfv ~/.local/share/Steam/appcache/*
# Snap
rm -rfv ~/snap/steam/common/.cache/*
rm -rfv ~/snap/steam/common/.local/share/Steam/appcache/*
# Flatpak
rm -rfv ~/.var/app/com.valvesoftware.Steam/cache/*
rm -rfv ~/.var/app/com.valvesoftware.Steam/data/Steam/appcache/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------------Clear Clementine cache------------------
# ----------------------------------------------------------
echo '--- Clear Clementine cache'
# Global installation
rm -rfv ~/.cache/Clementine/*
# Flatpak installation
rm -rfv ~/.var/app/org.clementine_player.Clementine/cache/*
# Snap installation
rm -rfv ~/snap/clementine/common/.cache/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Clear LibreOffice usage history--------------
# ----------------------------------------------------------
echo '--- Clear LibreOffice usage history'
# Global installation
rm -f ~/.config/libreoffice/4/user/registrymodifications.xcu
# Snap package
rm -fv ~/snap/libreoffice/*/.config/libreoffice/4/user/registrymodifications.xcu
# Flatpak installation
rm -fv ~/.var/app/org.libreoffice.LibreOffice/config/libreoffice/4/user/registrymodifications.xcu
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------------Clear Python history-------------------
# ----------------------------------------------------------
echo '--- Clear Python history'
rm -fv ~/.python_history
sudo rm -fv /root/.python_history
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Clear Visual Studio Code cache--------------
# ----------------------------------------------------------
echo '--- Clear Visual Studio Code cache'
# Cache: Global installation (also Snap with --classic)
rm -rfv ~/.config/Code/Cache/*
# Cache: Flatpak installation
rm -rfv ~/.var/app/com.visualstudio.code/config/Code/Cache/*
# CachedData: Global installation (also Snap with --classic)
rm -rfv ~/.config/Code/CachedData/*
# CachedData: Flatpak installation
rm -rfv ~/.var/app/com.visualstudio.code/config/Code/CachedData/*
# Code\ Cache: Global installation (also Snap with --classic)
rm -rfv ~/.config/Code/Code\ Cache/*
# Code\ Cache: Flatpak installation
rm -rfv ~/.var/app/com.visualstudio.code/config/Code/Code\ Cache/*
# GPUCache: Global installation (also Snap with --classic)
rm -rfv ~/.config/Code/GPUCache/*
# GPUCache: Flatpak installation
rm -rfv ~/.var/app/com.visualstudio.code/config/Code/GPUCache/*
# CachedExtensions: Global installation (also Snap with --classic)
rm -rfv ~/.config/Code/CachedExtensions/*
# CachedExtensions: Flatpak installation
rm -rfv ~/.var/app/com.visualstudio.code/config/Code/CachedExtensions/*
# CachedExtensionVSIXs: Global installation (also Snap with --classic)
rm -rfv ~/.config/Code/CachedExtensionVSIXs/*
# CachedExtensionVSIXs: Flatpak installation
rm -rfv ~/.var/app/com.visualstudio.code/config/Code/CachedExtensionVSIXs/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------------Clear bash history--------------------
# ----------------------------------------------------------
echo '--- Clear bash history'
rm -fv ~/.bash_history
sudo rm -fv /root/.bash_history
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------------Clear Zsh history---------------------
# ----------------------------------------------------------
echo '--- Clear Zsh history'
rm -fv ~/.zsh_history
sudo rm -fv /root/.zsh_history
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------------Clear tcsh history--------------------
# ----------------------------------------------------------
echo '--- Clear tcsh history'
rm -fv ~/.history
sudo rm -fv /root/.history
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------------Clear fish history--------------------
# ----------------------------------------------------------
echo '--- Clear fish history'
rm -fv ~/.local/share/fish/fish_history
sudo rm -fv /root/.local/share/fish/fish_history
rm -fv ~/.config/fish/fish_history
sudo rm -fv /root/.config/fish/fish_history
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Clear KornShell (ksh) history---------------
# ----------------------------------------------------------
echo '--- Clear KornShell (ksh) history'
rm -fv ~/.sh_history
sudo rm -fv /root/.sh_history
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------------Clear ash history---------------------
# ----------------------------------------------------------
echo '--- Clear ash history'
rm -fv ~/.ash_history
sudo rm -fv /root/.ash_history
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------------Clear crosh history--------------------
# ----------------------------------------------------------
echo '--- Clear crosh history'
rm -fv ~/.crosh_history
sudo rm -fv /root/.crosh_history
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Kill Zeitgeist daemon process---------------
# ----------------------------------------------------------
echo '--- Kill Zeitgeist daemon process'
if ! command -v 'zeitgeist-daemon' &> /dev/null; then
  echo 'Skipping because "zeitgeist-daemon" is not found.'
else
  zeitgeist-daemon --quit
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Remove Zeitgeist startup entry--------------
# ----------------------------------------------------------
echo '--- Remove Zeitgeist startup entry'
file='/etc/xdg/autostart/zeitgeist-datahub.desktop'
backup_file="${file}.old"
if [ -f "$file" ]; then
  echo "File exists: $file."
  sudo mv "$file" "$backup_file"
  echo "Moved to: $backup_file."
else
  echo "Skipping, no changes needed."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------Disable access to Zeitgeist database-----------
# ----------------------------------------------------------
echo '--- Disable access to Zeitgeist database'
file="$HOME/.local/share/zeitgeist/activity.sqlite"
if [ -f "$file" ]; then
  chmod -rw "$file"
  echo "Successfully disabled read/write access to $file."
else
  echo "Skipping, no action needed, file does not exist at $file."
fi
# ----------------------------------------------------------


# Disable online search result collection (collects queries)
echo '--- Disable online search result collection (collects queries)'
if ! command -v 'gsettings' &> /dev/null; then
  echo 'Skipping because "gsettings" is not found.'
else
  gsettings set com.canonical.Unity.Lenses remote-content-search none
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------------Remove `whoopsie` package-----------------
# ----------------------------------------------------------
echo '--- Remove `whoopsie` package'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  apt_package_name='whoopsie'
if status="$(dpkg-query -W --showformat='${db:Status-Status}' "$apt_package_name" 2>&1)" \
    && [ "$status" = installed ]; then
  echo "\"$apt_package_name\" is installed and will be uninstalled."
  sudo apt-get purge -y "$apt_package_name"
else
  echo "Skipping, no action needed, \"$apt_package_name\" is not installed."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------------Remove `apport` package------------------
# ----------------------------------------------------------
echo '--- Remove `apport` package'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  apt_package_name='apport'
if status="$(dpkg-query -W --showformat='${db:Status-Status}' "$apt_package_name" 2>&1)" \
    && [ "$status" = installed ]; then
  echo "\"$apt_package_name\" is installed and will be uninstalled."
  sudo apt-get purge -y "$apt_package_name"
else
  echo "Skipping, no action needed, \"$apt_package_name\" is not installed."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------Remove Ubuntu Report tool (`ubuntu-report`)--------
# ----------------------------------------------------------
echo '--- Remove Ubuntu Report tool (`ubuntu-report`)'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  apt_package_name='ubuntu-report'
if status="$(dpkg-query -W --showformat='${db:Status-Status}' "$apt_package_name" 2>&1)" \
    && [ "$status" = installed ]; then
  echo "\"$apt_package_name\" is installed and will be uninstalled."
  sudo apt-get purge -y "$apt_package_name"
else
  echo "Skipping, no action needed, \"$apt_package_name\" is not installed."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Disable Zorin OS census pings---------------
# ----------------------------------------------------------
echo '--- Disable Zorin OS census pings'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  apt_package_name='zorin-os-census'
if status="$(dpkg-query -W --showformat='${db:Status-Status}' "$apt_package_name" 2>&1)" \
    && [ "$status" = installed ]; then
  echo "\"$apt_package_name\" is installed and will be uninstalled."
  sudo apt-get purge -y "$apt_package_name"
else
  echo "Skipping, no action needed, \"$apt_package_name\" is not installed."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Remove Zorin OS census unique ID-------------
# ----------------------------------------------------------
echo '--- Remove Zorin OS census unique ID'
sudo rm -fv '/var/lib/zorin-os-census/uuid'
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------------Remove `pkgstats` package-----------------
# ----------------------------------------------------------
echo '--- Remove `pkgstats` package'
if ! command -v 'pacman' &> /dev/null; then
  echo 'Skipping because "pacman" is not found.'
else
  pkg_package_name='pkgstats'
if pacman -Qs "$pkg_package_name" > /dev/null ; then
  echo "\"$pkg_package_name\" is installed and will be uninstalled."
  sudo pacman -Rcns "$pkg_package_name" --noconfirm
else
  echo "The package $pkg_package_name is not installed"
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------------Remove `reportbug` package----------------
# ----------------------------------------------------------
echo '--- Remove `reportbug` package'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  apt_package_name='reportbug'
if status="$(dpkg-query -W --showformat='${db:Status-Status}' "$apt_package_name" 2>&1)" \
    && [ "$status" = installed ]; then
  echo "\"$apt_package_name\" is installed and will be uninstalled."
  sudo apt-get purge -y "$apt_package_name"
else
  echo "Skipping, no action needed, \"$apt_package_name\" is not installed."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------Remove Python modules for `reportbug`-----------
# ----------------------------------------------------------
echo '--- Remove Python modules for `reportbug`'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  apt_package_name='python3-reportbug'
if status="$(dpkg-query -W --showformat='${db:Status-Status}' "$apt_package_name" 2>&1)" \
    && [ "$status" = installed ]; then
  echo "\"$apt_package_name\" is installed and will be uninstalled."
  sudo apt-get purge -y "$apt_package_name"
else
  echo "Skipping, no action needed, \"$apt_package_name\" is not installed."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----Remove UI for reportbug (`reportbug-gtk` package)-----
# ----------------------------------------------------------
echo '--- Remove UI for reportbug (`reportbug-gtk` package)'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  apt_package_name='reportbug-gtk'
if status="$(dpkg-query -W --showformat='${db:Status-Status}' "$apt_package_name" 2>&1)" \
    && [ "$status" = installed ]; then
  echo "\"$apt_package_name\" is installed and will be uninstalled."
  sudo apt-get purge -y "$apt_package_name"
else
  echo "Skipping, no action needed, \"$apt_package_name\" is not installed."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------Remove Popularity Contest (`popcon`) package-------
# ----------------------------------------------------------
echo '--- Remove Popularity Contest (`popcon`) package'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  apt_package_name='popularity-contest'
if status="$(dpkg-query -W --showformat='${db:Status-Status}' "$apt_package_name" 2>&1)" \
    && [ "$status" = installed ]; then
  echo "\"$apt_package_name\" is installed and will be uninstalled."
  sudo apt-get purge -y "$apt_package_name"
else
  echo "Skipping, no action needed, \"$apt_package_name\" is not installed."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -Remove daily cron entry for Popularity Contest (popcon)--
# ----------------------------------------------------------
echo '--- Remove daily cron entry for Popularity Contest (popcon)'
job_name='popularity-contest'
cronjob_path="/etc/cron.daily/$job_name"
if [[ -f "$cronjob_path" ]]; then
  if [[ -x "$cronjob_path" ]]; then
    sudo chmod -x "$cronjob_path"
    echo "Successfully disabled cronjob \"$job_name\"."
  else
    echo "Skipping, cronjob \"$job_name\" is already disabled."
  fi
else
  echo "Skipping, \"$job_name\" cronjob is not found."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------Disable PowerShell Core telemetry-------------
# ----------------------------------------------------------
echo '--- Disable PowerShell Core telemetry'
variable='POWERSHELL_TELEMETRY_OPTOUT'
value='1'
declaration_file='/etc/environment'
if ! [ -f "$declaration_file" ]; then
  echo "\"$declaration_file\" does not exist."
  sudo touch "$declaration_file"
  echo "Created $declaration_file."
fi
assignment_start="$variable="
assignment="$variable=$value"
if ! grep --quiet "^$assignment_start" "${declaration_file}"; then
  echo "Variable \"$variable\" was not configured before."
  echo -n $'\n'"$assignment" | sudo tee -a "$declaration_file" > /dev/null
  echo "Successfully configured ($assignment)."
else
  if grep --quiet "^$assignment$" "${declaration_file}"; then
    echo "Skipping. Variable \"$variable\" is already set to value \"$value\"."
  else
    if ! sudo sed --in-place "/^$assignment_start/d" "$declaration_file"; then
      >&2 echo "Failed to delete assignment starting with \"$assignment_start\"."
    else
      echo "Successfully deleted unexpected assignment of \"$variable\"."
      if ! echo -n $'\n'"$assignment" | sudo tee -a "$declaration_file" > /dev/null; then
        >&2 echo "Failed to add assignment \"$assignment\"."
      else
        echo "Successfully reconfigured ($assignment)."
      fi
    fi
  fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# --Disable Python history for future interactive commands--
# ----------------------------------------------------------
echo '--- Disable Python history for future interactive commands'
history_file="$HOME/.python_history"
if [ ! -f "$history_file" ]; then
  touch "$history_file"
  echo "Created $history_file."
fi
sudo chattr +i "$(realpath $history_file)" # realpath in case of symlink
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---Disable outdated Firefox First-Party Isolation (FPI)---
# ----------------------------------------------------------
echo '--- Disable outdated Firefox First-Party Isolation (FPI)'
pref_name='privacy.firstparty.isolate'
pref_value='false'
echo "Setting preference \"$pref_name\" to \"$pref_value\"."
declare -a profile_paths=(
  ~/.mozilla/firefox/*/
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox/*/
  ~/snap/firefox/common/.mozilla/firefox/*/
)
declare -i total_profiles_found=0
for profile_dir in "${profile_paths[@]}"; do
  if [ ! -d "$profile_dir" ]; then
    continue
  fi
  if [[ ! "$(basename "$profile_dir")" =~ ^[a-z0-9]{8}\..+ ]]; then
    continue # Not a profile folder
  fi
  ((total_profiles_found++))
  user_js_file="${profile_dir}user.js"
  echo "$user_js_file:"
  if [ ! -f "$user_js_file" ]; then
    touch "$user_js_file"
    echo $'\t''Created new user.js file'
  fi
  pref_start="user_pref(\"$pref_name\","
  pref_line="user_pref(\"$pref_name\", $pref_value);"
  if ! grep --quiet "^$pref_start" "${user_js_file}"; then
    echo -n $'\n'"$pref_line" >> "$user_js_file"
    echo $'\t'"Successfully added a new preference in $user_js_file."
  elif grep --quiet "^$pref_line$" "$user_js_file"; then
    echo $'\t'"Skipping, preference is already set as expected in $user_js_file."
  else
    sed --in-place "/^$pref_start/c\\$pref_line" "$user_js_file"
    echo $'\t'"Successfully replaced the existing incorrect preference in $user_js_file."
  fi
done
if [ "$total_profiles_found" -eq 0 ]; then
  echo 'No profile folders are found, no changes are made.'
else
  echo "Successfully verified preferences in $total_profiles_found profiles."
fi
# ----------------------------------------------------------


echo 'Your privacy and security is now hardened 🎉💪'
echo 'Press any key to exit.'
read -n 1 -s