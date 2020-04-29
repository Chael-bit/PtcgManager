import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:modern_charts/modern_charts.dart';

var tableInstance = 0;
var countryCode;
int countryPopulation;
var cName;
var tableA = TableElement();

Future main() async {
  // Div element for error messages
  var output = DivElement();
  output.id = 'output';
  worldWideTable();
  allCountriesTable();
  getCountryTable();
  /*
  try {
     await
     //fillCountryList();

    } catch (err) {
    querySelector('#output').text = err.toString();
    }*/
}
void gaugeChart(double iRate,double fRate) async{
  var dataTable = new DataTable([
    ['Rate', 'Percent'],
    ['Infection Rate', iRate],
    ['Case Fatality Rate', fRate]
  ]);

  querySelector('#div3').children.clear();
  querySelector('#div3').style.height = '150px';
  var chart = GaugeChart(querySelector('#div3'));
  chart.draw(dataTable);
}

void lineChart() async{
  try {
    List<List<dynamic>> data = [['Date', 'Confirmed', 'Deaths', 'Recovered']];
    var day = await getDays(cName);
    await day.forEach((c) {
      data.add([c.date, c.confirmed, c.deaths, c.recovered]);
    });
    var dataTable = new DataTable(data);
    querySelector('#div2').children.clear();
    querySelector('#div2').style.height = '300px';
    var chart = LineChart(querySelector('#div2'));
    chart.draw(dataTable);
  } catch (err) {
    querySelector('#output').text = err.toString();
  }
}

class Day {
  String date;
  int confirmed;
  int deaths;
  int recovered;

  Day({this.date, this.confirmed, this.deaths, this.recovered});

  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(
        date: json['date'],
        confirmed: json['confirmed'],
        deaths: json['deaths'],
        recovered: json['recovered']
    );
  }
}

Future<List<Day>> getDays(String cName) async {
  var url = 'https://pomber.github.io/covid19/timeseries.json';
  var response = await http.get(url);
  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(response.body);
    if (cName == 'USA') {
      return jsonResponse['US'].map<Day>((m) => Day.fromJson(m)).toList();
    }else if (cName == 'UK') {
      return jsonResponse['United Kingdom'].map<Day>((m) => Day.fromJson(m)).toList();
    } else {
      return jsonResponse['$cName'].map<Day>((m) => Day.fromJson(m)).toList();
    }
  }else {
    throw Exception('Failed to fetch user');
  }
}

void worldWideTable() async{

  tableA.id = 'worldWideTable';
  tableA.style.textAlign = 'center';
if (tableInstance > 0) {
  querySelector('#worldWideTable').hidden = true;
}else {
  var tableAHeaderContent =
  ['Total Cases', 'Total Deaths', 'Total Recovered',
    'Total Active', 'Total Affected Countries'];
  var tableHeader = tableA.createTHead();
  var tableHeaderRow = tableHeader.addRow();
  for (var i = 0; i < tableAHeaderContent.length; i++) {
    tableHeaderRow
        .addCell()
        .text = '${tableAHeaderContent[i]}';
  }
  var tableBody = tableA.createTBody();
  try {
    var allCases = await getAllCases();
    var tableBodyRow = tableBody.addRow();
    var tableBodyRowCell0 = tableBodyRow.addCell();
    tableBodyRowCell0.style.color = 'red';
    tableBodyRowCell0.text = '${allCases.cases}';
    var tableBodyRowCell1 = tableBodyRow.addCell();
    tableBodyRowCell1.text = '${allCases.deaths}';
    var tableBodyRowCell2 = tableBodyRow.addCell();
    tableBodyRowCell2.style.color = 'green';
    tableBodyRowCell2.text = '${allCases.recovered}';
    var tableBodyRowCell3 = tableBodyRow.addCell();
    tableBodyRowCell3.text = '${allCases.active}';
    var tableBodyRowCell5 = tableBodyRow.addCell();
    tableBodyRowCell5.text = '${allCases.affectedCountries}';
  } catch (err) {
    querySelector('#output').text = err.toString();
  }
}
  var div1 = querySelector('#div1');
  div1.style.textAlign = 'center';
  tableA.style.marginLeft = 'auto';
  tableA.style.marginRight = 'auto';
  div1.children.add(tableA);

}

