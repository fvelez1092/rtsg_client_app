import 'package:flutter/material.dart';

// ---------- SCREEN 1: Package Details ----------
class PackageDetailsScreen extends StatefulWidget {
  const PackageDetailsScreen({super.key});

  @override
  State<PackageDetailsScreen> createState() => _PackageDetailsScreenState();
}

class _PackageDetailsScreenState extends State<PackageDetailsScreen> {
  int selectedSize = 0;
  int selectedUrgency = 0;
  bool photoConfirmation = false;
  bool signature = false;
  bool smsNotification = false;

  double baseCost = 12.0;

  double getTotalCost() {
    double total = baseCost;
    if (photoConfirmation) total += 1.0;
    if (signature) total += 2.0;
    if (smsNotification) total += 0.5;
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B0130), Color(0xFF3D244C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white10,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Enviar Encomienda',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Envío seguro puerta a puerta',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // PROGRESS STEPS
                Row(
                  children: [
                    stepCircle('1', true),
                    const Expanded(child: Divider(color: Colors.white30)),
                    stepCircle('2', false),
                    const Expanded(child: Divider(color: Colors.white30)),
                    stepCircle('3', false),
                  ],
                ),
              ],
            ),
          ),

          // MAIN CONTENT
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Remitente
                    sectionCard(
                      title: 'Datos del remitente',
                      icon: Icons.person,
                      children: [
                        textField('Nombre completo'),
                        textField('Teléfono'),
                        textField(
                          'Dirección de recogida',
                          suffixIcon: Icons.location_on,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Destinatario
                    sectionCard(
                      title: 'Datos del destinatario',
                      icon: Icons.location_on,
                      children: [
                        textField('Nombre completo'),
                        textField('Teléfono'),
                        textField(
                          'Dirección de entrega',
                          suffixIcon: Icons.map,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Detalles del paquete
                    sectionCard(
                      title: 'Detalles del paquete',
                      icon: Icons.inventory_2,
                      children: [
                        textField('Descripción del contenido'),
                        Row(
                          children: [
                            Expanded(
                              child: textField('Peso (kg)', isNumber: true),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: textField(
                                'Valor declarado',
                                isNumber: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tamaño del paquete',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(3, (index) {
                            final labels = ['Pequeño', 'Mediano', 'Grande'];
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedSize = index;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: selectedSize == index
                                          ? Colors.orange
                                          : Colors.grey,
                                      width: selectedSize == index ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.currency_bitcoin,
                                        color: selectedSize == index
                                            ? Colors.orange
                                            : Colors.grey,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        labels[index],
                                        style: TextStyle(
                                          color: selectedSize == index
                                              ? Colors.orange
                                              : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Urgencia del envío',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(2, (index) {
                            final icons = [Icons.access_time, Icons.flash_on];
                            final labels = ['Normal', 'Express'];
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedUrgency = index;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: selectedUrgency == index
                                          ? Colors.orange
                                          : Colors.grey,
                                      width: selectedUrgency == index ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        icons[index],
                                        color: selectedUrgency == index
                                            ? Colors.orange
                                            : Colors.grey,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        labels[index],
                                        style: TextStyle(
                                          color: selectedUrgency == index
                                              ? Colors.orange
                                              : Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        index == 0
                                            ? '24-48 horas'
                                            : 'Mismo día',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        index == 0 ? '\$5.00' : '\$12.00',
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Opciones adicionales
                    sectionCard(
                      title: 'Opciones adicionales',
                      icon: Icons.shield,
                      children: [
                        CheckboxListTile(
                          value: photoConfirmation,
                          title: const Text('Foto de confirmación'),
                          subtitle: const Text('Foto al entregar el paquete'),
                          secondary: const Icon(
                            Icons.camera_alt,
                            color: Colors.orange,
                          ),
                          onChanged: (val) =>
                              setState(() => photoConfirmation = val!),
                        ),
                        CheckboxListTile(
                          value: signature,
                          title: const Text('Firma del destinatario'),
                          subtitle: const Text(
                            'Confirmación con firma digital',
                          ),
                          secondary: const Icon(
                            Icons.edit,
                            color: Colors.orange,
                          ),
                          onChanged: (val) => setState(() => signature = val!),
                        ),
                        CheckboxListTile(
                          value: smsNotification,
                          title: const Text('Notificaciones SMS'),
                          subtitle: const Text('Alertas de estado del envío'),
                          secondary: const Icon(
                            Icons.notifications,
                            color: Colors.orange,
                          ),
                          onChanged: (val) =>
                              setState(() => smsNotification = val!),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Resumen de costos
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Resumen de costos',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          costRow('Envío express', 12.0),
                          if (photoConfirmation)
                            costRow('Foto de confirmación', 1.0),
                          if (signature) costRow('Firma del destinatario', 2.0),
                          if (smsNotification)
                            costRow('Notificaciones SMS', 0.5),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '\$${getTotalCost().toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botones
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PaymentScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Continuar al pago',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Borrador guardado exitosamente'),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Guardar como borrador',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget stepCircle(String text, bool active) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: active ? Colors.orange : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget textField(String hint, {bool isNumber = false, IconData? suffixIcon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: Colors.orange)
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget costRow(String label, double cost) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '\$${cost.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ---------- SCREEN 2: Payment ----------
class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Pantalla de Pago (Implementar similar a PackageDetailsScreen)',
        ),
      ),
    );
  }
}
