#!/bin/bash

set -e

if ! command -v trivy > /dev/null; then
    echo "Please install trivy first"
    exit 1
    fi 
    
echo "Package Name,Severity,Version,Fixed,Description,CVE ID,Source" > vulnerability_scan.csv

for image in "$@"; do 
    echo "Scanning $image"
    trivy image --format json "$image" | \
    jq -r '.Results[]?.Vulnerabilities[]? | 
        [.PkgName, .Severity, .InstalledVersion, .FixedVersion, .Description, .VulnerabilityID, "'"$image"'"] | 
        @csv' >> vulnerability_scan.csv
done


