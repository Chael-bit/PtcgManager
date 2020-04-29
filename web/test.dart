import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:modern_charts/modern_charts.dart';

Future main() async {

gaugeChart(5,25);

}
void gaugeChart(int iRate,int fRate) async{
    var dataTable = new DataTable([
      ['Rate', 'Percent'],
      ['Infection Rate', iRate],
      ['Case Fatality Rate', fRate]
    ]);

    querySelector('#div1').children.clear();
    querySelector('#div1').style.height = '300px';
    var chart = GaugeChart(querySelector('#div1'));
    chart.draw(dataTable);
}


