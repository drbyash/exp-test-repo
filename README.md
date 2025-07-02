# OpenSearch Football Team Data Ingestion Runbook

## Overview
The `ingest.py` script is a comprehensive data ingestion tool designed to load football team data into an OpenSearch cluster. It handles index creation, search template deployment, and bulk data ingestion with support for multiple authentication methods.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Script Functionality](#script-functionality)
3. [Command Line Arguments](#command-line-arguments)
4. [Authentication Methods](#authentication-methods)
5. [Usage Examples](#usage-examples)
6. [Data Structure](#data-structure)
7. [Troubleshooting](#troubleshooting)
8. [Performance Considerations](#performance-considerations)
9. [Monitoring and Validation](#monitoring-and-validation)

## Prerequisites

### System Requirements
- Python 3.6 or higher
- Access to an OpenSearch cluster
- Network connectivity to the OpenSearch endpoint
- Sufficient disk space for the teams.json file (~4.8GB)

### Required Files
Ensure the following files are present in your project directory:
```
opensearch/
├── ingest.py                                          # Main ingestion script
├── requirements.txt                                   # Python dependencies
├── teams.json                                        # Source data file (~4.8GB)
├── indicies/
│   └── ea.cadie.football.poc.v3.footballteam.json   # Index schema definition
└── search-templates/
    └── football_search.json                         # Search template definition
```

### Python Dependencies
Install required packages:
```bash
pip install -r requirements.txt
```

Required packages:
- `opensearch-py` - OpenSearch Python client
- `boto3` - AWS SDK for Python (required for AWS authentication)
- `argparse` - Command line argument parsing

## Script Functionality

The `ingest.py` script performs the following operations in sequence:

### 1. Index Management
- **Schema Loading**: Reads the index schema from `indicies/ea.cadie.football.poc.v3.footballteam.json`
- **Index Creation**: Creates the OpenSearch index if it doesn't exist
- **Settings Cleanup**: Removes `index.creation_date` from settings to avoid conflicts

### 2. Search Template Deployment
- **Template Loading**: Reads the search template from `search-templates/football_search.json`
- **Template Registration**: Registers the template as `football_search` in OpenSearch
- **Error Handling**: Provides detailed error messages for template deployment issues

### 3. Data Ingestion
- **Bulk Processing**: Uses OpenSearch bulk API for efficient data loading
- **Memory Optimization**: Processes data in chunks to avoid memory issues with the large dataset
- **Data Enhancement**: Adds suggestion fields for auto-complete functionality
- **Error Tracking**: Monitors and reports ingestion errors

## Command Line Arguments

### Required Arguments
- `--host`: OpenSearch cluster hostname or IP address
  - Example: `search-domain.region.es.amazonaws.com` or `localhost`

### Optional Arguments
- `--port`: OpenSearch port (default: 443)
  - Common values: 443 (HTTPS), 9200 (HTTP)
- `--use-ssl`: Enable SSL/TLS connection (flag, no value needed)
- `--auth`: Authentication method (choices: none, basic, aws)
  - Default: none
- `--username`: Username for basic authentication
- `--password`: Password for basic authentication  
- `--region`: AWS region for AWS authentication

## Authentication Methods

### 1. No Authentication
Use when OpenSearch cluster has no security enabled:
```bash
python ingest.py --host localhost --port 9200
```

### 2. Basic Authentication
Use with username/password credentials:
```bash
python ingest.py \
  --host your-opensearch-host \
  --port 443 \
  --use-ssl \
  --auth basic \
  --username admin \
  --password your-password
```

### 3. AWS Authentication
Use with AWS IAM credentials:
```bash
python ingest.py \
  --host search-domain.region.es.amazonaws.com \
  --port 443 \
  --use-ssl \
  --auth aws \
  --region us-west-2
```

**AWS Prerequisites:**
- AWS credentials configured via:
  - AWS CLI (`aws configure`)
  - Environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
  - IAM roles (for EC2 instances)
- Required IAM permissions:
  ```json
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "es:ESHttpPost",
          "es:ESHttpPut",
          "es:ESHttpGet"
        ],
        "Resource": "arn:aws:es:region:account:domain/domain-name/*"
      }
    ]
  }
  ```

## Usage Examples

### Local Development Environment
```bash
# Basic local setup with no authentication
python ingest.py --host localhost --port 9200

# Local setup with basic auth
python ingest.py \
  --host localhost \
  --port 9200 \
  --auth basic \
  --username admin \
  --password admin
```

### AWS OpenSearch Service
```bash
# Production AWS environment
python ingest.py \
  --host search-football-prod.us-west-2.es.amazonaws.com \
  --port 443 \
  --use-ssl \
  --auth aws \
  --region us-west-2

# Development AWS environment
python ingest.py \
  --host search-football-dev.us-east-1.es.amazonaws.com \
  --port 443 \
  --use-ssl \
  --auth aws \
  --region us-east-1
```

### Self-Managed OpenSearch with SSL
```bash
python ingest.py \
  --host opensearch.company.com \
  --port 9200 \
  --use-ssl \
  --auth basic \
  --username service-account \
  --password secure-password
```

## Data Structure

### Source Data Format
The `teams.json` file contains football team data in NDJSON format:
- Each line alternates between metadata and document data
- Metadata line: `{"index": {"_index": "index-name", "_id": "document-id"}}`
- Document line: JSON object with team information

### Document Fields
Key fields in each football team document:
- `name`: Full team name
- `nickname`: Team nickname/mascot
- `abbreviation`: Team abbreviation
- `state`: US state location
- `school`: Associated educational institution
- `brand`: Equipment brand
- `rating`: Team rating (float)
- `ratingCount`: Number of ratings
- `downloadCount`: Download statistics
- `primary/secondary/tertiary`: Color information
- `thumbnail`: Team logo thumbnail
- `homeOutfit/awayOutfit`: Uniform configurations

### Enhanced Fields
The script automatically adds suggestion fields for auto-complete:
- `name_suggest`: Based on team name
- `nickname_suggest`: Based on nickname
- `brand_suggest`: Based on brand
- `state_suggest`: Based on state
- `abbreviation_suggest`: Based on abbreviation

## Troubleshooting

### Common Issues and Solutions

#### Connection Issues
**Error**: `Connection refused` or `ConnectionError`
- **Cause**: Network connectivity or incorrect host/port
- **Solutions**:
  - Verify OpenSearch cluster is running and accessible
  - Check firewall rules and security groups
  - Confirm host and port parameters
  - Test connectivity: `curl -X GET "https://your-host:443"`

#### Authentication Failures
**Error**: `Authentication failed` or `403 Forbidden`
- **Cause**: Invalid credentials or insufficient permissions
- **Solutions**:
  - Verify username/password for basic auth
  - Check AWS credentials: `aws sts get-caller-identity`
  - Confirm IAM permissions for AWS auth
  - Test authentication separately before running script

#### SSL/TLS Issues
**Error**: `SSL verification failed` or `Certificate verify failed`
- **Cause**: SSL certificate problems
- **Solutions**:
  - Ensure `--use-ssl` flag is used for HTTPS endpoints
  - For development, temporarily disable certificate verification (not recommended for production)
  - Check if cluster uses self-signed certificates

#### Index Creation Errors
**Error**: `Index creation failed` or `Invalid mapping`
- **Cause**: Schema conflicts or permission issues
- **Solutions**:
  - Verify index schema file exists and is valid JSON
  - Check if index already exists with different mapping
  - Ensure user has index creation permissions
  - Delete existing index if schema needs to be updated

#### Data Ingestion Errors
**Error**: `Bulk upload failed` or `Document indexing error`
- **Cause**: Data format issues or resource constraints
- **Solutions**:
  - Verify `teams.json` file exists and is not corrupted
  - Check available disk space and memory
  - Reduce `chunk_size` parameter for memory-constrained environments
  - Monitor OpenSearch cluster resources

#### Memory Issues
**Error**: `MemoryError` or `Out of memory`
- **Cause**: Large dataset processing
- **Solutions**:
  - Reduce chunk_size in bulk operations (currently 5000)
  - Increase available system memory
  - Process data in smaller batches
  - Monitor memory usage during ingestion

### Debugging Steps

1. **Verify Prerequisites**:
   ```bash
   # Check Python version
   python --version
   
   # Verify required files exist
   ls -la indicies/ea.cadie.football.poc.v3.footballteam.json
   ls -la search-templates/football_search.json
   ls -la teams.json
   
   # Check file sizes
   du -h teams.json
   ```

2. **Test Connectivity**:
   ```bash
   # Test basic connectivity
   curl -X GET "https://your-host:443/_cluster/health"
   
   # Test with authentication
   curl -u username:password -X GET "https://your-host:443/_cluster/health"
   ```

3. **Validate JSON Files**:
   ```bash
   # Validate index schema
   python -m json.tool indicies/ea.cadie.football.poc.v3.footballteam.json
   
   # Validate search template
   python -m json.tool search-templates/football_search.json
   ```

4. **Monitor Progress**:
   ```bash
   # Check index status
   curl -X GET "https://your-host:443/ea.cadie.football.poc.v3.footballteam/_stats"
   
   # Monitor cluster health
   curl -X GET "https://your-host:443/_cluster/health"
   ```

## Performance Considerations

### Optimization Settings
- **Chunk Size**: Default 5000 documents per bulk request
  - Increase for better performance on powerful systems
  - Decrease for memory-constrained environments
- **Connection Pooling**: Script uses single connection
  - Consider connection pooling for production deployments
- **Parallel Processing**: Current implementation is single-threaded
  - Multi-threading could improve ingestion speed

### Resource Requirements
- **Memory**: Minimum 4GB RAM recommended
- **Disk Space**: 5GB+ free space for temporary processing
- **Network**: Stable connection for large data transfer
- **OpenSearch Cluster**: Adequate heap size and storage

### Monitoring Metrics
Track these metrics during ingestion:
- Documents indexed per second
- Memory usage
- Network throughput
- OpenSearch cluster CPU and memory
- Index size growth

## Monitoring and Validation

### Pre-Ingestion Checks
```bash
# Verify cluster health
curl -X GET "https://your-host:443/_cluster/health"

# Check available storage
curl -X GET "https://your-host:443/_nodes/stats/fs"

# Verify authentication
curl -u username:password -X GET "https://your-host:443/"
```

### During Ingestion
Monitor the script output for:
- Index creation confirmation
- Search template deployment success
- Bulk upload progress
- Error messages and warnings

### Post-Ingestion Validation
```bash
# Check document count
curl -X GET "https://your-host:443/ea.cadie.football.poc.v3.footballteam/_count"

# Verify index mapping
curl -X GET "https://your-host:443/ea.cadie.football.poc.v3.footballteam/_mapping"

# Test search template
curl -X POST "https://your-host:443/_scripts/football_search/_execute" \
  -H "Content-Type: application/json" \
  -d '{"params": {"query_string": "test", "size": 5}}'

# Sample document retrieval
curl -X GET "https://your-host:443/ea.cadie.football.poc.v3.footballteam/_search?size=1"
```

### Success Indicators
- Index created successfully
- Search template deployed without errors
- All documents ingested (check count matches source data)
- No bulk upload errors reported
- Search functionality working correctly

## Best Practices

1. **Backup**: Always backup existing data before running ingestion
2. **Testing**: Test on development environment before production
3. **Monitoring**: Monitor cluster resources during ingestion
4. **Validation**: Verify data integrity after ingestion
5. **Documentation**: Keep track of ingestion parameters and results
6. **Security**: Use appropriate authentication methods for your environment
7. **Performance**: Adjust chunk size based on your system capabilities

## Support and Maintenance

### Log Files
The script outputs to stdout/stderr. Redirect output for logging:
```bash
python ingest.py [args] > ingestion.log 2>&1
```

### Regular Maintenance
- Monitor index size and performance
- Update search templates as needed
- Refresh data periodically
- Clean up old indices if necessary

### Version Compatibility
- Ensure OpenSearch client version compatibility
- Test with target OpenSearch cluster version
- Update dependencies regularly for security patches
