import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/enums.gq.dart';
import 'package:recs_front/generated/inputs.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/utils/ui_utils.dart';
import 'package:recs_front/src/utils/validation_utils.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/futuretail_label.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:universal_html/html.dart' as html;
import 'package:csv/csv.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';

class CollectionMappingInputWidget extends StatefulWidget {
  final CollectionMapping collectionMapping;
  final Function(CollectionMapping) onChange;
  const CollectionMappingInputWidget({
    super.key,
    required this.collectionMapping,
    required this.onChange,
  });

  @override
  State<CollectionMappingInputWidget> createState() => _CollectionMappingInputWidgetState();
}

class _CollectionMappingInputWidgetState extends BasicState<CollectionMappingInputWidget>
    with FormUiUtils, WidgetUtilsMixin {
  late CollectionMapping collectionMapping;
  final delimiter = TextEditingController();
  final dateFormatCtrl = TextEditingController();
  final fileMask = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final headerFormKey = GlobalKey<FormState>();
  final columnWidth = 300.0;
  final fileInfoStream = BehaviorSubject<FileInfoFormat>();
  final headersStream = BehaviorSubject<List<String>>();
  final converter = CsvToListConverter();
  Map<String, String?> map = {};
  final client = GetIt.instance.get<GQClient>();
  final editStream = BehaviorSubject.seeded(false);
  static const headerElementWidth = 350.0;
  final controllerMap = <String, TextEditingController>{};
  String? rowData;
  @override
  void initState() {
    collectionMapping = widget.collectionMapping;
    delimiter.text = collectionMapping.delimiter ?? ",";
    dateFormatCtrl.text = collectionMapping.dateFormat ?? "";
    fileMask.text = collectionMapping.fileMask ?? "";

    headersStream.add(collectionMapping.headers);

    if (collectionMapping.headers.isNotEmpty && collectionMapping.delimiter != null) {
      rowData = collectionMapping.headers.join(collectionMapping.delimiter!);
    }
    collectionMapping.fields.forEach((col) {
      map[col.name] = col.csvFieldValue;
      controllerMap[col.name] = TextEditingController();
      controllerMap[col.name]!.text = col.csvFieldDefaultValue ?? "";
    });
    fileInfoStream.add(
      FileInfoFormat(
        dateFormat: dateFormatCtrl.text,
        delimiter: delimiter.text,
        fileMask: fileMask.text,
      ),
    );
    super.initState();
  }

  void initHeaders() {
    if (rowData == null) {
      return;
    }
    final headers = rowData!.split(delimiter.text.trim());
    headersStream.add(headers.toSet().toList());
  }

  void clearMapvalues() {
    map.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          streamBuilder(
              stream: editStream,
              onDataChanged: (editing) {
                if (editing) {
                  return Form(
                    key: headerFormKey,
                    child: Wrap(
                      spacing: 15,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          height: 50,
                          width: headerElementWidth,
                          child: FormUiUtils.input(lang.fileMask, true, fileMask, ""),
                        ),
                        SizedBox(
                          height: 50,
                          width: headerElementWidth,
                          child: FormUiUtils.input(lang.dateFormat, true, dateFormatCtrl, ""),
                        ),
                        SizedBox(
                          height: 50,
                          width: headerElementWidth,
                          child: FormUiUtils.input(lang.delimeter, true, delimiter, ""),
                        ),
                        SizedBox(
                          width: 200,
                          child: getButtons(onSave: () {
                            if (headerFormKey.currentState!.validate()) {
                              editStream.add(false);
                              initHeaders();
                              clearMapvalues();
                              fileInfoStream.add(
                                FileInfoFormat(
                                  dateFormat: dateFormatCtrl.text,
                                  delimiter: delimiter.text,
                                  fileMask: fileMask.text,
                                ),
                              );
                              setState(() {});
                            }
                          }, onCancel: () {
                            editStream.add(false);
                            fileMask.text = fileInfoStream.value.fileMask;
                            dateFormatCtrl.text = fileInfoStream.value.dateFormat;
                            delimiter.text = fileInfoStream.value.delimiter;
                          }),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Wrap(
                    spacing: 15,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        height: 50,
                        width: headerElementWidth,
                        child:
                            FormUiUtils.disabledInput(title: lang.fileMask, content: fileMask.text, hint: ""),
                      ),
                      SizedBox(
                        height: 50,
                        width: headerElementWidth,
                        child: FormUiUtils.disabledInput(
                          title: lang.dateFormat,
                          content: dateFormatCtrl.text,
                          hint: "",
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        width: headerElementWidth,
                        child: FormUiUtils.disabledInput(
                          title: lang.delimeter,
                          content: delimiter.text,
                          hint: "",
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: getButtons(
                          onSave: () {
                            editStream.add(true);
                          },
                          skipCancel: true,
                          saveLabel: lang.edit,
                        ),
                      )
                    ],
                  );
                }
              }),
          Gap(16),
          SizedBox(
            height: 70,
            child: FormUiUtils.uploadButton(
              null,
              false,
              context,
              onPressed: onPickFile,
              noBorder: true,
              boxWidth: 600,
              boxHeight: 70,
            ),
          ),
          Gap(10),
          Expanded(
            child: mainTable(),
          ),
          streamBuilder(
              stream: headersStream,
              onDataChanged: (headers) {
                if (headers.isEmpty) {
                  return SizedBox.shrink();
                }
                return getButtons(
                  skipCancel: true,
                  saveLabel: lang.save,
                  onSave: save,
                );
              })
        ],
      ),
    );
  }

  void save() async {
    if (formKey.currentState!.validate()) {
      var input = CollectionMappingInput(
        id: collectionMapping.id,
        headers: headersStream.value,
        dateFormat: fileInfoStream.value.dateFormat,
        fileMask: fileInfoStream.value.fileMask,
        delimiter: fileInfoStream.value.delimiter,
        collectionName: widget.collectionMapping.collectionName,
        collectionLabel: widget.collectionMapping.collectionLabel,
        fields: widget.collectionMapping.fields
            .map((col) => FieldMappingInput(
                  label: col.label,
                  name: col.name,
                  type: col.type,
                  csvFieldValue: (map[col.name]?.isEmpty ?? false) ? null : map[col.name],
                  required: col.required,
                  csvFieldDefaultValue:
                      controllerMap[col.name]!.text.isEmpty ? null : controllerMap[col.name]!.text,
                ))
            .toList(),
      );
      try {
        progressSubject.add(true);
        var value = await client.mutations.saveCollectionMapping(input: input);
        collectionMapping = value.saveCollectionMapping;
        widget.onChange(collectionMapping);
        showSnackBar2(context, lang.savedSuccessfully);
      } catch (error, stackTrace) {
        print(stackTrace);
        showServerError2(context, error: error);
      } finally {
        progressSubject.add(false);
      }
    }
  }

  Column mainTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 10),
          child: Row(
            children: [
              ...[lang.label, lang.importData].map((e) => SizedBox(
                    width: columnWidth,
                    child: Text(
                      e,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )),
              SizedBox(
                width: columnWidth,
                child: Text(
                  lang.defaultValue,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                width: columnWidth,
                child: Text(
                  lang.dataType,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: customMappingTable(),
          ),
        ),
      ],
    );
  }

  bool isItemSelectedElseWhere(String item) {
    return map.containsValue(item);
  }

  Widget customMappingTable() {
    return streamBuilder(
        stream: headersStream,
        onDataChanged: (headers) {
          if (headers.isEmpty) {
            return SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info,
                      size: 48,
                    ),
                    Gap(16),
                    FutureTailLabel(
                      lang.pleaseUploadCsvFile,
                    ),
                  ],
                ),
              ),
            );
          }
          return Form(
            key: formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: collectionMapping.fields.map(
                  (col) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SizedBox(
                          width: columnWidth * 4,
                          child: FormUiUtils.inputDropDownButton2<String>(
                            labelWidth: 200,
                            title: col.label,
                            items: headers,
                            required: col.required,
                            postTile: col.name == "id"
                                ? Tooltip(
                                    message: lang.primaryKey,
                                    child: Row(
                                      children: [
                                        Gap(10),
                                        Icon(FontAwesomeIcons.key, size: 12),
                                      ],
                                    ),
                                  )
                                : null,
                            mapper: (context, item, selected) {
                              Widget text;
                              if (selected) {
                                text = Text(
                                  item,
                                  style: TextStyle(
                                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                );
                              } else if (isItemSelectedElseWhere(item)) {
                                text = Text(
                                  item,
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                );
                              } else {
                                text = Text(item);
                              }
                              return ListTile(title: text);
                            },
                            onChanged: (newValue) {
                              map[col.name] = newValue;
                            },
                            validator: (selected) {
                              if (col.required && col.name != "id") {
                                if (selected == null) {
                                  return lang.requiredField;
                                }
                              }
                              return null;
                            },
                            value: map[col.name],
                            hint: "",
                            disabledItemFn: isItemSelectedElseWhere,
                            trailing2: SizedBox(
                              width: columnWidth,
                              child: Text(
                                col.type.name,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            trailing: SizedBox(
                              width: columnWidth,
                              child: _defaultValueInput(col),
                            ),
                          )),
                    );
                  },
                ).toList()),
          );
        });
  }

  void onPickFile() async {
    if (!kIsWeb) {
      String csvContent = """
item_id|ean13|reference_id|reference|c_color|d_color|c_size|d_size|first_col|current_col|last_col|actif|mixte|item_type|mixte1|division_id|division|departement_id|departement|theme_id|theme|categorie_id|categorie|ligne_id|ligne|statut_id|statut|sous_statut_id|sous_statut|detail_id|detail|typologie_id|typologie|composition_id|composition|nb_fil_id|nb_fil|groupecol_id|groupecol|cluster_id|cluster|coupe_id|coupe|hauteur_id|hauteur|longueur_id|longueur|capsule_id|capsule|saisonalite_id|saisonalite
"A1                00101C         X"|"3663447243521"|"A1"|"ECHARPE CLASSIQUE"|"01C"|"AZUR"|"GTU-001"|"TU"|"H15"|"H19"|"H19"|"1"|"0"|"ARTICLES"|"0"|"FN1.ACC"|"Accessoire"|"FN2.ECH"|"ECHARPE"|""|""|"FN4.ACC"|"ACCESSOIRE"|"FN5.CAC"|"Cachemire"|"FN6.INT"|"INTEMPOREL"|"FN7.UFU"|"UNI/FAUX-UNI"|"FN8.026"|"TOILE"|"LA1.TI"|"TISSE"|"LA2.CCM"|"100% CACHEMIRE"|""|""|"LA4.BLE"|"Bleu"|""|""|""|""|""|""|"LAA.NUL"|"X"|"LAB.SAI"|"SAISON"|"LAC.ANN"|"ANNUEL"
"A1                00101R         X"|"3663447243569"|"A1"|"ECHARPE CLASSIQUE"|"01R"|"NUAGE"|"GTU-001"|"TU"|"H15"|"H20"|"H19"|"1"|"0"|"ARTICLES"|"0"|"FN1.ACC"|"Accessoire"|"FN2.ECH"|"ECHARPE"|""|""|"FN4.ACC"|"ACCESSOIRE"|"FN5.CAC"|"Cachemire"|"FN6.INT"|"INTEMPOREL"|"FN7.UFU"|"UNI/FAUX-UNI"|"FN8.026"|"TOILE"|"LA1.TI"|"TISSE"|"LA2.CCM"|"100% CACHEMIRE"|""|""|"LA4.BLE"|"Bleu"|""|""|""|""|""|""|"LAA.NUL"|"X"|"LAB.SAI"|"SAISON"|"LAC.ANN"|"ANNUEL"
"A1                00105O         X"|"3663447281837"|"A1"|"ECHARPE CLASSIQUE"|"05O"|"CHASSELAS"|"GTU-001"|"TU"|"H15"|"H16"|"H15"|"1"|"0"|"ARTICLES"|"0"|"FN1.ACC"|"Accessoire"|"FN2.ECH"|"ECHARPE"|""|""|"FN4.ACC"|"ACCESSOIRE"|"FN5.CAC"|"Cachemire"|"FN6.INT"|"INTEMPOREL"|"FN7.UFU"|"UNI/FAUX-UNI"|"FN8.026"|"TOILE"|"LA1.TI"|"TISSE"|"LA2.CCM"|"100% CACHEMIRE"|""|""|"LA4.VIO"|"Violet"|""|""|""|""|""|""|"LAA.NUL"|"X"|"LAB.SAI"|"SAISON"|"LAC.ANN"|"ANNUEL"
"A1                0010BO         X"|"3663447192645"|"A1"|"ECHARPE CLASSIQUE"|"0BO"|"ROUGE GORGE"|"GTU-001"|"TU"|"H15"|"H22"|"H18"|"1"|"0"|"ARTICLES"|"0"|"FN1.ACC"|"Accessoire"|"FN2.ECH"|"ECHARPE"|""|""|"FN4.ACC"|"ACCESSOIRE"|"FN5.CAC"|"Cachemire"|"FN6.INT"|"INTEMPOREL"|"FN7.UFU"|"UNI/FAUX-UNI"|"FN8.026"|"TOILE"|"LA1.TI"|"TISSE"|"LA2.CCM"|"100% CACHEMIRE"|""|""|"LA4.ROU"|"Rouge"|""|""|""|""|""|""|"LAA.NUL"|"X"|"LAB.SAI"|"SAISON"|"LAC.ANN"|"ANNUEL"
"A1                0010GC         X"|"3663447281851"|"A1"|"ECHARPE CLASSIQUE"|"0GC"|"ALLIGATOR"|"GTU-001"|"TU"|"H15"|"H16"|"H15"|"1"|"0"|"ARTICLES"|"0"|"FN1.ACC"|"Accessoire"|"FN2.ECH"|"ECHARPE"|""|""|"FN4.ACC"|"ACCESSOIRE"|"FN5.CAC"|"Cachemire"|"FN6.INT"|"INTEMPOREL"|"FN7.UFU"|"UNI/FAUX-UNI"|"FN8.026"|"TOILE"|"LA1.TI"|"TISSE"|"LA2.CCM"|"100% CACHEMIRE"|""|""|"LA4.VER"|"Vert"|""|""|""|""|""|""|"LAA.NUL"|"X"|"LAB.SAI"|"SAISON"|"LAC.ANN"|"ANNUEL"
"A1                00100G         X"|"3663447325944"|"A1"|"ECHARPE CLASSIQUE"|"00G"|"NATTIER"|"GTU-001"|"TU"|"H15"|"H15"|"H15"|"1"|"0"|"ARTICLES"|"0"|"FN1.ACC"|"Accessoire"|"FN2.ECH"|"ECHARPE"|""|""|"FN4.ACC"|"ACCESSOIRE"|"FN5.CAC"|"Cachemire"|"FN6.INT"|"INTEMPOREL"|"FN7.UFU"|"UNI/FAUX-UNI"|"FN8.026"|"TOILE"|"LA1.TI"|"TISSE"|"LA2.CCM"|"100% CACHEMIRE"|""|""|"LA4.BLE"|"Bleu"|""|""|""|""|""|""|"LAA.NUL"|"X"|"LAB.SAI"|"SAISON"|"LAC.ANN"|"ANNUEL"
""";

      var firstLine = csvContent.split("\n").firstWhere((element) => element.isNotEmpty);
      rowData = firstLine;
      initHeaders();

      return;
    }
    try {
      final html.FileUploadInputElement input = html.FileUploadInputElement()..accept = '.csv';
      input.click();
      input.onChange.listen((event) {
        final html.File file = input.files!.first;
        final reader = html.FileReader();
        reader.readAsText(file);
        reader.onLoad.listen((fileEvent) async {
          final csvContent = reader.result as String;
          var firstLine = csvContent.split("\n").firstWhere((element) => element.isNotEmpty);
          rowData = firstLine;
          initHeaders();
        });
      });
    } catch (e, stacktrace) {
      print("stacktrace = $stacktrace");
    }
  }

  CollectionMappingInput? read() {
    return null;
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  Widget _defaultValueInput(FieldMapping col) {
    return streamBuilderDiscretLoading(
      stream: fileInfoStream,
      onDataChanged: (fileInfo) {
        return FormUiUtils.inputNoTitle(
          col.required,
          controllerMap[col.name]!,
          lang.defaultValue,
          enabled: col.name != "id",
          validator: (value) {
            switch (col.type) {
              case DataType.INT:
                return ValidationUtils.intValidator(value, context, required: false, minValue: 0);
              case DataType.DOUBLE:
                return ValidationUtils.doubleValidator(value, context, required: false);

              case DataType.STRING:
                return null;

              case DataType.BOOLEAN:
                if (value == null || value.isEmpty) {
                  return null;
                }
                if (value.toLowerCase() == "true" || value.toLowerCase() == "false") {
                  return null;
                }
                return lang.invalidValue;

              case DataType.DATE:
              case DataType.DATETIME:
                if (value == null || value.isEmpty) {
                  return null;
                }
                try {
                  DateFormat dateFormat = DateFormat(fileInfo.dateFormat);
                  dateFormat.parseStrict(value);
                  return null;
                } catch (e) {
                  return lang.invalidDateFormat;
                }
            }
          },
        );
      },
    );
  }
}

class FileInfoFormat {
  String fileMask;
  String dateFormat;
  String delimiter;

  FileInfoFormat({required this.dateFormat, required this.delimiter, required this.fileMask});
}
