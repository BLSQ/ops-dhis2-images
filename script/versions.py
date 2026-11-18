#!/usr/bin/env python3
"""Regenerate versions.json from the DHIS2 release index.

Each patch version is annotated with the JDK and Tomcat (webapp-runner) to
build it with, following the DHIS2 compatibility matrix:
https://docs.dhis2.org/en/manage/reference/dhis2-version-compatibility-matrix.html

Usage: ./script/versions.py
"""
import json
import os
import urllib.request

URL = "https://releases.dhis2.org/v1/versions/stable.json"
OUTPUT = os.path.join(os.path.dirname(__file__), "..", "versions.json")

# webapp-runner release embedding each Tomcat major
# https://repo.maven.apache.org/maven2/com/heroku/webapp-runner-main/
WEBAPP_RUNNER = {
    9: "9.0.98.0",
    10: "10.1.60.0",
}

# (minimum DHIS2 minor, recommended JDK, Tomcat major), newest first
MATRIX = [
    ((2, 42), 17, 10),
    ((2, 41), 17, 9),
    ((2, 40), 17, 9),
    ((2, 38), 11, 9),
    ((2, 35), 11, 9),
    ((0, 0), 8, 9),
]


def runtime_for(minor):
    for min_minor, jdk, tomcat in MATRIX:
        if minor >= min_minor:
            return jdk, tomcat


def main():
    with urllib.request.urlopen(URL) as response:
        index = json.load(response)

    versions = []
    for release in index["versions"]:
        minor = tuple(int(p) for p in release["name"].split(".")[:2])
        jdk, tomcat = runtime_for(minor)

        for patch in release["patchVersions"]:
            versions.append({
                "version": patch["name"],
                "url": patch["url"],
                "sha256": patch.get("sha256"),
                "releaseDate": patch.get("releaseDate"),
                "supported": release.get("supported", False),
                "jdk": jdk,
                "tomcat": tomcat,
                "webappRunner": WEBAPP_RUNNER[tomcat],
            })

    with open(OUTPUT, "w") as f:
        json.dump(versions, f, indent=4)
        f.write("\n")

    print(f"Wrote {len(versions)} versions to versions.json")


if __name__ == "__main__":
    main()
