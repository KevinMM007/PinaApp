import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoPickerWidget extends StatelessWidget {
  final String? currentPhotoUrl;
  final double size;
  final bool isLoading;
  final Function(XFile) onPhotoSelected;

  const PhotoPickerWidget({
    Key? key,
    this.currentPhotoUrl,
    this.size = 120,
    this.isLoading = false,
    required this.onPhotoSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: isLoading ? null : () => _showImageSourceDialog(context),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 3,
              ),
              image: currentPhotoUrl != null && currentPhotoUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(currentPhotoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: currentPhotoUrl == null || currentPhotoUrl!.isEmpty
                ? Icon(
                    Icons.camera_alt,
                    size: size * 0.33,
                    color: Colors.grey[600],
                  )
                : null,
          ),
        ),
        if (isLoading)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.5),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.white,
                size: size * 0.16,
              ),
              onPressed:
                  isLoading ? null : () => _showImageSourceDialog(context),
            ),
          ),
        ),
      ],
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Cámara'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      print('📷 Iniciando selección de imagen desde: ${source == ImageSource.gallery ? "Galería" : "Cámara"}');
      
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        print('✅ Imagen seleccionada: ${image.path}');
        print('   - Nombre: ${image.name}');
        onPhotoSelected(image);
      } else {
        print('⚠️ No se seleccionó ninguna imagen');
      }
    } catch (e) {
      print('❌ Error al seleccionar imagen: $e');
    }
  }
}
