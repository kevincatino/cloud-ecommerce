const { Client } = require('pg');
const AWS = require('aws-sdk');
const S3 = new AWS.S3();


exports.handler = async (event) => {

    const client = new Client({
        host: process.env.DB_HOST,
        port: process.env.DB_PORT,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
    });

    const { id } = event.pathParameters;

    if (!id) {
        return {
            statusCode: 400,
            body: JSON.stringify({ message: "Product ID is required" }),
        };
    }

    const bucketName = process.env.IMAGES_BUCKET;

    // Parse the content-type header to determine the file type
    const contentType = event.headers['Content-Type'] || event.headers['content-type'];

    // Validate the content type (allow only image types)
    if (!['image/png', 'image/jpeg', 'image/gif'].includes(contentType)) {
        return {
            statusCode: 400,
            body: JSON.stringify({ message: 'Unsupported file type. Only PNG, JPEG, and GIF are allowed.' })
        };
    }

    // Generate a random filename with the appropriate extension based on content-type
    const fileExtension = contentType.split('/')[1];  // Extract the file extension (e.g., 'png', 'jpeg')
    const randomFilename = `item-${id}.${fileExtension}`;

    // S3 parameters
    const s3Params = {
        Bucket: bucketName,
        Key: randomFilename,  // Use the generated random filename
        Body: Buffer.from(event.body, 'base64'),  // Assuming the image content is base64 encoded in the request
        ContentType: contentType,  // Dynamically set the content type
        ACL: 'public-read'  // Optional: Make the image publicly accessible
    };

    try {
        // Upload the image to S3
        await S3.putObject(s3Params).promise();

        // Construct the final S3 URL of the uploaded image
        const s3Url = `https://${bucketName}.s3.amazonaws.com/${randomFilename}`;

        await client.connect();

        const query = `UPDATE product SET image_url = $2 WHERE id = $1`;
        const result = await client.query(query, [id, s3Url]);

        if (result.rowCount === 0) {
            return {
                statusCode: 404,
                body: JSON.stringify({ message: "Product not found" }),
            };
        }

        return {
            statusCode: 200,
            body: JSON.stringify({
                message: 'Image uploaded successfully',
                imageUrl: s3Url  // Return the URL of the uploaded image
            })
        };

    } catch (error) {
        return {
            statusCode: 500,
            body: JSON.stringify({ message: 'Error uploading image', error: error.message })
        };
    } finally {
        await client.end()
    }

};
