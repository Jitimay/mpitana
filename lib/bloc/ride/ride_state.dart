import '../../screens/offerRide/models/ride_offer.dart';

abstract class RideState {}

class RideInitial extends RideState {}

class RideLoading extends RideState {}

class RideLoaded extends RideState {
  final List<RideOffer> rides;
  
  RideLoaded({required this.rides});
}

class RideCreated extends RideState {
  final RideOffer ride;
  
  RideCreated({required this.ride});
}

class RideBooked extends RideState {
  final String message;
  
  RideBooked({required this.message});
}

class RideError extends RideState {
  final String message;
  
  RideError({required this.message});
}
