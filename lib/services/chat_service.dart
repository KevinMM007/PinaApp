import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pina_app/models/mensaje.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crear o obtener una conversación
  Future<String?> crearOObtenerConversacion({
    required String usuario1Id,
    required String usuario1Nombre,
    required String usuario2Id,
    required String usuario2Nombre,
    String? productoId,
    String? productoNombre,
  }) async {
    try {
      print('🔍 Buscando conversación existente entre $usuario1Id y $usuario2Id');
      
      // Buscar si ya existe una conversación entre estos usuarios
      // Primero buscar donde usuario1 esté en participantes
      var querySnapshot = await _firestore
          .collection('conversaciones')
          .where('participantes', arrayContains: usuario1Id)
          .get();

      // Filtrar las conversaciones que contengan ambos usuarios
      var conversacionDocs = querySnapshot.docs.where((doc) {
        final participantes = List<String>.from(doc.data()['participantes']);
        return participantes.contains(usuario2Id);
      }).toList();
      
      if (conversacionDocs.isEmpty) {
        // Si no se encontró, buscar donde usuario2 esté en participantes
        querySnapshot = await _firestore
            .collection('conversaciones')
            .where('participantes', arrayContains: usuario2Id)
            .get();
            
        conversacionDocs = querySnapshot.docs.where((doc) {
          final participantes = List<String>.from(doc.data()['participantes']);
          return participantes.contains(usuario1Id);
        }).toList();
      }
      
      if (conversacionDocs.isNotEmpty) {
        // Si existe, retornar el ID
        return conversacionDocs.first.id;
      }
      
      // Si no existe, lanzar excepción para crear una nueva
      print('🆕 No se encontró conversación existente, creando nueva...');
      throw Exception('No existe conversación');
    } catch (e) {
      // Si no existe, crear una nueva conversación
      print('📨 Creando nueva conversación...');
      try {
        final conversationData = {
          'participantes': [usuario1Id, usuario2Id],
          'participantesInfo': {
            usuario1Id: usuario1Nombre,
            usuario2Id: usuario2Nombre,
          },
          'productoId': productoId,
          'productoNombre': productoNombre,
          'ultimoMensaje': 'Conversación iniciada',
          'fechaUltimoMensaje': Timestamp.now(),
          'mensajesNoLeidos': {
            usuario1Id: 0,
            usuario2Id: 0,
          },
          'fechaCreacion': Timestamp.now(),
        };
        
        print('📝 Datos de la conversación: $conversationData');
        
        final docRef = await _firestore.collection('conversaciones').add(conversationData);

        return docRef.id;
      } catch (error) {
        print('Error creando conversación: $error');
        return null;
      }
    }
  }

  // Enviar un mensaje
  Future<bool> enviarMensaje({
    required String conversacionId,
    required String senderId,
    required String senderNombre,
    required String receiverId,
    required String contenido,
    String tipo = 'texto',
    Map<String, dynamic>? datosAdicionales,
  }) async {
    try {
      // Crear el mensaje
      await _firestore
          .collection('conversaciones')
          .doc(conversacionId)
          .collection('mensajes')
          .add({
        'senderId': senderId,
        'senderNombre': senderNombre,
        'receiverId': receiverId,
        'conversacionId': conversacionId,
        'contenido': contenido,
        'tipo': tipo,
        'fechaEnvio': Timestamp.now(),
        'leido': false,
        'datosAdicionales': datosAdicionales,
      });

      // Actualizar la conversación con el último mensaje
      await _firestore.collection('conversaciones').doc(conversacionId).update({
        'ultimoMensaje': contenido,
        'fechaUltimoMensaje': Timestamp.now(),
        'mensajesNoLeidos.$receiverId': FieldValue.increment(1),
      });

      // Método de diagnóstico para verificar conversaciones
  Future<void> diagnosticarConversaciones(String usuarioId) async {
    print('\n🆔🆔🆔 DIAGNÓSTICO DE CONVERSACIONES 🆔🆔🆔');
    print('Usuario ID: $usuarioId');
    
    try {
      // Obtener TODAS las conversaciones
      final snapshot = await _firestore.collection('conversaciones').get();
      print('Total de conversaciones en la base de datos: ${snapshot.docs.length}');
      
      // Revisar cada conversación
      for (var doc in snapshot.docs) {
        final data = doc.data();
        print('\n--- Conversación ${doc.id} ---');
        print('Participantes: ${data['participantes']}');
        print('ParticipantesInfo: ${data['participantesInfo']}');
        print('Último mensaje: ${data['ultimoMensaje']}');
        print('Fecha último mensaje: ${data['fechaUltimoMensaje']}');
        
        // Verificar si el usuario es participante
        final participantes = List<String>.from(data['participantes'] ?? []);
        if (participantes.contains(usuarioId)) {
          print('⭐ ¡USUARIO ES PARTICIPANTE EN ESTA CONVERSACIÓN!');
        }
      }
    } catch (e) {
      print('❌ Error en diagnóstico: $e');
    }
    
    print('\n🆔🆔🆔 FIN DEL DIAGNÓSTICO 🆔🆔🆔\n');
  }

  // Crear notificación para el receptor
      await _crearNotificacion(
        usuarioId: receiverId,
        tipo: 'nuevo_mensaje',
        titulo: 'Nuevo mensaje de $senderNombre',
        mensaje: contenido,
        datos: {
          'conversacionId': conversacionId,
          'senderId': senderId,
        },
      );

      return true;
    } catch (e) {
      print('Error enviando mensaje: $e');
      return false;
    }
  }

  // Obtener mensajes de una conversación
  Stream<List<Mensaje>> getMensajes(String conversacionId) {
    return _firestore
        .collection('conversaciones')
        .doc(conversacionId)
        .collection('mensajes')
        .orderBy('fechaEnvio', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Mensaje.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Obtener conversaciones de un usuario - Versión alternativa sin índices
  Stream<List<Conversacion>> getConversacionesAlternativo(String usuarioId) {
    print('🔍 [ALTERNATIVO] Buscando conversaciones para usuario: $usuarioId');
    
    return _firestore
        .collection('conversaciones')
        .snapshots()
        .map((snapshot) {
      print('📊 [ALTERNATIVO] Total documentos en colección: ${snapshot.docs.length}');
      
      // Filtrar manualmente las conversaciones donde el usuario es participante
      final conversacionesFiltradas = snapshot.docs.where((doc) {
        final data = doc.data();
        final participantes = List<String>.from(data['participantes'] ?? []);
        final esParticipante = participantes.contains(usuarioId);
        
        if (esParticipante) {
          print('🌟 Usuario ES participante en conversación ${doc.id}');
          print('   Participantes: $participantes');
        }
        
        return esParticipante;
      }).toList();
      
      print('🔍 [ALTERNATIVO] Conversaciones filtradas: ${conversacionesFiltradas.length}');
      
      // Convertir a objetos Conversacion
      final conversaciones = conversacionesFiltradas
          .map((doc) {
            try {
              return Conversacion.fromMap(doc.id, doc.data());
            } catch (e) {
              print('❌ Error procesando conversación ${doc.id}: $e');
              return null;
            }
          })
          .where((conv) => conv != null)
          .cast<Conversacion>()
          .toList();
      
      print('✅ [ALTERNATIVO] Conversaciones válidas: ${conversaciones.length}');
      
      // Ordenar por fecha del último mensaje
      conversaciones.sort((a, b) {
        final fechaA = a.fechaUltimoMensaje ?? DateTime(1970);
        final fechaB = b.fechaUltimoMensaje ?? DateTime(1970);
        return fechaB.compareTo(fechaA);
      });
      
      return conversaciones;
    });
  }

  // Obtener conversaciones de un usuario
  Stream<List<Conversacion>> getConversaciones(String usuarioId) {
    // Usar el método alternativo por ahora
    return getConversacionesAlternativo(usuarioId);
  }

  // Método original con arrayContains (comentado por ahora)
  Stream<List<Conversacion>> getConversacionesOriginal(String usuarioId) {
    print('🔍 Buscando conversaciones para usuario: $usuarioId');
    
    return _firestore
        .collection('conversaciones')
        .where('participantes', arrayContains: usuarioId)
        .snapshots()
        .map((snapshot) {
      print('📊 Documentos encontrados: ${snapshot.docs.length}');
      
      // Obtener las conversaciones y ordenarlas manualmente
      final conversaciones = snapshot.docs
          .map((doc) {
            print('📄 Procesando documento: ${doc.id}');
            print('📋 Datos: ${doc.data()}');
            try {
              return Conversacion.fromMap(doc.id, doc.data());
            } catch (e) {
              print('❌ Error procesando conversación ${doc.id}: $e');
              return null;
            }
          })
          .where((conv) => conv != null)
          .cast<Conversacion>()
          .toList();
      
      print('✅ Conversaciones válidas: ${conversaciones.length}');
      
      // Ordenar por fecha del último mensaje (las más recientes primero)
      conversaciones.sort((a, b) {
        final fechaA = a.fechaUltimoMensaje ?? DateTime(1970);
        final fechaB = b.fechaUltimoMensaje ?? DateTime(1970);
        return fechaB.compareTo(fechaA);
      });
      
      return conversaciones;
    }).handleError((error) {
      print('❌ Error obteniendo conversaciones: $error');
      return <Conversacion>[];
    });
  }

  // Marcar mensajes como leídos
  Future<void> marcarMensajesComoLeidos(
    String conversacionId,
    String usuarioId,
  ) async {
    try {
      // Obtener mensajes no leídos
      final mensajesSnapshot = await _firestore
          .collection('conversaciones')
          .doc(conversacionId)
          .collection('mensajes')
          .where('receiverId', isEqualTo: usuarioId)
          .where('leido', isEqualTo: false)
          .get();

      // Actualizar cada mensaje
      final batch = _firestore.batch();

      for (final doc in mensajesSnapshot.docs) {
        batch.update(doc.reference, {'leido': true});
      }

      // Resetear contador de mensajes no leídos
      batch.update(
        _firestore.collection('conversaciones').doc(conversacionId),
        {'mensajesNoLeidos.$usuarioId': 0},
      );

      await batch.commit();
    } catch (e) {
      print('Error marcando mensajes como leídos: $e');
    }
  }

  // Eliminar una conversación
  Future<bool> eliminarConversacion(String conversacionId) async {
    try {
      // Eliminar todos los mensajes
      final mensajesSnapshot = await _firestore
          .collection('conversaciones')
          .doc(conversacionId)
          .collection('mensajes')
          .get();

      final batch = _firestore.batch();

      for (final doc in mensajesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Eliminar la conversación
      batch.delete(
        _firestore.collection('conversaciones').doc(conversacionId),
      );

      await batch.commit();
      return true;
    } catch (e) {
      print('Error eliminando conversación: $e');
      return false;
    }
  }

  // Buscar conversaciones por producto
  Future<List<Conversacion>> getConversacionesPorProducto(
      String productoId) async {
    try {
      final querySnapshot = await _firestore
          .collection('conversaciones')
          .where('productoId', isEqualTo: productoId)
          .get();

      return querySnapshot.docs
          .map((doc) => Conversacion.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error obteniendo conversaciones por producto: $e');
      return [];
    }
  }

  // Enviar mensaje de oferta
  Future<bool> enviarMensajeOferta({
    required String conversacionId,
    required String senderId,
    required String senderNombre,
    required String receiverId,
    required String ofertaId,
    required double precio,
    required double cantidad,
    required String unidad,
    required String productoNombre,
  }) async {
    return await enviarMensaje(
      conversacionId: conversacionId,
      senderId: senderId,
      senderNombre: senderNombre,
      receiverId: receiverId,
      contenido: 'Ha realizado una oferta por $productoNombre',
      tipo: 'oferta',
      datosAdicionales: {
        'ofertaId': ofertaId,
        'precio': precio,
        'cantidad': cantidad,
        'unidad': unidad,
        'productoNombre': productoNombre,
      },
    );
  }

  // Obtener número total de mensajes no leídos
  Stream<int> getTotalMensajesNoLeidos(String usuarioId) {
    return _firestore
        .collection('conversaciones')
        .where('participantes', arrayContains: usuarioId)
        .snapshots()
        .map((snapshot) {
      int total = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final mensajesNoLeidos =
            data['mensajesNoLeidos'] as Map<String, dynamic>?;
        if (mensajesNoLeidos != null && mensajesNoLeidos[usuarioId] != null) {
          total += mensajesNoLeidos[usuarioId] as int;
        }
      }
      return total;
    });
  }

  // Método de diagnóstico para verificar conversaciones
  Future<void> diagnosticarConversaciones(String usuarioId) async {
    print('\n🆔🆔🆔 DIAGNÓSTICO DE CONVERSACIONES 🆔🆔🆔');
    print('Usuario ID: $usuarioId');
    
    try {
      // Obtener TODAS las conversaciones
      final snapshot = await _firestore.collection('conversaciones').get();
      print('Total de conversaciones en la base de datos: ${snapshot.docs.length}');
      
      // Revisar cada conversación
      for (var doc in snapshot.docs) {
        final data = doc.data();
        print('\n--- Conversación ${doc.id} ---');
        print('Participantes: ${data['participantes']}');
        print('ParticipantesInfo: ${data['participantesInfo']}');
        print('Último mensaje: ${data['ultimoMensaje']}');
        print('Fecha último mensaje: ${data['fechaUltimoMensaje']}');
        
        // Verificar si el usuario es participante
        final participantes = List<String>.from(data['participantes'] ?? []);
        if (participantes.contains(usuarioId)) {
          print('⭐ ¡USUARIO ES PARTICIPANTE EN ESTA CONVERSACIÓN!');
        }
      }
    } catch (e) {
      print('❌ Error en diagnóstico: $e');
    }
    
    print('\n🆔🆔🆔 FIN DEL DIAGNÓSTICO 🆔🆔🆔\n');
  }

  // Crear notificación
  Future<void> _crearNotificacion({
    required String usuarioId,
    required String tipo,
    required String titulo,
    required String mensaje,
    required Map<String, dynamic> datos,
  }) async {
    try {
      await _firestore.collection('notificaciones').add({
        'usuarioId': usuarioId,
        'tipo': tipo,
        'titulo': titulo,
        'mensaje': mensaje,
        'datos': datos,
        'leido': false,
        'fechaCreacion': Timestamp.now(),
      });
    } catch (e) {
      print('Error creando notificación: $e');
    }
  }
}
