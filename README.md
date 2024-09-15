# cloud-inventory-management

## Descripción de módulos utilizados

Se utilizan los módulos `hashicorp/dir/template`, `terraform-aws-modules/vpc/aws` y un módulo propietario de nombre `web-app`.

## Componentes a analizar y diagrama de arquitectura
![Diagrama de arquitectura](architecture.jpeg)
Los componentes a analizar son los siguientes:
- Lambda
- VPC Endpoint
- VPC
- Buckets S3
- DynamoDB
- CloudFront

## Descripción de meta-argumentos

### for_each
- Se utiliza para poder definir un local de las variables y definir los [índices](https://github.com/Khato1319/cloud-inventory-management/blob/main/iac/database.tf#L26) y [atributos](https://github.com/Khato1319/cloud-inventory-management/blob/main/iac/database.tf#L26) de la tabla a partir del mismo sin tener que repetir los nombres.
- Se utiliza en [```lambda.tf```](https://github.com/Khato1319/cloud-inventory-management/blob/8e233475712b3862220ed89dc98909841b2c19e5/iac/lambda.tf#L44) para poder iterar sobre archivos del directorio y comprimir todos los archivos de funciones lambda.
- Se utiliza en [```lambda.tf```](https://github.com/Khato1319/cloud-inventory-management/blob/8e233475712b3862220ed89dc98909841b2c19e5/iac/lambda.tf#L54) para poder iterar sobre archivos del directorio y publicar los lambdas de cada archivo.
- Se utiliza en [```cdn.tf```](https://github.com/Khato1319/cloud-inventory-management/blob/8e233475712b3862220ed89dc98909841b2c19e5/iac/web-app/cdn.tf#L24) para poder reusar la mayoría de la configuración de la distribución de CloudFront.
- Se utiliza en [```storage.tf```](https://github.com/Khato1319/cloud-inventory-management/blob/8e233475712b3862220ed89dc98909841b2c19e5/iac/web-app/storage.tf#L28) para poder reusar la configuración de los recursos asociados a los buckets raíz y de www.
- Se utiliza en [```storage.tf```](https://github.com/Khato1319/cloud-inventory-management/blob/8e233475712b3862220ed89dc98909841b2c19e5/iac/web-app/storage.tf#L21) para poder agreagar al bucket todos los archivos estáticos de la página web al bucket S3.
### depends_on
- Se utiliza en [```database.tf```](https://github.com/Khato1319/cloud-inventory-management/blob/main/iac/database.tf#L73) para crear la tabla antes de crear los targets de lectura/escritura
- Se utiliza en [```database.tf```](https://github.com/Khato1319/cloud-inventory-management/blob/main/iac/database.tf#L102) para crear los targets de lectura/escritura antes de la política de auto-scaling
- Se utiliza en [```storage.tf```](https://github.com/Khato1319/cloud-inventory-management/blob/main/iac/database.tf#L102) para crear la configuración pública de los buckets antes del ACL. 
### lifecycle
- Agrega una capa de seguridad extra en [```database.tf```](https://github.com/Khato1319/cloud-inventory-management/blob/8e233475712b3862220ed89dc98909841b2c19e5/iac/database.tf#L49) para evitar borrados accidentales del inventario de los clientes.
- Se utiliza en [```storage.tf```](https://github.com/Khato1319/cloud-inventory-management/blob/8e233475712b3862220ed89dc98909841b2c19e5/iac/web-app/storage.tf#L37) para que un ```terraform apply``` en una arquitectura creada no aplique permisos públicos cuando el bucket es privado. El recurso se usa únicamente para permitir agregarle una política al bucket, pero el estado final del mismo queremos que sea privado.
## Descripción de funciones
### templatefile
- Se utiliza en [```storage.tf```](https://github.com/Khato1319/cloud-inventory-management/blob/8e233475712b3862220ed89dc98909841b2c19e5/iac/web-app/storage.tf#L16) para poder reutilizar la configuración de una bucket policy cambiando únicamente ciertos parámetros como la distribución de CloudFront y el nombre del bucket.
### jsonencode
- Se utiliza en ```vpc-endpoint.tf``` en [aws_vpc_endpoint](https://github.com/Khato1319/cloud-inventory-management/blob/8e233475712b3862220ed89dc98909841b2c19e5/iac/vpc-endpoint.tf#L8) y en ```vpc-endpoint``` en [aws_iam_policy](?????).
### fileset
- Se utiliza en ```lambda.tf``` en [archive_file](https://github.com/Khato1319/cloud-inventory-management/blob/8e233475712b3862220ed89dc98909841b2c19e5/iac/lambda.tf#L44) y en [aws_lambda_function](https://github.com/Khato1319/cloud-inventory-management/blob/8e233475712b3862220ed89dc98909841b2c19e5/iac/lambda.tf#L54).
### split
- Se utiliza en ```lambda.tf``` en [archive_file](https://github.com/Khato1319/cloud-inventory-management/blob/8e233475712b3862220ed89dc98909841b2c19e5/iac/lambda.tf#L47) y en [aws_lambda_function](https://github.com/Khato1319/cloud-inventory-management/blob/8e233475712b3862220ed89dc98909841b2c19e5/iac/lambda.tf#L55).

# cloud-ecommerce
