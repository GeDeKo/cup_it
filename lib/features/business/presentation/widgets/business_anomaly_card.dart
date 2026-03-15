import 'package:flutter/material.dart';

import '../../../../shared/widgets/glass_card.dart';
import '../../domain/business_anomaly_model.dart';

class BusinessAnomalyCard extends StatelessWidget {
  const BusinessAnomalyCard({super.key, required this.item});

  final BusinessAnomalyModel item;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.warning_amber_rounded, color: Color(0xFFFFC46B)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(item.description),
                const SizedBox(height: 4),
                Text(item.delta, style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
