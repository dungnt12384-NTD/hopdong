/* Chỉ lưu vỏ ứng dụng (HTML/biểu tượng) để mở nhanh; KHÔNG lưu dữ liệu hợp đồng. Ưu tiên mạng, mất mạng mới dùng bản đã lưu. */
const V='hd-shell-v1',SHELL=['./','index.html','manifest.webmanifest','icon-192.png','icon-512.png','huong-dan-quy-trinh.html'];
self.addEventListener('install',e=>{e.waitUntil(caches.open(V).then(c=>c.addAll(SHELL)).then(()=>self.skipWaiting()))});
self.addEventListener('activate',e=>{e.waitUntil(caches.keys().then(ks=>Promise.all(ks.filter(k=>k!==V).map(k=>caches.delete(k)))).then(()=>self.clients.claim()))});
self.addEventListener('fetch',e=>{
  const r=e.request,u=new URL(r.url);
  if(r.method!=='GET'||!(u.origin===location.origin||u.hostname==='cdnjs.cloudflare.com'))return;
  e.respondWith(fetch(r).then(x=>{if(x.ok){const cp=x.clone();caches.open(V).then(c=>c.put(r,cp))}return x}).catch(()=>caches.match(r)));
});