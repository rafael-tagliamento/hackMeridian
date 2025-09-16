import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:image/image.dart' as lower show normalize;
import 'package:diacritic/diacritic.dart';

/// Verificador local:
/// 1) Garante que a selfie tenha exatamente 1 rosto detectado.
/// 2) Faz OCR na foto do documento e tenta achar nome, CPF e data de nascimento.
/// 3) Compara com os valores esperados usando normalizações robustas.
/// Obs.: NÃO faz "face match" (selfie vs. foto do RG/CPF); isso exige modelo próprio/serviço.
class LocalDocSelfieVerifier {
  LocalDocSelfieVerifier._();
  static final instance = LocalDocSelfieVerifier._();

  /// Verifica documento x selfie.
  /// Retorna true se:
  ///  - Selfie tem exatamente 1 rosto, e
  ///  - OCR do documento contém (aprox.) nome + CPF + data.
  Future<bool> verify({
    required String docPath,
    required String selfiePath,
    required String expectedName,
    required String expectedCpf,
    required String expectedBirthDate, // você passa "yyyy-MM-dd"
  }) async {
    try {
      // 1) Checagens básicas de arquivos
      if (!await File(docPath).exists()) {
        debugPrint('[Verifier] Documento não encontrado em $docPath');
        return false;
      }
      if (!await File(selfiePath).exists()) {
        debugPrint('[Verifier] Selfie não encontrada em $selfiePath');
        return false;
      }

      // 2) Validar selfie: exatamente 1 rosto
      final facesOk = await _hasExactlyOneFace(selfiePath);
      if (!facesOk) {
        debugPrint('[Verifier] Selfie inválida (0 ou >1 rosto).');
        return false;
      }

      // 3) OCR no documento
      final ocrText = await _readTextFromImage(docPath);

      // 4) Normalizações
      final normDocText = _normalizeForSearch(ocrText);
      final normName = _normalizeForSearch(expectedName);
      final normCpf = _onlyDigits(expectedCpf);
      final normBirth = _normalizeBirth(expectedBirthDate);

      // 5) Heurísticas de correspondência
      final nameOk = _fuzzyContains(normDocText, normName, minRatio: 0.75);
      final cpfOk = normCpf.isEmpty ? false : normDocText.contains(normCpf);
      final birthOk = normDocText.contains(normBirth) ||
          // Tente variações comuns (ddMMyyyy, dd/MM/yyyy etc.)
          normDocText.contains(_birthToDdMmYyyyDigits(expectedBirthDate)) ||
          normDocText.contains(_birthToDdMmYyyySlashes(expectedBirthDate));

      debugPrint('[Verifier] nameOk=$nameOk cpfOk=$cpfOk birthOk=$birthOk');
      return nameOk && cpfOk && birthOk;
    } catch (e, st) {
      debugPrint('[Verifier] Erro: $e\n$st');
      return false;
    }
  }

