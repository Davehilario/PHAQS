(function(){
  const originalFetch=window.fetch.bind(window);
  let csrfPromise=null;

  function isWrite(method){
    return !['GET','HEAD','OPTIONS'].includes(String(method||'GET').toUpperCase());
  }

  function apiBaseFromUrl(url){
    const value=typeof url==='string'?url:(url&&url.url)||'';
    const marker='backend/api.php';
    const index=value.indexOf(marker);
    if(index>=0)return value.slice(0,index)+marker;
    return null;
  }

  async function getToken(apiBase){
    if(!csrfPromise){
      csrfPromise=originalFetch(apiBase+'?action=csrf_token',{
        method:'GET',credentials:'include',cache:'no-store'
      }).then(r=>r.json()).then(j=>{
        if(!j.ok||!j.csrfToken)throw new Error('Unable to initialize the security token.');
        return j.csrfToken;
      }).catch(error=>{
        csrfPromise=null;
        throw error;
      });
    }
    return csrfPromise;
  }

  window.fetch=async function(input,init){
    const options=Object.assign({},init||{});
    const method=options.method||((input&&input.method)||'GET');
    const apiBase=apiBaseFromUrl(input);

    if(apiBase&&isWrite(method)){
      const token=await getToken(apiBase);
      const headers=new Headers(options.headers||((input&&input.headers)||{}));
      headers.set('X-CSRF-Token',token);
      options.headers=headers;
      options.credentials=options.credentials||'include';
    }

    const response=await originalFetch(input,options);
    if(response.status===419)csrfPromise=null;
    return response;
  };
})();