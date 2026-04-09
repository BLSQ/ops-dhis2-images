import json
import requests
import os

url = 'https://releases.dhis2.org/v1/versions/stable.json'
response = requests.get(url)
json_object = response.json()

count = 0

DEBUG = False

versions = []

for version in json_object.get('versions'):
    count += 1

    if DEBUG:
        print(f"Version: {version.get('name')}")
        print(f"JDK: {version.get('jdk')}")

    jdk = version.get('jdk', 8)
    patch_versions = version['patchVersions']
    if len(patch_versions) > 0:
        if DEBUG:
            print(f"Patch Versions: {len(patch_versions)}")
        for patch_version in patch_versions:
            count += 1
            versions.append({
                'name': patch_version.get('name'),
                'jdk': jdk
            })
            if DEBUG:
                print(f"Patch Version: {patch_version.get('name')}")
    else:
        if DEBUG:
            print('No patch versions')
            print('--------------------------------')

if DEBUG:
    print(f"Total versions + patches to build: {count}")

print(json.dumps(versions, indent=4))