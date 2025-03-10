docker pull postgres:17

docker run --name my-postgres-container -e POSTGRES_PASSWORD=mysecretpassword -d postgres:17

docker exec -it my-postgres-container psql -U postgres
