# Solución de Problemas - PiñaApp

## Error al cargar perfil después de iniciar sesión

### Problema
Al iniciar sesión, la aplicación muestra "Error al cargar perfil" y sugiere cerrar sesión e intentar nuevamente. Especialmente ocurre con usuarios existentes después de reinstalar la app.

### Síntomas
- "Servicio no disponible. Verifica tu conexión a internet"
- Solo funciona con usuarios nuevos
- Al cerrar y abrir la app, se queda en la pantalla de carga
- Necesitas borrar datos de la app para que funcione

### Causas comunes
1. **Problemas con timestamps de Firestore**: Los campos de fecha pueden estar en formatos incompatibles
2. **Documento de usuario incompleto**: Faltan campos requeridos en Firestore
3. **Problemas de permisos**: Las reglas de seguridad de Firestore pueden estar bloqueando el acceso
4. **Problemas de red**: Conexión inestable o sin acceso a internet
5. **Conflictos de caché**: Desincronización entre el caché local y el servidor después de reinstalar la app o borrar datos

### Solución temporal implementada (v1.0.5)

**IMPORTANTE**: La persistencia de Firestore ha sido deshabilitada temporalmente para evitar problemas de caché.

```dart
// En main.dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: false, // Temporalmente deshabilitado
);
```

Esto significa que:
- La app siempre leerá datos desde el servidor
- No habrá problemas de caché corrupto
- Puede usar más datos móviles
- No funcionará offline

### Soluciones implementadas

#### 1. Parsing robusto de timestamps
Se mejoró el modelo `Usuario` para manejar diferentes formatos de timestamps:
- Timestamps de Firestore
- Maps con `_seconds` y `_nanoseconds`
- Objetos DateTime
- Strings ISO
- Números (milliseconds)

#### 2. Manejo de errores mejorado
El `AuthProvider` ahora:
- Intenta cargar el perfil hasta 3 veces
- Ejecuta diagnósticos automáticos en caso de fallo
- Intenta reparar documentos incompletos
- Proporciona mensajes de error más descriptivos

#### 3. Utilidad de depuración
Se agregó `FirebaseDebugUtils` que permite:
- Verificar el estado de la conexión a Firebase
- Inspeccionar la estructura del documento del usuario
- Reparar documentos con campos faltantes
- Ejecutar diagnósticos detallados
- Limpiar el caché de Firestore cuando hay conflictos
- Forzar la lectura desde el servidor

### Cómo usar las herramientas de depuración

#### En modo desarrollo
1. Si aparece el error, presiona el botón "Diagnóstico" que aparece debajo de "Reintentar"
2. Selecciona una de las siguientes opciones:
   - **Reparar documento**: Intenta corregir campos faltantes en el documento
   - **Limpiar caché**: Útil cuando hay problemas después de reinstalar la app
3. La aplicación intentará:
   - Verificar el estado de Firebase
   - Ejecutar la acción seleccionada
   - Recargar el perfil automáticamente

#### Problema específico: Error después de reinstalar la app
Si el error ocurre después de eliminar y reinstalar la app o borrar datos/caché:
1. Usa el botón "Diagnóstico"
2. Selecciona "Limpiar caché"
3. Si no funciona, cierra sesión y vuelve a iniciar sesión
4. Esto forzará la sincronización con el servidor

#### Verificar manualmente en la consola
Los logs muestran información detallada:
```
🔄 Auth state changed: usuario@ejemplo.com
✅ Usuario autenticado, cargando perfil...
📋 Datos del documento: nombre, email, tipo, telefono...
✅ Perfil cargado: Juan - Finca El Sol
```

### Prevención de futuros problemas

1. **Al crear nuevos usuarios**: Asegúrate de que todos los campos requeridos se guarden correctamente
2. **Al actualizar Firestore**: Usa siempre `FieldValue.serverTimestamp()` para campos de fecha
3. **Reglas de seguridad**: Verifica que las reglas permitan a los usuarios leer su propio documento

### Si el problema persiste

1. **Verifica la consola de Firebase**:
   - Revisa si el documento del usuario existe
   - Verifica que tenga los campos: nombre, email, tipo, telefono
   - Revisa que los timestamps no estén corruptos

2. **Limpia la caché local**:
   ```dart
   // En el archivo principal, temporalmente cambia:
   FirebaseFirestore.instance.settings = const Settings(
     persistenceEnabled: false, // Desactiva temporalmente
   );
   ```

3. **Recrea el documento del usuario**:
   - Elimina el documento desde la consola de Firebase
   - Cierra sesión en la app
   - Vuelve a iniciar sesión (se creará un nuevo documento)

### Registro de cambios

- **v1.0.1**: Implementación de parsing robusto de timestamps
- **v1.0.2**: Agregado sistema de reintentos con diagnóstico automático
- **v1.0.3**: Utilidad de depuración y reparación automática
- **v1.0.4**: Manejo mejorado de caché de Firestore
  - Lectura forzada desde servidor cuando hay problemas
  - Opción para limpiar caché manualmente
  - Solución para problemas después de reinstalar la app
- **v1.0.5**: Solución temporal - Persistencia deshabilitada
  - Deshabilitada la persistencia de Firestore para evitar problemas de caché
  - Agregado timeout de 15 segundos para evitar carga infinita
  - Mejorado el manejo de errores de conectividad
  - Agregada pantalla de error con opción de reintentar

### Trabajo futuro

1. **Investigar el problema raíz del caché**: Necesitamos entender por qué el caché se corrompe al reinstalar la app
2. **Implementar sincronización inteligente**: Crear un sistema que detecte cuando el caché está desactualizado
3. **Re-habilitar la persistencia**: Una vez solucionado el problema, volver a habilitar el caché para mejorar el rendimiento
4. **Agregar modo offline**: Permitir funcionalidad básica sin conexión

### Recomendaciones para usuarios

1. **Si tienes problemas al iniciar sesión**:
   - Verifica tu conexión a internet
   - Intenta cerrar sesión y volver a iniciar
   - Si el problema persiste, borra los datos de la app

2. **Si la app se queda cargando**:
   - Espera 15 segundos para que aparezca la pantalla de error
   - Presiona "Reintentar" o "Cerrar aplicación"
   - Verifica tu conexión a internet

3. **Para desarrolladores**:
   - Monitorea los logs de la consola para identificar errores específicos
   - Usa la pantalla de testing Firebase para diagnósticos
   - Considera re-habilitar la persistencia una vez solucionado el problema
