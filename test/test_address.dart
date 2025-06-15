import 'dart:io';

void main() {
  final InternetAddress loopback = InternetAddress.loopbackIPv4;
  print('Loopback address: ${loopback.address}');
  print('Is loopback IPv4? ${loopback.isIPv4}'); // This line should compile and run

  final InternetAddress customIPv6 = InternetAddress('::1');
  print('Custom IPv6 address: ${customIPv6.address}');
  print('Is custom IPv6 an IPv6? ${customIPv6.isIPv6}'); // This line should compile and run
}