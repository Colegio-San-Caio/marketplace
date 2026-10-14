#!/bin/bash
cd ~/oeneye/demo-repository
rm -f "index.html[press"* index.htmlgit* .git/hooks/post-commit
mkdir -p archive catalog

# keep only last 20 archives
ls -1t archive/*.html 2>/dev/null | tail -n +21 | xargs rm -f 2>/dev/null

cat >.gitignore <<'GIT'
__pycache__/
*.pyc
*.db
*.sqlite3
.env
.DS_Store
GIT

cat >.git/hooks/pre-commit <<'HOOK'
#!/bin/bash
rm -f index.htmlgit* "index.html[press"* 2>/dev/null
TS=$(date +"%Y%m%d-%H%M%S")
ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
mkdir -p archive catalog
cp index.html "archive/index-$TS.html" 2>/dev/null

# prune to 20 before building catalog.js
ls -1t archive/*.html 2>/dev/null | tail -n +21 | xargs rm -f 2>/dev/null

echo -n 'window.CATALOG={isbn:"978-3-00-068463-0",last:"'"$ISO"'",ts:"'"$TS"'",archives:[' > catalog.js
ls -1t archive/*.html 2>/dev/null | head -20 | sed 's/.*/"&"/' | paste -sd, - >> catalog.js
echo ']};' >> catalog.js
echo "{\"last\":\"$ISO\",\"ts\":\"$TS\",\"count\":$(ls archive/*.html 2>/dev/null | wc -l)}" > catalog/catalog.json

echo '<!DOCTYPE html><html lang="ja"><meta charset="utf-8"><script src="catalog.js"></script><body><h1>JP</h1><div id="c"></div><ul id="l"></ul><script>document.getElementById("c").innerText=CATALOG.last;CATALOG.archives.forEach(f=>{let li=document.createElement("li");li.innerHTML="<a href="+f+">"+f+"</a>";document.getElementById("l").appendChild(li)})</script></body></html>' > jp.html
echo '<!DOCTYPE html><html><meta charset="utf-8"><script src="catalog.js"></script><body><h1>Changelog</h1><pre id="c"></pre><script>document.getElementById("c").innerText=JSON.stringify(CATALOG,null,2)</script></body></html>' > changelog.html

git add -f archive/ catalog/ catalog.js jp.html changelog.html .gitignore 2>/dev/null
exit 0
HOOK
chmod +x .git/hooks/pre-commit
rm -f .git/hooks/post-commit

git add -A
git commit -m "V8 catalog.js with prune 20 - JP changelog" || true
git push origin main
echo "---"
ls -1 archive/ | wc -l; echo "archives kept"
git status
