#!/bin/bash

# https://www.markdownguide.org/basic-syntax/

# Vérification des arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <fichier.txt>"
    exit 1
fi

input_file="$1"

# Vérification de l'existence du fichier
if [ ! -f "$input_file" ]; then
    echo "Erreur: Le fichier '$input_file' n'existe pas"
    exit 1
fi

# Nom du fichier de sortie (remplace .txt par .md)
output_file="${input_file%.txt}.md"

# Fonction de conversion
convert_bbcode_to_markdown() {
    local content="$1"
    
    # Suppression des balises [align=center] et [/align]
    content=$(echo "$content" | sed 's/\[align=center\]//g' | sed 's/\[\/align\]//g')

    # Conversion des images [img]/path/image.png[/img] => ![](/path/image.png)
    content=$(echo "$content" | sed -E 's|\[img\]([^[]+)\[/img\]|![](\1)|g')
    
    # Conversion des titres de niveau 1 (-- titre --)
    content=$(echo "$content" | sed 's/^-- \(.*\) --$/# \1/g')
    
    # Conversion des titres de niveau 2 (--- titre ---)
    content=$(echo "$content" | sed 's/^--- \(.*\) ---$/## \1/g')
    
    # Conversion des titres de niveau 3 (---- titre ----)
    content=$(echo "$content" | sed 's/^---- \(.*\) ----$/### \1/g')
    
    # Conversion des titres de niveau 4 (----- titre -----)
    content=$(echo "$content" | sed 's/^----- \(.*\) -----$/### \1/g')

    # Conversion du gras [b]texte[/b] => **texte** (toutes occurrences)
    content=$(echo "$content" | sed 's/\[b\]/\*\*/g' | sed 's/\[\/b\]/\*\*/g')
    
    # Conversion de l'italique [i]texte[/i] => *texte* (toutes occurrences)
    content=$(echo "$content" | sed 's/\[i\]/\*/g' | sed 's/\[\/i\]/\*/g')
    
    # Conversion du soulignement [u]texte[/u] => <u>texte</u> (toutes occurrences)
    content=$(echo "$content" | sed 's/\[u\]/<u>/g' | sed 's/\[\/u\]/<\/u>/g')
    
    # Conversion des blocs de code avec langage [code=bash]...[/code]
    content=$(echo "$content" | sed 's/\[code=bash\]/```bash\n/g' | sed 's/\[code=\([^]]*\)\]/```\1\n/g')
    
    # Conversion des blocs de code sans langage [code]...[/code]
    content=$(echo "$content" | sed 's/\[code\]/```\n/g')
    
    # Fermeture des blocs de code [/code]
    content=$(echo "$content" | sed 's/\[\/code\]/\n```/g')

    # Conversion des URLs [url=...]...[/url] => [...](...){target="_blank"}
    content=$(echo "$content" | sed -E 's|\[url=([^]]+)\]([^[]+)\[/url\]|[\2](\1){target="_blank"}|g')

    # Conversion des liens locaux [link=...]...[/link] => [...](/wiki/...)
    content=$(echo "$content" | sed -E 's|\[link=([^]]+)\]([^[]+)\[/link\]|[\2](/wiki/\1)|g')
    
    # Conversion des blocs de style
    # [style=success]texte[/style] => > texte\n{.is-success}
    content=$(echo "$content" | sed -E 's|\[style=success\]([^[]+)\[/style\]|> \1\n{.is-success}\n|g')
    
    # [style=question]texte[/style] => > texte\n{.is-info}
    content=$(echo "$content" | sed -E 's|\[style=question\]([^[]+)\[/style\]|> \1\n{.is-info}\n|g')
    
    # [style=notice]texte[/style] => > texte\n{.is-warning}
    content=$(echo "$content" | sed -E 's|\[style=notice\]([^[]+)\[/style\]|> \1\n{.is-info}\n|g')
    
    # [style=warning]texte[/style] => > texte\n{.is-warning}
    content=$(echo "$content" | sed -E 's|\[style=warning\]([^[]+)\[/style\]|> \1\n{.is-warning}\n|g')
    
    # [style=error]texte[/style] => > texte\n{.is-danger}
    content=$(echo "$content" | sed -E 's|\[style=error\]([^[]+)\[/style\]|> \1\n{.is-danger}\n|g')
    
    echo "$content"
}

# Lecture et conversion du fichier
content=$(cat "$input_file")
converted=$(convert_bbcode_to_markdown "$content")

# Écriture dans le fichier de sortie
echo "$converted" > "$output_file"

echo "Conversion terminée: $input_file -> $output_file"
