import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import 'package:image_picker/image_picker.dart';
import '../models/medicine_info_model.dart';

class MLKitService {
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
  final ImageLabeler _imageLabeler =
      ImageLabeler(options: ImageLabelerOptions());
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  final LanguageIdentifier _languageIdentifier =
      LanguageIdentifier(confidenceThreshold: 0.5);
  final EntityExtractor _entityExtractor = EntityExtractor(
    language: EntityExtractorLanguage.french,
  );
  OnDeviceTranslator? _translator;

  MLKitService();

  Future<PrescriptionScanResult> scanPrescription(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final RecognizedText recognisedText =
        await _textRecognizer.processImage(inputImage);

    PrescriptionScanResult result = PrescriptionScanResult();
    List<String> allText = [];

    for (TextBlock block in recognisedText.blocks) {
      for (TextLine line in block.lines) {
        String text = line.text;
        allText.add(text);

        if (_isMedicationPattern(text)) {
          final med = _extractMedicationInfo(text);
          if (med.name.isNotEmpty) {
            result.medications.add(med);
          }
        }

        if (_isDatePattern(text)) {
          result.date = _extractDate(text);
        }

        if (_isDoctorPattern(text)) {
          result.doctorName = text;
        }

        if (_isPatientPattern(text)) {
          result.patientName = text;
        }

        if (_isDosagePattern(text)) {
          result.dosages.add(text);
        }
      }
    }

    result.fullText = allText.join('\n');

    final detectedLang = await identifyLanguage(result.fullText);
    result.language = detectedLang;

    return result;
  }

  Future<MedicineInfo> scanMedicationBarcode(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final List<Barcode> barcodes =
        await _barcodeScanner.processImage(inputImage);

    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      final code = barcode.rawValue ?? '';

      return await _fetchMedicineInfoFromCode(code);
    }

    throw Exception('Aucun code-barres détecté');
  }

  Future<String> scanBarcode(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final List<Barcode> barcodes =
        await _barcodeScanner.processImage(inputImage);

    if (barcodes.isNotEmpty) {
      return barcodes.first.rawValue ?? '';
    }

    throw Exception('Aucun code-barres détecté');
  }

  Future<List<String>> analyzeMedicalImage(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final List<ImageLabel> labels =
        await _imageLabeler.processImage(inputImage);

    return labels.map((label) => label.label).toList();
  }

  Future<Map<String, bool>> checkMedicalKeywords(String text) async {
    final keywords = {
      'diabète': false,
      'hypertension': false,
      'asthme': false,
      'allergie': false,
      'urgence': false,
      'danger': false,
    };

    final lowerText = text.toLowerCase();
    keywords.forEach((key, value) {
      keywords[key] = lowerText.contains(key);
    });

    return keywords;
  }

  Future<String> identifyLanguage(String text) async {
    final result = await _languageIdentifier.identifyLanguage(text);
    return result;
  }

  Future<List<IdentifiedLanguage>> identifyPossibleLanguages(
      String text) async {
    return await _languageIdentifier.identifyPossibleLanguages(text);
  }

  Future<String> translateText(
    String text,
    TranslateLanguage sourceLanguage,
    TranslateLanguage targetLanguage,
  ) async {
    final translator = OnDeviceTranslator(
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );

    try {
      final translated = await translator.translateText(text);
      return translated;
    } finally {
      translator.close();
    }
  }

  Future<List<EntityAnnotation>> extractEntities(String text) async {
    return await _entityExtractor.annotateText(text);
  }

  TranslateLanguage getLanguageEnum(String langCode) {
    switch (langCode) {
      case 'fr':
        return TranslateLanguage.french;
      case 'en':
        return TranslateLanguage.english;
      case 'ar':
        return TranslateLanguage.arabic;
      default:
        return TranslateLanguage.french;
    }
  }

  bool _isMedicationPattern(String text) {
    RegExp medPattern = RegExp(
      r'[A-Z]{2,}\s+\d+\s*(mg|g|ml|UI|µg)|PARACETAMOL|IBUPROFENE|ASPIRINE|AMOXICILLINE',
      caseSensitive: false,
    );
    return medPattern.hasMatch(text);
  }

  bool _isDatePattern(String text) {
    RegExp datePattern =
        RegExp(r'\d{2}[/.-]\d{2}[/.-]\d{4}|le\s+\d{2}[/.-]\d{2}[/.-]\d{4}');
    return datePattern.hasMatch(text);
  }

  bool _isDoctorPattern(String text) {
    RegExp doctorPattern = RegExp(r'Dr\.|Docteur|Médecin|Doctoresse|Professeur',
        caseSensitive: false);
    return doctorPattern.hasMatch(text);
  }

  bool _isPatientPattern(String text) {
    RegExp patientPattern =
        RegExp(r'Patient|Nom|Prénom|M\.|Mme|Mlle', caseSensitive: false);
    return patientPattern.hasMatch(text);
  }

  bool _isDosagePattern(String text) {
    RegExp dosagePattern = RegExp(
        r'\d+\s*(mg|g|ml|UI|comprimé|gouttes|capsule)',
        caseSensitive: false);
    return dosagePattern.hasMatch(text);
  }

  MedicineInfo _extractMedicationInfo(String text) {
    String name = '';
    String dosage = '';

    RegExp namePattern = RegExp(r'([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)');
    final nameMatch = namePattern.firstMatch(text);
    if (nameMatch != null) {
      name = nameMatch.group(0) ?? '';
    }

    RegExp dosagePattern =
        RegExp(r'(\d+\s*(mg|g|ml|UI))', caseSensitive: false);
    final dosageMatch = dosagePattern.firstMatch(text);
    if (dosageMatch != null) {
      dosage = dosageMatch.group(0) ?? '';
    }

    return MedicineInfo(
      code: '',
      name: name,
      dosage: dosage,
      form: 'Comprimé',
      manufacturer: null,
      activeIngredient: null,
      indications: const [],
      contraindications: const [],
      sideEffects: const [],
    );
  }

  DateTime _extractDate(String text) {
    RegExp datePattern = RegExp(r'(\d{2})[/.-](\d{2})[/.-](\d{4})');
    final match = datePattern.firstMatch(text);
    if (match != null) {
      try {
        final day = int.parse(match.group(1)!);
        final month = int.parse(match.group(2)!);
        final year = int.parse(match.group(3)!);
        return DateTime(year, month, day);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Future<MedicineInfo> _fetchMedicineInfoFromCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return MedicineInfo(
      code: code,
      name: "Médicament trouvé",
      dosage: "500 mg",
      form: "Comprimé",
      manufacturer: "Laboratoire Exemple",
      activeIngredient: "Paracétamol",
      indications: ["Douleur", "Fièvre"],
      contraindications: ["Insuffisance hépatique sévère"],
      sideEffects: ["Nausées", "Réactions allergiques"],
    );
  }

  void dispose() {
    _textRecognizer.close();
    _imageLabeler.close();
    _barcodeScanner.close();
    _languageIdentifier.close();
    _entityExtractor.close();
    _translator?.close();
  }
}

class PrescriptionScanResult {
  List<MedicineInfo> medications = [];
  List<String> dosages = [];
  DateTime? date;
  String? doctorName;
  String? patientName;
  String? language;
  String fullText = '';
  String? translatedText;
}
