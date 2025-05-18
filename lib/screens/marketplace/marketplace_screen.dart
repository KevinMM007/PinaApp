import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/config/constants.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/providers/product_provider.dart';
import 'package:pina_app/widgets/product/product_card.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _filterVariedad = 'Todas';
  
  @override
  void initState() {
    super.initState();
    // Cargar los productos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).cargarProductos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final esProductor = authProvider.userProfile?.tipo == AppConstants.rolProductor;
    
    return Scaffold(
      body: Column(
        children: [
          // Filtros
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Todas'),
                    selected: _filterVariedad == 'Todas',
                    onSelected: (selected) {
                      setState(() {
                        _filterVariedad = 'Todas';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ...AppConstants.variedadesPina.map((variedad) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(variedad),
                      selected: _filterVariedad == variedad,
                      onSelected: (selected) {
                        setState(() {
                          _filterVariedad = variedad;
                        });
                      },
                    ),
                  )).toList(),
                ],
              ),
            ),
          ),
          
          // Lista de productos
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : productProvider.productos.isEmpty
                    ? const Center(
                        child: Text('No hay productos disponibles.'),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          productProvider.cargarProductos();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: productProvider.productos.length,
                          itemBuilder: (context, index) {
                            final producto = productProvider.productos[index];
                            
                            // Filtrar por variedad si no es "Todas"
                            if (_filterVariedad != 'Todas' && producto.variedad != _filterVariedad) {
                              return const SizedBox.shrink();
                            }
                            
                            return ProductCard(
                              producto: producto,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/product_detail',
                                  arguments: producto.id,
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      // Botón para añadir producto (solo para productores)
      floatingActionButton: esProductor
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add_product');
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}