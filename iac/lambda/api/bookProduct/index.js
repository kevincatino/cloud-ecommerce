const { Client } = require('pg');

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

    if (!event.body){
        return {
            statusCode: 400,
            body: JSON.stringify({ message: "Request should have a body with fields productName, productPrice y productStockAmount are mandatory" }),
        };
    }
    const body = JSON.parse(event.body);

    const { userId, amount } = body;

    if (!productName || !productPrice || !productStockAmount || !productDescription){
        return {
            statusCode: 400,
            body: JSON.stringify({ message: "Fields productName, productPrice y productStockAmount are mandatory" }),
        };
    }

    await client.connect();

    try {
        const query = `UPDATE product SET stock = stock - $2 WHERE product_id = $1`;
        const result = await client.query(query, [id, amount]);
        if (result.rowCount === 0) {
            return {
                statusCode: 404,
                body: JSON.stringify({ message: "Product not found" }),
            };
        }
    } catch(error) {
        await client.end();
        return {
            statusCode: 500,
            body: JSON.stringify({ message: "Error booking product", error: error.message }),
        };
    }

    try{
        const query = `INSERT INTO reservation (user_id,product_id,quantity) VALUES($1,$2,$3)`
        const values = [userId,productId,amount]
        await client.query(query,values);
        await client.end();
    }catch(error){
        await client.end();
        return {
            statusCode: 500,
            body: JSON.stringify({ message: "Error booking product.", error: error.message }),
        };
    }
    
    return {
        statusCode: 200,
        body: JSON.stringify({ message: "Succesfull booking of product" }),
    };
};
