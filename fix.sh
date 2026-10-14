#!/bin/bash
cd ~/oeneye/demo-repository
rm -f "index.html[press"* index.htmlgit* .git/hooks/post-commit
mkdir -p archive catalog
ls -1t archive/*.html 2>/dev/null | tail -n +21 | xargs rm -f 2>/dev/null

cat >.gitignore <<'GIT'
__pycache__/
*.pyc
*.db
*.sqlite3
.env
.DS_Store
GIT

# V9.1 add catalog box if not present
if ! grep -q "catalog-box" index.html; then
echo '<div id="catalog-box" style="font-family:monospace;border:1px solid #ccc;padding:10px;margin:10px"><h3>Archives (<span id="cat-count"></span>) Last: <span id="cat-last"></span></h3><ul id="cat-list"></ul><a href="jp.html">JP</a> | <a href="changelog.html">Changelog</a></div><script src="catalog.js"></script><script>document.getElementById("cat-last").innerText=CATALOG.last;document.getElementById("cat-count").innerText=CATALOG.archives.length;CATALOG.archives.forEach(f=>{let li=document.createElement("li");li.innerHTML="<a href="+f+">"+f+"</a>";document.getElementById("cat-list").appendChild(li)})</script>' >> index.html
fi

cat >.git/hooks/pre-commit <<'HOOK'
#!/bin/bash
rm -f index.htmlgit* "index.html[press"* 2>/dev/null
TS=$(date +"%Y%m%d-%H%M%S")
ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
mkdir -p archive catalog
cp index.html "archive/index-$TS.html" 2>/dev/null
ls -1t archive/*.html 2>/dev/null | tail -n +21 | xargs rm -f 2>/dev/null
echo -n 'window.CATALOG={isbn:"978-3-00-068463-0",last:"'"$ISO"'",ts:"'"$TS"'",archives:[' > catalog.js
ls -1t archive/*.html 2>/dev/null | head -20 | sed 's/.*/"&"/' | paste -sd, - >> catalog.js
echo ']};' >> catalog.js
echo "{\"last\":\"$ISO\",\"ts\":\"$TS\"}" > catalog/catalog.json
echo '<html><script src="catalog.js"></script><body><h1>JP</h1><div id="c"></div><ul id="l"></ul><script>document.getElementById("c").innerText=CATALOG.last;CATALOG.archives.forEach(f=>{let li=document.createElement("li");li.innerHTML="<a href="+f+">"+f+"</a>";document.getElementById("l").appendChild(li)})</script></body></html>' > jp.html
echo '<html><script src="catalog.js"></script><body><h1>Changelog</h1><pre id="c"></pre><script>document.getElementById("c").innerText=JSON.stringify(CATALOG,null,2)</script></body></html>' > changelog.html
git add -f index.html archive/ catalog/ catalog.js jp.html changelog.html .gitignore
exit 0
HOOK
chmod +x .git/hooks/pre-commit
git add -A
git commit -m "V9.1 fix if bug - restore index + catalog box" || true
git push origin main
git status
