const express = require('express');
const { MongoClient } = require('mongodb');
const cors = require('cors');
const dotenv = require('dotenv');
const app = express();
const PORT = process.env.PORT || 3000;
dotenv.config();
// Enable CORS for all routes
app.use(cors());

// Connect to MongoDB Atlas
const uri = 'mongodb+srv://agreharshit610:i4ZnXRbFARI4kaSl@taskhandler.u5cgjfw.mongodb.net/CodeUp';

async function connectToMongo() {
  try {
    const client = await MongoClient.connect(uri);
    console.log('Connected to MongoDB');
    return client.db(); // Return the database instance
  } catch (error) {
    console.error('Error connecting to MongoDB:', error);
    throw error; // Propagate the error
  }
}

// Use an async function to ensure the MongoDB connection is established before starting the server
async function startServer() {
  const db = await connectToMongo();

  app.post('/api/data/:currentConnection', async (req, res) => {
    const currentConnection = req.params.currentConnection;
    console.log(`Current working collection name: ${currentConnection}`);
    // we have to make sure that collection name should be
    // saved in the .env file as the current active collection
    // Check if ACTIVE_COLLECTION is defined in the .env file
    if (!process.env.ACTIVE_COLLECTION) {
      // If not defined, set the currentConnection as the ACTIVE_COLLECTION
      process.env.ACTIVE_COLLECTION = currentConnection;
      console.log(`Set ACTIVE_COLLECTION to: ${currentConnection}`);
    }

    // Use 'db.collection' to work with a specific collection
    const collection = db.collection(currentConnection);
    // Perform operations on the collection as needed

    res.send(`Working with collection: ${currentConnection}`);
  });

  // trying to add a new tech in the collection name
  app.post('/api/data/createNewTech/:newTech', async (req, res) => {
    const newTech = req.params.newTech;
    console.log(`New tech name is: ${newTech}`);

    try {

      const collectionName = process.env.ACTIVE_COLLECTION;
      console.log(`collection name is ${collectionName}`);
      // Use 'db.collection' to work with a specific collection
      const collection = db.collection(collectionName);

      // Check if a document with the specified tech name already exists
      const existingDocument = await collection.findOne({ TechName: newTech });

      if (existingDocument) {
        // Tech name already exists, return an appropriate response
        return res.status(409).json({ message: 'Tech name already exists' });
      }

      // If the tech name doesn't exist, create a new document with an empty array
      const newDocument = { TechName: newTech, data: [] };
      await collection.insertOne(newDocument);

      // Return a success response
      return res.status(200).json({ message: 'Tech added successfully' });
    } catch (error) {
      // Handle errors
      console.error('Error adding tech:', error);
      return res.status(500).json({ message: 'Internal Server Error' });
    }
  });

  // getting all the tech names
  app.get('/fetchTechNames/:month_name', async (req, res) => {
    try {
      const month_name = req.params.month_name;
      console.log(`Month name for fetching tech names: ${month_name}`);
      const collectionName = process.env.ACTIVE_COLLECTION;
      console.log(`Collection name is ${collectionName}`);

      // Use 'db.collection' to work with a specific collection
      const collection = db.collection(collectionName);

      // Fetch all documents from the collection
      const cursor = collection.find({});
      const techNamesArray = [];

      await cursor.forEach((document) => {
        // Assuming 'TechName' is a key in each document
        const techName = document.TechName;

        // Add techName to the array
        techNamesArray.push(techName);
      });

      // Send the array as a response with status code 200
      res.status(200).json({ techNames: techNamesArray });
    } catch (error) {
      console.error('Error fetching tech names:', error);
      // Send an appropriate error status code
      res.status(500).json({ error: 'Internal Server Error' });
    }

  });

  app.post('/api/data/:month/techUpdate/:techName/:techUpdateText', async (req, res) => {
    const techName = req.params.techName;
    const textUpdate = req.params.techUpdateText;
    const month = req.params.month;
    console.log(`Tech name is: ${techName} and text update is: ${textUpdate}`);

    const collection = db.collection(month);

    try {
      // Find the document based on TechName
      const query = { "TechName": techName };
      const update = { $push: { "data": textUpdate } };

      const result = await collection.findOneAndUpdate(query, update);

      if (result.value) {
        // Document found and updated successfully
        res.status(200).send('Update successful');
      } else {
        // Document not found
        res.status(404).send('Document not found');
      }
    } catch (error) {
      // Error during the update
      console.error('Error updating document:', error);
      res.status(400).send('Error updating document');
    }
  });


  app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
  });
}


// Start the server after establishing the MongoDB connection
startServer();