void allCountriesTable() async{
  var table = TableElement();
  table.id = 'allCountriesTable';
  table.style.textAlign = 'center';
  if (tableInstance > 0) {
    querySelector('#allCountriesTable').hidden = true;
  }else {

    var tableBody = table.createTBody();
    var tableHeader = table.createTHead();
    var tableHeaderContent =
    ['Flag', 'Country', 'Cases', 'Todays Cases', 'Deaths', 'Todays Deaths', 'Recovered',
      'Active', 'Critical', 'Tests'];
    if (tableInstance == 0) {
      var tableHeaderRow = tableHeader.addRow();
      for (var i = 0; i < tableHeaderContent.length; i++) {
        tableHeaderRow
            .addCell()
            .text = '${tableHeaderContent[i]}';
      }
    }

    try {
      List<Covid19byCountry> orderedCasesList = [];
      var orderedCases = [];
      var cases = await getCases();
      cases.forEach((o) {
        orderedCases.add(o.cases);
      });
      orderedCases.sort((b, a) => a.compareTo(b));
      for (var i = 0; i < orderedCases.length; i++) {
        cases.forEach((e) {
          if (orderedCases[i] == e.cases) {
            orderedCasesList.add(e);
          }
        });
      }

      orderedCasesList.forEach((c) {
        var tableBodyRow = tableBody.addRow();
        var flagImage = ImageElement(
            src: '${c.flag}', width: 50, height: 25);
        var tableBodyRowCell = tableBodyRow.addCell();
        tableBodyRowCell.children.add(flagImage);
        var tableBodyRowCell0 = tableBodyRow.addCell();
        tableBodyRowCell0.text = c.country;
        var tableBodyRowCell1 = tableBodyRow.addCell();
        tableBodyRowCell1.style.color = 'red';
        tableBodyRowCell1.text = '${c.cases}';
        var tableBodyRowCell2 = tableBodyRow.addCell();
        tableBodyRowCell2.style.color = 'red';
        tableBodyRowCell2.text = '${c.todayCases}';
        var tableBodyRowCell3 = tableBodyRow.addCell();
        tableBodyRowCell3.text = '${c.deaths}';
        var tableBodyRowCell4 = tableBodyRow.addCell();
        tableBodyRowCell4.text = '${c.todayDeaths}';
        var tableBodyRowCell5 = tableBodyRow.addCell();
        tableBodyRowCell5.style.color = 'green';
        tableBodyRowCell5.text = '${c.recovered}';
        var tableBodyRowCell6 = tableBodyRow.addCell();
        tableBodyRowCell6.text = '${c.active}';
        var tableBodyRowCell7 = tableBodyRow.addCell();
        tableBodyRowCell7.style.color = 'red';
        tableBodyRowCell7.text = '${c.critical}';
        var tableBodyRowCell8 = tableBodyRow.addCell();
        tableBodyRowCell8.style.color= 'lightskyblue';
        tableBodyRowCell8.text = '${c.tests}';
      });

    } catch (err) {
      querySelector('#output').text = err.toString();
    }
  }
  var div2 = querySelector('#div2');
  div2.style.textAlign = 'center';
  table.style.marginLeft = 'auto';
  table.style.marginRight = 'auto';
  div2.insertAdjacentElement('afterBegin', table);

}

void getCountryTable() async{
  var table = TableElement();
  table.id = 'getCountryTable';
  table.style.textAlign = 'center';
  var tableBody = table.createTBody();
  querySelector('#search').onClick.listen((e) async {

    tableInstance ++;
    //allCountriesTable();
    if (tableInstance > 1) {
      tableBody.children.clear();
    }
     var countryName = (querySelector('#countryName')
    as TextInputElement).value;
  var tableHeaderContent =
  ['Flag','Country', 'Cases', 'Todays Cases', 'Deaths', 'Todays Deaths', 'Recovered',
    'Active','Critical', 'Tests'];
  var tableHeader = table.createTHead();
  if (tableInstance == 1) {
    var tableHeaderRow = tableHeader.addRow();
    for (var i = 0; i < tableHeaderContent.length; i++) {
      tableHeaderRow
          .addCell()
          .text = '${tableHeaderContent[i]}';
    }
  }

    worldWideTable();
  try {
    var country = await getCovidbyCountry(countryName);
    var tableBodyRow = tableBody.addRow();
    var flagImage = ImageElement(
        src: '${country.flag}', width: 50, height: 25);
    var tableBodyRowCell = tableBodyRow.addCell();
    tableBodyRowCell.children.add(flagImage);
    var tableBodyRowCell0 = tableBodyRow.addCell();
    tableBodyRowCell0.text = country.country;
    var tableBodyRowCell1 = tableBodyRow.addCell();
    tableBodyRowCell1.style.color= 'red';
    tableBodyRowCell1.text = '${country.cases}';
    var tableBodyRowCell2 = tableBodyRow.addCell();
    tableBodyRowCell2.style.color= 'red';
    tableBodyRowCell2.text = '${country.todayCases}';
    var tableBodyRowCell3 = tableBodyRow.addCell();
    tableBodyRowCell3.text = '${country.deaths}';
    var tableBodyRowCell4 = tableBodyRow.addCell();
    tableBodyRowCell4.text = '${country.todayDeaths}';
    var tableBodyRowCell5 = tableBodyRow.addCell();
    tableBodyRowCell5.style.color= 'green';
    tableBodyRowCell5.text = '${country.recovered}';
    var tableBodyRowCell6 = tableBodyRow.addCell();
    tableBodyRowCell6.text = '${country.active}';
    var tableBodyRowCell7 = tableBodyRow.addCell();
    tableBodyRowCell7.style.color= 'red';
    tableBodyRowCell7.text = '${country.critical}';
    var tableBodyRowCell8 = tableBodyRow.addCell();
    tableBodyRowCell8.style.color= 'lightskyblue';
    tableBodyRowCell8.text = '${country.tests}';

    countryCode = country.countryCode;
    cName = country.country;

    await getPopulation();
      var infectionRate = (country.cases / countryPopulation) * 100;
      var fatalityRate = (country.deaths/ country.cases) * 100;
      gaugeChart(infectionRate, fatalityRate);
      lineChart();


  } catch (err) {
    querySelector('#output').text = err.toString();
  }

  });

  var form = querySelector('#div1');
  form.style.textAlign = 'center';
  table.style.marginLeft = 'auto';
  table.style.marginRight = 'auto';
  form.insertAdjacentElement('beforeEnd', table);
}

 void getPopulation() async{
  try {
    var country = await getCountry(countryCode);
    countryPopulation = country.population;
  } catch (err) {
    querySelector('#output').text = err.toString();
}
}



