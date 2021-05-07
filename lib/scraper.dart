import 'package:web_scraper/web_scraper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoder/geocoder.dart';

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
        String s = element[0].replaceAll(RegExp(r'[^0-9]'), '');
        int length = 10;
        if (s[0] == '1') {
          length = length + 1;
        }
        s = s.substring(0, length);
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
          webScraper.getElementAttribute('#businesslist > div >h3>a', 'href');

      elements.forEach((element) async {
        String page = element.substring(33);
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
          if (i != null) {
            for (int j = i.length - 1; j > 50; j--) {
              if (i[j] == '-') {
                i = i.substring(0, j) + i.substring(i.length - 4, i.length);
                break;
              }
            }
          }
          Future<GeoPoint> toLatLng(String addr) async {
            if (addr == null) {
              return null;
            }
            var address = await Geocoder.local.findAddressesFromQuery(addr);
            var first = address.first;
            var coor = first.coordinates;
            var lat = coor.latitude;
            var lng = coor.longitude;
            return GeoPoint(lat, lng);
          }

          toLatLng(a)
              .then((geopoint) => {
                    addBusiness({
                      'name': n,
                      'address': a,
                      'phone': p,
                      'email': e,
                      'website': w,
                      'description': d,
                      'imgURL': i,
                      'category': c,
                      'LatLng': geopoint,
                      'socialMedia': {
                        'facebook': ".",
                        'instagram': ".",
                        'twitter': "."
                      },
                    }, n)
                  })
              .catchError((error) => print("Failed to get GeoPoint: $error"));
        }
      });
    }
  }
}
