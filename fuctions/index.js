const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNewEventNotification = functions.firestore
    .document('events/{eventId}')
    .onCreate(async (snap, context) => {
      const event = snap.data();

      const payload = {
        notification: {
          title: 'New Event Posted!',
          body: `Check out the new event: ${event.name}`,
        },
        topic: 'events'
      };

      await admin.messaging().send(payload);
    });