  // ---------- FACE DETECTION ----------
  Future<bool> _hasExactlyOneFace(String path) async {
    final options = FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableContours: false,
      enableLandmarks: false,
      enableClassification: false,
    );
    final detector = FaceDetector(options: options);
    try {
      final input = await _asInputImage(path);
      final faces = await detector.processImage(input);
      debugPrint('[Verifier] Faces detectadas: ${faces.length}');
      return faces.length == 1;
    } finally {
      await detector.close();
    }
  }

  // ---------- OCR ----------
  Future<String> _readTextFromImage(String path) async {
    // Pré-processa: corrige orientação EXIF e limita tamanho para ajudar OCR
    final processedBytes = await _prepareImage(path, maxSide: 1600);
    final temp = File('${path}_proc.jpg')..writeAsBytesSync(processedBytes);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final input = InputImage.fromFilePath(temp.path);
      final result = await recognizer.processImage(input);
      final text = result.text;
      debugPrint('[Verifier] OCR retornou ${text.length} chars.');
      return text;
    } finally {
      await recognizer.close();
      // Não apaga o temp para permitir debug; se quiser, remova a linha acima e apague aqui.
    }
  }

  Future<InputImage> _asInputImage(String path) async {
    return InputImage.fromFilePath(path);
  }

  // ---------- PREPROCESS ----------
  Future<Uint8List> _prepareImage(String path, {int maxSide = 1600}) async {
    final bytes = await File(path).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;

    // Corrige orientação EXIF
    final fixed = img.bakeOrientation(decoded);

    // Redimensiona mantendo proporção
    final w = fixed.width, h = fixed.height;
    final scale = (w > h ? maxSide / w : maxSide / h);
    img.Image resized = fixed;
    if (scale < 1.0) {
      resized = img.copyResize(fixed, width: (w * scale).round(), height: (h * scale).round());
    }
    return Uint8List.fromList(img.encodeJpg(resized, quality: 92));
  }

  // ---------- NORMALIZAÇÕES ----------
  String _normalizeForSearch(String s) {
    final lower = s.toLowerCase();
    final noAccents = removeDiacritics(lower); // ← remove acentos
    return noAccents.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  String _onlyDigits(String s) => s.replaceAll(RegExp(r'\D'), '');

  // Retorna data como "yyyyMMdd" (para busca por dígitos consecutivos)
  String _normalizeBirth(String yyyyMmDd) {
    final d = yyyyMmDd.trim();
    final parts = d.split('-'); // "yyyy-MM-dd"
    if (parts.length != 3) return _onlyDigits(d);
    final yyyy = parts[0].padLeft(4, '0');
    final mm = parts[1].padLeft(2, '0');
    final dd = parts[2].padLeft(2, '0');
    return '$yyyy$mm$dd';
  }

  String _birthToDdMmYyyyDigits(String yyyyMmDd) {
    final parts = yyyyMmDd.split('-');
    if (parts.length != 3) return _onlyDigits(yyyyMmDd);
    final yyyy = parts[0].padLeft(4, '0');
    final mm = parts[1].padLeft(2, '0');
    final dd = parts[2].padLeft(2, '0');
    return '$dd$mm$yyyy';
  }

  String _birthToDdMmYyyySlashes(String yyyyMmDd) {
    final parts = yyyyMmDd.split('-');
    if (parts.length != 3) return yyyyMmDd;
    final yyyy = parts[0].padLeft(4, '0');
    final mm = parts[1].padLeft(2, '0');
    final dd = parts[2].padLeft(2, '0');
    return '$dd/$mm/$yyyy'.toLowerCase();
  }

  /// `a` contém aproximadamente `b`? (similaridade simples por n-grams)
  bool _fuzzyContains(String a, String b, {double minRatio = 0.8}) {
    if (b.length <= 4) return a.contains(b); // nome muito curto → literal
    // Se b for muito grande, pegue trechos principais (primeiro e último sobrenome)
    final chunks = _nameChunks(b);
    int ok = 0;
    for (final c in chunks) {
      if (c.length < 3) continue;
      if (_diceCoefficientContains(a, c) >= minRatio) ok++;
    }
    // Ex.: exige coincidência de pelo menos 2 chunks (nome + sobrenome)
    return ok >= (chunks.length >= 3 ? 2 : 1);
  }

  List<String> _nameChunks(String name) {
    // separa nome por “ ” e remove stopwords comuns
    final raw = name.replaceAll(RegExp(r'[^a-z0-9 ]'), ' ').split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    const stops = {'da','de','do','das','dos','e'};
    return raw.where((w) => !stops.contains(w)).toList();
  }

  double _diceCoefficientContains(String haystack, String needle) {
    final hn = _bigrams(haystack);
    final nd = _bigrams(needle);
    if (nd.isEmpty) return haystack.contains(needle) ? 1.0 : 0.0;
    int inter = 0;
    for (final b in nd) {
      if (hn.contains(b)) inter++;
    }
    return (2.0 * inter) / (hn.length + nd.length);
  }

  Set<String> _bigrams(String s) {
    final set = <String>{};
    for (var i = 0; i < s.length - 1; i++) {
      set.add(s.substring(i, i + 2));
    }
    return set;
  }
}
