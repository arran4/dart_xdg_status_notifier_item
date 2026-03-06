import urllib.request
url = "https://raw.githubusercontent.com/AyatanaIndicators/libdbusmenu/master/libdbusmenu-glib/dbus-menu.xml"
try:
    response = urllib.request.urlopen(url)
    print(response.read().decode('utf-8'))
except Exception as e:
    print(e)
