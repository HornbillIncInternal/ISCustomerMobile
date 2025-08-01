abstract class ConnectivityEvent {}

class CheckConnectivity extends ConnectivityEvent {}
class ConnectivityChanged extends ConnectivityEvent {
  final bool isConnected;
  ConnectivityChanged(this.isConnected);
}
