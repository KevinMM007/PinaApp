import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  
  StorageService() {
    // Imprimir configuración de Storage para debug
    print('🔥 Firebase Storage inicializado');
    print('   - Bucket: ${_storage.bucket}');
    print('   - Max upload retry time: ${_storage.maxUploadRetryTime}');
    print('   - Max download retry time: ${_storage.maxDownloadRetryTime}');
  }

  // Seleccionar imagen de galería o cámara
  Future<File?> seleccionarImagen(ImageSource source) async {
    try {
      final XFile? imagen = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (imagen != null) {
        return File(imagen.path);
      }
      return null;
    } catch (e) {
      print('Error al seleccionar imagen: $e');
      return null;
    }
  }

  // Subir imagen de perfil
  Future<String?> subirImagenPerfil({
    required String userId,
    required XFile imagen,
  }) async {
    try {
      print('📸 Iniciando subida de imagen...');
      print('   - UserId: $userId');
      print('   - Path imagen: ${imagen.path}');
      
      // Verificar que el archivo existe
      File imageFile = File(imagen.path);
      if (!await imageFile.exists()) {
        print('❌ El archivo no existe en la ruta especificada');
        return null;
      }
      
      print('   - Tamaño archivo: ${await imageFile.length()} bytes');
      
      return await subirFotoPerfil(userId: userId, imagen: imageFile);
    } catch (e) {
      print('❌ Error al subir imagen de perfil: $e');
      print('   - Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  // Subir foto de perfil (método interno)
  Future<String?> subirFotoPerfil({
    required String userId,
    required File imagen,
  }) async {
    try {
      print('📤 Subiendo archivo a Firebase Storage...');
      
      // Crear referencia única para la imagen
      String fileName = 'perfil_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      print('   - Nombre archivo: $fileName');
      
      Reference ref = _storage.ref().child('perfiles').child(fileName);
      print('   - Referencia creada: ${ref.fullPath}');
      
      // Configurar metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );
      
      // Subir imagen
      print('   - Iniciando upload...');
      UploadTask uploadTask = ref.putFile(imagen, metadata);
      
      // Monitorear progreso
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('   - Progreso: ${progress.toStringAsFixed(0)}%');
      });
      
      // Esperar a que termine la subida
      TaskSnapshot snapshot = await uploadTask;
      print('   - Upload completado. Estado: ${snapshot.state}');
      
      // Obtener URL de descarga
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('✅ URL obtenida: $downloadUrl');
      
      return downloadUrl;
    } catch (e) {
      print('❌ Error detallado al subir foto de perfil:');
      print('   - Tipo de error: ${e.runtimeType}');
      print('   - Mensaje: $e');
      print('   - Stack trace: ${StackTrace.current}');
      
      if (e is FirebaseException) {
        print('   - Código Firebase: ${e.code}');
        print('   - Plugin: ${e.plugin}');
      }
      
      return null;
    }
  }

  // Subir imagen de producto
  Future<String?> subirImagenProducto({
    required String productId,
    required File imagen,
    required int index,
  }) async {
    try {
      String fileName = 'producto_${productId}_${index}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child('productos').child(fileName);
      
      UploadTask uploadTask = ref.putFile(imagen);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error al subir imagen de producto: $e');
      return null;
    }
  }

  // Eliminar imagen
  Future<bool> eliminarImagen(String imageUrl) async {
    try {
      // Obtener referencia desde la URL
      Reference ref = _storage.refFromURL(imageUrl);
      
      // Eliminar imagen
      await ref.delete();
      
      return true;
    } catch (e) {
      print('Error al eliminar imagen: $e');
      return false;
    }
  }

  // Subir múltiples imágenes (para productos)
  Future<List<String>> subirMultiplesImagenes({
    required String productId,
    required List<File> imagenes,
  }) async {
    List<String> urls = [];
    
    for (int i = 0; i < imagenes.length; i++) {
      String? url = await subirImagenProducto(
        productId: productId,
        imagen: imagenes[i],
        index: i,
      );
      
      if (url != null) {
        urls.add(url);
      }
    }
    
    return urls;
  }
}
