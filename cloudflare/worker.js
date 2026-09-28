// 정적 자산(cloudflare/dist/emotion_map/*)에 없는 요청만 여기로 온다.
// APK도 정적 자산이다 — 기기별(ABI) 분리 빌드라 한 파일이 25MiB 한도 안에 든다.
//   공주를걷다_vX.Y.Z.apk        arm64 (2018년 이후 대부분의 폰)
//   공주를걷다_vX.Y.Z_32bit.apk  armeabi-v7a (구형 32비트 폰)
const PREFIX = "/emotion_map";
const CANONICAL_HOST = "changminim.com";
const APK_LATEST = "공주를걷다_v0.7.1.apk";

export default {
  async fetch(request) {
    const url = new URL(request.url);

    if (url.hostname === `www.${CANONICAL_HOST}`) {
      url.hostname = CANONICAL_HOST;
      return Response.redirect(url.toString(), 301);
    }
    if (!url.pathname.startsWith(PREFIX)) {
      return Response.redirect(`${url.origin}${PREFIX}/`, 302);
    }

    // 짧은 주소 /emotion_map/apk → 최신 APK (QR·카톡 안내용)
    const rest = decodeURIComponent(url.pathname.slice(PREFIX.length)).replace(/^\/+/, "");
    if (rest === "apk" || rest === "apk/") {
      return Response.redirect(`${url.origin}${PREFIX}/${encodeURIComponent(APK_LATEST)}`, 302);
    }
    return new Response("Not Found", {
      status: 404,
      headers: { "content-type": "text/plain; charset=utf-8" },
    });
  },
};
