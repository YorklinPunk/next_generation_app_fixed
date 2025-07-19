import 'package:flutter/material.dart';

void showCustomDialog(BuildContext context, String message, int code,{VoidCallback? onClose}) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIcon(code),
                color: _getColor(code),
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                _getText(code),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (onClose != null) onClose();
                },
                child: const Text(
                  'Cerrar',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


Color _getColor(int code) {
  switch (code) {
    case 1:
      return Colors.green;
    case 2:
      return Colors.orange;
    case 3:
      return Colors.red;
    default:
      return Colors.grey;
  }
}

IconData _getIcon(int code) {
  switch (code) {
    case 1:
      return Icons.check_circle;
    case 2:
      return Icons.warning_amber_rounded;
    case 3:
      return Icons.cancel;
    default:
      return Icons.info_outline;
  }
}

String _getText(int code) {
  switch (code) {
    case 1:
      return 'Resultado';
    case 2:
      return 'Error';
    case 3:
      return 'Canlelado';
    default:
      return 'Información';
  }
}
