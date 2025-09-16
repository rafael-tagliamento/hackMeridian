import 'package:flutter/material.dart';
import '../widgets/vaccination_lists.dart';

class VaccinationScreen extends StatelessWidget {
  const VaccinationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: const [
            SizedBox(height: 12),
            VaccinationLists(),
          ],
        ),
      ),
    );
  }
}
