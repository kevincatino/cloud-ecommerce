const { Client } = require('pg');

exports.handler = async (event) => {
    const client = new Client({
        host: process.env.DB_HOST,
        port: process.env.DB_PORT,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
    });

    await client.connect();

    const query = `
        DO $$
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users') THEN
                CREATE TABLE users (id SERIAL PRIMARY KEY, name VARCHAR(50));
            END IF;
            IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'orders') THEN
                CREATE TABLE orders (id SERIAL PRIMARY KEY, user_id INT, amount DECIMAL);
            END IF;
        END $$;
    `;

    await client.query(query);
    await client.end();

    return {
        statusCode: 200,
        body: JSON.stringify({ message: "Migration executed successfully" }),
    };
};
