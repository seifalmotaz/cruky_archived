//


// import 'dart:io';

// import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
// import 'package:analyzer/dart/analysis/results.dart';
// import 'package:analyzer/dart/element/element.dart';
// import 'package:analyzer/file_system/physical_file_system.dart';

// Future<void> main(List<String> args) async {
//   Directory entity = Directory.current;

//   final collection = AnalysisContextCollection(
//       includedPaths: [entity.absolute.path],
//       resourceProvider: PhysicalResourceProvider.INSTANCE);
//   // print(collection.contexts.first.contextRoot.analyzedFiles().toList());
//   var result = await collection.contexts.first.currentSession
//       .getUnitElement(r'D:\StartUps\open source\cruky\cruky\example\test.dart');
//   if (result is UnitElementResult) {
//     CompilationUnitElement element = result.element;
//     for (var element in element.functions) {
//       print(element.metadata);
//     }
//   }
// }

// void main(List<String> args) {
//   InstanceMirror mirror =
//       currentMirrorSystem().isolate.rootLibrary.getField(#myfunc);
//   ClosureMirror mm = mirror as ClosureMirror;
//   print(mm.function.metadata);
// }
// /// this is a doc comment
// @ClassName()
// myfunc() {}

// class ClassName {
//   const ClassName();
// }
