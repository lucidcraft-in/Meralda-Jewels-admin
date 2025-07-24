import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionTile extends StatelessWidget {
  final Map<dynamic, dynamic> transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    DateTime date = transaction["date"].toDate();
    String formattedDate = DateFormat.yMMMEd().format(date);
    String amount = NumberFormat.currency(symbol: "₹", decimalDigits: 2)
        .format(transaction["amount"]);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Row(
        children: [
          // Leading Icon
          CircleAvatar(
            radius: 16,
            backgroundColor: Color.fromARGB(255, 160, 20, 20),
            child: Icon(
              Icons.payment,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 15),

          // Transaction Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      transaction["customerName"],
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  "${transaction["custID"]}",
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  formattedDate,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            amount,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: transaction["transactionType"] == 0
                    ? Color.fromARGB(255, 32, 110, 20)
                    : Colors.red),
          ),
        ],
      ),
    );
  }
}
