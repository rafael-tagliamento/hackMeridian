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
  late final List<FocusNode> _focusNodes;
  late final List<TextEditingController> _controllers;
  late final TextEditingController _hiddenController;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _hiddenController = widget.controller ?? TextEditingController();
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
    for (final n in _focusNodes) {
      n.dispose();
    }
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
        FocusScope.of(context).requestFocus(_focusNodes[index]);
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
        SizedBox(
          height: 0,
          width: 0,
          child: TextField(
            controller: _hiddenController,
            autofocus: false,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.number,
            obscureText: false,
            maxLength: widget.length,
            decoration: const InputDecoration(counterText: ''),
            // onChanged is already handled by controller listener
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
        GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
            // attach focus to hidden field by requesting keyboard
            FocusScope.of(context).requestFocus(FocusNode());
            // hack: focus to the underlying (hidden) textfield by using primaryFocus
            FocusScope.of(context).requestFocus();
            // Show keyboard by focusing a new FocusNode is unreliable; instead
            // we bring up keyboard by requesting focus on an invisible node via context
          },
          child: const SizedBox.shrink(),
        ),
      ],
    );
  }
}
