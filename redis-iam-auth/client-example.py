#!/usr/bin/env python3
"""
Example client for connecting to ElastiCache Redis using IAM authentication
"""

import boto3
import redis
import os
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Redis connection parameters
REDIS_HOST = os.environ.get('REDIS_HOST')
REDIS_PORT = int(os.environ.get('REDIS_PORT', '6379'))
REDIS_CLUSTER_ID = os.environ.get('REDIS_CLUSTER_ID')
REDIS_USER = os.environ.get('REDIS_USER', 'IAMAuthUser')

def get_auth_token():
    """Generate an authentication token using IAM credentials"""
    try:
        elasticache = boto3.client('elasticache')
        auth_token = elasticache.generate_auth_token(
            ReplicationGroupId=REDIS_CLUSTER_ID,
            UserName=REDIS_USER
        )
        logger.info("Successfully generated auth token")
        return auth_token
    except Exception as e:
        logger.error(f"Failed to generate auth token: {e}")
        raise

def connect_to_redis():
    """Connect to Redis using IAM authentication"""
    try:
        # Get authentication token
        auth_token = get_auth_token()
        
        # Connect to Redis
        client = redis.Redis(
            host=REDIS_HOST,
            port=REDIS_PORT,
            password=auth_token,
            ssl=True,
            decode_responses=True
        )
        
        # Test connection
        response = client.ping()
        logger.info(f"Redis connection test: {response}")
        
        return client
    except Exception as e:
        logger.error(f"Failed to connect to Redis: {e}")
        raise

def main():
    """Main function to demonstrate Redis IAM authentication"""
    try:
        # Check required environment variables
        if not REDIS_HOST or not REDIS_CLUSTER_ID:
            logger.error("Required environment variables not set")
            logger.error("Please set REDIS_HOST and REDIS_CLUSTER_ID")
            return
        
        # Connect to Redis
        redis_client = connect_to_redis()
        
        # Example operations
        redis_client.set('test_key', 'Hello from IAM auth!')
        value = redis_client.get('test_key')
        logger.info(f"Retrieved value: {value}")
        
    except Exception as e:
        logger.error(f"Error in main function: {e}")

if __name__ == "__main__":
    main()
