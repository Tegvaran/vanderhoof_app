import 'package:web_scraper/web_scraper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> scrap(bool activate) async {
  if (!activate) {
    print("----------scraping deactivated");
  } else {
    print("----------------scrap------------");

    //==================================
    // Assistance Methods
    //==================================

    CollectionReference business =
        FirebaseFirestore.instance.collection('businesses');
    Future<void> addBusiness(Map<String, dynamic> businessInfo, String docID) {
      if (docID.contains("/")) {
        docID = docID.replaceAll('/', '|');
      }
      return business
          .doc("$docID")
          .set(businessInfo)
          .then((value) => {
                print("Business Added:  ${docID}"),
              })
          .catchError((error) => print("Failed to add Business: $error"));
    }

    String _check(List element) {
      if (element.isNotEmpty) {
        return element[0];
      } else {
        return null;
      }
    }

    String _checkElement(List element, String tag) {
      if (element.isNotEmpty) {
        return element[0]['attributes'][tag];
      } else {
        return null;
      }
    }

    String _checkPhone(List element) {
      if (element.isNotEmpty) {
        String s = element[0].replaceAll(RegExp(r'[-.() ]'), '');
        s = s.substring(0, 10) + "\n" + s.substring(10);
        return s;
      } else {
        return null;
      }
    }
    //==================================
    // End of Assistance Methods
    //==================================

    final webScraper = WebScraper('https://www.vanderhoofchamber.com/');

    if (await webScraper.loadWebPage('/membership/business-directory')) {
      var elements =
          webScraper.getElement('#businesslist > div >h3>a', ['href']);
      elements.forEach((element) async {
        String page = element['attributes']['href'].substring(33);
        if (await webScraper.loadWebPage(page)) {
          var name = webScraper.getElementTitle('h1.entry-title');
          var phone = webScraper.getElementTitle('p.phone');
          var desc = webScraper.getElementTitle('#business > p');
          var address = webScraper.getElementTitle('p.address');
          var email = webScraper.getElementTitle('p.email > a');
          var web = webScraper.getElement('p.website>a', ['href']);
          var img = webScraper.getElement('div.entry-content >img', ['src']);
          var category = webScraper.getElementTitle('p.categories > a');

          String n = _check(name);
          String p = _checkPhone(phone);
          String d = _check(desc);
          String a = _check(address);
          String e = _check(email);
          String w = _checkElement(web, 'href');
          String i = _checkElement(img, 'src');
          String c = _check(category);

          addBusiness({
            'name': n,
            'address': a,
            'phone': p,
            'email': e,
            'website': w,
            'description': d,
            'imgURL': i,
            'category': c,
          }, n);
        }
      });
    }
  }
}
