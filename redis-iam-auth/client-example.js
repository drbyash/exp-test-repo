/**
 * Example Node.js client for connecting to ElastiCache Redis using IAM authentication
 */

const AWS = require('aws-sdk');
const Redis = require('ioredis');

// Configure AWS SDK
AWS.config.update({ region: process.env.AWS_REGION || 'us-east-1' });

// Redis connection parameters
const REDIS_HOST = process.env.REDIS_HOST;
const REDIS_PORT = parseInt(process.env.REDIS_PORT || '6379');
const REDIS_CLUSTER_ID = process.env.REDIS_CLUSTER_ID;
const REDIS_USER = process.env.REDIS_USER || 'IAMAuthUser';

/**
 * Generate an authentication token using IAM credentials
 * @returns {Promise<string>} The authentication token
 */
async function getAuthToken() {
  try {
    const elasticache = new AWS.ElastiCache();
    const params = {
      ReplicationGroupId: REDIS_CLUSTER_ID,
      UserName: REDIS_USER
    };
    
    const data = await elasticache.generateAuthToken(params).promise();
    console.log('Successfully generated auth token');
    return data.AuthToken;
  } catch (error) {
    console.error('Failed to generate auth token:', error);
    throw error;
  }
}

/**
 * Connect to Redis using IAM authentication
 * @returns {Promise<Redis>} Redis client
 */
async function connectToRedis() {
  try {
    // Get authentication token
    const authToken = await getAuthToken();
    
    // Connect to Redis
    const client = new Redis({
      host: REDIS_HOST,
      port: REDIS_PORT,
      password: authToken,
      tls: true
    });
    
    // Handle connection events
    client.on('connect', () => {
      console.log('Connected to Redis');
    });
    
    client.on('error', (err) => {
      console.error('Redis connection error:', err);
    });
    
    // Test connection
    const pingResult = await client.ping();
    console.log(`Redis connection test: ${pingResult}`);
    
    return client;
  } catch (error) {
    console.error('Failed to connect to Redis:', error);
    throw error;
  }
}

/**
 * Main function to demonstrate Redis IAM authentication
 */
async function main() {
  try {
    // Check required environment variables
    if (!REDIS_HOST || !REDIS_CLUSTER_ID) {
      console.error('Required environment variables not set');
      console.error('Please set REDIS_HOST and REDIS_CLUSTER_ID');
      return;
    }
    
    // Connect to Redis
    const redisClient = await connectToRedis();
    
    // Example operations
    await redisClient.set('test_key', 'Hello from IAM auth!');
    const value = await redisClient.get('test_key');
    console.log(`Retrieved value: ${value}`);
    
    // Close connection
    await redisClient.quit();
  } catch (error) {
    console.error('Error in main function:', error);
  }
}

// Run the main function
main();
