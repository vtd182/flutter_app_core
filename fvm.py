import os
import re
import subprocess
import sys

os.chdir(os.path.dirname(os.path.abspath(__file__)))

is_window = sys.platform == "win32"

file = open('pubspec.yaml', mode='r', encoding="utf-8")
pubspec = file.read()
file.close()
used_version = re.search('flutter:.*(\d+\.\d+)\.\d+.*', pubspec).group(1)

installed_versions = subprocess.run(["fvm", "list"], stdout=subprocess.PIPE, shell=is_window)
installed_versions = installed_versions.stdout.decode('utf-8')
installed_versions = installed_versions.splitlines()

matched_versions = list(
    filter(lambda version: version.startswith(used_version), installed_versions))
matched_versions = list(
    map(lambda version: re.sub("(\d+\.\d+\.\d+).*", lambda match_obj: match_obj.group(1), version),
        matched_versions))
if len(matched_versions) > 0:
    matched_version = matched_versions[0]
else:
    matched_version = f"{used_version}.0"
    subprocess.run(["fvm", "install", matched_version], shell=is_window)

subprocess.run(["fvm", "use", matched_version], shell=is_window)
