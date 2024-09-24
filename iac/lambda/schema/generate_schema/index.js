const { Client } = require('pg');

exports.handler = async (event) => {
    const client = new Client({
        host: process.env.DB_HOST,
        port: process.env.DB_PORT,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
    });

    const overwrite = event?.body?.overwrite

    await client.connect();

    if (overwrite) {
        const query = `
        DO $$
        BEGIN
            DROP TABLE product;
            DROP TABLE reservation;
            DROP TABLE users
        END $$; `
        await client.query(query);
    }

    const query = `
        DO $$
        BEGIN
            CREATE TABLE IF NOT EXISTS product(
                id serial PRIMARY KEY,
                name varchar(256) UNIQUE NOT NULL,
                price numeric(10,2)  NOT NULL,
                stock int  NOT NULL CHECK (stock > 0),
                description varchar(1000)  NOT NULL,
                image_url varchar(256)
            );
            
             CREATE TABLE IF NOT EXISTS  users(
                id serial PRIMARY KEY,
                username varchar(256) UNIQUE  NOT NULL,
                role int  NOT NULL, 
                email varchar(256)  NOT NULL,
                verified boolean  NOT NULL
            );

            CREATE TABLE IF NOT EXISTS  reservation(
                id serial PRIMARY KEY,
                user_id int  NOT NULL,
                product_id int  NOT NULL,
                quantity int NOT NULL,
                reservation_date timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP,
                status varchar(256)  NOT NULL DEFAULT 'PENDING',
                foreign key (user_id) references users(id),
                foreign key (product_id) references product(id)
            );

            -- Insert a user into the 'users' table
            INSERT INTO users (username, role, email, verified)
            VALUES ('john_doe', 1, 'john.doe@example.com', true)
            ON CONFLICT (username) DO NOTHING;

            -- Insert two products into the 'product' table
            INSERT INTO product (name, price, stock, description, image_url)
            VALUES 
                ('Product 1', 29.99, 100, 'Description for Product 1', 'http://example.com/product1.jpg'),
                ('Product 2', 49.99, 50, 'Description for Product 2', 'http://example.com/product2.jpg')
            ON CONFLICT (name) DO NOTHING;
        END $$;
    `;

    await client.query(query);
    await client.end();

    return {
        statusCode: 200,
        body: JSON.stringify({ message: "Migration executed successfully" }),
    };
};
