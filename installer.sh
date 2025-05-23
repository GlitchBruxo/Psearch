#!/data/data/com.termux/files/usr/bin/bash

#==================================================
#             INSTALLADOR DO PSEARCH
#     Comando de busca avançada de conteúdo H      
#==================================================

clear
echo "╔════════════════════════════════════════╗"
echo "║     🍑 INSTALANDO O PSEARCH TOOL 🍑     ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "[*] Instalando dependências..."
pkg update -y > /dev/null 2>&1
pkg install python -y > /dev/null 2>&1
pip install requests beautifulsoup4 --quiet

echo "[*] Criando diretório do comando..."
mkdir -p ~/.psearch

echo "[*] Gerando script Python..."
cat << 'EOF' > ~/.psearch/psearch.py
#!/usr/bin/env python3
import sys, re, requests
from bs4 import BeautifulSoup
from urllib.parse import quote
from datetime import datetime

HEADER = {"User-Agent": "Mozilla/5.0"}
CATEGORIAS = {
    "porno": ["xvideos.com", "xnxx.com"],
    "hentai": ["hanime.tv", "hentaihaven.xxx", "animeshentai.biz"],
    "manga": ["nhentai.net", "hentai.cafe", "tsumino.com", "doujins.com"]
}

def formatar_resultados(links, dominio):
    print(f"🔎 Dominio: {dominio}")
    for i, link in enumerate(links[:8]):
        full = link if link.startswith("http") else f"https://{dominio}{link}"
        print(f" {i+1:02d} ➤ {full}")
    print("")

def extrair_links(html):
    soup = BeautifulSoup(html, "html.parser")
    return list(set(a["href"] for a in soup.find_all("a", href=True) if re.search(r"/(watch|video|view|gallery|galleries|g|read|episodes|episode|entry)/", a["href"])))

def buscar_por_categoria(termo, lista):
    for site in lista:
        url = f"https://{site}/search/{quote(termo)}" if "xvideos" in site or "xnxx" in site else f"https://{site}/?s={quote(termo)}"
        print(f"🌐 {site}")
        try:
            r = requests.get(url, headers=HEADER, timeout=10)
            if r.status_code == 200:
                links = extrair_links(r.text)
                formatar_resultados(links, site)
            else:
                print(f"⚠️ Falha ao acessar {site}")
        except Exception as e:
            print(f"❌ Erro: {str(e)}")

def ajuda():
    print("""
🍆 psearch <args> [--tags|--date|--person]

Comando de busca avançado em sites +18
─────────────────────────────────────────
--tags      ➤ busca por palavra-chave
--date      ➤ filtra por ano (ex: 2023)
--person    ➤ busca por atriz/autor

Categorias:
  🔞 Porno: Xvideos, XNXX
  🍥 Hentai: Hanime, HentaiHaven, AnimesHentai
  📖 Mangá: Nhentai, Hentai.cafe, Doujins, Tsumino
""")

def main():
    if len(sys.argv) < 2 or "--help" in sys.argv:
        ajuda()
        return

    termo = " ".join(arg for arg in sys.argv[1:] if not arg.startswith("--"))
    flag = next((arg for arg in sys.argv if arg.startswith("--")), "--tags")

    print("🛰️ Buscando por:", termo)
    print("⌛ Aguarde...\n")

    if flag == "--tags":
        for tipo, sites in CATEGORIAS.items():
            print(f"================== {tipo.upper()} ==================")
            buscar_por_categoria(termo, sites)
    elif flag == "--date":
        buscar_por_categoria(termo, CATEGORIAS["porno"] + CATEGORIAS["hentai"])
    elif flag == "--person":
        buscar_por_categoria(termo, CATEGORIAS["porno"])
    else:
        ajuda()

if __name__ == "__main__":
    main()
EOF

chmod +x ~/.psearch/psearch.py

echo "[*] Criando alias global..."
cat << 'EOL' >> ~/.bashrc

# Alias para comando psearch
alias psearch="python ~/.psearch/psearch.py"
EOL

source ~/.bashrc
echo ""
echo "✅ Instalação concluída! Use o comando: psearch --help"
