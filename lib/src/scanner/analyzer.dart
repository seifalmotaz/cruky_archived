// import 'dart:io';

// import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
// import 'package:analyzer/dart/analysis/results.dart';
// import 'package:analyzer/dart/element/element.dart';
// import 'package:analyzer/file_system/physical_file_system.dart';

// class AnalyzerData {
//   final Map _files;
//   AnalyzerData._(this._files);

//   file() {}

//   factory AnalyzerData.new() {
//     Directory entity = Directory.current;

//     final collection = AnalysisContextCollection(
//         includedPaths: [entity.absolute.path],
//         resourceProvider: PhysicalResourceProvider.INSTANCE);
//     // print(collection.contexts.first.contextRoot.analyzedFiles().toList());
//     collection.contexts.first.currentSession
//         .getUnitElement(r'D:\StartUps\open source\cruky\cruky\test\test.dart')
//         .then((result) {
//       if (result is UnitElementResult) {
//         CompilationUnitElement element = result.element;
//         print(element.functions.first.metadata);
//       }
//     });
//     return AnalyzerData._({});
//   }
// }
