import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/order_item_entity.dart';

class OrderItemTile extends StatelessWidget {
  const OrderItemTile({super.key, required this.item, this.trailing});

  final OrderItemEntity item;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text('${item.quantity} x ${Formatters.currency(item.price)}'),
      trailing: trailing ??
          Text(
            Formatters.currency(item.subtotal),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
    );
  }
}
