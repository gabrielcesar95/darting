import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

main() {
  menu();
}

void menu() {
  print('################## Início ##################\n');
  print('Selecione uma das opções:');
  print('1. Cotação de hoje');
  print('2. Registrar a cotação de hoje');

  String option = stdin.readLineSync();
  switch (int.parse(option, onError: (String s) => 0)) {
    case 1:
      today();
      break;

    case 2:
      registerData();
      break;

    default:
      print('Opção inválida');
      menu();
  }
}

Future registerData() async {
  Map hgData = await getData();
  dynamic fileData = readFile();

  fileData =
      (fileData != null && fileData.length > 0 ? jsonDecode(fileData) : List());

  bool exists = false;
  fileData.forEach((data) {
    if (data['date'] == now()) {
      exists = true;
    }
  });

  if (!exists) {
    fileData.add({"date": now(), "data": "${hgData['data']}"});

    Directory dir = Directory.current;
    File file = File(dir.path + '/arquivo.txt');
    RandomAccessFile raf = file.openSync(mode: FileMode.write);
    raf.writeStringSync(jsonEncode(fileData).toString());
    raf.flushSync();
    raf.closeSync();

    print('######## Dados salvos com sucesso! ########');
  } else {
    print('Já existe registro referente à data de hoje!');
  }
}

String readFile() {
  Directory dir = Directory.current;
  File file = File(dir.path + '/arquivo.txt');

  if (!file.existsSync()) {
    print('Arquivo não encontrado!');
    return null;
  }

  return file.readAsStringSync();
}

Future today() async {
  var data = await getData();
  print('############ HG Brasil - Cotação ##########');
  print(
      '${data['date'].padLeft(43, ' ')}\n${data['data']}\n-------------------------------------------');
}

Future getData() async {
  String url = 'https://api.hgbrasil.com/finance';
  http.Response response = await http.get(url);

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body)['results']['currencies'];
    var usd = data['USD'];
    var eur = data['EUR'];
    var gbp = data['GBP'];
    var btc = data['BTC'];

    Map formattedMap = Map();
    formattedMap['date'] = now();
    formattedMap['data'] =
        '${usd['name']}: ${usd['buy']}\n${eur['name']}: ${eur['buy']}\n${gbp['name']}: ${gbp['buy']}${btc['name']}: ${btc['buy']}';

    return formattedMap;
  }
}

String now() {
  DateTime date = DateTime.now();

  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString()}';
}
