import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

/// Card input form widget with validation
class CardInputWidget extends StatefulWidget {
  final Function(Map<String, String>) onCardDetailsChanged;

  const CardInputWidget({super.key, required this.onCardDetailsChanged});

  @override
  State<CardInputWidget> createState() => _CardInputWidgetState();
}

class _CardInputWidgetState extends State<CardInputWidget> {
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  String _cardNumberError = '';
  String _expiryError = '';
  String _cvvError = '';
  String _nameError = '';

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _validateAndNotify() {
    widget.onCardDetailsChanged({
      'cardNumber': _cardNumberController.text,
      'expiry': _expiryController.text,
      'cvv': _cvvController.text,
      'name': _nameController.text,
      'isValid': _isFormValid().toString(),
    });
  }

  bool _isFormValid() {
    return _cardNumberError.isEmpty &&
        _expiryError.isEmpty &&
        _cvvError.isEmpty &&
        _nameError.isEmpty &&
        _cardNumberController.text.isNotEmpty &&
        _expiryController.text.isNotEmpty &&
        _cvvController.text.isNotEmpty &&
        _nameController.text.isNotEmpty;
  }

  void _validateCardNumber(String value) {
    setState(() {
      if (value.isEmpty) {
        _cardNumberError = 'Card number is required';
      } else if (value.replaceAll(' ', '').length < 16) {
        _cardNumberError = 'Invalid card number';
      } else {
        _cardNumberError = '';
      }
    });
    _validateAndNotify();
  }

  void _validateExpiry(String value) {
    setState(() {
      if (value.isEmpty) {
        _expiryError = 'Expiry date is required';
      } else if (value.length < 5) {
        _expiryError = 'Invalid expiry date';
      } else {
        final parts = value.split('/');
        if (parts.length == 2) {
          final month = int.tryParse(parts[0]) ?? 0;
          final year = int.tryParse(parts[1]) ?? 0;
          if (month < 1 || month > 12) {
            _expiryError = 'Invalid month';
          } else if (year < DateTime.now().year % 100) {
            _expiryError = 'Card expired';
          } else {
            _expiryError = '';
          }
        } else {
          _expiryError = 'Invalid format';
        }
      }
    });
    _validateAndNotify();
  }

  void _validateCVV(String value) {
    setState(() {
      if (value.isEmpty) {
        _cvvError = 'CVV is required';
      } else if (value.length < 3) {
        _cvvError = 'Invalid CVV';
      } else {
        _cvvError = '';
      }
    });
    _validateAndNotify();
  }

  void _validateName(String value) {
    setState(() {
      if (value.isEmpty) {
        _nameError = 'Cardholder name is required';
      } else if (value.length < 3) {
        _nameError = 'Name too short';
      } else {
        _nameError = '';
      }
    });
    _validateAndNotify();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          TextField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              _CardNumberFormatter(),
            ],
            onChanged: _validateCardNumber,
            decoration: InputDecoration(
              labelText: 'Card Number',
              hintText: '1234 5678 9012 3456',
              errorText: _cardNumberError.isEmpty ? null : _cardNumberError,
              prefixIcon: Icon(Icons.credit_card),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _expiryController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _ExpiryDateFormatter(),
                  ],
                  onChanged: _validateExpiry,
                  decoration: InputDecoration(
                    labelText: 'Expiry',
                    hintText: 'MM/YY',
                    errorText: _expiryError.isEmpty ? null : _expiryError,
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: TextField(
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  onChanged: _validateCVV,
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    hintText: '123',
                    errorText: _cvvError.isEmpty ? null : _cvvError,
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          TextField(
            controller: _nameController,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            onChanged: _validateName,
            decoration: InputDecoration(
              labelText: 'Cardholder Name',
              hintText: 'John Doe',
              errorText: _nameError.isEmpty ? null : _nameError,
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) {
        buffer.write(' ');
      }
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.length > 2) {
      return TextEditingValue(
        text: '${text.substring(0, 2)}/${text.substring(2)}',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    }
    return newValue;
  }
}
