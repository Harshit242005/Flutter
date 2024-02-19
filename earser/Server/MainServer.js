const express = require('express');
const { MongoClient } = require('mongodb');
const cors = require('cors');
const bodyParser = require('body-parser');
const app = express();
const PORT = process.env.PORT || 3000;

// Enable CORS for all routes
app.use(cors());
// Parse JSON-encoded request bodies
app.use(express.json());
// Connect to MongoDB Atlas
const uri = 'mongodb+srv://agreharshit610:i4ZnXRbFARI4kaSl@taskhandler.u5cgjfw.mongodb.net/CodeUp';

// Connect to MongoDB
async function connectToMongoDB() {
  const client = new MongoClient(uri);

  try {
    await client.connect();
    
    return client.db(); // Return the database object
  } catch (error) {
    console.error('Error connecting to MongoDB:', error);
    throw error;
  }
}

// trying to add a new tech in the collection name
app.post('/api/data/:month/createNewTech/:newTech', async (req, res) => {
  const month_name = req.params.month;
  const newTech = req.params.newTech;
  console.log(`New tech name is: ${newTech}`);

  try {
    console.log(`collection name is ${month_name}`);
    const db = await connectToMongoDB();  // Connect to MongoDB
    // Use 'db.collection' to work with a specific collection
    const collection = db.collection(month_name);

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
app.get('/api/data/fetchTechNames/:month_name', async (req, res) => {
  
  try {
    const db = await connectToMongoDB();  
    const month_name = req.params.month_name;
    //console.log(`Month name for fetching tech names: ${month_name}`);
    
    // Use 'db.collection' to work with a specific collection
    const collection = db.collection(month_name);

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

// this would add the current date also over the doc
app.post('/api/data/:month/techUpdate/:techName/:techUpdateText', async (req, res) => {
  const techName = req.params.techName;
  const textUpdate = req.params.techUpdateText;
  const month = req.params.month;
  const currentDate = new Date().toLocaleDateString('en-GB'); // Get current date in dd/mm/yy format
  console.log(`Tech name is: ${techName}, text update is: ${textUpdate}, current date is: ${currentDate}`);
  const db = await connectToMongoDB();  // Connect to MongoDB
  const collection = db.collection(month);

  try {
    // Find the document based on TechName and current date
    const query = { "TechName": techName, "data.today_date": currentDate };
    const update = { $push: { "data.$.updates": textUpdate } };

    const result = await collection.findOneAndUpdate(query, update);
    // console.log(result);
    if (result == null) {
      // Document not found for the current date, create a new one
      const existingDocument = await collection.findOne({ "TechName": techName });

      if (existingDocument) {
        // Document found for the TechName, but not for the current date
        const newDataObject = {
          "today_date": currentDate,
          "updates": [textUpdate]
        };

        await collection.updateOne(
          { "TechName": techName },
          { $push: { "data": newDataObject } }
        );
      }
    } else {
      // Document found for the current date, update the existing one
      res.status(200).send('Update successful');
    }

  } catch (error) {
    // Error during the update
    console.error('Error updating document:', error);
    res.status(400).send('Error updating document');
  }
});


// fetch the tech update
app.get('/api/data/:month/getTechUpdates/:tech_name', async (req, res) => {
  const month = req.params.month;
  const techName = req.params.tech_name;
  const db = await connectToMongoDB();  // Connect to MongoDB
  const collection = db.collection(month);
  console.log('getting tech updates!');
  // Find the document that matches the tech_name
  const query = { "TechName": techName };

  // Use findOne to get a single matching document
  collection.findOne(query)
    .then((document) => {
      if (document) {
        const techUpdates = document.data || []; // Assuming 'data' is your array field
        // console.log(techUpdates);
        res.status(200).json({ techUpdates });
      } else {
        res.status(404).json({ message: 'Tech not found' });
      }
    })
    .catch((error) => {
      console.error('Error fetching tech updates:', error);
      res.status(500).json({ message: 'Internal Server Error' });
    });
});

// app.post('/api/data/:month/delete/:techName/:currentDate', async (req, res) => {
//   const month = req.params.month;
//   const techName = req.params.techName;
//   const currentDate = req.params.currentDate;
//   console.log(`month name is: ${month}, tech name is: ${techName} and current date is: ${currentDate}`);
//   const db = await connectToMongoDB();  // Connect to MongoDB
//   const collection = db.collection(month);

//   // Update the document using $pull to remove the specified object from the data array
//   const result = await collection.updateOne(
//     { "TechName": techName },
//     { $pull: { "data": { "today_date": currentDate } } }
//   );

//   if (result.modifiedCount > 0) {
//     res.status(200).json({ message: 'Object deleted successfully' });
//   } else {
//     res.status(404).json({ message: 'Object not found or not modified' });
//   }
// });



// delete the container
app.post('/api/data/removeContainer', async (req, res) => {
  console.log('testing api for delete container');
  console.log(req.body);
  console.log(req.body.Month);
  console.log(req.body.techName);
  console.log(req.body.date);
  
  const month = req.body.Month;
  const techName = req.body.techName;
  const currentDate = req.body.date;

  console.log(`month name is: ${month}, tech name is: ${techName} and current date is: ${currentDate}`);
  
  try {
    const db = await connectToMongoDB();  
    const collection = db.collection(month);

    const result = await collection.updateOne(
      { "TechName": techName },
      { $pull: { "data": { "today_date": currentDate } } }
    );

    if (result.modifiedCount > 0) {
      res.status(200).json({ message: 'Object deleted successfully' });
    } else {
      res.status(404).json({ message: 'Object not found or not modified' });
    }
  } catch (error) {
    console.error(`Error: ${error}`);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});


// api endpoint to delete the whole tech
app.post('/api/data/:Month/deleteTech/:TechName', async (req, res) => {
  const month = req.params.Month;
  const techName = req.params.TechName;
  console.log(`params data for this: ${month} and ${techName}`);

  try {
    const db = await connectToMongoDB();
    const collection = db.collection(month);

    // Delete the document with the specified TechName
    const result = await collection.deleteOne({ "TechName": techName });

    if (result.deletedCount > 0) {
      res.status(200).json({ message: 'Tech deleted successfully' });
    } else {
      res.status(404).json({ message: 'Tech not found or not deleted' });
    }
  } catch (error) {
    console.error(`Error: ${error}`);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});


app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});