import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pina_app/services/storage_service.dart';

class ImagePickerWidget extends StatelessWidget {
  final Function(File) onImageSelected;
  final String? currentImageUrl;
  final bool isLoading;

  const ImagePickerWidget({
    Key? key,
    required this.onImageSelected,
    this.currentImageUrl,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: isLoading ? null : () => _showImageSourceDialog(context),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 3,
              ),
              image: currentImageUrl != null && currentImageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(currentImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: currentImageUrl == null || currentImageUrl!.isEmpty
                ? Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: Colors.grey[600],
                  )
                : null,
          ),
        ),
        if (isLoading)
          Container(
            width: 120,
            height: 120,
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
              icon: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 20,
              ),
              onPressed: isLoading ? null : () => _showImageSourceDialog(context),
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
              if (currentImageUrl != null && currentImageUrl!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Eliminar foto'),
                  onTap: () {
                    Navigator.of(context).pop();
                    // Para eliminar, pasamos un archivo vacío
                    onImageSelected(File(''));
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final StorageService storageService = StorageService();
    final File? image = await storageService.seleccionarImagen(source);
    
    if (image != null) {
      onImageSelected(image);
    }
  }
}
