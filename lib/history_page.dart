import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class HistoryPage extends StatefulWidget {
  final List<String> scannedCodes;
  final VoidCallback onDelete;

  const HistoryPage({Key? key, required this.scannedCodes, required this.onDelete}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final Set<int> _selectedItems = Set<int>();

  Future<String?> _showDescriptionInputDialog(BuildContext context) async {
    String? description;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Введите описание'),
          content: TextField(
            onChanged: (value) {
              description = value;
            },
            decoration: const InputDecoration(hintText: "Описание"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('ОК'),
              onPressed: () => Navigator.of(context).pop(description),
            ),
          ],
        );
      },
    );
  }

  Future<void> _shareDataDirectly() async {
    final String? description = await _showDescriptionInputDialog(context);
    if (description == null || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Описание не введено. Поделиться невозможно.'))
      );
      return;
    }

    final String dataToShare = widget.scannedCodes
        .map((code) => 'Код: $code, Описание: $description')
        .join('\n');

    Share.share(dataToShare);
  }

  Future<void> _exportWithDescription() async {
    final String? description = await _showDescriptionInputDialog(context);
    if (description == null || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Описание не введено. Экспорт отменён.'))
      );
      return;
    }

    final StringBuffer csvBuffer = StringBuffer();
    csvBuffer.write('\ufeff');
    widget.scannedCodes.forEach((code) {
      csvBuffer.writeln('"$code";"$description"');
    });

    final Directory dir = await getApplicationDocumentsDirectory();
    final String path = '${dir.path}/scanned_codes.csv';
    final File file = File(path);

    await file.writeAsString(csvBuffer.toString(), mode: FileMode.write, flush: true, encoding: utf8);

    Share.shareFiles([file.path], text: 'Сканированные штрих-коды с описанием');
  }

  void _selectAll() {
    setState(() {
      if (_selectedItems.length == widget.scannedCodes.length) {
        _selectedItems.clear();
      } else {
        _selectedItems.addAll(List.generate(widget.scannedCodes.length, (index) => index));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isAllSelected = _selectedItems.length == widget.scannedCodes.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('История сканирований'),
        actions: [
          IconButton(
            icon: Icon(isAllSelected ? Icons.indeterminate_check_box : Icons.select_all),
            onPressed: _selectAll,
            tooltip: 'Выбрать все',
          ),
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: _shareDataDirectly,
            tooltip: 'Поделиться как текст',
          ),
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: _exportWithDescription,
            tooltip: 'Экспорт в CSV',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: widget.onDelete,
          ),
        ],
      ),
      body: widget.scannedCodes.isEmpty
        ? const Center(child: Text("История пуста"))
        : ListView.builder(
            itemCount: widget.scannedCodes.length,
            itemBuilder: (context, index) {
              bool isSelected = _selectedItems.contains(index);
              return ListTile(
                title: Text(widget.scannedCodes[index]),
                trailing: Icon(
                 
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                ),
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedItems.remove(index);
                    } else {
                      _selectedItems.add(index);
                    }
                  });
                },
              );
            },
          ),
    );
  }
}