class Covid19 {
  int cases;
  int deaths;
  int recovered;
  int active;
  int affectedCountries;

  Covid19 ({this.cases, this.deaths,
    this.recovered, this.active, this.affectedCountries});

  factory Covid19.fromJson(Map<String, dynamic> json) {
    return Covid19(
        cases: json['cases'],
        deaths: json['deaths'],
        recovered: json['recovered'],
        active: json['active'],
        affectedCountries: json['affectedCountries']
    );
  }
}

Future<Covid19> getAllCases() async {
  var url = 'https://corona.lmao.ninja/V2/all';
  var response = await http.get(url);
  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(response.body);
    return Covid19.fromJson(jsonResponse);
  }else {
    throw Exception('Failed to fetch user');
  }
}

class Covid19byCountry {
  String country;
  int cases;
  int todayCases;
  int deaths;
  int todayDeaths;
  int recovered;
  int active;
  int critical;
  String countryCode;
  String flag;
  int tests;

  Covid19byCountry ({this.country, this.cases, this.todayCases, this.deaths, this.todayDeaths,
    this.recovered, this.active, this.critical, this.countryCode, this.flag,
    this.tests});

  factory Covid19byCountry.fromJson(Map<String, dynamic> json) {
    return Covid19byCountry(
      country: json['country'],
      cases: json['cases'],
      todayCases: json['todayCases'],
      deaths: json['deaths'],
      todayDeaths: json['todayDeaths'],
      recovered: json['recovered'],
      active: json['active'],
      critical: json['critical'],
      countryCode: json['countryInfo']['iso3'],
      flag: json['countryInfo']['flag'],
      tests: json['tests']
    );
  }
}

Future<List<Covid19byCountry>> getCases() async {
  var url = 'https://corona.lmao.ninja/v2/countries/';
  var response = await http.get(url);
  if (response.statusCode == 200) {
    List jsonResponse = jsonDecode(response.body);
    return jsonResponse.map((m) => Covid19byCountry.fromJson(m)).toList();
  }else {
    throw Exception('Failed to fetch user');
  }
}

Future<Covid19byCountry> getCovidbyCountry(String country) async {
  var url = 'https://corona.lmao.ninja/v2/countries/$country';
  var response = await http.get(url);
  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(response.body);
    return Covid19byCountry.fromJson(jsonResponse);
  }else {
    throw Exception('Failed to fetch user');
  }
}

class Country {
  String name;
  int population;

  Country({this.name, this.population});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['country']['value'],
      population: json['value'],
    );
  }
}

Future<Country> getCountry(String countryCode) async {
  var url = 'https://api.worldbank.org/v2/country/$countryCode/indicator/SP.POP.TOTL?source=2&date=2018&format=json&filter=country';
  var response = await http.get(url);
  if (response.statusCode == 200) {
    List jsonResponse = jsonDecode(response.body);
    return Country.fromJson(jsonResponse[1][0]);
  }else {
    throw Exception('Failed to fetch user');
  }
}


/*
void fillCountryList() async{

  try {
    //for (var i = 0; i < countryCodeList.length; i++) {
      var country = await getCountry(countryCodeList[3]);
      country.forEach((p) {

        querySelector('#div3').text = p.countryName;
        querySelector('#div2').text = '${p.population}';



     });
    //}
  } catch (err) {
    querySelector('#output').text = err.toString();
  }
}


 */
