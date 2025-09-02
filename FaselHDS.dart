import 'package:mangayomi/bridge_lib.dart';

class FaselHDS extends MProvider {
  FaselHDS()
      : super(
          name: "FaselHDS",
          baseUrl: "https://www.faselhds.life",
          lang: "ar",
          typeSource: SourceType.anime,
        );

  // 🔍 البحث
  @override
  Future<List<Manga>> searchManga(String query, int page) async {
    final url = "$baseUrl/search/$query/page/$page/";
    final res = await httpGet(url);
    final document = parseHtml(res.body);

    return document
        .select("div.BlockItem") // عنصر نتائج البحث
        .map((element) {
          final title = element.selectFirst("h3 a")?.text ?? "بدون عنوان";
          final link = element.selectFirst("h3 a")?.attr("href") ?? "";
          final cover = element.selectFirst("img")?.attr("data-src") ??
              element.selectFirst("img")?.attr("src") ??
              "";
          return Manga(
            title: title,
            url: link,
            imageUrl: cover,
          );
        })
        .toList();
  }

  // 📂 جلب الحلقات
  @override
  Future<List<Chapter>> fetchChapters(String mangaUrl) async {
    final res = await httpGet(mangaUrl);
    final document = parseHtml(res.body);

    return document
        .select("ul.episodes li a") // قائمة الحلقات
        .map((e) {
          final name = e.text.trim();
          final link = e.attr("href") ?? "";
          return Chapter(name: name, url: link);
        })
        .toList();
  }

  // ▶️ روابط المشاهدة
  @override
  Future<List<Page>> fetchPages(String chapterUrl) async {
    final res = await httpGet(chapterUrl);
    final document = parseHtml(res.body);

    return document
        .select("video source") // روابط الفيديو
        .map((e) {
          final videoUrl = e.attr("src") ?? "";
          ret
