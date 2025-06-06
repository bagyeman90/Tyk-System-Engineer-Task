# Tyk-System-Engineer-Task

# Vulnerability Scanner

A tool for scanning Docker images for vulnerabilities using Trivy and generating deduplicated CSV reports. The scanner identifies similar vulnerabilities across different images and consolidates them into a single report.

## Prerequisites

### Installing Trivy

#### macOS (using Homebrew)
```bash
brew install trivy
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy
```

#### Linux (RHEL/CentOS)
```bash
sudo rpm -ivh https://github.com/aquasecurity/trivy/releases/download/v0.18.3/trivy_0.18.3_Linux-64bit.rpm
```

### Installing jq

#### macOS (using Homebrew)
```bash
brew install jq
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt-get install jq
```

#### Linux (RHEL/CentOS)
```bash
sudo yum install jq
```

## Usage

1. Make the script executable:
```bash
chmod +x my.sh
```

2. Run the scanner with one or more Docker images:
```bash
./my.sh tykio/tyk-gateway:latest tykio/tyk-dashboard:latest
```

## Output Files

The script generates two CSV files:

1. `vulnerability_scan_raw.csv`: Contains all raw vulnerability data
2. `vulnerability_scan.csv`: Contains deduplicated vulnerabilities with combined sources

### CSV Format

The output CSV files contain the following columns:
1. Package Name
2. Severity
3. Version
4. Fixed Version
5. Description
6. CVE ID
7. Source(s)

## Features

- Scans multiple Docker images for vulnerabilities
- Deduplicates similar vulnerabilities across images
- Normalizes package names to combine similar packages
- Combines sources when similar vulnerabilities are found
- Properly handles CSV escaping and formatting

