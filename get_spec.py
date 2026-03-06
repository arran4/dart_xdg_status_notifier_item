import urllib.request
url = "https://raw.githubusercontent.com/AyatanaIndicators/libdbusmenu/master/libdbusmenu-glib/dbusmenu-glib.xml"
try:
    print(urllib.request.urlopen(url).read().decode('utf-8'))
except Exception as e:
    print(e)
