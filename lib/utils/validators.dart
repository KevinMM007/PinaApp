/// Clase utilitaria para validaciones de formularios
/// Centraliza todas las validaciones comunes de la aplicación
class Validators {
  /// Validación de email mejorada con regex completo
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu correo electrónico';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }
    
    return null;
  }

  /// Validación de contraseña con criterios de seguridad
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa una contraseña';
    }
    
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    
    // Opcional: validaciones adicionales de seguridad
    if (!RegExp(r'^(?=.*[a-zA-Z])').hasMatch(value)) {
      return 'La contraseña debe contener al menos una letra';
    }
    
    return null;
  }

  /// Validación de teléfono con formato mexicano
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu número de teléfono';
    }
    
    // Remover espacios y guiones
    final cleanPhone = value.replaceAll(RegExp(r'[\s-]'), '');
    
    if (cleanPhone.length < 10) {
      return 'El teléfono debe tener al menos 10 dígitos';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanPhone)) {
      return 'El teléfono solo debe contener números';
    }
    
    return null;
  }

  /// Validación de números positivos (precio, cantidad, etc.)
  static String? validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Ingresa $fieldName';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Ingresa un número válido';
    }
    
    if (number <= 0) {
      return '$fieldName debe ser mayor que 0';
    }
    
    return null;
  }

  /// Validación de campos de texto requeridos
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa $fieldName';
    }
    
    if (value.trim().length < 2) {
      return '$fieldName debe tener al menos 2 caracteres';
    }
    
    return null;
  }

  /// Validación específica para nombres (sin números ni caracteres especiales)
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu nombre';
    }
    
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
      return 'El nombre solo debe contener letras';
    }
    
    return null;
  }

  /// Validación para descripción de productos
  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa una descripción';
    }
    
    if (value.trim().length < 10) {
      return 'La descripción debe tener al menos 10 caracteres';
    }
    
    if (value.trim().length > 500) {
      return 'La descripción no debe exceder 500 caracteres';
    }
    
    return null;
  }
}
