# SuTakip

Çift temalı su takip uygulaması: sade beyaz arayüz, gizli VIP modu, interaktif su bildirimleri ve kilit ekranı widget’ı.

Bu proje Windows’ta kaynak olarak yazıldı. Derlemek için bir Mac’te **Xcode 15+** gerekir (iOS 17).

## Açılış

1. `SuTakip.xcodeproj` dosyasını Xcode ile aç.
2. Signing & Capabilities içinde kendi Apple ID / Team seç.
3. Hem **SuTakip** hem **SuTakipWidget** hedeflerinde App Group’un açık olduğundan emin ol: `group.com.can.sutakip`.
4. iPhone veya simülatörde SuTakip scheme’ini çalıştır.

## Standart mod

İlk açılışta beyaz arka planlı su takip, geçmiş ve ayarlar sekmeleri gelir. Mor / yeşil / turuncu yalnızca buton, halka ve ikonlarda pastel kullanılır.

## Gizli VIP

Ayarlar’ın en altına kaydır → **Aktivasyon Kodu** → `1234`.

Kod doğruysa `isVIP` kalıcı olarak `true` yazılır. Bundan sonra uygulama doğrudan VIP ana ekranı açar; standart moda dönüş yoktur.

VIP’de takma ad, romantik mesaj listesi, su paneli ve sürpriz bildirimler vardır.

## Bildirimler

Su kategorisi (`WATER_REMINDER`) iki aksiyon taşır:

- **Onayla** — içme aralığını sıfırlar, sonraki hatırlatmayı normal aralıkla kurar.
- **Onaylama** — bildirimi kapatır, **90 saniye** sonraya yeni uyarı zamanlar.

VIP açıkken rastgele aralıklı romantik mesaj bildirimleri de eklenir.

## Widget

Kilit ekranı: `accessoryCircular` (yüzde + damla) ve `accessoryRectangular` (miktar + kısa mesaj). Veri App Group UserDefaults üzerinden paylaşılır.
