exports.handler = async (event) => {
    const queryStringParameters = event.queryStringParameters || {};

    const queryParams = new URLSearchParams(queryStringParameters).toString();

    const baseUrl = 'http://mycustomdomain.com.s3-website-us-east-1.amazonaws.com/';

    const redirectUrl = queryParams ? `${baseUrl}?${queryParams}` : baseUrl;

    const response = {
        statusCode: 301, // Use 301 for permanent redirect, or 302 for temporary redirect
        headers: {
            Location: redirectUrl,
        },
    };
    return response;
};