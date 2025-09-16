import 'dart:io';

/// Stub de serviço KYC - integrar com backend depois.
class KycService {
  Future<bool> uploadDocument(
      {required File file, required String docType}) async {
    // TODO: implementar chamada HTTP para backend
    await Future.delayed(const Duration(milliseconds: 400));
    return true; // retorna sucesso simulado
  }

  Future<bool> submitKycData({required Map<String, dynamic> data}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }
}
