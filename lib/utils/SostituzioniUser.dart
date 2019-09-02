import 'package:itetsostituzioni/Utils/Sostituzione.dart';

class SostituzioniUser {

  String user;
  List<Sostituzione> sostituzioni = List();

  SostituzioniUser(this.user);

  int get length => sostituzioni.length;
  operator [](i) => sostituzioni[i];

  void add(Sostituzione sostituzione){
    sostituzioni.add(sostituzione);
    sostituzioni.sort((a,b) => a.orario.compareTo(b.orario));
  }
}