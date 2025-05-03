import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seminari_flutter/provider/users_provider.dart';
import 'package:seminari_flutter/widgets/Layout.dart';
import 'package:go_router/go_router.dart';

class ContrasenyaScreen extends StatefulWidget {
  const ContrasenyaScreen({super.key});

  @override
  State<ContrasenyaScreen> createState() => _ContrasenyaScreenState();
}

class _ContrasenyaScreenState extends State<ContrasenyaScreen> {
  final _formKey = GlobalKey<FormState>();
  final currentPassController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();

  @override
  void dispose() {
    currentPassController.dispose();
    newPassController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    // Verifica si el usuario actual está correctamente inicializado
    if (user.id == null || user.id!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Canviar Contrasenya')),
        body: const Center(
          child: Text('Error: No s\'ha trobat cap usuari vàlid.'),
        ),
      );
    }

    return LayoutWrapper(
      title: 'Canviar Contrasenya',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Hola, ${user.name}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Actualitza la teva contrasenya de forma segura',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Formulario
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildPasswordField(
                            controller: currentPassController,
                            label: 'Contrasenya actual',
                          ),
                          const SizedBox(height: 16),
                          _buildPasswordField(
                            controller: newPassController,
                            label: 'Nova contrasenya',
                          ),
                          const SizedBox(height: 16),
                          _buildPasswordField(
                            controller: confirmPassController,
                            label: 'Confirma nova contrasenya',
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (newPassController.text !=
                                    confirmPassController.text) {
                                  _showError(
                                    'Les contrasenyes no coincideixen',
                                  );
                                  return;
                                }

                                final result = await userProvider
                                    .canviarContrasenya(newPassController.text);

                                if (result == true) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Contrasenya actualitzada correctament!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  currentPassController.clear();
                                  newPassController.clear();
                                  confirmPassController.clear();
                                  context.go('/login');
                                } else {
                                  _showError(result.toString());
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'CANVIAR CONTRASENYA',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.lock),
        filled: true,
        fillColor: Colors.grey.shade100,
        floatingLabelStyle: const TextStyle(
          color: Colors.blue, // Cambia el color del label flotante aquí
          fontWeight: FontWeight.bold,
        ),
      ),
      style: const TextStyle(color: Colors.blue), // Cambia el color del texto aquí
      validator: (value) =>
          value == null || value.isEmpty ? 'Aquest camp és obligatori' : null,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}