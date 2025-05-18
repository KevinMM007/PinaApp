import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/config/constants.dart';
import 'package:pina_app/models/producto.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/providers/product_provider.dart';
import 'package:pina_app/widgets/common/custom_button.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as String;
    final productProvider = Provider.of<ProductProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Cargar el producto seleccionado
    if (productProvider.productoSeleccionado?.id != productId && !_isLoading) {
      setState(() {
        _isLoading = true;
      });

      Future.microtask(() async {
        await productProvider.seleccionarProducto(productId);
        setState(() {
          _isLoading = false;
        });
      });
    }

    final Producto? producto = productProvider.productoSeleccionado;
    final bool esPropio = producto?.idVendedor == authProvider.user?.uid;
    final formatCurrency =
        NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 2);
    final formatDate = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Producto'),
        actions: esPropio
            ? [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'editar') {
                      Navigator.pushNamed(
                        context,
                        '/edit_product',
                        arguments: producto!.id,
                      );
                    } else if (value == 'eliminar') {
                      _mostrarDialogoEliminar(context, producto!.id ?? '');
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'editar',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Editar'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'eliminar',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Eliminar',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : producto == null
              ? const Center(child: Text('Producto no encontrado'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Galería de imágenes
                      SizedBox(
                        height: 250,
                        child: producto.fotos.isNotEmpty
                            ? PageView.builder(
                                itemCount: producto.fotos.length,
                                itemBuilder: (context, index) {
                                  return Image.network(
                                    producto.fotos[index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(Icons.image_not_supported,
                                              size: 50),
                                        ),
                                      );
                                    },
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.image, size: 50),
                                ),
                              ),
                      ),

                      // Información del producto
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              producto.titulo,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Chip(
                                  label: Text(
                                    'Variedad: ${producto.variedad}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text(
                                    'Calidad: ${producto.calidad}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formatCurrency.format(producto.precio),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  'por ${producto.unidadPrecio}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cantidad disponible: ${producto.cantidadDisponible} ${producto.unidadPrecio}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Descripción',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              producto.descripcion,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Ubicación',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    producto.ubicacion,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Publicado el ${formatDate.format(producto.fechaPublicacion)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Botones de acción (solo para compradores y cuando no es propio)
                            if (!esPropio &&
                                authProvider.userProfile?.tipo ==
                                    AppConstants.rolComprador)
                              Column(
                                children: [
                                  CustomButton(
                                    text: 'Contactar al vendedor',
                                    onPressed: () {
                                      // Implementar navegación a chat
                                    },
                                    width: double.infinity,
                                  ),
                                  const SizedBox(height: 12),
                                  CustomButton(
                                    text: 'Hacer oferta',
                                    onPressed: () {
                                      // Implementar lógica de oferta
                                    },
                                    width: double.infinity,
                                    color: Colors.orange,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  void _mostrarDialogoEliminar(BuildContext context, String productoId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: const Text(
            '¿Estás seguro de que deseas eliminar este producto? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final productProvider =
                  Provider.of<ProductProvider>(context, listen: false);
              final success =
                  await productProvider.eliminarProducto(productoId);

              if (success) {
                Navigator.pop(context); // Regresar a la lista
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Producto eliminado correctamente')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(productProvider.error)),
                );
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
