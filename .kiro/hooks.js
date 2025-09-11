// Custom Kiro hooks for Mpitana ride-sharing app

module.exports = {
    afterUserCreated: (user) => {
      console.log(`New user registered: ${user.name}`);
    },
  
    afterRideOffered: (ride) => {
      console.log(`Ride offered from ${ride.origin} to ${ride.destination} by driver ${ride.driverId}`);
    },
  
    afterRideAccepted: (ride) => {
      console.log(`Ride ${ride.id} was accepted by driver ${ride.driverId}`);
    },
  
    afterRideCompleted: (ride) => {
      console.log(`Ride ${ride.id} completed. Updating wallet balances...`);
      // simulate transaction
    },
  
    afterMessageSent: (message) => {
      console.log(`Message from ${message.senderId} to ${message.receiverId}: ${message.content}`);
    }
  };
  