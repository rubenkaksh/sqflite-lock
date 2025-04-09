Timeline

1. Created a Database Service with sqflite package
2. Created a photo repository and model to fetch list of 5000 from https://jsonplaceholder.typicode.com/photos
3. Insert the data into table `photos` inside a transaction. Time taken: 3500 - 4000 ms
4. Use a batch-commit instead of repetitive inserts. Time taken: 100-144ms
5. Place batch-commit inside a transaction to ensure integrity. Time taken: 140-150ms