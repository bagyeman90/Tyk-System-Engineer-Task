#!/bin/bash

set -e

if ! command -v trivy > /dev/null; then
    echo "Please install trivy first"
    exit 1
fi 


echo "Package Name,Severity,Version,Fixed,Description,CVE ID,Source" > vulnerability_scan_raw.csv

for image in "$@"; do 
    echo "Scanning $image"
    trivy image --format json "$image" | \
    jq -r '.Results[]?.Vulnerabilities[]? | 
        [.PkgName, .Severity, .InstalledVersion, .FixedVersion, .Description, .VulnerabilityID, "'"$image"'"] | 
        @csv' >> vulnerability_scan_raw.csv
done


awk -F, '
function csv_quote(field) {
    if (field ~ /[",;]/) {
        gsub(/"/, "\"\"", field)
        return "\"" field "\""
    }
    return field
}

function normalize_pkg_name(name) {
    # Convert to lowercase and remove common prefixes/suffixes
    name = tolower(name)
    gsub(/^python-|^python3-|^lib|-dev$|-common$/, "", name)
    return name
}

BEGIN { 
    OFS=",";
    print "Package Name,Severity,Version,Fixed,Description,CVE ID,Source"
}
NR==1 { next }  # Skip header
{
    for (i=1; i<=NF; i++) {
        gsub(/^"|"$/, "", $i)
    }
    
    # Normalize package name for comparison
    norm_pkg = normalize_pkg_name($1)
    
    # Create a key based on normalized package name and CVE ID
    key = norm_pkg "," $6
    
    if (!(key in seen)) {
        for (i=1; i<=6; i++) fields[key,i]=$i
        sources[key]=$7
    } else {
        if (index(sources[key], $7) == 0) {
            sources[key]=sources[key] "; " $7
        }
    }
}
END {
    for (key in sources) {
        out=""
        for (i=1; i<=6; i++) {
            gsub(/"/, "\"\"", fields[key,i])
            out = out (i==1 ? "" : OFS) "\"" fields[key,i] "\""
        }
        gsub(/"/, "\"\"", sources[key])
        print out OFS "\"" sources[key] "\""
    }
}' vulnerability_scan_raw.csv > vulnerability_scan.csv

echo "Raw scan data saved to vulnerability_scan_raw.csv"
echo "Duplicated report saved to vulnerability_scan.csv"
