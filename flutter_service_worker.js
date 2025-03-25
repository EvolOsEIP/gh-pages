'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"index.html": "f66f764a5c8411583e0b5a0e65844e5a",
"/": "f66f764a5c8411583e0b5a0e65844e5a",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"splash/img/dark-4x.png": "a8475b57a5fdb1b415b0063b0c662dd0",
"splash/img/dark-3x.png": "4a965150d3eea43da268f2f4595f946c",
"splash/img/dark-2x.png": "ac8f9603247dd48196306e55615aeb3c",
"splash/img/light-2x.png": "ac8f9603247dd48196306e55615aeb3c",
"splash/img/dark-1x.png": "742ae4d97271b1854e0914510b6b1548",
"splash/img/light-3x.png": "4a965150d3eea43da268f2f4595f946c",
"splash/img/light-1x.png": "742ae4d97271b1854e0914510b6b1548",
"splash/img/light-4x.png": "a8475b57a5fdb1b415b0063b0c662dd0",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"manifest.json": "a515cd28e5a5d75716c1bbad901297bf",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/NOTICES": "f2590a6708c5ea0eb528bf6cbb26d71b",
"assets/fonts/MaterialIcons-Regular.otf": "51f1e7b7e88cd6ade454f50c7bceb78c",
"assets/AssetManifest.bin": "0497a8db7953712acaa5915a911bc79e",
"assets/AssetManifest.json": "209d138732b5cf8a89ac8def6c20a063",
"assets/AssetManifest.bin.json": "c84c54c30bbdd8387c37226296e44f27",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/assets/chapters.json": "c61afc5a4374f81c9cce33baf3c2895a",
"assets/assets/images/modules/1_basics/ch1/course1/step3.png": "5dca96d4dd35685fe4c1ba98d831abd4",
"assets/assets/images/modules/1_basics/ch1/course1/step1.png": "7c894f723288bcf709f733fa4b7935d6",
"assets/assets/images/modules/1_basics/ch1/course1/step4.png": "1ca21cf01a06be55023e3cb39d52a5fa",
"assets/assets/images/modules/1_basics/ch1/course1/step2.png": "cfea3e30616e834fc2e2c933f900a4da",
"assets/assets/images/44.jpg": "ee7f23d6cb6677f1dcc534bc67752105",
"assets/assets/images/keyboard.png": "1303479c3057b9b7f2f8097125fc4ed9",
"assets/assets/images/genetic-data-svgrepo-com.svg": "425a28fade633140f331bb3d7f7492cf",
"assets/assets/images/achievements.png": "22ce797a4463eb2a3c3db9727b05be4e",
"assets/assets/images/logo.png": "58b8f040f01b1151e633bc5c3f9ff22d",
"assets/assets/json/success.json": "96bed9cca9b8b5428106cbfb3623e695",
"assets/assets/json/offline_modules.json": "c928f0285aed3e5a15e43880e230fb06",
"assets/assets/courses_page_example.json": "ec41c2b90946cc084ed7b262ff8d3fc4",
"main.dart.js": "85f2319b7165d6148510648a537b6ce2",
"flutter_bootstrap.js": "84af6fcfb62ffec94f576c0c4665bc54"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
