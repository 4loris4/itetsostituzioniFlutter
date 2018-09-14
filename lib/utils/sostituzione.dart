Map ore = {
  "07.50-08.40":"1° ora",
  "08.40-09.30":"2° ora",
  "09.30-10.20":"3° ora",
  "10.30-11.20":"4° ora",
  "11.20-12.10":"5° ora",
  "12.10-13.00":"6° ora",
  "13.30-14.20":"7° ora",
  "14.20-15.10":"8° ora",
  "15.10-16.00":"9° ora",
  "16.00-16.50":"10° ora",
};

class Sostituzione{

  String profSostituto;
  String orario;
  String classe;
  String profAssente;
  String note;

  Sostituzione(this.profSostituto,this.orario,this.classe,this.profAssente,this.note);

  String get ora => ore[orario]==null ? "" : ore[orario];
}

class SostituzioneDocente{

  String profSostituto;
  List<Sostituzione> _sostituzioni = new List();

  SostituzioneDocente(this.profSostituto);

  void addSostituzione(Sostituzione sostituzione){
    _sostituzioni.add(sostituzione);
    _sostituzioni.sort((a,b)=>a.orario.compareTo(b.orario));
  }

  int get length => _sostituzioni.length;
  Sostituzione sostituzione(int i){
    return _sostituzioni[i];
  }
}

class SostituzioneClasse{

  String classe;
  List<Sostituzione> _sostituzioni = new List();

  SostituzioneClasse(this.classe);

  void addSostituzione(Sostituzione sostituzione){
    _sostituzioni.add(sostituzione);
    _sostituzioni.sort((a,b)=>a.orario.compareTo(b.orario));
  }

  int get length => _sostituzioni.length;
  Sostituzione sostituzione(int i){
    return _sostituzioni[i];
  }
}