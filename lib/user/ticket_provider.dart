import 'package:flutter/material.dart';
import 'ticket_model.dart';

class TicketProvider with ChangeNotifier {
  List<Ticket> _tickets = [];

  List<Ticket> get tickets => _tickets;

  void addTicket(Ticket ticket) {
    _tickets.add(ticket);
    notifyListeners();
  }
}
