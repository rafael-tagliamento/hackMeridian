import 'package:flutter/material.dart';

/// Componente de entrada PIN com 6 quadradinhos.
/// Uso: fornece callback onChanged(String pin) e onCompleted(String pin).
class PinInputBoxes extends StatefulWidget {
  final int length;
  final void Function(String)? onChanged;
  final void Function(String)? onCompleted;
  final bool obscure;
  final TextEditingController? controller;

  const PinInputBoxes({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.obscure = true,
    this.controller,
  });

  @override
  State<PinInputBoxes> createState() => _PinInputBoxesState();
}

class _PinInputBoxesState extends State<PinInputBoxes> {
  late final List<TextEditingController> _controllers;
  late final TextEditingController _hiddenController;
  late final FocusNode _hiddenFocusNode;

  @override
  void initState() {
    super.initState();
    // usamos um FocusNode único para o TextField oculto.
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _hiddenController = widget.controller ?? TextEditingController();
    _hiddenFocusNode = FocusNode();
    // sync hidden controller -> individual boxes
    _hiddenController.addListener(_onHiddenChanged);
  }

  void _onHiddenChanged() {
    final text = _hiddenController.text;
    for (var i = 0; i < widget.length; i++) {
      final c = i < text.length ? text[i] : '';
      _controllers[i].text = c;
    }
    widget.onChanged?.call(text);
    if (text.length == widget.length) widget.onCompleted?.call(text);
    setState(() {});
  }

  @override
  void dispose() {
    _hiddenFocusNode.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    _hiddenController.removeListener(_onHiddenChanged);
    if (widget.controller == null) _hiddenController.dispose();
    super.dispose();
  }

  Widget _buildBox(int index) {
    final filled = _controllers[index].text.isNotEmpty;
    return GestureDetector(
      onTap: () {
        // Foca o TextField oculto e posiciona o caret no final
        FocusScope.of(context).requestFocus(_hiddenFocusNode);
        _hiddenController.selection =
            TextSelection.collapsed(offset: _hiddenController.text.length);
      },
      child: Container(
        width: 44,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          widget.obscure && filled ? '•' : _controllers[index].text,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hidden TextField for actual input (handles keyboard/paste/backspace)
        // Hidden TextField for actual input (handles keyboard/paste/backspace)
        Offstage(
          offstage: true,
          child: TextField(
            focusNode: _hiddenFocusNode,
            controller: _hiddenController,
            autofocus: false,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.number,
            obscureText: false,
            maxLength: widget.length,
            decoration: const InputDecoration(counterText: ''),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.length, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _buildBox(i),
            );
          }),
        ),
        const SizedBox(height: 8),
        // Make the whole row tappable to focus the hidden field
        // Make the whole row tappable to focus the hidden field
        GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(_hiddenFocusNode);
            _hiddenController.selection =
                TextSelection.collapsed(offset: _hiddenController.text.length);
          },
          child: const SizedBox.shrink(),
        ),
      ],
    );
  }
}
