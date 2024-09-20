//const { Client } = require('pg');

exports.handler = async (event) => {
    
    /*const client = new Client({
        host: process.env.DB_HOST,
        port: process.env.DB_PORT,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
    });

    await client.connect();

    // Assuming the user data is passed in the event body
    const { username, email } = JSON.parse(event.body);

    console.log("Received data:");
    console.log("Username:", username);
    console.log("Email:", email);

    try {
        const query = `
            INSERT INTO users (username, role, email, verified)
            VALUES ($1, $2, $3, true)
            RETURNING id;
        `;

        const values = [username, 2, email];
        
        // Execute the query and get the inserted user's id
        const res = await client.query(query, values);
        const userId = res.rows[0].id;

        await client.end();

        return {
            statusCode: 200,
            body: JSON.stringify({
                message: "User created successfully",
                userId: userId,
            }),
        };
    } catch (error) {
        console.error('Error inserting user:', error);
        
        await client.end();

        return {
            statusCode: 500,
            body: JSON.stringify({
                message: "Failed to create user",
                error: error.message,
            }),
        };
    }*/

        const response = {
            statusCode: 200,
            body: JSON.stringify({ message: "This is a fake user!" }),
        };
        return response;
};
