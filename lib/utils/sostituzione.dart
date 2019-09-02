class Sostituzione {

  String docenteSostituto;
  String ora;
  String orario;
  String classe;
  String docenteAssente;
  String note;

  Sostituzione(String docenteSostituto, int ora, String classe, String docenteAssente, String note) {
    List<String> orari = ["07.50 - 08.40", "08.40 - 09.30", "09.30 - 10.20", "10.30 - 11.20", "11.20 - 12.10", "12.10 - 13.00", "13.30 - 14.20", "14.20 - 15.10", "15.10 - 16.00", "16.00 - 16.50"];

    this.docenteSostituto = docenteSostituto;
    this.classe = classe;
    this.ora = "$ora° ora";
    this.orario = orari[ora-1];
    this.docenteAssente = docenteAssente;
    this.note = note;
  }
}