// 정적 자산(cloudflare/dist/emotion_map/*)에 없는 요청만 여기로 온다.
const PREFIX = "/emotion_map";
const CANONICAL_HOST = "changminim.com";

// APK는 Worker 정적 자산 한도(25MiB)를 넘어 GitHub Release 에 둔다.
// 페이지의 링크(./공주를걷다_v0.7.1.apk)는 그대로 두고 여기서 실제 파일로 보낸다.
const APK = {
  "공주를걷다_v0.7.1.apk":
    "https://github.com/ChangminIm/emotion_map/releases/download/v0.7.1/gongju_walk_v0.7.1.apk",
};
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

    const rest = decodeURIComponent(url.pathname.slice(PREFIX.length)).replace(/^\/+/, "");
    if (rest === "apk" || rest === "apk/") {
      return Response.redirect(APK[APK_LATEST], 302);
    }
    if (rest.endsWith(".apk")) {
      const target = APK[rest] ?? APK[APK_LATEST];
      return Response.redirect(target, 302);
    }
    return new Response("Not Found", {
      status: 404,
      headers: { "content-type": "text/plain; charset=utf-8" },
    });
  },
};
